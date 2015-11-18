
CREATE OR REPLACE PROCEDURE pre_bulk_repatriate  IS
begin
 -- reinsert the lookup values
	-- only run this if ALL records are loaded=go_go_gadget_repatriate; set loaded in this procedure.
	select count(*) into nrec from pre_bulkloader;
	select count(*) into stscnt from pre_bulkloader where loaded !='go_go_gadget_repatriate';
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
	 * 
	 

	
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
	
	
	 */
	

	
	for r in (select * from pre_bulk_agent) loop
		update pre_bulkloader set COLLECTOR_agent_1=trim(r.shouldbe) where trim(COLLECTOR_agent_1)=trim(r.AGENT_NAME);
		update pre_bulkloader set COLLECTOR_agent_2=trim(r.shouldbe) where trim(COLLECTOR_agent_2)=trim(r.AGENT_NAME);
		update pre_bulkloader set COLLECTOR_agent_3=trim(r.shouldbe) where trim(COLLECTOR_agent_3)=trim(r.AGENT_NAME);
		update pre_bulkloader set COLLECTOR_agent_4=trim(r.shouldbe) where trim(COLLECTOR_agent_4)=trim(r.AGENT_NAME);
		update pre_bulkloader set COLLECTOR_agent_5=trim(r.shouldbe) where trim(COLLECTOR_agent_5)=trim(r.AGENT_NAME);
		update pre_bulkloader set COLLECTOR_agent_6=trim(r.shouldbe) where trim(COLLECTOR_agent_6)=trim(r.AGENT_NAME);
		update pre_bulkloader set COLLECTOR_agent_7=trim(r.shouldbe) where trim(COLLECTOR_agent_7)=trim(r.AGENT_NAME);
		update pre_bulkloader set COLLECTOR_agent_8=trim(r.shouldbe) where trim(COLLECTOR_agent_8)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_1=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_1)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_2=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_2)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_3=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_3)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_4=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_4)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_5=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_5)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_6=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_6)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_7=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_7)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_8=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_8)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_9=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_9)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_10=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_10)=trim(r.AGENT_NAME);
		update pre_bulkloader set ID_MADE_BY_AGENT=trim(r.shouldbe) where trim(ID_MADE_BY_AGENT)=trim(r.AGENT_NAME);
		update pre_bulkloader set EVENT_ASSIGNED_BY_AGENT=trim(r.shouldbe) where trim(EVENT_ASSIGNED_BY_AGENT)=trim(r.AGENT_NAME);
	end loop;

	
		
	for r in (select * from pre_bulk_taxa) loop
		update pre_bulkloader set taxon_name=trim(r.shouldbe) where trim(taxon_name)=trim(r.taxon_name);
	end loop;

	
	for r in (select * from pre_bulk_attributes) loop
		update pre_bulkloader set ATTRIBUTE_1=r.shouldbe where ATTRIBUTE_1=r.attribute_type;
		update pre_bulkloader set ATTRIBUTE_2=r.shouldbe where ATTRIBUTE_2=r.attribute_type;
		update pre_bulkloader set ATTRIBUTE_3=r.shouldbe where ATTRIBUTE_3=r.attribute_type;
		update pre_bulkloader set ATTRIBUTE_4=r.shouldbe where ATTRIBUTE_4=r.attribute_type;
		update pre_bulkloader set ATTRIBUTE_5=r.shouldbe where ATTRIBUTE_5=r.attribute_type;
		update pre_bulkloader set ATTRIBUTE_6=r.shouldbe where ATTRIBUTE_6=r.attribute_type;
		update pre_bulkloader set ATTRIBUTE_7=r.shouldbe where ATTRIBUTE_7=r.attribute_type;
		update pre_bulkloader set ATTRIBUTE_8=r.shouldbe where ATTRIBUTE_8=r.attribute_type;
		update pre_bulkloader set ATTRIBUTE_9=r.shouldbe where ATTRIBUTE_9=r.attribute_type;
		update pre_bulkloader set ATTRIBUTE_10=r.shouldbe where ATTRIBUTE_10=r.attribute_type;
	end loop;

	
	for r in (select * from pre_bulk_oidt) loop
		update pre_bulkloader set OTHER_ID_NUM_TYPE_1=r.shouldbe where OTHER_ID_NUM_TYPE_1=r.OTHER_ID_TYPE;
		update pre_bulkloader set OTHER_ID_NUM_TYPE_2=r.shouldbe where OTHER_ID_NUM_TYPE_2=r.OTHER_ID_TYPE;
		update pre_bulkloader set OTHER_ID_NUM_TYPE_3=r.shouldbe where OTHER_ID_NUM_TYPE_3=r.OTHER_ID_TYPE;
		update pre_bulkloader set OTHER_ID_NUM_TYPE_4=r.shouldbe where OTHER_ID_NUM_TYPE_4=r.OTHER_ID_TYPE;
		update pre_bulkloader set OTHER_ID_NUM_TYPE_5=r.shouldbe where OTHER_ID_NUM_TYPE_5=r.OTHER_ID_TYPE;
	end loop;

		
	for r in (select * from pre_bulk_date) loop
		update pre_bulkloader set MADE_DATE=r.shouldbe where MADE_DATE=r.adate;
		update pre_bulkloader set BEGAN_DATE=r.shouldbe where BEGAN_DATE=r.adate;
		update pre_bulkloader set ENDED_DATE=r.shouldbe where ENDED_DATE=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_1=r.shouldbe where ATTRIBUTE_DATE_1=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_2=r.shouldbe where ATTRIBUTE_DATE_2=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_3=r.shouldbe where ATTRIBUTE_DATE_3=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_4=r.shouldbe where ATTRIBUTE_DATE_4=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_5=r.shouldbe where ATTRIBUTE_DATE_5=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_6=r.shouldbe where ATTRIBUTE_DATE_6=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_7=r.shouldbe where ATTRIBUTE_DATE_7=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_8=r.shouldbe where ATTRIBUTE_DATE_8=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_9=r.shouldbe where ATTRIBUTE_DATE_9=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_10=r.shouldbe where ATTRIBUTE_DATE_10=r.adate;
		update pre_bulkloader set EVENT_ASSIGNED_DATE=r.shouldbe where EVENT_ASSIGNED_DATE=r.adate;
	end loop;


	for r in (select * from pre_bulk_parts) loop
		update pre_bulkloader set part_name_1=r.shouldbe where part_name_1=r.part_name;
		update pre_bulkloader set part_name_2=r.shouldbe where part_name_2=r.part_name;
		update pre_bulkloader set part_name_3=r.shouldbe where part_name_3=r.part_name;
		update pre_bulkloader set part_name_4=r.shouldbe where part_name_4=r.part_name;
		update pre_bulkloader set part_name_5=r.shouldbe where part_name_5=r.part_name;
		update pre_bulkloader set part_name_6=r.shouldbe where part_name_6=r.part_name;
		update pre_bulkloader set part_name_7=r.shouldbe where part_name_7=r.part_name;
		update pre_bulkloader set part_name_8=r.shouldbe where part_name_8=r.part_name;
		update pre_bulkloader set part_name_9=r.shouldbe where part_name_9=r.part_name;
		update pre_bulkloader set part_name_10=r.shouldbe where part_name_10=r.part_name;
		update pre_bulkloader set part_name_11=r.shouldbe where part_name_11=r.part_name;
		update pre_bulkloader set part_name_12=r.shouldbe where part_name_12=r.part_name;
	end loop;
	
	
	for r in (select * from pre_bulk_disposition) loop
		update pre_bulkloader set PART_DISPOSITION_1=r.shouldbe where PART_DISPOSITION_1=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_2=r.shouldbe where PART_DISPOSITION_2=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_3=r.shouldbe where PART_DISPOSITION_3=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_4=r.shouldbe where PART_DISPOSITION_4=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_5=r.shouldbe where PART_DISPOSITION_5=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_6=r.shouldbe where PART_DISPOSITION_6=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_7=r.shouldbe where PART_DISPOSITION_7=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_8=r.shouldbe where PART_DISPOSITION_8=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_9=r.shouldbe where PART_DISPOSITION_9=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_10=r.shouldbe where PART_DISPOSITION_10=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_11=r.shouldbe where PART_DISPOSITION_11=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_12=r.shouldbe where PART_DISPOSITION_12=r.disposition;
	end loop;

	
	
		drop table pre_bulk_collrole;
	create table pre_bulk_collrole (collector_role varchar2(4000), shouldbe varchar2(4000));
	
	
	
	
	
	
	
	
	
	
	
	
