
-- there can be a maximum of 10 keywords

function check_keywords(keywords)
    ct = 0
    if keywords ~= nil then
	  kwds = pandoc.utils.stringify(keywords)
	  -- clean the list of extra commas and white space
	  kwds, n = kwds:gsub("%s+", "") -- get rid of whitespae
	  kwds, n = kwds:gsub(",+", ",") -- remove repeated commas
	  kwds, n = kwds:gsub(",+$", "") -- remove comma at end of list
	  kwds, n = kwds:gsub("^,+", "") -- remove comma at start of list
	  -- check if they are alphabetical ordered
	  in_order = true
	  curr_letter = 'a'
	  for c in (','..kwds):gmatch('[,^]%S') do
		  next_letter = c:sub(2,2)
                  if curr_letter > next_letter then
			  in_order = false
		  end
		  curr_letter = next_letter
	  end
	  -- find out how many commas there are in the cleaned string, adding 1 should give num keywords
	  kwds, ct = kwds:gsub(",", ",")
          ct = ct + 1
    end
    if ct == 0 then
	    print('Keywords check: Fail')
	    print('\t- There are no keywords specified')
    elseif ct > 10 then
	    print('Keywords check: Fail')
	    print('\t- There are', ct, 'keywords. Only 10 are allowed.')
    elseif not in_order then
	    print('Keywords check: Fail')
	    print('\t- The keywords are not in alphabetical order.')
    else
	    print('Keywords check: OK')
    end

end

-- there should be 4 abstract headings  
-- 1) Aims/hypothesis
-- 2) Methods
-- 3) Results
-- 4) Conclusions/interpretation
--
-- This script assumes that the abstract is in the YAML header in a section called abstract
-- It assumes the subheaders are emphasised in that section. 
-- The script loops and finds all emphasised text
--

abstract_headings = {
	    ["Aims/hypothesis"] = 0,
	    ["Methods"] = 0,
	    ["Results"] = 0,
	    ["Conclusions/interpretation"] = 0
            }

extra_abstract_headings = {}


-- Check the correct headings are in the abstract
function check_abstract_headings(abs)
    for k, v in pairs(abs) do
	    if v.tag == 'Strong' then
		heading = pandoc.utils.stringify(v.content)		 
	        -- now we have the text see if its in the table
	        if abstract_headings[heading] ~= nil then
	        	abstract_headings[heading] = abstract_headings[heading] + 1
	        else
	        	if extra_abstract_headings[heading] ~= nil then
	        	    extra_abstract_headings[heading] = extra_abstract_headings[heading] + 1
	                else
	        	    extra_abstract_headings[heading] = 1	    
	                end
	        end
        end
    end
    repeated_subheader = false
    missing_subheader = false
    extra_subheader = false
    for k, v in pairs(abstract_headings) do
	    repeated_subheader = repeated_subheader or v > 1
	    missing_subheader = missing_subheader or v < 1
    end
    for k, v in pairs(extra_abstract_headings) do
	    extra_subheader = true
    end
    if repeated_subheader or missing_subheader or extra_subheader then
	    print('Abstract Heading check:\tFailed')
	    if repeated_subheader then
                for k, v in pairs(abstract_headings) do
			if v > 0 then
				print("\t- Repeated heading: '", k,"'")
			end
		end
	    end
	    if missing_subheader then
                for k, v in pairs(abstract_headings) do
			if v < 1 then
				print("\t- Missing heading: '", k,"'")
			end
		end
	    end
	    if extra_subheader then
                for k, v in pairs(extra_abstract_headings) do
			print("\t- '", k,"' is not a valid heading")
		end
	    end
		    
    else
	    print('Abstract Heading check\t:OK')
    end

end



-- there should be headings
-- 1) research in context
-- 2) introduction
-- 3) methods
-- 4) results
-- 5) discussion
-- 6) acknowledgements
-- 7) data availability 
-- 8) funding
-- 9) Authors’ relationships and activities
-- 10) Contribution statement
researchincontext = "Research in context"
methods = "Methods"
headings = {
	    [researchincontext] = 0,
	    ["Introduction"] = 0,
	    [methods] = 0,
	    ["Results"] = 0,
	    ["Discussion"] = 0,
	    ["Acknowledgements"] = 0,
	    ["Data availability"] = 0,
	    ["Funding"] = 0,
	    ["Authors’ relationships and activities"] = 0,
	    ["Contribution statement"] = 0,
            }

extra_headings = {}

function check_heading(hd) 
	if headings[hd] ~= nil then
		headings[hd] = headings[hd] + 1
	else
		extra_headings[hd] = 1
	end
end

heading_funcs = {

    
    Header = function(el)
    	if el.level == 1 then
    		-- top level header so check if its one of the headings
    		check_heading(pandoc.utils.stringify(el.content))
    	end
    
    end

}


function check_headings(blocks)
    pandoc.walk_block(pandoc.Div(blocks), heading_funcs)
    repeated_subheader = false
    missing_subheader = false
    extra_subheader = false
    for k, v in pairs(headings) do
	    repeated_subheader = repeated_subheader or v > 1
	    missing_subheader = missing_subheader or v < 1
    end
    for k, v in pairs(extra_headings) do
	    extra_subheader = true
    end
    if repeated_subheader or missing_subheader or extra_subheader then
	    print('Heading check:\tFailed')
	    if repeated_subheader then
                for k, v in pairs(headings) do
			if v > 0 then
				print("\t- Repeated heading: '", k,"'")
			end
		end
	    end
	    if missing_subheader then
                for k, v in pairs(headings) do
			if v < 1 then
				print("\t- Missing heading: '", k,"'")
			end
		end
	    end
	    if extra_subheader then
                for k, v in pairs(extra_headings) do
			print("\t- '", k,"' is not a valid heading")
		end
	    end
		    
    else
	    print('Heading check\t:OK')
    end

