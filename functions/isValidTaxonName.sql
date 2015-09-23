CREATE OR REPLACE FUNCTION isValidTaxonName (name  in varchar)
	return varchar as
		botabbr varchar2(4000);
		v_tab parse_list.varchar2_table;
	    v_nfields integer;
	    isval number := 0;
	    temp varchar2(255);
	BEGIN
		-- keep this here so we have ONE place to maintain the code, call it from triggers/application/whatever
		-- put cheap stuff first, try to find errors before running more-expensive checks

		-- our one and only official not-taxonomy
		if name='unidentifiable' then
			return 'valid';
		end if;
			
		-- no taxa is a single character
		if length(trim(name)) = 1 then
			return 'Too short.';
		end if;
		if lower(name) like '% x %' then
			return 'Looks like a hybrid.';
		end if;
		if lower(name) like '% sp %' or lower(name) like '% sp' then
			return '"sp" is not a valid name-part';
		end if;
		if lower(name) like '% ssp %' or lower(name) like '% ssp' then
			return '"ssp" is not a valid name-part';
		end if;
		if lower(name) like '% or %' then
			return '"or" is not a valid name-part';
		end if;
		if lower(name) like '% and %' then
			return '"and" is not a valid name-part';
		end if;
		
		-- check for "Name" or "Name morestuff" not NaMe or Name Othername
		if substr(name,1,1) != '×' and (lower(substr(name,2)) != substr(name,2) or upper(substr(name,1,1)) != substr(name,1,1)) then
			return 'Names must be Proper case.';
		end if;
  		if name like '%  %' then
			return 'Double spaces detected';
		end if;
		if name != trim(name) then
			return 'Leading or trailing spaces detected';
		end if;
		IF name=LOWER(name) THEN
			return 'Names should not be all lower-case';
		END IF;
		IF name=UPPER(name) THEN
			return 'Names should not be all upper-case';
		END IF;
		if regexp_like(name,'[^A-Za-z üë×ö.-]') then
			return 'Invalid characters.';
		end if;
  
		
		
		-- limit abbreviations to botanist-sanctioned terms
		-- set up botanical abbreviations list
		botabbr:='agamosp.|agamovar.|convar.|f.|lus.|modif.|monstr.|mut.|nm.|nothof.|nothosubsp.|nothovar.|prol.'; 
		botabbr:=botabbr || '|subf.|subhybr.|subsp.|subsubvar.|subf.|subvar.|var.';
		if name like '%.%' then
			-- only allow dots in botanical abbreviations
			temp:=regexp_replace(name, botabbr, '');
			-- if there's still a dot, die
			if temp like '%.%' then
				return 'Invalid abbreviation.';
			end if;
		end if;
				
		-- 5 terms is never valid
		if REGEXP_COUNT(name,' ') > 4 then
			return 'Too many terms.';
		end if;
		
		if REGEXP_COUNT(name,' ') >= 4 then
			-- valid only in botanical name of the form
			-- Gen sp irank. ssp
			-- add any unabbreviated infraspecific ranks to the list created above
			botabbr:=botabbr || '|forma';
			-- strip out the i-rank
			temp:=regexp_replace(name, botabbr, '');
			-- die if we still have the spaces
			if REGEXP_COUNT(name,' ') >= 4 then
				return 'Too many terms or invalid infraspecific rank';
			end if;
		end if;
		
		
		
		
		-- if we made it here we can't find any problems
		return 'valid';
	end;
/
sho err;


CREATE OR REPLACE PUBLIC SYNONYM isValidTaxonName FOR isValidTaxonName;
GRANT execute ON isValidTaxonName TO PUBLIC;


-- select isValidTaxonName(scientific_name),scientific_name from taxon_name where isValidTaxonName(scientific_name) != 'valid' order by scientific_name;

-- select scientific_name from taxon_name where isValidTaxonName(scientific_name) != 'valid' order by scientific_name;

--select 	isValidTaxonName('Some name var. bla lus. boo') from dual;