begin
	for r in (select * from pre_bulk_date) loop
		update pre_bulkloader set EVENT_ASSIGNED_DATE=r.shouldbe where EVENT_ASSIGNED_DATE=r.adate;
	end loop;
end;



BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_temp_update_junk',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_junk',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/ 
select STATE,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';








----------------- geog ----------------------------


update pre_bulkloader set HIGHER_GEOG=trim(HIGHER_GEOG);

select distinct replace(HIGHER_GEOG,'quad','Quad') from pre_bulkloader where HIGHER_GEOG like '% quad%';
select distinct replace(HIGHER_GEOG,'Ameica','America') from pre_bulkloader where HIGHER_GEOG like '% Ameica%';
select distinct replace(HIGHER_GEOG,'  ',' ') from pre_bulkloader where HIGHER_GEOG like '%  %';



update pre_bulkloader set HIGHER_GEOG=replace(HIGHER_GEOG,'quad','Quad') where HIGHER_GEOG like '% quad%';
update pre_bulkloader set HIGHER_GEOG=replace(HIGHER_GEOG,'Ameica','America') where HIGHER_GEOG like '% Ameica%';
update pre_bulkloader set HIGHER_GEOG=replace(HIGHER_GEOG,'  ',' ' ) where HIGHER_GEOG like '%  %';

drop table pre_bulk_geog;

create table pre_bulk_geog as select distinct(HIGHER_GEOG) from pre_bulkloader;

delete from pre_bulk_geog where HIGHER_GEOG in (select HIGHER_GEOG from geog_auth_rec);

select * from pre_bulk_geog order by HIGHER_GEOG;

