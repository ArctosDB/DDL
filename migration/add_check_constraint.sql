-- ref https://github.com/ArctosDB/arctos/issues/813
-- write check constraints via sql
-- should work anywhere
/*
 * 
  select constraint_name,search_condition from all_constraints where table_name='BULKLOADER' and constraint_type='C';
   select * from all_constraints where table_name='BULKLOADER' and constraint_type='C';
   
   
	select 
		column_name from all_tab_cols where DATA_TYPE='VARCHAR2' and OWNER='UAM' AND table_name='BULKLOADER' 
		and column_name not in (select column_name from DBA_CONS_COLUMNS where table_name='BULKLOADER' and
		constraint_name like '%PRINT%') order by column_name
   
   
   
      select * from DBA_CONS_COLUMNS where table_name='BULKLOADER' and constraint_type='C';
      
      
      
      
      
   

Elapsed: 00:00:00.08
UAM@ARCTEST> desc all_constraints
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 OWNER									    VARCHAR2(30)
 CONSTRAINT_NAME						   NOT NULL VARCHAR2(30)
 CONSTRAINT_TYPE							    VARCHAR2(1)
 TABLE_NAME							   NOT NULL VARCHAR2(30)
 SEARCH_CONDITION							    LONG
 R_OWNER								    VARCHAR2(30)
 R_CONSTRAINT_NAME							    VARCHAR2(30)
 DELETE_RULE								    VARCHAR2(9)
 STATUS 								    VARCHAR2(8)
 DEFERRABLE								    VARCHAR2(14)
 DEFERRED								    VARCHAR2(9)
 VALIDATED								    VARCHAR2(13)
 GENERATED								    VARCHAR2(14)
 BAD									    VARCHAR2(3)
 RELY									    VARCHAR2(4)
 LAST_CHANGE								    DATE
 INDEX_OWNER								    VARCHAR2(30)
 INDEX_NAME								    VARCHAR2(30)
 INVALID								    VARCHAR2(7)
 VIEW_RELATED								    VARCHAR2(14)

UAM@ARCTEST> 

 */

-- oh messy people....

select distinct attribute_value_4, regexp_replace(attribute_value_4,'[^[:print:]]','[X]')  from bulkloader where regexp_like(attribute_value_4,'[^[:print:]]');
update bulkloader set attribute_value_4=regexp_replace(attribute_value_4,'[^[:print:]]','') where regexp_like(attribute_value_4,'[^[:print:]]');


select distinct attribute_value_7, regexp_replace(attribute_value_7,'[^[:print:]]','[X]')  from bulkloader where regexp_like(attribute_value_7,'[^[:print:]]');
update bulkloader set attribute_value_7=regexp_replace(attribute_value_7,'[^[:print:]]','') where regexp_like(attribute_value_7,'[^[:print:]]');

select distinct LOADED, regexp_replace(LOADED,'[^[:print:]]','[X]')  from bulkloader where regexp_like(LOADED,'[^[:print:]]');

select distinct OTHER_ID_NUM_2, regexp_replace(OTHER_ID_NUM_2,'[^[:print:]]','[X]')  from bulkloader where regexp_like(OTHER_ID_NUM_2,'[^[:print:]]');
update bulkloader set OTHER_ID_NUM_2=regexp_replace(OTHER_ID_NUM_2,'[^[:print:]]','') where regexp_like(OTHER_ID_NUM_2,'[^[:print:]]');
  
   
select distinct OTHER_ID_NUM_5, regexp_replace(OTHER_ID_NUM_5,'[^[:print:]]','[X]')  from bulkloader where regexp_like(OTHER_ID_NUM_5,'[^[:print:]]');
update bulkloader set OTHER_ID_NUM_5=regexp_replace(OTHER_ID_NUM_5,'[^[:print:]]','') where regexp_like(OTHER_ID_NUM_5,'[^[:print:]]');


select distinct part_condition_4, regexp_replace(part_condition_4,'[^[:print:]]','[X]')  from bulkloader where regexp_like(part_condition_4,'[^[:print:]]');
update bulkloader set part_condition_4=regexp_replace(part_condition_4,'[^[:print:]]','') where regexp_like(part_condition_4,'[^[:print:]]');

select distinct part_condition_7, regexp_replace(part_condition_7,'[^[:print:]]','[X]')  from bulkloader where regexp_like(part_condition_7,'[^[:print:]]');
update bulkloader set part_condition_7=regexp_replace(part_condition_7,'[^[:print:]]','') where regexp_like(part_condition_7,'[^[:print:]]');

