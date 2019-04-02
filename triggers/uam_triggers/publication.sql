CREATE OR REPLACE TRIGGER trg_biu_publicaton
BEFORE UPDATE OR INSERT ON PUBLICATION
FOR EACH ROW
BEGIN
    IF :NEW.doi is not null THEN
    	if :NEW.doi != trim(:NEW.doi) then
    		raise_application_error(
                -20001,
                'Invalid DOI: DOIs may not have leading or trailing spaces.'
            );
    	end if;
    	if lower(substr(:NEW.doi,1,3)) in ('htt','doi') then
            raise_application_error(
                -20001,
                'Invalid DOI: DOIs may not be prefixed. Use "10.1093/jmammal/12.4.432" instead of "http://dx.doi.org/10.1093/jmammal/12.4.432" or "DOI:10.1093/jmammal/12.4.432"'
            );
        END IF;
        if lower(:NEW.FULL_CITATION) like 'unknown' then
        	 if substr(:NEW.FULL_CITATION,1,1) = '*' then
				:NEW.FULL_CITATION:=replace(:NEW.FULL_CITATION,'*');
			else
				raise_application_error(
	            	-20368,
	            	'Full Citation contains _unknown_. Prefix Full Citation with an asterisk if this is an accurate representation of the data. DO NOT indicate uncertainty in publication titles.');	
			end if;
		end if;
    END IF;
END;
/
sho err;