update pre_bulkloader set HIGHER_GEOG='North Pacific Ocean, Marshall Islands' where trim(HIGHER_GEOG)='Asia, Marshall Islands';
update pre_bulkloader set HIGHER_GEOG='Central America, Honduras' where trim(HIGHER_GEOG)='North America, Honduras';
update pre_bulkloader set HIGHER_GEOG='Central America, Panama' where trim(HIGHER_GEOG)='North America, Panama';
update pre_bulkloader set HIGHER_GEOG='South America, Peru' where trim(HIGHER_GEOG)='North America, Peru';
update pre_bulkloader set HIGHER_GEOG='North America, Bering Sea, United States, Alaska, Adak Quad, Andreanof Islands, Aleutian Islands' where trim(HIGHER_GEOG)='North America, United States, Alaska, Adak Quad';
update pre_bulkloader set HIGHER_GEOG='North America, Bering Sea, United States, Alaska, Attu Quad, Aleutian Islands' where trim(HIGHER_GEOG)='North America, United States, Alaska, Attu Quad';
update pre_bulkloader set HIGHER_GEOG='North America, Bering Sea, United States, Alaska, Baird Inlet Quad' where trim(HIGHER_GEOG)='North America, United States, Alaska, Baird Inlet Quad';
update pre_bulkloader set HIGHER_GEOG='North America, United States, Alaska, Baird Mts. Quad' where trim(HIGHER_GEOG)='North America, United States, Alaska, Baird Mountains Quad';
update pre_bulkloader set HIGHER_GEOG='North America, Bering Sea, United States, Alaska, Black Quad' where trim(HIGHER_GEOG)='North America, United States, Alaska, Black Quad';
update pre_bulkloader set HIGHER_GEOG='North America, United States, Alaska, Craig Quad, Alexander Archipelago' where trim(HIGHER_GEOG)='North America, United States, Alaska, Craig Quad';
update pre_bulkloader set HIGHER_GEOG='North America, United States, Alaska, De Long Mts. Quad' where trim(HIGHER_GEOG)='North America, United States, Alaska, DeLong Mountains Quad';
update pre_bulkloader set HIGHER_GEOG='North America, Bering Sea, United States, Alaska, Gareloi Island Quad, Aleutian Islands' where trim(HIGHER_GEOG)='North America, United States, Alaska, Gareloi Island Quad';
update pre_bulkloader set HIGHER_GEOG='North America, Bering Sea, United States, Alaska, Kiska Quad, Aleutian Islands' where trim(HIGHER_GEOG)='North America, United States, Alaska, Kiska Quad';
update pre_bulkloader set HIGHER_GEOG='North America, United States, Alaska, Misheguk Mtn. Quad' where trim(HIGHER_GEOG)='North America, United States, Alaska, Misheguk Mountain Quad';
update pre_bulkloader set HIGHER_GEOG='North America, United States, Alaska, Mt. Fairweather Quad' where trim(HIGHER_GEOG)='North America, United States, Alaska, Mount Fairweather Quad';
update pre_bulkloader set HIGHER_GEOG='North America, United States, Alaska, Mt. Hayes Quad' where trim(HIGHER_GEOG)='North America, United States, Alaska, Mount Hayes Quad';
update pre_bulkloader set HIGHER_GEOG='North America, United States, Alaska, Mt. Katmai Quad' where trim(HIGHER_GEOG)='North America, United States, Alaska, Mount Katmai Quad';
update pre_bulkloader set HIGHER_GEOG='North America, United States, Alaska, Mt. McKinley Quad' where trim(HIGHER_GEOG)='North America, United States, Alaska, Mount McKinley Quad';
update pre_bulkloader set HIGHER_GEOG='North America, United States, Alaska, Mt. Michelson Quad' where trim(HIGHER_GEOG)='North America, United States, Alaska, Mount Michelson Quad';
update pre_bulkloader set HIGHER_GEOG='North America, United States, Alaska, Petersburg Quad, Alexander Archipelago' where trim(HIGHER_GEOG)='North America, United States, Alaska, Petersburg Quad';
update pre_bulkloader set HIGHER_GEOG='North America, United States, Alaska, Philip Smith Mts. Quad' where trim(HIGHER_GEOG)='North America, United States, Alaska, Phillip Smith Mountains Quad';
update pre_bulkloader set HIGHER_GEOG='North America, Bering Sea, United States, Alaska, Rat Islands Quad, Aleutian Islands' where trim(HIGHER_GEOG)='North America, United States, Alaska, Rat Islands Quad';
update pre_bulkloader set HIGHER_GEOG='North America, United States, Alaska, Simeonof Island Quad, Shumagin Islands' where trim(HIGHER_GEOG)='North America, United States, Alaska, Simeonof Island Quad';
update pre_bulkloader set HIGHER_GEOG='North America, United States, Alaska, Table Mtn. Quad' where trim(HIGHER_GEOG)='North America, United States, Alaska, Table Mountain Quad';
update pre_bulkloader set HIGHER_GEOG='North America, United States, Alaska, Talkeetna Mts. Quad' where trim(HIGHER_GEOG)='North America, United States, Alaska, Talkeetna Mountains Quad';
update pre_bulkloader set HIGHER_GEOG='North America, Bering Sea, United States, Alaska, Umnak Quad, Aleutian Islands' where trim(HIGHER_GEOG)='North America, United States, Alaska, Umnak Quad';
update pre_bulkloader set HIGHER_GEOG='North America, Bering Sea, United States, Alaska, Unalaska Quad, Aleutian Islands' where trim(HIGHER_GEOG)='North America, United States, Alaska, Unalaska Quad';
update pre_bulkloader set HIGHER_GEOG='Pacific Ocean, United States, Hawaii, Hawaiian Islands' where trim(HIGHER_GEOG)='North America, United States, Hawaii';
update pre_bulkloader set HIGHER_GEOG='South Pacific Ocean, Chile, Valparaiso, Easter Island' where trim(HIGHER_GEOG)='South Pacific Ocean, Easter Island';


update pre_bulkloader set HIGHER_GEOG='xxxxxxx' where trim(HIGHER_GEOG)='xxxxxx';
update pre_bulkloader set HIGHER_GEOG='xxxxxxx' where trim(HIGHER_GEOG)='xxxxxx';





















---------------------------- random single-column junk ------------------------------


