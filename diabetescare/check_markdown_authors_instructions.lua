
-- there should be 4 abstract headings  
-- 1) Objective
-- 2) Research Design and Methods
-- 3) Results
-- 4) Conclusions
--
-- This script assumes that the abstract is in the YAML header in a section called abstract
-- It assumes the subheaders are emphasised in that section. 
-- The script loops and finds all emphasised text
--

abstract_headings = {
	    ["Objective"] = 0,
	    ["Research Design and Methods"] = 0,
	    ["Results"] = 0,
	    ["Conclusions"] = 0
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

abstract_ct = 0

function check_abstract_wordcount(abs)
    for k, v in pairs(abs) do
	    if v.tag ~= 'Strong' and v.text ~= nil then
		    if v.text:find('%P+') then
			    abstract_ct = abstract_ct + 1
		    end
	    end
    end
    if abstract_ct > 250 then
	    print('Abstract word count check: Fail')
	    print('\t- Abstract has 250 word limit. Current word count is', abstract_ct)
    else
	    print('Abstract word count check: OK')
    end
end

nomenclature_ok = true
nomenclature_funcs = {
	Str = function(el) 
		-- if string contains T1D/T2D then suggest "Type 1/2 diabetes" 
		check_diabetes_text(el.text)
	end
}

function check_diabetes_text(text)
	if text:find('T[12]D') then
		nomenclature_ok = false
	end
end

function check_diabetes_nomenclature(doc)
    pandoc.walk_block(pandoc.Div(doc.blocks), nomenclature_funcs)
    check_diabetes_text(pandoc.utils.stringify(doc.meta.abstract))
    check_diabetes_text(pandoc.utils.stringify(doc.meta.title))
    if nomenclature_ok then
	    print('Nomenclature check: OK')
    else
	    print('Nomenclature check: Fail')
	    print('\t- Do not use abbreviations T1D/T2D use "type 1/2 diabetes" instead')
    end

end

mmolpermol_ok = true
mmolpermol_funcs = {
	Para = function(el)
		check_mmolpermol_text(pandoc.utils.stringify(el))
	end
}

function check_mmolpermol_text(text)
	if text:find('mmol/mol') and not text:find('%%%s*%(%s*[0-9.]*%s*mmol/mol%s*%)') then
		mmolpermol_ok = false
	end
end

function check_mmolpermol(doc)
    pandoc.walk_block(pandoc.Div(doc.blocks), mmolpermol_funcs)
    check_mmolpermol_text(pandoc.utils.stringify(doc.meta.abstract))
    check_mmolpermol_text(pandoc.utils.stringify(doc.meta.title))
    if mmolpermol_ok then
	    print('mmol/mol check: OK')
    else
	    print('mmol/mol check: Fail')
	    print('\t- Check that HbA1c has been reported in both % and mmol/mol')
    end

end

tables_ct = 0
figures_ct = 0
figures_and_tables_funcs = {
	Table = function(el)
		tables_ct = tables_ct + 1
	end,

	Image = function(el)
		figures_ct = figures_ct + 1
	end
}

function check_figures_and_tables(doc)
    pandoc.walk_block(pandoc.Div(doc.blocks), figures_and_tables_funcs)
    if tables_ct + figures_ct > 4 then
	    print('Figures and Table Check: Fail')
	    print('\t- Only allowed 4 figures/tables in total. You have', tables_ct + figures_ct)
    else
	    print('Figures and Table Check: OK')
    end
end

results = "Results"

function check_sex_and_ethnicity(blocks)
    in_results = false
    found_sex = false
    found_ethnicity = false
    for i, el in pairs(blocks) do
	    if el.tag == 'Header' and el.level == 1 then
		    if pandoc.utils.stringify(el.content) == results then
			    in_results = true
		    else
			    in_results = false
		    end
	    elseif el.tag == 'Para' and in_results then
		    cts = 0
		    para = pandoc.utils.stringify(v)
		    if para:find('[Ss]ex') then
			    found_sex = true
		    end
		    if para:find('[Ee]thnicity') then
			    found_ethnicity = true
		    end

	    end
    end
    if found_sex and found_ethnicity then
	    print('Sex and Ethnicity check: OK')
    else
	    print('Sex and Ethnicity check: Fail')
	    print('\t- Results section needs to mention effect of sex and ethnicity')
    end

end


-- there should be headings
-- 1) introduction (no heading)
-- 3) research design and methods
-- 4) results
-- 5) conclusions
-- 6) acknowledgements
methods = "Research Design and Methods"
headings = {
	    [""] = 0,
	    [methods] = 0,
	    [results] = 0,
	    ["Conclusions"] = 0,
	    ["Acknowledgements"] = 0,
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


words = 0

wordcount = {
	  Str = function(el)
		  -- we don't count a word if it's entirely punctuation:
		  if el.text:match("%P") then
			  words = words + 1
		  end
	  end,
	  
	  Code = function(el)
		  _,n = el.text:gsub("%S+","")
		  words = words + n
	  end,
	  
	  CodeBlock = function(el)
		  _,n = el.text:gsub("%S+","")
		  words = words + n
	  end
  }

function check_wordcount(doc)
	pandoc.walk_block(pandoc.Div(doc.blocks), wordcount)
	if words > 4000 then
		print('Word count check: Fail')
		print('\t- word limit is 4000. Current word count is', words)
	else
		print('Word count check: OK')
	end
		
end

function Pandoc(doc)
	print('===============================================')
	print('===============================================')
	print('===============================================')
	print(' Diabetes care instructions for authors checks')
	print('===============================================')
	check_abstract_headings(doc.meta.abstract)
	check_abstract_wordcount(doc.meta.abstract)
	check_headings(doc.blocks)
        check_diabetes_nomenclature(doc)
	check_mmolpermol(doc)
	check_figures_and_tables(doc)
	check_sex_and_ethnicity(doc)
	check_wordcount(doc)
	print('===============================================')
	print('===============================================')
	print('===============================================')
end