end

ric_question1 = "What is already known about this subject?"
ric_question2 = "What is the key question?"
ric_question3 = "What are the new findings?"
ric_question4 = "How might this impact on clinical practice in the foreseeable future?"
researchincontext_points = {
	                       [ric_question1] = 0,
	                       [ric_question2] = 0,
	                       [ric_question3] = 0,
	                       [ric_question4] = 0
		              }
researchincontext_extra_questions = {}
researchincontext_maxpoints = {
	                       [ric_question1] = 3,
	                       [ric_question2] = 1,
	                       [ric_question3] = 3,
	                       [ric_question4] = 1
		              }
researchincontext_as_question = {
	                       [ric_question2] = 0
		              }

function check_research_in_context(blocks)
    in_ric = false
    curr_question = ""
    words = 0
    maxwords = 200
    for i, el in pairs(blocks) do
	    if el.tag == 'Header' and el.level == 1 then
		    if pandoc.utils.stringify(el.content) == researchincontext then
			    in_ric = true
		    else
			    in_ric = false
		    end
	    elseif el.tag == 'Header' and el.level == 2 and in_ric then
                    curr_question = pandoc.utils.stringify(el.content)
		    if researchincontext_points[curr_question] == nil then
			    researchincontext_extra_questions[curr_question] = 1
		    end
	    elseif el.tag == 'BulletList' and in_ric then
		    cts = 0
		    for k, v in pairs(el.content) do
			    cts = cts + 1
			    bpoint = pandoc.utils.stringify(v)
			    _,n = bpoint:gsub("%S+","")
			    words = words + n
                            if researchincontext_as_question[curr_question] ~= nil then
			        -- these bullet points have to been in the form of a question
				if string.find(bpoint, '?') then
					researchincontext_as_question[curr_question] = 1
				end
	                    end
		    end
		    if researchincontext_points[curr_question] ~= nil then
			    researchincontext_points[curr_question] = researchincontext_points[curr_question] + cts
		    end
	    end
    end
    -- now know how many bullet points per question and how many questions
    ric_fail = false
    for question, ct_points in pairs(researchincontext_points) do
	    if ct_points > researchincontext_maxpoints[question] then
		    -- there's too many bullet points for this question
		    ric_fail = true
	    elseif ct_points == 0 then
		    ric_fail = true
	    end
    end
    for question, ct in pairs(researchincontext_as_question) do
	    if ct == 0 then
	        ric_fail = true
	    end
    end
    for question, ct in pairs(researchincontext_extra_questions) do
	    ric_fail = true
    end
    if words > maxwords then
	    ric_fail = true
    end
    if ric_fail then
	    print('Research in context check: Fail')
	    
            for question, ct_points in pairs(researchincontext_points) do
                    if ct_points > researchincontext_maxpoints[question] then
                	    -- there's too many bullet points for this question
                	    print('\t-', question, 'has', ct_points, 'bulletpoints. Only allowed ', researchincontext_maxpoints[question]) 
                    elseif ct_points == 0 then
                	    print('\t-', question, 'requires bulletpoints')
                    end
            end
            for question, ct in pairs(researchincontext_as_question) do
                    if ct == 0 then
                        print('\t- Bulletpoint for', question, 'needs to be a question')
                    end
            end
            for question, ct in pairs(researchincontext_extra_questions) do
                    print('\t- Subsection/question', question,'should not be in the', researchincontext,'section')
            end
            if words > maxwords then
                    print('\t- ', researchincontext, 'contains too many words. Allowed', maxwords, 'has', words)
            end
    else
	    print('Research in context check: OK')
    end
end

function check_methods(blocks)
    in_methods = false
    ethics = false
    for i, el in pairs(blocks) do
	    if el.tag == 'Header' and el.level == 1 then
		    if pandoc.utils.stringify(el.content) == methods then
			    in_methods = true
		    else
			    in_methods = false
		    end
	    elseif el.tag == 'Para' and in_methods then
		    if string.find(pandoc.utils.stringify(el.content), "ethics") then
			    ethics = true
		    end
	    elseif el.tag == 'Plain' and in_methods then
		    if string.find(pandoc.utils.stringify(el.content), "ethics") then
			    ethics = true
		    end
	    end
    end
    if ethics then
	    print('Methods check: OK')
    else
	    print('Methods check: Fail')
	    if not ethics then
		    print('\t- do not find ethics in methods section text. Was a ethics statement included in this section?')
	    end
    end

end



--function Meta(el)
--	check_abstract_headings(el.abstract)
--	check_keywords(el.keywords)
--end

function Pandoc(doc)
	print('===============================================')
	print('===============================================')
	print('===============================================')
	print(' Diabetologia instructions for authors checks')
	print('===============================================')
	check_abstract_headings(doc.meta.abstract)
	check_keywords(doc.meta.keywords)
	check_headings(doc.blocks)
	check_research_in_context(doc.blocks)
	check_methods(doc.blocks)

	print('===============================================')
	print('===============================================')
	print('===============================================')
end