select distinct NATURE_OF_ID from pre_bulkloader where NATURE_OF_ID not in (select NATURE_OF_ID from ctNATURE_OF_ID);

/*
	http://arctos.database.museum/info/ctDocumentation.cfm?table=CTNATURE_OF_ID
	update pre_bulkloader set NATURE_OF_ID='legacy' where NATURE_OF_ID is null;
*/

select distinct ORIG_LAT_LONG_UNITS from pre_bulkloader where ORIG_LAT_LONG_UNITS not in (select ORIG_LAT_LONG_UNITS from CTLAT_LONG_UNITS);
/*
	http://arctos.database.museum/info/ctDocumentation.cfm?table=CTLAT_LONG_UNITS
	update pre_bulkloader set ORIG_LAT_LONG_UNITS='decimal degrees' where ORIG_LAT_LONG_UNITS is null and dec_lat is not null;
*/

select distinct GEOREFERENCE_PROTOCOL from pre_bulkloader where GEOREFERENCE_PROTOCOL not in (select GEOREFERENCE_PROTOCOL from CTGEOREFERENCE_PROTOCOL);

/*
	http://arctos.database.museum/info/ctDocumentation.cfm?table=CTGEOREFERENCE_PROTOCOL
	update pre_bulkloader set GEOREFERENCE_PROTOCOL='not recorded' where GEOREFERENCE_PROTOCOL is null and ORIG_LAT_LONG_UNITS is not null;
*/

select distinct VERIFICATIONSTATUS from pre_bulkloader where VERIFICATIONSTATUS not in (select VERIFICATIONSTATUS from CTVERIFICATIONSTATUS);


select distinct MAX_ERROR_UNITS from pre_bulkloader where MAX_ERROR_UNITS not in (select MAX_ERROR_UNITS from CTLAT_LONG_ERROR_UNITS);



select distinct COLLECTING_SOURCE from pre_bulkloader where COLLECTING_SOURCE not in (select COLLECTING_SOURCE from CTCOLLECTING_SOURCE);


select distinct DEPTH_UNITS from pre_bulkloader where DEPTH_UNITS not in (select DEPTH_UNITS from CTDEPTH_UNITS);


select distinct DATUM from pre_bulkloader where DATUM not in (select DATUM from CTDATUM);


------------------------------------- accn ---------------------------------------------
declare
	tempStr VARCHAR2(255);
	tempStr2 VARCHAR2(255);
	a_instn VARCHAR2(255);
	a_coln VARCHAR2(255);
	numRecs number;
begin
	for rec in (select distinct accn,collection_cde,institution_acronym from pre_bulkloader) loop
		if rec.accn LIKE '[%' AND rec.accn LIKE '%]%' THEN
        	tempStr :=  substr(rec.accn, instr(rec.accn,'[',1,1) + 1,instr(rec.accn,']',1,1) -2);
        	tempStr2 := REPLACE(rec.accn,'['||tempStr||']');
        	tempStr:=REPLACE(tempStr,'[');
        	tempStr:=REPLACE(tempStr,']');
            a_instn := substr(tempStr,1,instr(tempStr,':')-1);
            a_coln := substr(tempStr,instr(tempStr,':')+1);
          ELSE
            -- use institution_acronym	
            a_coln := rec.collection_cde;
            a_instn := rec.institution_acronym;
            tempStr2 := rec.accn;
    	END IF; 
		select count(distinct(accn.transaction_id)) into numRecs from 
            accn,trans,collection 
        where 
          	accn.transaction_id = trans.transaction_id and
           	trans.collection_id=collection.collection_id AND
           	collection.institution_acronym = a_instn and
           	collection.collection_cde = a_coln AND
           	accn_number = tempStr2;
        if (numRecs != 1) then
        	dbms_output.put_line('found ' || numRecs || ' for ' || a_instn || ':' || a_coln || ':' || tempStr2);
        end if;
    end loop;
end;
/

create table temp_pre_accn as 
select distinct ACCN from pre_bulkloader where (ACCN,guid_prefix) not in 
	(select ACCN_NUMBER,guid_prefix from accn,trans,collection where 
	accn.transaction_id=trans.transaction_id and trans.collection_id=collection.collection_id);

	
	select distinct ':'||ACCN||':' from pre_bulkloader where (ACCN,guid_prefix) not in 
	(select ACCN_NUMBER,guid_prefix from accn,trans,collection where 
	accn.transaction_id=trans.transaction_id and trans.collection_id=collection.collection_id);

	update accn set accn_number=trim(accn_number) where accn_number != trim(accn_number);
	
	
	select accn_number from accn where accn_number != trim(accn_number);
	
	update pre_bulkloader set accn='1-1954' where accn='1-1954 (01)';
	update pre_bulkloader set accn='1-1929' where accn='29-Jan';
	update pre_bulkloader set accn='1-1933' where accn='Feb-33';
	update pre_bulkloader set accn='1-1932' where accn='Jan-32';
	update pre_bulkloader set accn='UA70-212' where accn='Ua70-212';
	
	
	update pre_bulkloader set accn='xxxx' where accn='xxxx';
	update pre_bulkloader set accn='xxxx' where accn='xxxx';
	update pre_bulkloader set accn='xxxx' where accn='xxxx';



--------------------------------- parts -----------------------------------------

drop table pre_bulk_parts;

create table pre_bulk_parts as select p part_name, COLLECTION_CDE from (
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
) where p is not null group by p,COLLECTION_CDE;


drop table pre_bulk_disposition;

