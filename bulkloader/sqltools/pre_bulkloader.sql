drop table pre_bulkloader;

create table pre_bulkloader as select * from bulkloader where 1=2;

-- drop the constraints
alter table pre_bulkloader modify collection_id null;
alter table pre_bulkloader modify ENTERED_AGENT_ID null;
alter table pre_bulkloader modify COLLECTION_OBJECT_ID null;
alter table pre_bulkloader modify part_lot_count_1 varchar2(4000);





-- hu...
alter table specimen_event modify COLLECTING_METHOD VARCHAR2(4000);
alter table flat modify COLLECTING_METHOD VARCHAR2(4000);
alter table bulkloader modify COLLECTING_METHOD VARCHAR2(4000);
alter table bulkloader_stage modify COLLECTING_METHOD VARCHAR2(4000);
alter table bulkloader_deletes modify COLLECTING_METHOD VARCHAR2(4000);
alter table pre_bulkloader modify COLLECTING_METHOD VARCHAR2(4000);
alter table FLAT modify COLLECTING_METHOD VARCHAR2(4000);
alter table BULKLOADER_CLONE modify COLLECTING_METHOD VARCHAR2(4000);
alter table FILTERED_FLAT modify COLLECTING_METHOD VARCHAR2(4000);



-- don't worry about data, just column names at this point
-- fix this stuff
select column_name from user_tab_cols where table_name=upper('YYYOOUURRTTAABBLLEE') and column_name not in (select column_name from user_tab_cols where table_name='BULKLOADER');

-- except lot count is hosed/doesn't fit so
-- back
drop table pre_bulk_date;
create table pre_bulk_date as select * from dlm.my_temp_cf ;
create table pre_bulk_plc1 as select * from dlm.my_temp_cf ;

select ':' || part_lot_count_1 || ':' from pre_bulkloader where is_number(part_lot_count_1)=0;



begin
	for r in (select * from pre_bulk_plc1) loop
		if r.APPEND_REMARK is not null then
			update 
				pre_bulkloader 
			set 
				part_lot_count_1=r.SHOULDBE, 
				COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; ' || r.APPEND_REMARK
			where
				part_lot_count_1=r.PART_LOT_COUNT_1;
		else
			update 
				pre_bulkloader 
			set 
				part_lot_count_1=r.SHOULDBE
			where
				part_lot_count_1=r.PART_LOT_COUNT_1;
		end if;
	end loop;
end;
/
	
	update pre_bulkloader set 
				part_lot_count_1=184, 
				COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; approximate count'
			where
				part_lot_count_1='approx.184';
					
				update pre_bulkloader set 
				part_lot_count_1=33, 
				COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; approximate count'
			where
				part_lot_count_1='approx 33';
	update pre_bulkloader set 
				part_lot_count_1=30, 
				COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; part 1 count "30�"'
			where
				part_lot_count_1='30�';
				
				
				
				update pre_bulkloader set 
				part_lot_count_1=1, 
				COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; part 1 count not given'
			where
				part_lot_count_1 =' ';
------------------------------------------------------------------------------------------------------------------------
approx.184




4 rows selected.


	
-- back
drop table pre_bulk_date;
create table pre_bulk_date as select * from dlm.my_temp_cf ;


-- example of column-merger-code
-- use this to get your columns into bulkloader format
/*
update uc_herp set 
	locality_remarks=decode(locality_remarks,null,'NoGeorefBecause: ' || NOGEOREFBECAUSE,locality_remarks || '; NoGeorefBecause: ' || NOGEOREFBECAUSE)
	where NoGeorefBecause is not null;
*/
	

-- then use this to bring your data into the pre-named table so these scripts will work

delete from pre_bulkloader;

declare 
	s varchar2(4000);
	clist varchar2(4000);
	sep varchar2(20);
begin
	for r in (select column_name from user_tab_cols where table_name=upper('YYYOOUURRTTAABBLLEE')) loop 
		clist:=clist || sep || r.column_name;
		sep := ',';
	end loop;
	s:='insert into pre_bulkloader (' || clist || ') ( select ' || clist || ' from YYYOOUURRTTAABBLLEE)';
	dbms_output.put_line(s);
	execute immediate s;
