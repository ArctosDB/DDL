CREATE OR REPLACE TRIGGER trg_blacklist_subnet_ckblist
BEFORE INSERT or update ON blacklist_subnet
FOR EACH ROW declare 
	v_tab parse_list.varchar2_table;
    v_nfields integer;
    pipl cf_global_settings.PROTECTED_IP_LIST%TYPE;
    sip varchar2(255);
begin
	-- make sure it's formatted correctly etc.
	sip:=:NEW.SUBNET || '.1.1';
	if isvalidip(sip) != 'true' then
		RAISE_APPLICATION_ERROR(-20001,'invalid subnet ' || :NEW.SUBNET);
	end if;
	-- make sure it's not protected
	select PROTECTED_IP_LIST into pipl from cf_global_settings;
	
 	parse_list.delimstring_to_table (pipl, v_tab, v_nfields);
 	for i in 1..v_nfields loop
 		if v_tab(i) like :NEW.SUBNET || '.%' then
 			RAISE_APPLICATION_ERROR(-20001,'subnet ' || :NEW.SUBNET || ' contains protected IPs and cannot be blacklisted.');
 		end if;
	end loop;
END;
/
sho err