create table pre_bulk_disposition as select d disposition from (
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
) where d is not null group by d;

delete from pre_bulk_disposition where disposition in (select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP);

delete from pre_bulk_disposition where disposition in ('in collection/being process/on loan/not deposited/missing/destroyed');


select * from pre_bulk_disposition;

-- reload

drop table pre_bulk_disposition;
create table pre_bulk_disposition as select * from dlm.my_temp_cf;

insert into pre_bulk_disposition(disposition,shouldbe) values ('not deposited','being processed');


		

------------------------------ collector role ------------------------------



drop table pre_bulk_collrole;

create table pre_bulk_collrole as select r collector_role from (
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
) where r is not null group by r;

delete from pre_bulk_collrole where collector_role in (select collector_role from CTcollector_role);

select * from pre_bulk_collrole;

alter table pre_bulk_collrole add shouldbe VARCHAR2(255);



update pre_bulk_collrole set shouldbe='preparator' where collector_role = 'cataloger';
update pre_bulk_collrole set shouldbe='collector' where collector_role = 'excavator';

begin
	for r in (select * from pre_bulk_collrole) loop
		update pre_bulkloader set collector_role_1=r.shouldbe where collector_role_1=r.collector_role;
		update pre_bulkloader set collector_role_2=r.shouldbe where collector_role_2=r.collector_role;
		update pre_bulkloader set collector_role_3=r.shouldbe where collector_role_3=r.collector_role;
		update pre_bulkloader set collector_role_4=r.shouldbe where collector_role_4=r.collector_role;
		update pre_bulkloader set collector_role_5=r.shouldbe where collector_role_5=r.collector_role;
		update pre_bulkloader set collector_role_6=r.shouldbe where collector_role_6=r.collector_role;
		update pre_bulkloader set collector_role_7=r.shouldbe where collector_role_7=r.collector_role;
		update pre_bulkloader set collector_role_8=r.shouldbe where collector_role_8=r.collector_role;
	end loop;
end;
/




------------------------------------ deal with common-default, often-NULL junk -----------------------------------


-- set empty and required determiners to first collector when available
select count(*) from pre_bulkloader where event_assigned_date is null;

select count(*) from pre_bulkloader where EVENT_ASSIGNED_BY_AGENT is null;
select count(*) from pre_bulkloader where ID_MADE_BY_AGENT is null;
select count(*) from pre_bulkloader where SPECIMEN_EVENT_TYPE is null;

-- just default versions of "no idea" in

update pre_bulkloader set ATTRIBUTE_DETERMINER_1='unknown' where attribute_1 is not null and ATTRIBUTE_DETERMINER_1 is null;
update pre_bulkloader set ATTRIBUTE_DETERMINER_2='unknown' where attribute_2 is not null and ATTRIBUTE_DETERMINER_2 is null;
update pre_bulkloader set ATTRIBUTE_DETERMINER_3='unknown' where attribute_3 is not null and ATTRIBUTE_DETERMINER_3 is null;
update pre_bulkloader set ATTRIBUTE_DETERMINER_4='unknown' where attribute_4 is not null and ATTRIBUTE_DETERMINER_4 is null;
update pre_bulkloader set ATTRIBUTE_DETERMINER_5='unknown' where attribute_5 is not null and ATTRIBUTE_DETERMINER_5 is null;
update pre_bulkloader set ATTRIBUTE_DETERMINER_6='unknown' where attribute_6 is not null and ATTRIBUTE_DETERMINER_6 is null;
update pre_bulkloader set ATTRIBUTE_DETERMINER_7='unknown' where attribute_7 is not null and ATTRIBUTE_DETERMINER_7 is null;
update pre_bulkloader set ATTRIBUTE_DETERMINER_8='unknown' where attribute_8 is not null and ATTRIBUTE_DETERMINER_8 is null;
update pre_bulkloader set ATTRIBUTE_DETERMINER_9='unknown' where attribute_9 is not null and ATTRIBUTE_DETERMINER_9 is null;
update pre_bulkloader set ATTRIBUTE_DETERMINER_10='unknown' where attribute_10 is not null and ATTRIBUTE_DETERMINER_10 is null;

   
update pre_bulkloader set BEGAN_DATE='1900-01-01' where BEGAN_DATE is null;
update pre_bulkloader set ENDED_DATE=to_char(sysdate,'yyyy-mm-dd') where ENDED_DATE is null;
update pre_bulkloader set VERBATIM_DATE='before October 2015' where VERBATIM_DATE is null;

 
update pre_bulkloader set ATTRIBUTE_DATE_1=to_char(sysdate,'yyyy-mm-dd') where attribute_1 is not null and ATTRIBUTE_DATE_1 is null;
update pre_bulkloader set ATTRIBUTE_DATE_2=to_char(sysdate,'yyyy-mm-dd') where attribute_2 is not null and ATTRIBUTE_DATE_2 is null;
update pre_bulkloader set ATTRIBUTE_DATE_3=to_char(sysdate,'yyyy-mm-dd') where attribute_3 is not null and ATTRIBUTE_DATE_3 is null;
update pre_bulkloader set ATTRIBUTE_DATE_4=to_char(sysdate,'yyyy-mm-dd') where attribute_4 is not null and ATTRIBUTE_DATE_4 is null;
update pre_bulkloader set ATTRIBUTE_DATE_5=to_char(sysdate,'yyyy-mm-dd') where attribute_5 is not null and ATTRIBUTE_DATE_5 is null;
update pre_bulkloader set ATTRIBUTE_DATE_6=to_char(sysdate,'yyyy-mm-dd') where attribute_6 is not null and ATTRIBUTE_DATE_6 is null;
update pre_bulkloader set ATTRIBUTE_DATE_7=to_char(sysdate,'yyyy-mm-dd') where attribute_7 is not null and ATTRIBUTE_DATE_7 is null;
update pre_bulkloader set ATTRIBUTE_DATE_8=to_char(sysdate,'yyyy-mm-dd') where attribute_8 is not null and ATTRIBUTE_DATE_8 is null;
update pre_bulkloader set ATTRIBUTE_DATE_9=to_char(sysdate,'yyyy-mm-dd') where attribute_9 is not null and ATTRIBUTE_DATE_9 is null;
update pre_bulkloader set ATTRIBUTE_DATE_10=to_char(sysdate,'yyyy-mm-dd') where attribute_10 is not null and ATTRIBUTE_DATE_10 is null;

