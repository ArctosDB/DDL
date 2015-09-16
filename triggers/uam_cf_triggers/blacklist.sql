

CREATE OR REPLACE TRIGGER trg_blacklist_ckblist
BEFORE INSERT or update ON blacklist
FOR EACH ROW declare 
	v_tab parse_list.varchar2_table;
    v_nfields integer;
    pipl cf_global_settings.PROTECTED_IP_LIST%TYPE;
begin
	if isvalidip(:NEW.ip) != 'true' then
		RAISE_APPLICATION_ERROR(-20001,'invalid ip ' || :NEW.ip);
	end if;
	-- make sure it's not protected
	select PROTECTED_IP_LIST into pipl from cf_global_settings;
	
 	parse_list.delimstring_to_table (pipl, v_tab, v_nfields);
 	for i in 1..v_nfields loop
 		-- see if there's an exact IP match
 		if v_tab(i) = :NEW.IP then
 			RAISE_APPLICATION_ERROR(-20001,'IP ' || :NEW.IP || ' is protected and cannot be blacklisted.');
 		end if;
 		-- and see if the IP is part of a protected subnet
 		if :NEW.IP like  replace(v_tab(i),'*','%') then
 			RAISE_APPLICATION_ERROR(-20001,'IP ' || :NEW.IP || ' is in a protected subnet and cannot be blacklisted.');
 		end if;
	end loop;
END;
/
sho err

delete from blacklist where ip='1.1.1.1';
insert into blacklist(ip) values ('1.1.1.1');