end;
/


--- check

select count(*) from YYYOOUURRTTAABBLLEE;
select count(*) from pre_bulkloader;


---- trim and de-regex everything
-- slow as hell in big data so proceduretime

CREATE OR REPLACE PROCEDURE temp_update_junk IS
	s varchar2(4000);
	clist varchar2(4000);
	sep varchar2(20);
BEGIN
	for r in (select column_name from user_tab_cols where table_name=upper('pre_bulkloader')) loop
		--s:='update pre_bulkloader set ' || r.column_name || '=trim(' || r.column_name || ') where ' ||  r.column_name || ' != trim(' || r.column_name || ')';
		s:='update pre_bulkloader set ' || r.column_name || '=trim(' || r.column_name || ')';
		--dbms_output.put_line(s);
		execute immediate s;
		s:='update pre_bulkloader set ' || r.column_name || '=regexp_replace(' || r.column_name || ',''[^[:print:]]'','''') where regexp_like(' || r.column_name || ',''[^[:print:]]'')';
		--dbms_output.put_line(s);
		execute immediate s;
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

select STATE,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';


/*

declare 
	s varchar2(4000);
	clist varchar2(4000);
	sep varchar2(20);
begin
	for r in (select column_name from user_tab_cols where table_name=upper('pre_bulkloader')) loop
		--s:='update pre_bulkloader set ' || r.column_name || '=trim(' || r.column_name || ') where ' ||  r.column_name || ' != trim(' || r.column_name || ')';
		s:='update pre_bulkloader set ' || r.column_name || '=trim(' || r.column_name || ')';
		--dbms_output.put_line(s);
		execute immediate s;
		s:='update pre_bulkloader set ' || r.column_name || '=regexp_replace(' || r.column_name || ',''[^[:print:]]'','''') where regexp_like(' || r.column_name || ',''[^[:print:]]'')';
		--dbms_output.put_line(s);
		execute immediate s;
	end loop;
end;
/

*/

/*
  horrible evil hack to deal with getting collection_cde out of here
  sorray!
 */

alter table pre_bulkloader add collection_cde varchar2(30);
update pre_bulkloader set collection_cde=(select collection_cde from collection where collection.guid_prefix=pre_bulkloader.guid_prefix);

 -- /sorray
 

--------------------------- agents -------------------------------------


drop table pre_bulk_agent;

create table pre_bulk_agent as select distinct n agent_name from (
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
) where n is not null;

delete from pre_bulk_agent where getAgentId(agent_name) is not null;

select ':'||agent_name||':' from pre_bulk_agent;

-- global swap-in table is pre_bulk_agent_lookup;
/* setup
	create table pre_bulk_agent_lookup as select * from t_uc_agntlookup;
	drop table t_uc_agntlookup;
*/
-- see if there's anything already in the lookup, and check if it makes sense if there is
select 
	BAD_DUPLICATE || '--->' || GOOD_NAME
from
	pre_bulk_agent_lookup
where
	GOOD_NAME in (select trim(agent_name) from pre_bulk_agent);
	
	
--- anything that's missed will need to be created or whatever.
-- custom-ish code for that; will vary wildly based on data.
-- one example:
insert into pre_bulk_agent_lookup (BAD_DUPLICATE, GOOD_NAME,DLMDIDIT) values ('bbbb','gggggg',1);
-- from excel/csv

insert into pre_bulk_agent_lookup (BAD_DUPLICATE, GOOD_NAME,DLMDIDIT) (select PREFERRED_NAME,SHOULDBE,1 from dlm.my_temp_cf);
	
                                                VA

-- update all from lookup

