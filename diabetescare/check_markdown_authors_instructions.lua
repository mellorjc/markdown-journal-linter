

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

function Pandoc(doc)
	print('===============================================')
	print('===============================================')
	print('===============================================')
	print(' Diabetes care instructions for authors checks')
	print('===============================================')
        check_diabetes_nomenclature(doc)
	check_mmolpermol(doc)
	print('===============================================')
	print('===============================================')
	print('===============================================')
end
