CHANGELOG::

- intrusion reports are more widely distributed (based on severity), have better documentation
- subnets are auto-blacklisted after 10 IPs are blacklisted
-- reduces application variable load
-- better scary-subnet alerts
-- possible increased chance of catching problems before they happen
- better history - can now track past blocks from the Arctos forms
- better reporting - blacklist IP form rebuilt to show historical data
- better integration - tighter link between blocked IPs and subnets
- more self-service; users can unblock auto-blocked subnets
- more control 
-- remains possible to hard-block subnet
-- possible to add finer-grained IP blocking (eg, could implement hard IP blocks)
- more modular - forms and functions have been consolidated

 this branch also addresses various security concerns, mostly minor intrusion attempts from the logs

-- test
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
  update blacklist_subnet set status='autoinsert'  where SUBNET='67.166';

 
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



drop index IU_BLACKLISTSUBNET_SUBNET;











--------------- everything below here DONE pre-release -----------------




---- for https://github.com/ArctosDB/arctos/issues/904

-- rebuild functions/niceURL (needs to be deterministic)

CREATE OR REPLACE FUNCTION niceURL (s  in VARCHAR)
return varchar2
deterministic as
 r VARCHAR2(255);
begin
	r:=trim(regexp_replace(s,'<[^<>]+>'));
	r:=regexp_replace(r,'[^A-Za-z ]*');
	r:=regexp_replace(r,' +','-');
	r:=lower(r);
	if length(r)>149 then
		r:=substr(r,0,149);
	end if;
	IF (substr(r, -1)='-') THEN
	    r:=substr(r,1,length(r)-1);
	END IF;
    RETURN r;	
end;
/

sho err;


create or replace public synonym niceURL for niceURL;
grant execute on niceURL to public;

-- clean up data
-- leave results with the issue

-- just in case....

create table project20161010 as select * from project;

--rollback....
begin
	for r in (select project20161010.project_name,project20161010.project_id from project20161010,project where project20161010.project_id=project.project_id and
project20161010.project_name != project.project_name) loop
update project set project_name=r.project_name where project_id=r.project_id;
end loop;
end;
/


set escape \;


declare
	npn varchar2(4000);
	npu varchar2(4000);
	g varchar2(4000);
begin
	for r in (select niceURL(project_name) nu from project having count(*) > 1 group by niceURL(project_name)) loop
		dbms_output.put_line('Bad project URL: /project/' || r.nu);
		for p in (select project_name,project_id from project where NICEURL(PROJECT_NAME)=r.nu) loop
			dbms_output.put_line('    Affected project name: ' || p.project_name);
			-- update to something unique
			 SELECT DBMS_RANDOM.string('u',10) into g FROM dual;
			 npn:=p.project_name || ' [' || g || ']';
			 npu:=niceURL(npn);
			 dbms_output.put_line('        New project name: ' || npn);
			 dbms_output.put_line('        New project URL: /project/' || npu);
			 dbms_output.put_line('        Edit Path: /Project.cfm?Action=editProject\&project_id=' || p.project_id);
			 
			 update project set project_name=npn where project_id=p.project_id;
			 
		end loop;
		
	end loop;
end;
/


-- make sure to paste whatever that barfs out to https://github.com/ArctosDB/arctos/issues/904 and tag affected people

-- now a unique functional index
-- this is copied to /DDL/indexes
create unique index iu_proj_niceurl_pname on project (niceURL(PROJECT_NAME)) tablespace uam_idx_1;