begin
	for r in (select * from pre_bulk_agent_lookup) loop
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; collector 1 original: ' || r.BAD_DUPLICATE,COLLECTOR_agent_1=trim(r.GOOD_NAME) where trim(COLLECTOR_agent_1)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; collector 2 original: ' || r.BAD_DUPLICATE,COLLECTOR_agent_2=trim(r.GOOD_NAME) where trim(COLLECTOR_agent_2)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; collector 3 original: ' || r.BAD_DUPLICATE,COLLECTOR_agent_3=trim(r.GOOD_NAME) where trim(COLLECTOR_agent_3)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; collector 4 original: ' || r.BAD_DUPLICATE,COLLECTOR_agent_4=trim(r.GOOD_NAME) where trim(COLLECTOR_agent_4)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; collector 5 original: ' || r.BAD_DUPLICATE,COLLECTOR_agent_5=trim(r.GOOD_NAME) where trim(COLLECTOR_agent_5)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; collector 6 original: ' || r.BAD_DUPLICATE,COLLECTOR_agent_6=trim(r.GOOD_NAME) where trim(COLLECTOR_agent_6)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; collector 7 original: ' || r.BAD_DUPLICATE,COLLECTOR_agent_7=trim(r.GOOD_NAME) where trim(COLLECTOR_agent_7)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; collector 8 original: ' || r.BAD_DUPLICATE,COLLECTOR_agent_8=trim(r.GOOD_NAME) where trim(COLLECTOR_agent_8)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; ATTRIBUTE_DETERMINER_1 original: ' || trim(r.BAD_DUPLICATE),ATTRIBUTE_DETERMINER_1=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_1)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; ATTRIBUTE_DETERMINER_2 original: ' || trim(r.BAD_DUPLICATE),ATTRIBUTE_DETERMINER_2=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_2)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; ATTRIBUTE_DETERMINER_3 original: ' || trim(r.BAD_DUPLICATE),ATTRIBUTE_DETERMINER_3=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_3)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; ATTRIBUTE_DETERMINER_4 original: ' || trim(r.BAD_DUPLICATE),ATTRIBUTE_DETERMINER_4=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_4)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; ATTRIBUTE_DETERMINER_5 original: ' || trim(r.BAD_DUPLICATE),ATTRIBUTE_DETERMINER_5=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_5)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; ATTRIBUTE_DETERMINER_6 original: ' || trim(r.BAD_DUPLICATE),ATTRIBUTE_DETERMINER_6=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_6)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; ATTRIBUTE_DETERMINER_7 original: ' || trim(r.BAD_DUPLICATE),ATTRIBUTE_DETERMINER_7=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_7)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; ATTRIBUTE_DETERMINER_8 original: ' || trim(r.BAD_DUPLICATE),ATTRIBUTE_DETERMINER_8=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_8)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; ATTRIBUTE_DETERMINER_9 original: ' || trim(r.BAD_DUPLICATE),ATTRIBUTE_DETERMINER_9=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_9)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; ATTRIBUTE_DETERMINER_10 original: ' || trim(r.BAD_DUPLICATE),ATTRIBUTE_DETERMINER_10=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_10)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; ID_MADE_BY_AGENT original: ' || trim(r.BAD_DUPLICATE),ID_MADE_BY_AGENT=trim(r.GOOD_NAME) where trim(ID_MADE_BY_AGENT)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; EVENT_ASSIGNED_BY_AGENT original: ' || trim(r.BAD_DUPLICATE),EVENT_ASSIGNED_BY_AGENT=trim(r.GOOD_NAME) where trim(EVENT_ASSIGNED_BY_AGENT)=trim(r.BAD_DUPLICATE);
	end loop;
end;
/	