update pre_bulkloader set PART_CONDITION_1='unchecked' where PART_NAME_1 is not null and PART_CONDITION_1 is null;
update pre_bulkloader set PART_CONDITION_2='unchecked' where PART_NAME_2 is not null and PART_CONDITION_2 is null;
update pre_bulkloader set PART_CONDITION_3='unchecked' where PART_NAME_3 is not null and PART_CONDITION_3 is null;
update pre_bulkloader set PART_CONDITION_4='unchecked' where PART_NAME_4 is not null and PART_CONDITION_4 is null;
update pre_bulkloader set PART_CONDITION_5='unchecked' where PART_NAME_5 is not null and PART_CONDITION_5 is null;
update pre_bulkloader set PART_CONDITION_6='unchecked' where PART_NAME_6 is not null and PART_CONDITION_6 is null;
update pre_bulkloader set PART_CONDITION_7='unchecked' where PART_NAME_7 is not null and PART_CONDITION_7 is null;
update pre_bulkloader set PART_CONDITION_8='unchecked' where PART_NAME_8 is not null and PART_CONDITION_8 is null;
update pre_bulkloader set PART_CONDITION_9='unchecked' where PART_NAME_9 is not null and PART_CONDITION_9 is null;
update pre_bulkloader set PART_CONDITION_10='unchecked' where PART_NAME_10 is not null and PART_CONDITION_10 is null;
update pre_bulkloader set PART_CONDITION_11='unchecked' where PART_NAME_11 is not null and PART_CONDITION_11 is null;
update pre_bulkloader set PART_CONDITION_12='unchecked' where PART_NAME_12 is not null and PART_CONDITION_12 is null;



update pre_bulkloader set SPECIMEN_EVENT_TYPE='accepted place of collection' where SPECIMEN_EVENT_TYPE is null;

update pre_bulkloader set NATURE_OF_ID='legacy' where NATURE_OF_ID is null;






update pre_bulkloader set EVENT_ASSIGNED_DATE=to_char(sysdate,'yyyy-mm-dd') where event_assigned_date is null;
update pre_bulkloader set EVENT_ASSIGNED_BY_AGENT='unknown' where EVENT_ASSIGNED_BY_AGENT is null;
update pre_bulkloader set ID_MADE_BY_AGENT='unknown' where ID_MADE_BY_AGENT is null;

-- for cultural stuff only
update pre_bulkloader set taxon_name='unidentifiable {' || taxon_name || '}';
--- draw from data, make crazy assumptions
-- date object, so special handling
update pre_bulkloader set EVENT_ASSIGNED_DATE=substr(ended_date,0,10) where EVENT_ASSIGNED_DATE is null and is_iso8601(ended_date)='valid' and length(ended_date)>=10;

select count(*) from pre_bulkloader where EVENT_ASSIGNED_DATE is null;

-- set the rest to sysdate, lacking better options
update pre_bulkloader set EVENT_ASSIGNED_DATE=sysdate where EVENT_ASSIGNED_DATE is null;

-- set iso8601 dates to the year of the ended date
update pre_bulkloader set ATTRIBUTE_DATE_1=substr(ended_date,0,4) where attribute_1 is not null and ATTRIBUTE_DATE_1 is null;
update pre_bulkloader set ATTRIBUTE_DATE_2=substr(ended_date,0,4) where attribute_2 is not null and ATTRIBUTE_DATE_2 is null;
update pre_bulkloader set ATTRIBUTE_DATE_3=substr(ended_date,0,4) where attribute_3 is not null and ATTRIBUTE_DATE_3 is null;
update pre_bulkloader set ATTRIBUTE_DATE_4=substr(ended_date,0,4) where attribute_4 is not null and ATTRIBUTE_DATE_4 is null;
update pre_bulkloader set ATTRIBUTE_DATE_5=substr(ended_date,0,4) where attribute_5 is not null and ATTRIBUTE_DATE_5 is null;
update pre_bulkloader set ATTRIBUTE_DATE_6=substr(ended_date,0,4) where attribute_6 is not null and ATTRIBUTE_DATE_6 is null;
update pre_bulkloader set ATTRIBUTE_DATE_7=substr(ended_date,0,4) where attribute_7 is not null and ATTRIBUTE_DATE_7 is null;
update pre_bulkloader set ATTRIBUTE_DATE_8=substr(ended_date,0,4) where attribute_8 is not null and ATTRIBUTE_DATE_8 is null;
update pre_bulkloader set ATTRIBUTE_DATE_9=substr(ended_date,0,4) where attribute_9 is not null and ATTRIBUTE_DATE_9 is null;
update pre_bulkloader set ATTRIBUTE_DATE_10=substr(ended_date,0,4) where attribute_10 is not null and ATTRIBUTE_DATE_10 is null;
update pre_bulkloader set MADE_DATE=substr(ended_date,0,4) where MADE_DATE is null;

