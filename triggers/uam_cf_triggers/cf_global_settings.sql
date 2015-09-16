CREATE OR REPLACE TRIGGER trg_cf_global_settings_ckblist
BEFORE INSERT or update ON cf_global_settings
FOR EACH ROW declare 
	v_tab parse_list.varchar2_table;
    v_nfields integer;
begin
	IF :NEW.PROTECTED_IP_LIST != :OLD.PROTECTED_IP_LIST then
	 	parse_list.delimstring_to_table (:NEW.PROTECTED_IP_LIST, v_tab, v_nfields);
	 	for i in 1..v_nfields loop
	 		if isvalidip(v_tab(i)) != 'true' then
    			RAISE_APPLICATION_ERROR(-20001,'invalid IP ' || v_tab(i));
    		end if;
    	end loop;
    END IF;
END;
/
sho err


update cf_global_settings set PROTECTED_IP_LIST='127.0.0.1,129.114.52.171,1.1.1.*';






update cf_global_settings set PROTECTED_IP_LIST='127.0.0.1,129.114.52.171,1.1.1.*';

