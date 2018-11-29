CREATE OR REPLACE FUNCTION isValidTaxonName (name  in varchar)
	return varchar as
		botabbr varchar2(4000);
	    temp varchar2(255);
	BEGIN
		-- keep this here so we have ONE place to maintain the code, call it from triggers/application/whatever
		-- put cheap stuff first, try to find errors before running more-expensive checks
		-- Goals: 
		---- 1) Do NOT block anything that is someone's idea of a taxon name
		---- 2) Do block anything that is NOT someone's idea of a taxon name

		-- our one and only official not-taxonomy
		if name='unidentifiable' then
			return 'valid';
		end if;
		-- nope	
		if name like '%  %' then
			return 'Double spaces detected';
		end if;
		-- nope
		if name != trim(name) then
			return 'Leading or trailing spaces detected';
		end if;
		-- nope
		IF name=LOWER(name) THEN
			return 'Names should not be all lower-case';
		END IF;
		-- nope
		IF name=UPPER(name) THEN
			return 'Names should not be all upper-case';
		END IF;
		-- allowable:
		-- upper and lower a-z
		-- spaces
		-- umlauts, because botany
		-- hybrid sign
		-- dot - more below
		-- dash, because botany
		-- (), because ICZN subgenera - more below
		-- EDIT
		--    https://github.com/ArctosDB/arctos/issues/1704
		--    DO NOT allow ()
		--if regexp_like(name,'[^A-Za-z -\.üë×ö\(\)]') th
		if regexp_like(name,'[^A-Za-z \-\.üë×ö]') then
			return 'Invalid characters.';
		end if;
		-- no taxa is a single character
		if length(trim(name)) = 1 then
			return 'Too short.';
		end if;
		-- hybrids are IDs, not names.
		if lower(name) like '% x %' then
			return 'Looks like a hybrid.';
		end if;
		-- no taxon contains the "word" sp.
		if lower(name) like '% sp %' or lower(name) like '% sp' then
			return '"sp" is not a valid name-part';
		end if;
		-- no taxon contains the "word" ssp.
		if lower(name) like '% ssp %' or lower(name) like '% ssp' then
			return '"ssp" is not a valid name-part';
		end if;
		-- no taxon contains the "word" or
		if lower(name) like '% or %' then
			return '"or" is not a valid name-part';
		end if;
		-- no taxon contains the "word" and
		if lower(name) like '% and %' then
			return '"and" is not a valid name-part';
		end if;
		-- 5 terms is never valid
		if REGEXP_COUNT(name,' ') > 4 then
			return 'Too many terms.';
		end if;
		-- limit abbreviations to botanist-sanctioned terms
		-- set up botanical abbreviations list
		botabbr:='agamosp.|agamovar.|convar.|f.|lus.|modif.|monstr.|mut.|nm.|nothof.|nothosubsp.|nothovar.|prol.|subf.|subhybr.|subsp.|subsubvar.|subf.|subvar.|var.';
		if name like '%.%' then
			-- only allow dots in botanical abbreviations
			temp:=regexp_replace(name, ' ' || botabbr || ' ', ' ');
			-- if there's still a dot, die
			if temp like '%.%' then
				return 'Invalid abbreviation.';
			end if;
		end if;
		if REGEXP_COUNT(name,' ') = 4 then
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
		if name like '%cf.%' then
			return 'identification terminology';
		end if;
		
		if name like '%(%' or name like '%)%' then
			return 'Parentheses are not allowed.';
		end if;
		
		if REGEXP_COUNT(name,'[A-Z]') >1 then
			return 'Too many uppercase characters';
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
--select isValidTaxonName('Some name var. bla lus. boo') from dual;

select isValidTaxonName ('Arctos (Euarctos)') from dual;