begin
	for r in (select * from pre_bulk_agent_lookup) loop
		update pre_bulkloader set COLLECTOR_agent_1=trim(r.GOOD_NAME) where trim(COLLECTOR_agent_1)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLLECTOR_agent_2=trim(r.GOOD_NAME) where trim(COLLECTOR_agent_2)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLLECTOR_agent_3=trim(r.GOOD_NAME) where trim(COLLECTOR_agent_3)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLLECTOR_agent_4=trim(r.GOOD_NAME) where trim(COLLECTOR_agent_4)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLLECTOR_agent_5=trim(r.GOOD_NAME) where trim(COLLECTOR_agent_5)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLLECTOR_agent_6=trim(r.GOOD_NAME) where trim(COLLECTOR_agent_6)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLLECTOR_agent_7=trim(r.GOOD_NAME) where trim(COLLECTOR_agent_7)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set COLLECTOR_agent_8=trim(r.GOOD_NAME) where trim(COLLECTOR_agent_8)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_1=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_1)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_2=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_2)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_3=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_3)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_4=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_4)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_5=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_5)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_6=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_6)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_7=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_7)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_8=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_8)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_9=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_9)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_10=trim(r.GOOD_NAME) where trim(ATTRIBUTE_DETERMINER_10)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set ID_MADE_BY_AGENT=trim(r.GOOD_NAME) where trim(ID_MADE_BY_AGENT)=trim(r.BAD_DUPLICATE);
		update pre_bulkloader set EVENT_ASSIGNED_BY_AGENT=trim(r.GOOD_NAME) where trim(EVENT_ASSIGNED_BY_AGENT)=trim(r.BAD_DUPLICATE);
	end loop;
end;
/	



-- rinse and repeat as necessary


--------------------------------------------------------- taxonomy ---------------------------

drop table pre_bulk_taxa;

create table pre_bulk_taxa as select distinct taxon_name from pre_bulkloader;

-- now loop through and use the bulkloader-checker to figure out what's MIA	

declare
	has_problems number;
	L_TAXA_FORMULA VARCHAR2(200);
	TAXA_ONE VARCHAR2(200);
	NUM number;
	L_TAXON_NAME_ID_1 number;
	L_TAXON_NAME_ID_2 number;
	TAXA_TWO VARCHAR2(200);
begin
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
end;
/

select * from pre_bulk_taxa;



update pre_bulkloader set taxon_name=trim('gggggg') where trim(taxon_name)='bbbbbbb';

---------------------- attributes --------------------------------------

drop table pre_bulk_attributes;

create table pre_bulk_attributes as select a attribute_type,c COLLECTION_CDE from (
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
) where a is not null group by a,c;


delete from pre_bulk_attributes where (attribute_type,COLLECTION_CDE) in (select attribute_type,COLLECTION_CDE from ctattribute_type);


select * from pre_bulk_attributes;


alter table pre_bulk_attributes add shouldbe varchar2(4000);

update pre_bulk_attributes set shouldbe='xxxxx' where attribute_type='xxxxx';
update pre_bulk_attributes set shouldbe='xxxxx' where attribute_type='xxxxx';
update pre_bulk_attributes set shouldbe='xxxxx' where attribute_type='xxxxx';
update pre_bulk_attributes set shouldbe='xxxxx' where attribute_type='xxxxx';
update pre_bulk_attributes set shouldbe='xxxxx' where attribute_type='xxxxx';

select * from pre_bulk_attributes where shouldbe is null;



 select * from pre_bulk_attributes where (shouldbe) not in (select attribute_type from ctattribute_type where COLLECTION_CDE='Arc');

begin
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
end;
/


--------------------------- other IDs ------------------------------------

drop table pre_bulk_oidt;

create table pre_bulk_oidt as select o other_id_type from (
	select OTHER_ID_NUM_TYPE_1 o from pre_bulkloader
	union
	select OTHER_ID_NUM_TYPE_2 o from pre_bulkloader
	union
	select OTHER_ID_NUM_TYPE_3 o from pre_bulkloader
	union
	select OTHER_ID_NUM_TYPE_4 o from pre_bulkloader
	union
	select OTHER_ID_NUM_TYPE_5 o from pre_bulkloader
) group by o;

delete from pre_bulk_oidt where other_id_type in (select other_id_type from CTCOLL_OTHER_ID_TYPE);

select * from pre_bulk_oidt;



original identifier.



---------------------------------------------------------------------------------------



original identifier (field number)










