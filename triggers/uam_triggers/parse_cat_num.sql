CREATE OR REPLACE TRIGGER parse_cat_num
    BEFORE INSERT OR UPDATE ON cataloged_item
    FOR EACH ROW
    DECLARE
		dlms VARCHAR2(255) := '|-.; '; -- delimiters that can be used to split the "number"
		td VARCHAR2(255);
		dc number := 0;
		catalog_number_format VARCHAR2(255);
    BEGIN
		SELECT /*+ result_cache */ catalog_number_format INTO catalog_number_format FROM collection WHERE collection_id=:NEW.collection_id;
		if catalog_number_format='integer' then
			IF is_number(:NEW.cat_num) = 0 or :NEW.cat_num<1 THEN -- just a number
				RAISE_APPLICATION_ERROR(-20001,'This collection requires numeric catalog numbers >0 ' || :NEW.cat_num || ' is invalid.');	
			else
				:NEW.cat_num_prefix := NULL;
        		:NEW.cat_num_integer := :NEW.cat_num;
        		:NEW.cat_num_suffix := NULL;
			end if;
	    		
		elsif catalog_number_format='prefix-integer-suffix' then
			FOR i IN 1..100 LOOP
				td := substr(dlms,i,1);
				EXIT WHEN td IS NULL;
				IF instr(:NEW.cat_num,td,1,2) > 0 AND instr(:NEW.cat_num,td,1,3)=0 THEN
					-- we have a 3-part string
					dc:=dc+1;
					:NEW.cat_num_prefix := get_str_el (:NEW.cat_num,td,1) || td;
					:NEW.cat_num_integer := get_str_el (:NEW.cat_num,td,2);
					:NEW.cat_num_suffix := td || get_str_el (:NEW.cat_num,td,3);
				ELSIF instr(:NEW.cat_num,td) > 0 AND instr(:NEW.cat_num,td,1,2)=0 THEN
					-- got a 2-part string
					dc:=dc+1;
					IF is_number(get_str_el (:NEW.cat_num,td,1)) = 1 THEN
					-- got suffix
					:NEW.cat_num_prefix := NULL;
					:NEW.cat_num_integer:=get_str_el (:NEW.cat_num,td,1);
					:NEW.cat_num_suffix:=td || get_str_el (:NEW.cat_num,td,2);
				ELSIF is_number(get_str_el(:NEW.cat_num,td,2)) = 1 THEN
					-- got prefix
					:NEW.cat_num_prefix:=get_str_el(:NEW.cat_num,td,1) || td;
					:NEW.cat_num_integer:=get_str_el(:NEW.cat_num,td,2);
					:NEW.cat_num_suffix := NULL;
					--ELSE something goofy happened, fail later
				END IF;
				END IF;
			END LOOP;
			if dc>1 then
		    	RAISE_APPLICATION_ERROR(-20001,'catnum parse failed: more than one potentially valid delimiter found');
		    end if;
		    IF :NEW.cat_num_integer IS NULL THEN
		        RAISE_APPLICATION_ERROR(-20001,'catnum parse failed: a numeric component could not be found in input (' || :NEW.cat_num || ')'); 
		    END IF;
		    IF (:NEW.cat_num_prefix || :NEW.cat_num_integer || :NEW.cat_num_suffix) != :NEW.cat_num THEN
		       RAISE_APPLICATION_ERROR(-20001,'catnum parse failed: result (' || :NEW.cat_num_prefix || :NEW.cat_num_integer || :NEW.cat_num_suffix || ') is not input (' || :NEW.cat_num || ')');
		    END IF;
		    IF is_number(:NEW.cat_num_integer) = 0 THEN
		      RAISE_APPLICATION_ERROR(-20001,'catnum parse failed: integer component (' || :NEW.cat_num_integer || ') is not numeric');
		    END IF;
			IF round(:NEW.cat_num_integer) != :NEW.cat_num_integer THEN
			  RAISE_APPLICATION_ERROR(-20001,'catnum parse failed: integer component (' || :NEW.cat_num_integer || ') is decimal');
			END IF;
		elsif catalog_number_format='string' then
			:NEW.cat_num_prefix := NULL;
        	:NEW.cat_num_integer := NULL;
        	:NEW.cat_num_suffix := NULL;
		END IF;
		

end;
/
sho err