select count(*) from pre_bulkloader where EVENT_ASSIGNED_DATE is null;



update pre_bulkloader set EVENT_ASSIGNED_BY_AGENT=COLLECTOR_agent_1 where EVENT_ASSIGNED_BY_AGENT is null and COLLECTOR_agent_1 is not null and COLLECTOR_ROLE_1='collector';
update pre_bulkloader set ID_MADE_BY_AGENT=COLLECTOR_agent_1 where ID_MADE_BY_AGENT is null and COLLECTOR_agent_1 is not null and COLLECTOR_ROLE_1='collector';

-- and unknown where not

update pre_bulkloader set EVENT_ASSIGNED_BY_AGENT='unknown' where EVENT_ASSIGNED_BY_AGENT is null;
update pre_bulkloader set ID_MADE_BY_AGENT='unknown' where ID_MADE_BY_AGENT is null;

update pre_bulkloader set SPECIMEN_EVENT_TYPE='accepted place of collection' where SPECIMEN_EVENT_TYPE is null;


---------------------------------- need special handling for UTM, which are not convertible -------


select distinct
	'DEC_LAT: ' || DEC_LAT,
	'DEC_LONG: ' || DEC_LONG,
	'LATDEG: ' || LATDEG,
	'DEC_LAT_MIN: ' || DEC_LAT_MIN,
	'LATMIN: ' || LATMIN,
	'LATSEC: ' || LATSEC,
	'LATDIR: ' || LATDIR,
	'LONGDEG: ' || LONGDEG,
	'DEC_LONG_MIN: ' || DEC_LONG_MIN,
	'LONGMIN: ' || LONGMIN,
	'LONGSEC: ' || LONGSEC,
	'LONGDIR: ' || LONGDIR,
	'DATUM: ' || DATUM,
	'GEOREFERENCE_SOURCE: ' || GEOREFERENCE_SOURCE,
	'MAX_ERROR_DISTANCE: ' || MAX_ERROR_DISTANCE,
	'MAX_ERROR_UNITS: ' || MAX_ERROR_UNITS,
	'GEOREFERENCE_PROTOCOL: ' || GEOREFERENCE_PROTOCOL,
	'UTM_ZONE: ' || UTM_ZONE,
	'UTM_EW: ' || UTM_EW,
	'UTM_NS: ' || UTM_NS 								    
from
	pre_bulkloader
where ORIG_LAT_LONG_UNITS='UTM';

-- code for 
--  	DEC_LAT: NULL
--		DEC_LONG: NULL
--		DATUM: unknown
-- 		GEOREFERENCE_SOURCE: MaNIS georeferencing guidelines
-- 		GEOREFERENCE_PROTOCOL: not recorded
-- 		UTM_ZONE:
-- 		UTM_EW: 476492
-- 		UTM_NS: 4427774
-- check
select distinct
	decode(locality_remarks,null,'UTM cannot be converted by bulkloader; data follow: DATUM: ' || DATUM || '; GEOREFERENCE_SOURCE: ' || GEOREFERENCE_SOURCE || '; GEOREFERENCE_PROTOCOL: ' || GEOREFERENCE_PROTOCOL || '; UTM_ZONE: ' || UTM_ZONE || '; UTM_EW: ' || UTM_EW || '; UTM_NS: ' || UTM_NS,
		locality_remarks || '; UTM cannot be converted by bulkloader; data follow: DATUM: ' || DATUM || '; GEOREFERENCE_SOURCE: ' || GEOREFERENCE_SOURCE || '; GEOREFERENCE_PROTOCOL: ' || GEOREFERENCE_PROTOCOL || '; UTM_ZONE: ' || UTM_ZONE || '; UTM_EW: ' || UTM_EW || '; UTM_NS: ' || UTM_NS)
	from pre_bulkloader where ORIG_LAT_LONG_UNITS='UTM';

-- update
update pre_bulkloader set 
	locality_remarks=
	decode(locality_remarks,null,'UTM cannot be converted by bulkloader; data follow: DATUM: ' || DATUM || '; GEOREFERENCE_SOURCE: ' || GEOREFERENCE_SOURCE || '; GEOREFERENCE_PROTOCOL: ' || GEOREFERENCE_PROTOCOL || '; UTM_ZONE: ' || UTM_ZONE || '; UTM_EW: ' || UTM_EW || '; UTM_NS: ' || UTM_NS,
		locality_remarks || '; UTM cannot be converted by bulkloader; data follow: DATUM: ' || DATUM || '; GEOREFERENCE_SOURCE: ' || GEOREFERENCE_SOURCE || '; GEOREFERENCE_PROTOCOL: ' || GEOREFERENCE_PROTOCOL || '; UTM_ZONE: ' || UTM_ZONE || '; UTM_EW: ' || UTM_EW || '; UTM_NS: ' || UTM_NS)
	where ORIG_LAT_LONG_UNITS='UTM';



--------------------------------- actual per-row checker aimed at pre-bulk -----------------------------


	
	
CREATE OR REPLACE PROCEDURE temp_update_junk IS
	e VARCHAR2(4000);
BEGIN
	for r in (select collection_object_id from pre_bulkloader) loop
		select bulk_pre_check_one(r.collection_object_id) into e from dual;
		update pre_bulkloader set loaded=e where collection_object_id=r.collection_object_id;
	end loop;
