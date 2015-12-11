
--	select STATE,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where lower(JOB_NAME)='J_sched_immediate_pre_bulk_check';

	
CREATE OR REPLACE PROCEDURE pre_bulk_check  IS
	s varchar2(4000);
	has_problems number;
	L_TAXA_FORMULA VARCHAR2(200);
	TAXA_ONE VARCHAR2(200);
	NUM number;
	L_TAXON_NAME_ID_1 number;
	L_TAXON_NAME_ID_2 number;
	TAXA_TWO VARCHAR2(200);
	
	nrec number;
	stscnt number;
	
	gbp number;
	
	a_guidprefix varchar2(255);
	tempStr varchar2(255);
    tempStr2 varchar2(255);
    numRecs number;
BEGIN
	-- only run this if ALL records are loaded=null; set loaded in this procedure.
	select count(*) into nrec from pre_bulkloader;
	select count(*) into stscnt from pre_bulkloader where loaded is null;
	if nrec = 0 or stscnt != stscnt then
		return;
	end if;
	
	-- don't even try to deal with funky guid_prefix
	select count(*) into gbp from pre_bulkloader where guid_prefix not in (select guid_prefix from collection);
	if gbp > 0 then
		update pre_bulkloader set loaded='funky guid_prefix detected; abort';
		return;
	end if;
	
	/*
	 * 
	 * 
	 * manual test:
	 * 
	 
	 select * from pre_bulk_agent;
	 select * from pre_bulk_taxa;
	 select * from pre_bulk_attributes;
	 select * from pre_bulk_oidt;
	 select * from pre_bulk_date;
	 select * from pre_bulk_parts;
	 select * from pre_bulk_disposition;
	 select * from pre_bulk_collrole;
	 select * from pre_bulk_accn;
	 select * from pre_bulk_geog;
	 select * from pre_bulk_NATURE_OF_ID;
	 select * from pre_bulk_ORIG_LAT_LONG_UNITS;
	 select * from pre_bulk_GEOREFERENCE_PROTOCOL;
	 select * from pre_bulk_VERIFICATIONSTATUS;
	 select * from pre_bulk_MAX_ERROR_UNITS;
	 select * from pre_bulk_COLLECTING_SOURCE;
	 select * from pre_bulk_DEPTH_UNITS;
	 select * from pre_bulk_DATUM;
	











	 
	  SEE bulkloader/sqltools for help in getting to pre_bulkloader
	  
	  -- dependancies:
	  
	  
	  
	  alter table pre_bulkloader add collection_cde varchar2(255);

	  
	  drop table pre_bulk_agent;
	  create table pre_bulk_agent (agent_name varchar2(4000),shouldbe varchar2(4000));
	  
	  drop table pre_bulk_taxa;
	  create table pre_bulk_taxa (taxon_name varchar2(4000),shouldbe varchar2(4000));

	drop table pre_bulk_attributes;
	create table pre_bulk_attributes (attribute_type varchar2(4000),COLLECTION_CDE varchar2(4000), shouldbe varchar2(4000));

	drop table pre_bulk_oidt;
	create table pre_bulk_oidt (other_id_type varchar2(4000), shouldbe varchar2(4000));
	
	drop table pre_bulk_date;
	create table pre_bulk_date (adate varchar2(4000), shouldbe varchar2(4000));
	
	drop table pre_bulk_parts;
	create table pre_bulk_parts (part_name varchar2(4000),COLLECTION_CDE varchar2(4000), shouldbe varchar2(4000));
	
	drop table pre_bulk_disposition;
	create table pre_bulk_disposition (disposition varchar2(4000), shouldbe varchar2(4000));
	
	drop table pre_bulk_collrole;
	create table pre_bulk_collrole (collector_role varchar2(4000), shouldbe varchar2(4000));
	
	
	drop table pre_bulk_accn;
	create table pre_bulk_accn (accn varchar2(4000), shouldbe varchar2(4000));
	







	drop table pre_bulk_geog;
	create table pre_bulk_geog (HIGHER_GEOG varchar2(4000), shouldbe varchar2(4000));
	
	drop table pre_bulk_NATURE_OF_ID;
	create table pre_bulk_NATURE_OF_ID (NATURE_OF_ID varchar2(4000), shouldbe varchar2(4000));
	
	drop table pre_bulk_ORIG_LAT_LONG_UNITS;
	create table pre_bulk_ORIG_LAT_LONG_UNITS (ORIG_LAT_LONG_UNITS varchar2(4000), shouldbe varchar2(4000));
	
	drop table pre_bulk_GEOREFERENCE_PROTOCOL;
	create table pre_bulk_GEOREFERENCE_PROTOCOL (GEOREFERENCE_PROTOCOL varchar2(4000), shouldbe varchar2(4000));
	
	drop table pre_bulk_VERIFICATIONSTATUS;
	create table pre_bulk_VERIFICATIONSTATUS (VERIFICATIONSTATUS varchar2(4000), shouldbe varchar2(4000));
	
	drop table pre_bulk_MAX_ERROR_UNITS;
	create table pre_bulk_MAX_ERROR_UNITS (MAX_ERROR_UNITS varchar2(4000), shouldbe varchar2(4000));
	
	drop table pre_bulk_COLLECTING_SOURCE;
	create table pre_bulk_COLLECTING_SOURCE (COLLECTING_SOURCE varchar2(4000), shouldbe varchar2(4000));
	
	drop table pre_bulk_DEPTH_UNITS;
	create table pre_bulk_DEPTH_UNITS (DEPTH_UNITS varchar2(4000), shouldbe varchar2(4000));

	drop table pre_bulk_DATUM;
	create table pre_bulk_DATUM (DATUM varchar2(4000), shouldbe varchar2(4000));
	

	------->


	
	
	  -- about:
	  
	  This procedure checks pre-bulkloader, tries to automate cleanup.
	  
	  Pathway to here:
	  	- fix multiple-agents-in-one-column agent data by splitting them up into the correct columns.
	  	
	  	- Massage data into the bulkloader format. Content is unimportant, column names 
	  	(and the TYPE of content - eg see multi-agent strings) are al that matter.
	  	
	  What it does; don't use this if you don't want any of this to happen:
	  
	  	REMOVE all nonprinting characters from all fields
	  	
	  
	  
	  -- after:
	  
	download 
		pre_bulk_agent
		pre_bulk_taxa
		pre_bulk_attributes
		pre_bulk_oidt
	  	pre_bulk_date




	 */
	
	--REMOVE all nonprinting characters from all fields
	for r in (select column_name from user_tab_cols where table_name=upper('pre_bulkloader')) loop
		--s:='update pre_bulkloader set ' || r.column_name || '=trim(' || r.column_name || ') where ' ||  r.column_name || ' != trim(' || r.column_name || ')';
		s:='update pre_bulkloader set ' || r.column_name || '=trim(' || r.column_name || ')';
		--dbms_output.put_line(s);
		execute immediate s;
		s:='update pre_bulkloader set ' || r.column_name || '=regexp_replace(' || r.column_name || ',''[^[:print:]]'','''') where regexp_like(' || r.column_name || ',''[^[:print:]]'')';
		--dbms_output.put_line(s);
		execute immediate s;
	end loop;

	-- get this closer to simplify collection-specific updates
	update pre_bulkloader set collection_cde=(select collection_cde from collection where collection.guid_prefix=pre_bulkloader.guid_prefix);

	
	 
	---------------------------- accn -------------------------------------
	
	delete from pre_bulk_accn;
	
	for rec in (select distinct accn,guid_prefix from pre_bulkloader) loop
		if rec.accn LIKE '[%' AND rec.accn LIKE '%]%' THEN
        	tempStr :=  substr(rec.accn, instr(rec.accn,'[',1,1) + 1,instr(rec.accn,']',1,1) -2);
        	tempStr2 := REPLACE(rec.accn,'['||tempStr||']');
        	tempStr:=REPLACE(tempStr,'[');
        	tempStr:=REPLACE(tempStr,']');
            a_guidprefix := tempStr;
          ELSE
            -- use institution_acronym	
            a_guidprefix := rec.guid_prefix;
            tempStr2 := rec.accn;
    	END IF; 
		select count(distinct(accn.transaction_id)) into numRecs from 
            accn,trans,collection 
        where 
          	accn.transaction_id = trans.transaction_id and
           	trans.collection_id=collection.collection_id AND
           	collection.guid_prefix = a_guidprefix AND
           	accn_number = tempStr2;
        if (numRecs != 1) then
        	insert into pre_bulk_accn(accn) values (rec.accn);
        end if;
    end loop;
	--------------------------- agents -------------------------------------
	
	
	delete from pre_bulk_agent;
	
	insert into pre_bulk_agent (agent_name) (
		select distinct n from (
			select ID_MADE_BY_AGENT n from pre_bulkloader
			union
			select EVENT_ASSIGNED_BY_AGENT n from pre_bulkloader
			union
			select COLLECTOR_AGENT_1 n from pre_bulkloader
			union
			select COLLECTOR_AGENT_2 n from pre_bulkloader
			union
			select COLLECTOR_AGENT_3 n from pre_bulkloader
			union
			select COLLECTOR_AGENT_4 n from pre_bulkloader
			union
			select COLLECTOR_AGENT_5 n from pre_bulkloader
			union
			select COLLECTOR_AGENT_6 n from pre_bulkloader
			union
			select COLLECTOR_AGENT_7 n from pre_bulkloader
			union
			select COLLECTOR_AGENT_8 n from pre_bulkloader
			union
			select ATTRIBUTE_DETERMINER_1 n from pre_bulkloader
			union
			select ATTRIBUTE_DETERMINER_2 n from pre_bulkloader
			union
			select ATTRIBUTE_DETERMINER_3 n from pre_bulkloader
			union
			select ATTRIBUTE_DETERMINER_4 n from pre_bulkloader
			union
			select ATTRIBUTE_DETERMINER_5 n from pre_bulkloader
			union
			select ATTRIBUTE_DETERMINER_6 n from pre_bulkloader
			union
			select ATTRIBUTE_DETERMINER_7 n from pre_bulkloader
			union
			select ATTRIBUTE_DETERMINER_8 n from pre_bulkloader
			union
			select ATTRIBUTE_DETERMINER_9 n from pre_bulkloader
			union
			select ATTRIBUTE_DETERMINER_10 n from pre_bulkloader
			union
			select GEO_ATT_DETERMINER_1 n from pre_bulkloader
			union
			select GEO_ATT_DETERMINER_2 n from pre_bulkloader
			union
			select GEO_ATT_DETERMINER_3 n from pre_bulkloader
			union
			select GEO_ATT_DETERMINER_4 n from pre_bulkloader
			union
			select GEO_ATT_DETERMINER_5 n from pre_bulkloader
			union
			select GEO_ATT_DETERMINER_6 n from pre_bulkloader
		) where n is not null
	) ;

	delete from pre_bulk_agent where getAgentId(agent_name) is not null;
	
	-- taxonomy
	
	delete from pre_bulk_taxa;
	
	insert into pre_bulk_taxa (taxon_name) (select distinct taxon_name from pre_bulkloader);

	-- now loop through and use the bulkloader-checker to figure out what's MIA	
	for rec in (select taxon_name from pre_bulk_taxa) loop
		has_problems:=0;
		if (instr(rec.taxon_name,' {') > 1 AND instr(rec.taxon_name,'}') > 1) then
			l_taxa_formula := 'A {string}';
			taxa_one := regexp_replace(rec.taxon_name,' {.*}$','');
		elsif instr(rec.taxon_name,' or ') > 1 then
			num := instr(rec.taxon_name, ' or ') -1;
			taxa_one := substr(rec.taxon_name,1,num);
			taxa_two := substr(rec.taxon_name,num+5);
			l_taxa_formula := 'A or B';
		elsif instr(rec.taxon_name,' and ') > 1 then
			num := instr(rec.taxon_name, ' and ') -1;
			taxa_one := substr(rec.taxon_name,1,num);
			taxa_two := substr(rec.taxon_name,num+5);
			l_taxa_formula := 'A and B';
	    elsif instr(rec.taxon_name,' x ') > 1 then
			num := instr(rec.taxon_name, ' x ') -1;
			taxa_one := substr(rec.taxon_name,1,num);
			taxa_two := substr(rec.taxon_name,num+4);
			l_taxa_formula := 'A x B';			
		elsif  substr(rec.taxon_name,length(rec.taxon_name) - 3) = ' sp.' then
			l_taxa_formula := 'A sp.';
			taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 3);
		elsif  substr(rec.taxon_name,length(rec.taxon_name) - 4) = ' ssp.' then
			l_taxa_formula := 'A ssp.';
			taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 4);
		elsif  substr(rec.taxon_name,length(rec.taxon_name) - 3) = ' cf.' then
			l_taxa_formula := 'A cf.';
			taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 3);
		elsif  substr(rec.taxon_name,length(rec.taxon_name) - 1) = ' ?' then
			l_taxa_formula := 'A ?';
			taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 1);
		else
			l_taxa_formula := 'A';
			taxa_one := rec.taxon_name;
		end if;
		if taxa_two is not null AND (
			  substr(taxa_one,length(taxa_one) - 3) = ' sp.' OR
				substr(taxa_two,length(taxa_two) - 3) = ' sp.' OR
				substr(taxa_one,length(taxa_one) - 1) = ' ?' OR
				substr(taxa_two,length(taxa_two) - 1) = ' ?' 
			) then
				has_problems:=1;
		end if;
		if taxa_one is not null then
			select count(distinct(taxon_name_id)) into num from taxon_name where scientific_name = trim(taxa_one);
			if num = 1 then
				select distinct(taxon_name_id) into l_taxon_name_id_1 from taxon_name where scientific_name = trim(taxa_one);
			else
				has_problems:=1;
			end if;
		end if;
		if taxa_two is not null then
			select count(distinct(taxon_name_id)) into num from taxon_name where scientific_name = trim(taxa_two);
			if num = 1 then
				select distinct(taxon_name_id) into l_taxon_name_id_2 from taxon_name where scientific_name = trim(taxa_two);
			else
				has_problems:=1;
			end if;
		end if;
		if has_problems = 0 then
			delete from pre_bulk_taxa where taxon_name=rec.taxon_name;
		end if;
	end loop;
	

	delete from pre_bulk_attributes;
	
	insert into pre_bulk_attributes (attribute_type, COLLECTION_CDE) (
		select a ,c  from (
			select ATTRIBUTE_1 a,COLLECTION_CDE c from pre_bulkloader
			union
			select ATTRIBUTE_2 a,COLLECTION_CDE c from pre_bulkloader
			union
			select ATTRIBUTE_3 a,COLLECTION_CDE c from pre_bulkloader
			union
			select ATTRIBUTE_4 a,COLLECTION_CDE c from pre_bulkloader
			union
			select ATTRIBUTE_5 a,COLLECTION_CDE c from pre_bulkloader
			union
			select ATTRIBUTE_6 a,COLLECTION_CDE c from pre_bulkloader
			union
			select ATTRIBUTE_7 a,COLLECTION_CDE c from pre_bulkloader
			union
			select ATTRIBUTE_8 a,COLLECTION_CDE c from pre_bulkloader
			union
			select ATTRIBUTE_9 a,COLLECTION_CDE c from pre_bulkloader
			union
			select ATTRIBUTE_10 a,COLLECTION_CDE c from pre_bulkloader
		) where a is not null group by a,c
	);
		
	delete from pre_bulk_attributes where (attribute_type,COLLECTION_CDE) in (select attribute_type,COLLECTION_CDE from ctattribute_type);

	
	
	delete from pre_bulk_oidt;
	insert into  pre_bulk_oidt (other_id_type) (
		select o from (
			select OTHER_ID_NUM_TYPE_1 o from pre_bulkloader
			union
			select OTHER_ID_NUM_TYPE_2 o from pre_bulkloader
			union
			select OTHER_ID_NUM_TYPE_3 o from pre_bulkloader
			union
			select OTHER_ID_NUM_TYPE_4 o from pre_bulkloader
			union
			select OTHER_ID_NUM_TYPE_5 o from pre_bulkloader
		) group by o
	);
	
	delete from pre_bulk_oidt where other_id_type in (select other_id_type from CTCOLL_OTHER_ID_TYPE);

	
	
	
	delete from pre_bulk_date;
	insert into pre_bulk_date (adate) (
		select d from (
			select MADE_DATE d from pre_bulkloader
			union
			select BEGAN_DATE d from pre_bulkloader
			union
			select ENDED_DATE d from pre_bulkloader
			union
			select EVENT_ASSIGNED_DATE d from pre_bulkloader
			union
			select ATTRIBUTE_DATE_1 d from pre_bulkloader
			union
			select ATTRIBUTE_DATE_2 d from pre_bulkloader
			union
			select ATTRIBUTE_DATE_3 d from pre_bulkloader
			union
			select ATTRIBUTE_DATE_4 d from pre_bulkloader
			union
			select ATTRIBUTE_DATE_5 d from pre_bulkloader
			union
			select ATTRIBUTE_DATE_6 d from pre_bulkloader
			union
			select ATTRIBUTE_DATE_7 d from pre_bulkloader
			union
			select ATTRIBUTE_DATE_8 d from pre_bulkloader
			union
			select ATTRIBUTE_DATE_9 d from pre_bulkloader
			union
			select ATTRIBUTE_DATE_10 d from pre_bulkloader
			union
			select GEO_ATT_DETERMINED_DATE_1 d from pre_bulkloader
			union
			select GEO_ATT_DETERMINED_DATE_2 d from pre_bulkloader
			union
			select GEO_ATT_DETERMINED_DATE_3 d from pre_bulkloader
			union
			select GEO_ATT_DETERMINED_DATE_4 d from pre_bulkloader
			union
			select GEO_ATT_DETERMINED_DATE_5 d from pre_bulkloader
			union
			select GEO_ATT_DETERMINED_DATE_6 d from pre_bulkloader
		) where d is not null group by d
	);

	delete from pre_bulk_date where is_iso8601(adate)='valid';

	

	
	delete from pre_bulk_parts;

	insert into pre_bulk_parts (part_name,COLLECTION_CDE) (
		select p , COLLECTION_CDE from (
			select PART_NAME_1 p, COLLECTION_CDE from pre_bulkloader
			union
			select PART_NAME_2 p, COLLECTION_CDE from pre_bulkloader
			union
			select PART_NAME_3 p, COLLECTION_CDE from pre_bulkloader
			union
			select PART_NAME_4 p, COLLECTION_CDE from pre_bulkloader
			union
			select PART_NAME_5 p, COLLECTION_CDE from pre_bulkloader
			union
			select PART_NAME_6 p, COLLECTION_CDE from pre_bulkloader
			union
			select PART_NAME_7 p, COLLECTION_CDE from pre_bulkloader
			union
			select PART_NAME_8 p, COLLECTION_CDE from pre_bulkloader
			union
			select PART_NAME_9 p, COLLECTION_CDE from pre_bulkloader
			union
			select PART_NAME_10 p, COLLECTION_CDE from pre_bulkloader
			union
			select PART_NAME_11 p, COLLECTION_CDE from pre_bulkloader
			union
			select PART_NAME_12 p, COLLECTION_CDE from pre_bulkloader
		) where p is not null group by p,COLLECTION_CDE
	);

	delete from pre_bulk_parts where (PART_NAME,collection_cde) in (select part_name,collection_cde from ctspecimen_part_name);

	
	
	
	delete from pre_bulk_disposition;
	insert into pre_bulk_disposition (disposition) (
		select d  from (
			select PART_DISPOSITION_1 d from pre_bulkloader
			union
			select PART_DISPOSITION_2 d from pre_bulkloader
			union
			select PART_DISPOSITION_3 d from pre_bulkloader
			union
			select PART_DISPOSITION_4 d from pre_bulkloader
			union
			select PART_DISPOSITION_5 d from pre_bulkloader
			union
			select PART_DISPOSITION_6 d from pre_bulkloader
			union
			select PART_DISPOSITION_7 d from pre_bulkloader
			union
			select PART_DISPOSITION_8 d from pre_bulkloader
			union
			select PART_DISPOSITION_9 d from pre_bulkloader
			union
			select PART_DISPOSITION_10 d from pre_bulkloader
			union
			select PART_DISPOSITION_11 d from pre_bulkloader
			union
			select PART_DISPOSITION_12 d from pre_bulkloader
		) where d is not null group by d
	);

	delete from pre_bulk_disposition where disposition in (select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP);

	
	delete from pre_bulk_collrole;
	
	insert into pre_bulk_collrole (collector_role) (
		select r from (
			select collector_role_1 r from pre_bulkloader
			union
			select collector_role_2 r from pre_bulkloader
			union
			select collector_role_3 r from pre_bulkloader
			union
			select collector_role_4 r from pre_bulkloader
			union
			select collector_role_5 r from pre_bulkloader
			union
			select collector_role_6 r from pre_bulkloader
			union
			select collector_role_7 r from pre_bulkloader
			union
			select collector_role_8 r from pre_bulkloader
		) where r is not null group by r
	);
	
	delete from pre_bulk_collrole where collector_role in (select collector_role from CTcollector_role);
	
	
	
	delete from pre_bulk_geog;
	insert into pre_bulk_geog (HIGHER_GEOG) (select distinct HIGHER_GEOG from pre_bulkloader);
	delete from pre_bulk_geog where HIGHER_GEOG in (select HIGHER_GEOG from geog_auth_rec);

	delete from  pre_bulk_NATURE_OF_ID;
	insert into pre_bulk_NATURE_OF_ID (NATURE_OF_ID) (
		select distinct NATURE_OF_ID from pre_bulkloader where NATURE_OF_ID not in (select NATURE_OF_ID from ctNATURE_OF_ID)
	);
	
	delete from  pre_bulk_ORIG_LAT_LONG_UNITS;
	insert into pre_bulk_ORIG_LAT_LONG_UNITS (ORIG_LAT_LONG_UNITS) (
		select distinct ORIG_LAT_LONG_UNITS from pre_bulkloader where ORIG_LAT_LONG_UNITS not in (select ORIG_LAT_LONG_UNITS from CTLAT_LONG_UNITS)
	);
	
	delete from  pre_bulk_GEOREFERENCE_PROTOCOL;
	insert into pre_bulk_GEOREFERENCE_PROTOCOL (GEOREFERENCE_PROTOCOL) (
		select distinct GEOREFERENCE_PROTOCOL from pre_bulkloader where  GEOREFERENCE_PROTOCOL not in (select GEOREFERENCE_PROTOCOL from CTGEOREFERENCE_PROTOCOL)
	);
	
	delete from  pre_bulk_VERIFICATIONSTATUS;
	insert into pre_bulk_VERIFICATIONSTATUS (VERIFICATIONSTATUS) (
		select distinct VERIFICATIONSTATUS from pre_bulkloader where  VERIFICATIONSTATUS not in (select VERIFICATIONSTATUS from CTVERIFICATIONSTATUS)
	);
	
	delete from  pre_bulk_MAX_ERROR_UNITS;
	insert into pre_bulk_MAX_ERROR_UNITS (MAX_ERROR_UNITS) (
		select distinct MAX_ERROR_UNITS from pre_bulkloader where  MAX_ERROR_UNITS not in (select MAX_ERROR_UNITS from CTLAT_LONG_ERROR_UNITS)
	);
	
	delete from  pre_bulk_COLLECTING_SOURCE;
	insert into pre_bulk_COLLECTING_SOURCE (COLLECTING_SOURCE) (
		select distinct COLLECTING_SOURCE from pre_bulkloader where  COLLECTING_SOURCE not in (select COLLECTING_SOURCE from CTCOLLECTING_SOURCE)
	);
	
	delete from  pre_bulk_DEPTH_UNITS;
	insert into pre_bulk_DEPTH_UNITS (DEPTH_UNITS) (
		select distinct DEPTH_UNITS from pre_bulkloader where  DEPTH_UNITS not in (select DEPTH_UNITS from CTDEPTH_UNITS)
	);
	
	delete from  pre_bulk_DATUM;
	insert into pre_bulk_DATUM (DATUM) (
		select distinct DATUM from pre_bulkloader where  DATUM not in (select DATUM from CTDATUM)
	);
	
	

	
	

	update pre_bulkloader set loaded = 'init_pull_complete';
END;
/ 

sho err;

BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'J_PRE_BULK_CHK',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'pre_bulk_check',
   start_date         =>  SYSTIMESTAMP,
   repeat_interval    =>  'freq=hourly; byminute=5,15,25,35,44,55;',
   enabled             =>  TRUE,
   end_date           =>  NULL,
   comments           =>  'make some tables yo');
END;
/

select STATE,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_PRE_BULK_CHK';

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	