select distinct part_remark_4, regexp_replace(part_remark_4,'[^[:print:]]','[X]')  from bulkloader where regexp_like(part_remark_4,'[^[:print:]]');
update bulkloader set part_remark_4=regexp_replace(part_remark_4,'[^[:print:]]','') where regexp_like(part_remark_4,'[^[:print:]]');

select distinct verbatim_locality, regexp_replace(verbatim_locality,'[^[:print:]]','[X]')  from bulkloader where regexp_like(verbatim_locality,'[^[:print:]]');
update bulkloader set verbatim_locality=regexp_replace(verbatim_locality,'[^[:print:]]','') where regexp_like(verbatim_locality,'[^[:print:]]');



declare 
	s varchar2(4000);
	scn varchar2(60);
begin
	for r in (
		select 
			column_name 
		from 
			all_tab_cols 
		where 
			DATA_TYPE='VARCHAR2' and 
			OWNER='UAM' AND 
			table_name='BULKLOADER' and
			-- exclude these
			column_name not in ('LOADED') and
			-- and exclude stuff that already exists
			column_name not in (
				select column_name from DBA_CONS_COLUMNS where table_name='BULKLOADER' and constraint_name like '%PRINT%'
			) 
		order by 
			column_name
			) LOOP
		-- constraint names must be 30 or fewer characters
		-- pattern is CK_BL_x_noprint
		-- so "column" must be 15 or fewer characters
		scn:=r.column_name;
		
		--DBMS_OUTPUT.PUT_LINE('-------');
		--DBMS_OUTPUT.PUT_LINE(scn);
		if length(scn) > 15 then
			scn:=replace(scn,'DETERMINER','DTR');
			scn:=replace(scn,'DETERMINED','DTD');
			scn:=replace(scn,'GEOLOGY','GEO');
			scn:=replace(scn,'REMARK','RMK');
			scn:=replace(scn,'ATTRIBUTE','ATR');
			scn:=replace(scn,'METHOD','MTD');
			scn:=replace(scn,'COLLECTING','CLG');
			scn:=replace(scn,'REFERENCES','RFS');
			scn:=replace(scn,'DISPOSITION','DSP');
			scn:=replace(scn,'CONTAINER','CTR');
			scn:=replace(scn,'LABEL','LBL');
			scn:=replace(scn,'OTHER','OTR');
			scn:=replace(scn,'COLLECTOR','CLR');
			scn:=replace(scn,'CONDITION','CDN');
			scn:=replace(scn,'COUNT','CT');
			scn:=replace(scn,'VERIFICATIONSTATUS','VRFCATSTS');
			scn:=replace(scn,'VERBATIM','VBTM');
			scn:=replace(scn,'LOCALITY','LOC');
			scn:=replace(scn,'SPECIMEN','SPC');
			scn:=replace(scn,'EVENT','ET');
			scn:=replace(scn,'TYPE','TP');
			scn:=replace(scn,'ORIG_LAT_LONG_UNITS','ORG_LL_UNIT');
			scn:=replace(scn,'MINIMUM','MI');
			scn:=replace(scn,'ELEVATION','EL');
			scn:=replace(scn,'DISTANCE','DST');
			scn:=replace(scn,'MAXIMUM','MA');
			scn:=replace(scn,'IDENTIFICATION','ID');
			scn:=replace(scn,'MADE_BY','BY');
			scn:=replace(scn,'GEO_ATT_','G_A');
			scn:=replace(scn,'ASSOCIATED_SPECIES','ASS_SPCS');
			scn:=replace(scn,'OBJECT','OBJ');
			scn:=replace(scn,'ASSIGNED','ASD');
			scn:=replace(scn,'AGENT','AGT');
			scn:=replace(scn,'_BY_','_');
			scn:=replace(scn,'DATE','DT');
			scn:=replace(scn,'GEOREFERENCE_PROTOCOL','GEO_PRTCL');
			scn:=replace(scn,'GEOREFERENCE_SOURCE','GEO_SRC');
		end if;
		scn:='CK_BL_' || scn || '_noprint';
		
		s:='alter table BULKLOADER add constraint ' || scn;
		s:=s || ' check (NOT (regexp_like(' || R.COLUMN_NAME || ',''[^[:print:]]'')))';

		DBMS_OUTPUT.PUT_LINE(s);
		execute immediate (s);
		DBMS_OUTPUT.PUT_LINE('made it');
	END LOOP;
end ;
/

