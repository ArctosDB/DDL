 67.166.156.208 
 
 
 insert into blacklist(IP,LISTDATE,STATUS,LASTDATE) values ('67.166.156.1',sysdate,'active',sysdate);
 insert into blacklist(IP,LISTDATE,STATUS,LASTDATE) values ('67.166.156.2',sysdate,'active',sysdate);
 insert into blacklist(IP,LISTDATE,STATUS,LASTDATE) values ('67.166.156.3',sysdate,'active',sysdate);
 insert into blacklist(IP,LISTDATE,STATUS,LASTDATE) values ('67.166.156.4',sysdate,'active',sysdate);
 insert into blacklist(IP,LISTDATE,STATUS,LASTDATE) values ('67.166.156.5',sysdate,'active',sysdate);
 insert into blacklist(IP,LISTDATE,STATUS,LASTDATE) values ('67.166.156.6',sysdate,'active',sysdate);
 insert into blacklist(IP,LISTDATE,STATUS,LASTDATE) values ('67.166.156.7',sysdate,'active',sysdate);
 insert into blacklist(IP,LISTDATE,STATUS,LASTDATE) values ('67.166.156.8',sysdate,'active',sysdate);
 insert into blacklist(IP,LISTDATE,STATUS,LASTDATE) values ('67.166.156.9',sysdate,'active',sysdate);
 insert into blacklist(IP,LISTDATE,STATUS,LASTDATE) values ('67.166.156.10',sysdate,'active',sysdate);
 insert into blacklist(IP,LISTDATE,STATUS,LASTDATE) values ('67.166.156.11',sysdate,'active',sysdate);

 update blacklist_subnet set status='hardblock'  where SUBNET='67.166';
 
 
  Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 IP								   NOT NULL VARCHAR2(40)
 LISTDATE								    DATE
 STATUS 								    VARCHAR2(255)
 LASTDATE								    DATE


 
 
 
/*
	
	Purpose:
		More automation, less intrusive blocking of subnets, better history of activity from IPs and subnets
		
	-- revoke delete on blacklist, 	blacklist_subnet
	
	- add status to blacklist
		- on insert, set status=active
		- on "delete" set status to 'released'
		- future possibility: disallow self-unlist when the IP has been blocked more than x times
	- add last_date to blacklist
		- on insert/update-->sysdate
		
	add status to blacklist_subnet
		- on insert, -->active
		- on "delete --> released
	- add last_date to blacklist
		- on insert/update-->sysdate
		
	
	in application
		- When IPs within a subnet gets blacklisted X (5??) times, auto-blacklist the subnet
		- Allow users to un-blacklist subnets along with their IP
		- When a subnet has been blacklisted X (5??) times, send the rule to TACC
			for a firewall block (so needs scheduled task)
			
		- Include number of times a subnet has been blacklisted in communications
			- Consider making subnets blacklisted more than x times permanent
*/
			
			
	alter table blacklist add status varchar2(255);
	alter table blacklist add lastdate date;
	
	
  
  
	
	
	select ip from blacklist where isvalidip(ip) != 'true';
	
	delete from blacklist where  isvalidip(ip) != 'true';
	
	
	update blacklist set lastdate=LISTDATE;
	update blacklist set status='active';
	ALTER TABLE blacklist ADD CONSTRAINT check_bl_status CHECK (status IN ('active', 'released'));

	
	-- make sure the final version of this gets copied back to
	--	DDL/triggers/uam_cf_triggers/blacklist.sql
	
CREATE OR REPLACE TRIGGER trg_blacklist_ckblist
	for INSERT or update or delete ON blacklist
	COMPOUND TRIGGER
	v_tab parse_list.varchar2_table;
	v_nfields integer;
	pipl cf_global_settings.PROTECTED_IP_LIST%TYPE;
	
	BEFORE EACH ROW IS BEGIN
		 if deleting then
		 	RAISE_APPLICATION_ERROR(-20001,'delete not allowed; mark "released" instead');
		 end if;
		 if inserting or updating then
		 	:new.lastdate:=sysdate;
		 	
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
		 end if;
	end BEFORE EACH ROW;
END;
/
sho err

drop index IU_BLACKLIST_IP;


		
	alter table blacklist_subnet add status varchar2(255);
	alter table blacklist_subnet add lastdate date;
	
	
	select SUBNET || '.1.1' from blacklist_subnet where isvalidip(SUBNET || '.1.1') != 'true';
	
	delete from blacklist_subnet where  isvalidip(SUBNET || '.1.1') != 'true';
	
	
	
	
	
	update blacklist_subnet set lastdate=INSERT_DATE;
	update blacklist_subnet set status='active';
	ALTER TABLE blacklist_subnet drop CONSTRAINT check_bl_sn_status;
	ALTER TABLE blacklist_subnet ADD CONSTRAINT check_bl_sn_status CHECK (status IN ('active','released','autoinsert','hardblock'));


	
	


	
CREATE OR REPLACE TRIGGER trg_blacklist_subnet_ckblist
	for INSERT or update or delete ON blacklist_subnet
	COMPOUND TRIGGER
	v_tab parse_list.varchar2_table;
	v_nfields integer;
	pipl cf_global_settings.PROTECTED_IP_LIST%TYPE;
    sip varchar2(255);
	
	BEFORE EACH ROW IS BEGIN
		 if deleting then
		 	RAISE_APPLICATION_ERROR(-20001,'delete not allowed; mark "released" instead');
		 end if;
		 if inserting or updating then
		 	:new.lastdate:=sysdate;
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
		 end if;
	end BEFORE EACH ROW;
END;
/
sho err
