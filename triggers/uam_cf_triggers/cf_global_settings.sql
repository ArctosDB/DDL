CREATE OR REPLACE TRIGGER trg_cf_global_settings_onerow
BEFORE INSERT or delete ON cf_global_settings
begin
	RAISE_APPLICATION_ERROR(-20001,'insert/delete is not allowed. Drop this trigger if the table does not contain one row; otherwise update');
end;
/



CREATE OR REPLACE TRIGGER trg_cf_global_settings_ckblist
BEFORE update ON cf_global_settings
FOR EACH ROW declare 
	v_tab parse_list.varchar2_table;
    v_nfields integer;
    c number;    
begin
	IF :NEW.PROTECTED_IP_LIST != :OLD.PROTECTED_IP_LIST then
		parse_list.delimstring_to_table (:NEW.PROTECTED_IP_LIST, v_tab, v_nfields);
		for i in 1..v_nfields loop
			-- for each protected IP (or subnet or sub-subnet designated with *).....
			--  make sure it is valid
			if isvalidip(v_tab(i)) != 'true' then
				RAISE_APPLICATION_ERROR(-20001,'invalid IP ' || v_tab(i));
			end if;
			-- make sure it is not already blacklisted
			select count(*) into c from blacklist where ip=v_tab(i);
			if c>0 then
				RAISE_APPLICATION_ERROR(-20001,'IP ' || v_tab(i) || ' is blacklisted and cannot be protected.');
			end if;
			-- if we're protecting an IP range, make sure no IP from that range is blacklisted
			select count(*) into c from blacklist where ip like replace(v_tab(i),'*','%');
			if c>0 then
				RAISE_APPLICATION_ERROR(-20001,'An IP in the range ' || v_tab(i) || ' is blacklisted and cannot be protected.');
			end if;
			-- make sure the subnet of the IP is not blacklisted
			select count(*) into c from blacklist_subnet where subnet = substr(v_tab(i),1,instr(v_tab(i),'.',1,2)-1);
			if c>0 then
				RAISE_APPLICATION_ERROR(-20001,'The subnet of IP ' || v_tab(i) || ' is blacklisted and cannot be protected.');
			end if;
		end loop;
	END IF;
END;
/
sho err