end;
/

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_temp_update_junk',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_junk',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/ 



select collection_object_id from pre_bulkloader where ro;


select collection_object_id,bulk_pre_check_one(collection_object_id) from pre_bulkloader where rownum<100;

select EVENT_ASSIGNED_DATE from pre_bulkloader where collection_object_id=11775037;

select attribute_2, attribute_value_2 from pre_bulkloader where collection_object_id=11775057;
select distinct attribute_1 from pre_bulkloader;
select distinct attribute_2 from pre_bulkloader;
select distinct attribute_3 from pre_bulkloader;
select distinct attribute_4 from pre_bulkloader;
select distinct attribute_5 from pre_bulkloader;
select distinct attribute_6 from pre_bulkloader;
select distinct attribute_7 from pre_bulkloader;
select distinct attribute_8 from pre_bulkloader;
select distinct attribute_9 from pre_bulkloader;
select distinct attribute_10 from pre_bulkloader;

create table temp_arc_culture as select distinct attribute_value_2 culture from pre_bulkloader where attribute_value_2 not in (select CULTURE from ctCULTURE where collection_cde='Arc');

alter table temp_arc_culture add shouldbe varchar2(255);

select culture from temp_arc_culture order by culture

update temp_arc_culture set shouldbe='Aleut' where culture='Alaskan Native-Aleut';
update temp_arc_culture set shouldbe='Aleut' where culture='AleutArch Study Lab';
update temp_arc_culture set shouldbe='unknown' where culture='Unaffiliated';
update temp_arc_culture set shouldbe='unknown' where culture='Undetermine';
update temp_arc_culture set shouldbe='unknown' where culture='Undetermined';
update temp_arc_culture set shouldbe='unknown' where culture='Undeturmined';
update temp_arc_culture set shouldbe='unknown' where culture='Unidentified';
update temp_arc_culture set shouldbe='unknown' where culture='Unknown';
update temp_arc_culture set shouldbe='unknown' where culture='uknown';
update temp_arc_culture set shouldbe='unknown' where culture='unknownq';
update temp_arc_culture set shouldbe='unknown' where culture='unkown';
update temp_arc_culture set shouldbe='unknown' where culture='various';
update temp_arc_culture set shouldbe='Athabascan' where culture='Athabaskan';
update temp_arc_culture set shouldbe='Athabascan' where culture='Athabaskan';
update temp_arc_culture set shouldbe='Athabascan' where culture='Athapaskan';
update temp_arc_culture set shouldbe='non-Native' where culture='Non-Native';
update temp_arc_culture set shouldbe='unknown' where culture='Culturally Unidentif';
update temp_arc_culture set shouldbe='Eskimo, Cup''ik' where culture='Cup''ik';
update temp_arc_culture set shouldbe='Athabascan, Dena''ina' where culture='Denaina';
update temp_arc_culture set shouldbe='Eskimo, Inupiaq' where culture='Eskimoid-Inupiaq';
update temp_arc_culture set shouldbe='Eskimo, Yup''ik' where culture='Eskimoid-Yupik';
update temp_arc_culture set shouldbe='Pueblo, Hopi' where culture='Hopi';
update temp_arc_culture set shouldbe='Eskimo, Inupiaq' where culture='Inupiaq';
update temp_arc_culture set shouldbe='Eskimo, Inupiaq' where culture='Ipiutak Eskimo';


update temp_arc_culture set shouldbe='xxxxxxx' where culture='xxxxxxxxxx';
update temp_arc_culture set shouldbe='xxxxxxx' where culture='xxxxxxxxxx';
update temp_arc_culture set shouldbe='xxxxxxx' where culture='xxxxxxxxxx';
update temp_arc_culture set shouldbe='xxxxxxx' where culture='xxxxxxxxxx';
update temp_arc_culture set shouldbe='xxxxxxx' where culture='xxxxxxxxxx';
update temp_arc_culture set shouldbe='xxxxxxx' where culture='xxxxxxxxxx';
update temp_arc_culture set shouldbe='xxxxxxx' where culture='xxxxxxxxxx';



create table temp_arc_cltr_r as select * from dlm.my_temp_cf;


select count(*) from pre_bulkloader where began_date is null;



select EVENT_ASSIGNED_DATE from pre_bulkloader where collection_object_id=11775144;




declare
	e VARCHAR2(4000);
begin
	for r in (select collection_object_id from pre_bulkloader) loop
		select bulk_pre_check_one(r.collection_object_id) into e from dual;
		update pre_bulkloader set loaded=e where collection_object_id=r.collection_object_id;
	end loop;
end;
/

select STATE,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';

select distinct loaded from pre_bulkloader;





-------------------------------- insert ------------------------------------------
update pre_bulkloader set collection_object_id=bulkloader_pkey.nextval;

update pre_bulkloader set loaded='arcwait';

ALTER TABLE PRE_BULKLOADER DROP COLUMN COLLECTION_CDE;
update pre_bulkloader set entered_agent_id='2072';
update pre_bulkloader set collection_id='75';


insert into bulkloader (select * from pre_bulkloader);

update bulkloader set loaded=null where collection_object_id in (
select collection_object_id from bulkloader where loaded='arcwait' and rownum<10
);

select count(*) from bulkloader where guid_prefix='UAM:Arc';


select column_name from user_tab_cols where table_name=upper('PRE_BULKLOADER') and column_name not in 
(select column_name from user_tab_cols where table_name='BULKLOADER');

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
end;
/
sho err