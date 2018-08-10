-- temp table to hold a flattened version of Arctos classification/taxonomy data

create table temp_gn_flat_tax (
	classification varchar2(4000),
	author_text varchar2(4000),
	display_name varchar2(4000),
	scientific_name varchar2(4000),
	source_authority varchar2(4000),
	valid_catalog_term_fg varchar2(4000),
	taxon_status varchar2(4000),
	remark varchar2(4000),
	nomenclatural_code varchar2(4000),
	infraspecific_author varchar2(4000),
	superkingdom varchar2(4000),
	kingdom varchar2(4000),
	subkingdom varchar2(4000),
	infrakingdom varchar2(4000),
	superphylum varchar2(4000),
	phylum varchar2(4000),
	subphylum varchar2(4000),
	subdivision varchar2(4000),
	infraphylum varchar2(4000),
	superclass varchar2(4000),
	class varchar2(4000),
	subclass varchar2(4000),
	infraclass varchar2(4000),
	hyperorder varchar2(4000),
	superorder varchar2(4000),
	phyl_order varchar2(4000),
	suborder varchar2(4000),
	infraorder varchar2(4000),
	hyporder varchar2(4000),
	subhyporder varchar2(4000),
	superfamily varchar2(4000),
	family varchar2(4000),
	subfamily varchar2(4000),
	supertribe varchar2(4000),
	tribe varchar2(4000),
	subtribe varchar2(4000),
	genus varchar2(4000),
	subgenus varchar2(4000),
	species varchar2(4000),
	subspecies varchar2(4000),
	forma varchar2(4000),
	variety varchar2(4000)
);

-- procedure to squish

CREATE OR REPLACE procedure temp_get_gn_taxonomy is 
	s varchar2(4000);
	tt varchar2(4000);
	trm varchar2(4000);
   	begin
   		for r in (select * from taxon_name where scientific_name not in (select scientific_name from temp_gn_flat_tax) and rownum<1000) loop
   			insert into temp_gn_flat_tax (scientific_name) values (r.scientific_name);
   			for c in (select distinct taxon_term.TERM,taxon_term.TERM_TYPE,taxon_term.SOURCE from taxon_term,CTTAXONOMY_SOURCE where taxon_term.SOURCE=CTTAXONOMY_SOURCE.source and taxon_term.taxon_name_id=r.taxon_name_id) loop
	   				begin
		   				--dbms_output.put_line(c.TERM);
		   				if c.TERM_TYPE != 'scientific_name' then
			   				if c.TERM_TYPE = 'order' then
			   					tt:='phyl_order';
			   				else
			   					tt:=c.TERM_TYPE;
			   				end if;
			   				trm:=replace(c.term,'''','''''');
		   					--dbms_output.put_line(tt);
			   				s:='update temp_gn_flat_tax set classification=''' || c.source || ''',' || tt || '=''' || trm || ''' where scientific_name=''' || r.scientific_name || '''';
			   				--dbms_output.put_line(s);
			   				execute immediate s;
			   			end if;
			   		exception when others then
			   				dbms_output.put_line(s);
			   		end;
   			end loop;
   		end loop;
   	end;
/
sho err;
 

-- gets slow as it gets big; fix that
create index ix_tmp_gn_t_scinm on temp_gn_flat_tax (scientific_name) tablespace uam_idx_1;


-- run the proc as a job
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_TEMP_get_gn_taxonomy',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_get_gn_taxonomy',
    enabled     => TRUE,
    start_date => systimestamp,
    repeat_interval => 'FREQ=MINUTELY;INTERVAL=1'
  );
END;
/ 


-- wat?
select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION from all_scheduler_jobs where JOB_NAME='J_TEMP_GET_GN_TAXONOMY';

-- all done
exec DBMS_SCHEDULER.DROP_JOB (JOB_NAME => 'J_TEMP_GET_GN_TAXONOMY', FORCE => TRUE);

-- check in
select count(*) from temp_gn_flat_tax;
-- final tally
-- 2451044


-- relationships

create table temp_gn_tax_rel as select
	a.scientific_name,
	b.scientific_name related_name,
	TAXON_RELATIONSHIP,
	RELATION_AUTHORITY
from
	taxon_relations,
	taxon_name a,
	taxon_name b
where
	taxon_relations.TAXON_NAME_ID=a.TAXON_NAME_ID and
	taxon_relations.RELATED_TAXON_NAME_ID=b.TAXON_NAME_ID
;



-- common names

create table temp_gn_tax_comname as select
	scientific_name,
	COMMON_NAME
from
	common_name,
	taxon_name
where
	common_name.taxon_name_id=taxon_name.taxon_name_id
;


-- spool tables to CSV
-- create files and ...
@/usr/local/tmp/ORACSV/a.sql
-- ... to spool to CSV without printing everything to the screen




-- spool classifications
set feedback off
set heading on
set underline off
set colsep ','
set linesize 32767

spool /usr/local/tmp/ORACSV/flat_classification.csv
	

select 
		'"' || classification || '",' ||
		cvsdata(author_text) || ',' ||
		cvsdata(display_name) ||
		',"' || scientific_name || '",' ||
		cvsdata(source_authority) ||
		',"' || valid_catalog_term_fg || '","' ||
		taxon_status || '",' ||
		cvsdata(remark) ||
		',"' || nomenclatural_code || '",' || 
		cvsdata(infraspecific_author)  || ',"' || 
		superkingdom || '","' || 
		subkingdom || '","' || 
		infrakingdom || '","' || 
		superphylum || '","' || 
		phylum || '","' || 
		subphylum || '","' || 
		subdivision || '","' || 
		infraphylum || '","' || 
		superclass || '","' || 
		class || '","' || 
		subclass || '","' || 
		infraclass || '","' || 
		hyperorder || '","' || 
		superorder || '","' || 
		phyl_order || '","' ||
		suborder || '","' ||
		infraorder || '","' ||
		hyporder || '","' ||
		subhyporder || '","' ||
		superfamily || '","' ||
		family || '","' ||
		subfamily || '","' ||
		supertribe || '","' ||
		tribe || '","' ||
		subtribe || '","' ||
		genus || '","' ||
		subgenus || '","' ||
		species || '","' ||
		subspecies || '","' ||
		forma || '","' ||
		variety || '"'
		from  temp_gn_flat_tax ;
		
spool off



-- spool relationships

set feedback off
set heading on
set underline off
set colsep ','
set linesize 32767

spool /usr/local/tmp/ORACSV/flat_relationships.csv
	
select 
		'"' || scientific_name || '","' ||
		related_name || '","' ||
		TAXON_RELATIONSHIP || '",' ||
		cvsdata(RELATION_AUTHORITY)
		from  temp_gn_tax_rel ;
		
spool off

-- spool common names

set feedback off
set heading on
set underline off
set colsep ','
set linesize 32767

spool /usr/local/tmp/ORACSV/flat_common_name.csv
	
select 
		'"' || scientific_name || '","' ||
		COMMON_NAME || '"' 
		from  temp_gn_tax_comname ;
		
spool off
		


-- fetch
scp  usr@url:/usr/local/tmp/ORACSV/flat_classification.zip ./

scp  usr@url:/usr/local/tmp/ORACSV/flat_relationships.csv ./

scp  usr@url:/usr/local/tmp/ORACSV/flat_common_name.csv ./