-- add a lookup
alter table pre_bulk_oidt add shouldbe varchar2(4000);
update pre_bulk_oidt set shouldbe='original identifier' where OTHER_ID_TYPE='original identifier (field number)';
update pre_bulk_oidt set shouldbe='AHRS (Alaska Heritage Resources Survey)' where OTHER_ID_TYPE='AHRS Number (State of Alaska ID)';
update pre_bulk_oidt set shouldbe='UAM:Arc Locality ID' where OTHER_ID_TYPE='Locality ID (site name)';

update pre_bulk_oidt set shouldbe='xxxxx' where OTHER_ID_TYPE='xxxxxx';
update pre_bulk_oidt set shouldbe='xxxxx' where OTHER_ID_TYPE='xxxxxx';
update pre_bulk_oidt set shouldbe='xxxxx' where OTHER_ID_TYPE='xxxxxx';
update pre_bulk_oidt set shouldbe='xxxxx' where OTHER_ID_TYPE='xxxxxx';
update pre_bulk_oidt set shouldbe='xxxxx' where OTHER_ID_TYPE='xxxxxx';


begin
	for r in (select * from pre_bulk_oidt) loop
		update pre_bulkloader set OTHER_ID_NUM_TYPE_1=r.shouldbe where OTHER_ID_NUM_TYPE_1=r.OTHER_ID_TYPE;
		update pre_bulkloader set OTHER_ID_NUM_TYPE_2=r.shouldbe where OTHER_ID_NUM_TYPE_2=r.OTHER_ID_TYPE;
		update pre_bulkloader set OTHER_ID_NUM_TYPE_3=r.shouldbe where OTHER_ID_NUM_TYPE_3=r.OTHER_ID_TYPE;
		update pre_bulkloader set OTHER_ID_NUM_TYPE_4=r.shouldbe where OTHER_ID_NUM_TYPE_4=r.OTHER_ID_TYPE;
		update pre_bulkloader set OTHER_ID_NUM_TYPE_5=r.shouldbe where OTHER_ID_NUM_TYPE_5=r.OTHER_ID_TYPE;
	end loop;
end;
/

----------------------- dates -----------------------------------------



drop table pre_bulk_date;

create table pre_bulk_date as select d adate from (
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
) where d is not null group by d;


delete from pre_bulk_date where is_iso8601(adate)='valid';


select * from pre_bulk_date;

alter table pre_bulk_date add shouldbe VARCHAR2(255);

--ONLY run this for what is apprently m/d/y format eg 1/19/2001

update pre_bulk_date set shouldbe=null;

declare
	v_tab parse_list.varchar2_table;
	v_nfields integer;
	o varchar(20);
	d varchar(20);
	m varchar(20);
	y varchar(20);
	id varchar(20);
begin
	for r in (select adate from pre_bulk_date ) loop
		d:=NULL;
		m:=NULL;
		y:=NULL;
		o:=trim(r.adate);
		dbms_output.put_line(o);
		parse_list.delimstring_to_table (o, v_tab, v_nfields,'/');
		for i in 1..v_nfields loop
			dbms_output.put_line(i || '--> ' || v_tab(i));
	        if i=1 then
	        	m:=lpad(v_tab(i),2,0);
	        elsif i=2 then
	        	d:=lpad(v_tab(i),2,0);
	        elsif i=3 then
	        	y:=v_tab(i);
	        end if;
		end loop;
		dbms_output.put_line('d=' || d);
		dbms_output.put_line('m=' || m);
		dbms_output.put_line('y=' || y);
		id:=y || '-' || m || '-' || d;
		
	        dbms_output.put_line('id=' || id);
		if is_iso8601(id) ='valid' then
			dbms_output.put_line('isdate');
			update pre_bulk_date set shouldbe=id where adate=r.adate;
		end if;
	
	end loop;
end;
/


select adate || '---->' || shouldbe from pre_bulk_date order by adate;
select adate || '---->' || shouldbe from pre_bulk_date where shouldbe is null order by adate;

delete from pre_bulk_date where shouldbe is null;

update pre_bulk_date set shouldbe='xxxxxx' where adate='xxxxxx';



	
CREATE OR REPLACE PROCEDURE temp_update_junk IS
	begin
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
end;
/



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

begin
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
end;
/

		

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
