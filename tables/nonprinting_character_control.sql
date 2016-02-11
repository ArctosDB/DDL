-- find stuff


select constraint_name,search_condition from all_constraints where table_name='TTAAABLLEE' and constraint_type='C';

declare 
	s varchar2(4000);
begin
	for t in (select table_name from nonprinting group by table_name order by table_name) loop
		dbms_output.put_line('');
		s:='LOCK TABLE ' || t.table_name || ' IN EXCLUSIVE MODE NOWAIT;';
		dbms_output.put_line(s);
		for r in (select table_name,column_name from nonprinting where table_name=t.table_name group by table_name,column_name) loop
			s:= 'select ' || r.column_name || ', regexp_replace(' || r.column_name || ',''[^[:print:]]'','' '') from ' || r.table_name || ' where regexp_like(' || r.column_name || ',''[^[:print:]]'');' ;


			--dbms_output.put_line(s);


			s:= 'select regexp_replace(' || r.column_name || ',''[^[:print:]]'','' '') from ' || r.table_name || ' where regexp_like(' || r.column_name || ',''[^[:print:]]'');' ;
			--dbms_output.put_line(s);

			s:= 'update ' || r.table_name || ' set ' || r.column_name || '=regexp_replace(' || r.column_name || ',''[^[:print:]]'','' '')  where regexp_like(' || r.column_name || ',''[^[:print:]]'');' ;
			dbms_output.put_line(s);
  			s:='ALTER TABLE ' || r.table_name || ' add CONSTRAINT ck_' || substr(r.column_name,1,27) || '_noprint CHECK (NOT (regexp_like(' || r.column_name || ', ''[^[:print:]]'')));';
			dbms_output.put_line(s);
		end loop;
		dbms_output.put_line('commit;');
	end loop;
end;
/


select regexp_replace(NATURE_OF_MATERIAL,'[^[:print:]]','[X]') from cf_temp_accn where regexp_like(NATURE_OF_MATERIAL,'[^[:print:]]');



LOCK TABLE ADDR IN EXCLUSIVE MODE NOWAIT;
update ADDR set DEPARTMENT=regexp_replace(DEPARTMENT,'[^[:print:]]',' ')  where regexp_like(DEPARTMENT,'[^[:print:]]');
ALTER TABLE ADDR add CONSTRAINT ck_DEPARTMENT_noprint CHECK (NOT (regexp_like(DEPARTMENT, '[^[:print:]]')));
update ADDR set STREET_ADDR1=regexp_replace(STREET_ADDR1,'[^[:print:]]',' ')  where regexp_like(STREET_ADDR1,'[^[:print:]]');
ALTER TABLE ADDR add CONSTRAINT ck_STREET_ADDR1_noprint CHECK (NOT (regexp_like(STREET_ADDR1, '[^[:print:]]')));
update ADDR set INSTITUTION=regexp_replace(INSTITUTION,'[^[:print:]]',' ')  where regexp_like(INSTITUTION,'[^[:print:]]');
ALTER TABLE ADDR add CONSTRAINT ck_INSTITUTION_noprint CHECK (NOT (regexp_like(INSTITUTION, '[^[:print:]]')));
commit;

LOCK TABLE AGENT IN EXCLUSIVE MODE NOWAIT;
update AGENT set AGENT_REMARKS=regexp_replace(AGENT_REMARKS,'[^[:print:]]',' ')  where regexp_like(AGENT_REMARKS,'[^[:print:]]');
ALTER TABLE AGENT add CONSTRAINT ck_AGENT_REMARKS_noprint CHECK (NOT (regexp_like(AGENT_REMARKS, '[^[:print:]]')));
commit;

LOCK TABLE ANNOTATIONS IN EXCLUSIVE MODE NOWAIT;
update ANNOTATIONS set ANNOTATION=regexp_replace(ANNOTATION,'[^[:print:]]',' ')  where regexp_like(ANNOTATION,'[^[:print:]]');
ALTER TABLE ANNOTATIONS add CONSTRAINT ck_ANNOTATION_noprint CHECK (NOT (regexp_like(ANNOTATION, '[^[:print:]]')));
update ANNOTATIONS set REVIEWER_COMMENT=regexp_replace(REVIEWER_COMMENT,'[^[:print:]]',' ')  where regexp_like(REVIEWER_COMMENT,'[^[:print:]]');
ALTER TABLE ANNOTATIONS add CONSTRAINT ck_REVIEWER_COMMENT_noprint CHECK (NOT (regexp_like(REVIEWER_COMMENT, '[^[:print:]]')));
commit;
-- done

LOCK TABLE ATTRIBUTES IN EXCLUSIVE MODE NOWAIT;
update ATTRIBUTES set ATTRIBUTE_VALUE=regexp_replace(ATTRIBUTE_VALUE,'[^[:print:]]',' ')  where regexp_like(ATTRIBUTE_VALUE,'[^[:print:]]');
ALTER TABLE ATTRIBUTES add CONSTRAINT ck_ATTRIBUTE_VALUE_noprint CHECK (NOT (regexp_like(ATTRIBUTE_VALUE, '[^[:print:]]')));
commit;




LOCK TABLE COLLECTING_EVENT IN EXCLUSIVE MODE NOWAIT;
update COLLECTING_EVENT set COLL_EVENT_REMARKS=regexp_replace(COLL_EVENT_REMARKS,'[^[:print:]]',' ')  where regexp_like(COLL_EVENT_REMARKS,'[^[:print:]]');
ALTER TABLE COLLECTING_EVENT add CONSTRAINT ck_COLL_EVENT_REMARKS_noprint CHECK (NOT (regexp_like(COLL_EVENT_REMARKS, '[^[:print:]]')));
update COLLECTING_EVENT set VERBATIM_LOCALITY=regexp_replace(VERBATIM_LOCALITY,'[^[:print:]]',' ')  where regexp_like(VERBATIM_LOCALITY,'[^[:print:]]');
ALTER TABLE COLLECTING_EVENT add CONSTRAINT ck_VERBATIM_LOCALITY_noprint CHECK (NOT (regexp_like(VERBATIM_LOCALITY, '[^[:print:]]')));
update COLLECTING_EVENT set VERBATIM_DATE=regexp_replace(VERBATIM_DATE,'[^[:print:]]',' ')  where regexp_like(VERBATIM_DATE,'[^[:print:]]');
ALTER TABLE COLLECTING_EVENT add CONSTRAINT ck_VERBATIM_DATE_noprint CHECK (NOT (regexp_like(VERBATIM_DATE, '[^[:print:]]')));
commit;



LOCK TABLE COLLECTION IN EXCLUSIVE MODE NOWAIT;
update COLLECTION set DESCR=regexp_replace(DESCR,'[^[:print:]]',' ')  where regexp_like(DESCR,'[^[:print:]]');
ALTER TABLE COLLECTION add CONSTRAINT ck_DESCR_noprint CHECK (NOT (regexp_like(DESCR, '[^[:print:]]')));
commit;


LOCK TABLE COLL_OBJECT IN EXCLUSIVE MODE NOWAIT;
update COLL_OBJECT set CONDITION=regexp_replace(CONDITION,'[^[:print:]]',' ')  where regexp_like(CONDITION,'[^[:print:]]');
ALTER TABLE COLL_OBJECT add CONSTRAINT ck_CONDITION_noprint CHECK (NOT (regexp_like(CONDITION, '[^[:print:]]')));
commit;



LOCK TABLE COLL_OBJECT_REMARK IN EXCLUSIVE MODE NOWAIT;
update COLL_OBJECT_REMARK set ASSOCIATED_SPECIES=regexp_replace(ASSOCIATED_SPECIES,'[^[:print:]]',' ')	where regexp_like(ASSOCIATED_SPECIES,'[^[:print:]]');
ALTER TABLE COLL_OBJECT_REMARK add CONSTRAINT ck_ASSOCIATED_SPECIES_noprint CHECK (NOT (regexp_like(ASSOCIATED_SPECIES, '[^[:print:]]')));
update COLL_OBJECT_REMARK set HABITAT=regexp_replace(HABITAT,'[^[:print:]]',' ')  where regexp_like(HABITAT,'[^[:print:]]');
ALTER TABLE COLL_OBJECT_REMARK add CONSTRAINT ck_HABITAT_noprint CHECK (NOT (regexp_like(HABITAT, '[^[:print:]]')));
update COLL_OBJECT_REMARK set COLL_OBJECT_REMARKS=regexp_replace(COLL_OBJECT_REMARKS,'[^[:print:]]',' ')  where regexp_like(COLL_OBJECT_REMARKS,'[^[:print:]]');
ALTER TABLE COLL_OBJECT_REMARK add CONSTRAINT ck_COLL_OBJECT_REMARKS_noprint CHECK (NOT (regexp_like(COLL_OBJECT_REMARKS, '[^[:print:]]')));
update COLL_OBJECT_REMARK set DISPOSITION_REMARKS=regexp_replace(DISPOSITION_REMARKS,'[^[:print:]]',' ')  where regexp_like(DISPOSITION_REMARKS,'[^[:print:]]');
ALTER TABLE COLL_OBJECT_REMARK add CONSTRAINT ck_DISPOSITION_REMARKS_noprint CHECK (NOT (regexp_like(DISPOSITION_REMARKS, '[^[:print:]]')));
commit;


LOCK TABLE COMMON_NAME IN EXCLUSIVE MODE NOWAIT;
update COMMON_NAME set COMMON_NAME=regexp_replace(COMMON_NAME,'[^[:print:]]',' ')  where regexp_like(COMMON_NAME,'[^[:print:]]');
ALTER TABLE COMMON_NAME add CONSTRAINT ck_COMMON_NAME_noprint CHECK (NOT (regexp_like(COMMON_NAME, '[^[:print:]]')));
commit;



LOCK TABLE CONTAINER IN EXCLUSIVE MODE NOWAIT;
update CONTAINER set CONTAINER_REMARKS=regexp_replace(CONTAINER_REMARKS,'[^[:print:]]',' ')  where regexp_like(CONTAINER_REMARKS,'[^[:print:]]');
ALTER TABLE CONTAINER add CONSTRAINT ck_CONTAINER_REMARKS_noprint CHECK (NOT (regexp_like(CONTAINER_REMARKS, '[^[:print:]]')));
update CONTAINER set DESCRIPTION=regexp_replace(DESCRIPTION,'[^[:print:]]',' ')  where regexp_like(DESCRIPTION,'[^[:print:]]');
ALTER TABLE CONTAINER add CONSTRAINT ck_DESCRIPTION_noprint CHECK (NOT (regexp_like(DESCRIPTION, '[^[:print:]]')));
update CONTAINER set BARCODE=regexp_replace(BARCODE,'[^[:print:]]',' ')  where regexp_like(BARCODE,'[^[:print:]]');
ALTER TABLE CONTAINER add CONSTRAINT ck_BARCODE_noprint CHECK (NOT (regexp_like(BARCODE, '[^[:print:]]')));
update CONTAINER set LABEL=regexp_replace(LABEL,'[^[:print:]]',' ')  where regexp_like(LABEL,'[^[:print:]]');
ALTER TABLE CONTAINER add CONSTRAINT ck_LABEL_noprint CHECK (NOT (regexp_like(LABEL, '[^[:print:]]')));
commit;



LOCK TABLE IDENTIFICATION IN EXCLUSIVE MODE NOWAIT;
update IDENTIFICATION set IDENTIFICATION_REMARKS=regexp_replace(IDENTIFICATION_REMARKS,'[^[:print:]]',' ')  where regexp_like(IDENTIFICATION_REMARKS,'[^[:print:]]');
ALTER TABLE IDENTIFICATION add CONSTRAINT ck_ID_REMARKS_noprint CHECK (NOT (regexp_like(IDENTIFICATION_REMARKS, '[^[:print:]]')));
commit;



LOCK TABLE LOAN IN EXCLUSIVE MODE NOWAIT;
update LOAN set LOAN_DESCRIPTION=regexp_replace(LOAN_DESCRIPTION,'[^[:print:]]',' ')  where regexp_like(LOAN_DESCRIPTION,'[^[:print:]]');
ALTER TABLE LOAN add CONSTRAINT ck_LOAN_DESCRIPTION_noprint CHECK (NOT (regexp_like(LOAN_DESCRIPTION, '[^[:print:]]')));
update LOAN set LOAN_INSTRUCTIONS=regexp_replace(LOAN_INSTRUCTIONS,'[^[:print:]]',' ')	where regexp_like(LOAN_INSTRUCTIONS,'[^[:print:]]');
ALTER TABLE LOAN add CONSTRAINT ck_LOAN_INSTRUCTIONS_noprint CHECK (NOT (regexp_like(LOAN_INSTRUCTIONS, '[^[:print:]]')));
commit;


LOCK TABLE LOAN_ITEM IN EXCLUSIVE MODE NOWAIT;
update LOAN_ITEM set LOAN_ITEM_REMARKS=regexp_replace(LOAN_ITEM_REMARKS,'[^[:print:]]',' ')  where regexp_like(LOAN_ITEM_REMARKS,'[^[:print:]]');
ALTER TABLE LOAN_ITEM add CONSTRAINT ck_LOAN_ITEM_REMARKS_noprint CHECK (NOT (regexp_like(LOAN_ITEM_REMARKS, '[^[:print:]]')));
update LOAN_ITEM set ITEM_INSTRUCTIONS=regexp_replace(ITEM_INSTRUCTIONS,'[^[:print:]]',' ')  where regexp_like(ITEM_INSTRUCTIONS,'[^[:print:]]');
ALTER TABLE LOAN_ITEM add CONSTRAINT ck_ITEM_INSTRUCTIONS_noprint CHECK (NOT (regexp_like(ITEM_INSTRUCTIONS, '[^[:print:]]')));
commit;



LOCK TABLE LOCALITY IN EXCLUSIVE MODE NOWAIT;
update LOCALITY set SPEC_LOCALITY=regexp_replace(SPEC_LOCALITY,'[^[:print:]]',' ')  where regexp_like(SPEC_LOCALITY,'[^[:print:]]');
ALTER TABLE LOCALITY add CONSTRAINT ck_SPEC_LOCALITY_noprint CHECK (NOT (regexp_like(SPEC_LOCALITY, '[^[:print:]]')));
update LOCALITY set GEOREFERENCE_SOURCE=regexp_replace(GEOREFERENCE_SOURCE,'[^[:print:]]',' ')	where regexp_like(GEOREFERENCE_SOURCE,'[^[:print:]]');
ALTER TABLE LOCALITY add CONSTRAINT ck_GEOREFERENCE_SOURCE_noprint CHECK (NOT (regexp_like(GEOREFERENCE_SOURCE, '[^[:print:]]')));
update LOCALITY set LOCALITY_REMARKS=regexp_replace(LOCALITY_REMARKS,'[^[:print:]]',' ')  where regexp_like(LOCALITY_REMARKS,'[^[:print:]]');
ALTER TABLE LOCALITY add CONSTRAINT ck_LOCALITY_REMARKS_noprint CHECK (NOT (regexp_like(LOCALITY_REMARKS, '[^[:print:]]')));
commit;



LOCK TABLE PROJECT IN EXCLUSIVE MODE NOWAIT;
update PROJECT set PROJECT_REMARKS=regexp_replace(PROJECT_REMARKS,'[^[:print:]]',' ')  where regexp_like(PROJECT_REMARKS,'[^[:print:]]');
ALTER TABLE PROJECT add CONSTRAINT ck_PROJECT_REMARKS_noprint CHECK (NOT (regexp_like(PROJECT_REMARKS, '[^[:print:]]')));
update PROJECT set PROJECT_NAME=regexp_replace(PROJECT_NAME,'[^[:print:]]',' ')  where regexp_like(PROJECT_NAME,'[^[:print:]]');
ALTER TABLE PROJECT add CONSTRAINT ck_PROJECT_NAME_noprint CHECK (NOT (regexp_like(PROJECT_NAME, '[^[:print:]]')));
update PROJECT set PROJECT_DESCRIPTION=regexp_replace(PROJECT_DESCRIPTION,'[^[:print:]]',' ')  where regexp_like(PROJECT_DESCRIPTION,'[^[:print:]]');
ALTER TABLE PROJECT add CONSTRAINT ck_PROJECT_DESCRIPTION_noprint CHECK (NOT (regexp_like(PROJECT_DESCRIPTION, '[^[:print:]]')));
commit;



LOCK TABLE PUBLICATION IN EXCLUSIVE MODE NOWAIT;
update PUBLICATION set PUBLICATION_REMARKS=regexp_replace(PUBLICATION_REMARKS,'[^[:print:]]',' ')  where regexp_like(PUBLICATION_REMARKS,'[^[:print:]]');
ALTER TABLE PUBLICATION add CONSTRAINT ck_PUBLICATION_REMARKS_noprint CHECK (NOT (regexp_like(PUBLICATION_REMARKS, '[^[:print:]]')));
update PUBLICATION set PUBLICATION_TITLE=regexp_replace(PUBLICATION_TITLE,'[^[:print:]]',' ')  where regexp_like(PUBLICATION_TITLE,'[^[:print:]]');
ALTER TABLE PUBLICATION add CONSTRAINT ck_PUBLICATION_TITLE_noprint CHECK (NOT (regexp_like(PUBLICATION_TITLE, '[^[:print:]]')));
update PUBLICATION set FULL_CITATION=regexp_replace(FULL_CITATION,'[^[:print:]]',' ')  where regexp_like(FULL_CITATION,'[^[:print:]]');
ALTER TABLE PUBLICATION add CONSTRAINT ck_FULL_CITATION_noprint CHECK (NOT (regexp_like(FULL_CITATION, '[^[:print:]]')));
commit;

LOCK TABLE SPECIMEN_EVENT IN EXCLUSIVE MODE NOWAIT;
update SPECIMEN_EVENT set SPECIMEN_EVENT_REMARK=regexp_replace(SPECIMEN_EVENT_REMARK,'[^[:print:]]',' ')  where regexp_like(SPECIMEN_EVENT_REMARK,'[^[:print:]]');
ALTER TABLE SPECIMEN_EVENT add CONSTRAINT ck_SPEC_EVNT_REMARK_noprint CHECK (NOT (regexp_like(SPECIMEN_EVENT_REMARK, '[^[:print:]]')));
update SPECIMEN_EVENT set COLLECTING_METHOD=regexp_replace(COLLECTING_METHOD,'[^[:print:]]',' ')  where regexp_like(COLLECTING_METHOD,'[^[:print:]]');
ALTER TABLE SPECIMEN_EVENT add CONSTRAINT ck_COLLECTING_METHOD_noprint CHECK (NOT (regexp_like(COLLECTING_METHOD, '[^[:print:]]')));
update SPECIMEN_EVENT set HABITAT=regexp_replace(HABITAT,'[^[:print:]]',' ')  where regexp_like(HABITAT,'[^[:print:]]');
ALTER TABLE SPECIMEN_EVENT add CONSTRAINT ck_SE_HABITAT_noprint CHECK (NOT (regexp_like(HABITAT, '[^[:print:]]')));
commit;

LOCK TABLE TAXONOMY IN EXCLUSIVE MODE NOWAIT;
update TAXONOMY set AUTHOR_TEXT=regexp_replace(AUTHOR_TEXT,'[^[:print:]]',' ')	where regexp_like(AUTHOR_TEXT,'[^[:print:]]');
ALTER TABLE TAXONOMY add CONSTRAINT ck_AUTHOR_TEXT_noprint CHECK (NOT (regexp_like(AUTHOR_TEXT, '[^[:print:]]')));
update TAXONOMY set TAXON_REMARKS=regexp_replace(TAXON_REMARKS,'[^[:print:]]',' ')  where regexp_like(TAXON_REMARKS,'[^[:print:]]');
ALTER TABLE TAXONOMY add CONSTRAINT ck_TAXON_REMARKS_noprint CHECK (NOT (regexp_like(TAXON_REMARKS, '[^[:print:]]')));
update TAXONOMY set DISPLAY_NAME=regexp_replace(DISPLAY_NAME,'[^[:print:]]',' ')  where regexp_like(DISPLAY_NAME,'[^[:print:]]');
ALTER TABLE TAXONOMY add CONSTRAINT ck_DISPLAY_NAME_noprint CHECK (NOT (regexp_like(DISPLAY_NAME, '[^[:print:]]')));
commit;

-- done


LOCK TABLE TRANS IN EXCLUSIVE MODE NOWAIT;
update TRANS set TRANS_REMARKS=regexp_replace(TRANS_REMARKS,'[^[:print:]]',' ')  where regexp_like(TRANS_REMARKS,'[^[:print:]]');
ALTER TABLE TRANS add CONSTRAINT ck_TRANS_REMARKS_noprint CHECK (NOT (regexp_like(TRANS_REMARKS, '[^[:print:]]')));
update TRANS set NATURE_OF_MATERIAL=regexp_replace(NATURE_OF_MATERIAL,'[^[:print:]]',' ')  where regexp_like(NATURE_OF_MATERIAL,'[^[:print:]]');
ALTER TABLE TRANS add CONSTRAINT ck_NATURE_OF_MATERIAL_noprint CHECK (NOT (regexp_like(NATURE_OF_MATERIAL, '[^[:print:]]')));
commit;




LOCK TABLE BULKLOADER IN EXCLUSIVE MODE NOWAIT;
update BULKLOADER set COLL_OBJECT_REMARKS=regexp_replace(COLL_OBJECT_REMARKS,'[^[:print:]]',' ')  where regexp_like(COLL_OBJECT_REMARKS,'[^[:print:]]');
ALTER TABLE BULKLOADER add CONSTRAINT ck_BLCOLL_OBJ_REMARKS_noprint CHECK (NOT (regexp_like(COLL_OBJECT_REMARKS, '[^[:print:]]')));
update BULKLOADER set LOADED=regexp_replace(LOADED,'[^[:print:]]',' ')	where regexp_like(LOADED,'[^[:print:]]');
ALTER TABLE BULKLOADER add CONSTRAINT ck_LOADED_noprint CHECK (NOT (regexp_like(LOADED, '[^[:print:]]')));
update BULKLOADER set PART_BARCODE_1=regexp_replace(PART_BARCODE_1,'[^[:print:]]',' ')	where regexp_like(PART_BARCODE_1,'[^[:print:]]');
ALTER TABLE BULKLOADER add CONSTRAINT ck_PART_BARCODE_1_noprint CHECK (NOT (regexp_like(PART_BARCODE_1, '[^[:print:]]')));
update BULKLOADER set COLLECTING_METHOD=regexp_replace(COLLECTING_METHOD,'[^[:print:]]',' ')  where regexp_like(COLLECTING_METHOD,'[^[:print:]]');
ALTER TABLE BULKLOADER add CONSTRAINT ck_BL_COLLING_METHOD_noprint CHECK (NOT (regexp_like(COLLECTING_METHOD, '[^[:print:]]')));
update BULKLOADER set PART_REMARK_2=regexp_replace(PART_REMARK_2,'[^[:print:]]',' ')  where regexp_like(PART_REMARK_2,'[^[:print:]]');
ALTER TABLE BULKLOADER add CONSTRAINT ck_PART_REMARK_2_noprint CHECK (NOT (regexp_like(PART_REMARK_2, '[^[:print:]]')));





VERBATIM_DATE


IDENTIFICATION_REMARKS





UAM@ARCTEST> desc bulkloader
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 COLLECTION_OBJECT_ID						   NOT NULL NUMBER
 LOADED 								    VARCHAR2(4000)
 ENTEREDBY								    VARCHAR2(255)
 CAT_NUM								    VARCHAR2(20)
 OTHER_ID_NUM_5 							    VARCHAR2(255)
 OTHER_ID_NUM_TYPE_5							    VARCHAR2(255)
 OTHER_ID_NUM_1 							    VARCHAR2(255)
 OTHER_ID_NUM_TYPE_1							    VARCHAR2(255)
 ACCN									    VARCHAR2(60)
 TAXON_NAME								    VARCHAR2(255)
 NATURE_OF_ID								    VARCHAR2(255)
 ID_MADE_BY_AGENT							    VARCHAR2(255)
 MADE_DATE								    VARCHAR2(20)
 IDENTIFICATION_REMARKS 						    VARCHAR2(4000)
 								    VARCHAR2(4000)
 BEGAN_DATE								    VARCHAR2(20)
 ENDED_DATE								    VARCHAR2(20)
 HIGHER_GEOG								    VARCHAR2(255)
 SPEC_LOCALITY								    VARCHAR2(255)
 VERBATIM_LOCALITY							    VARCHAR2(4000)
 ORIG_LAT_LONG_UNITS							    VARCHAR2(255)
 DEC_LAT								    VARCHAR2(255)
 DEC_LONG								    VARCHAR2(255)
 LATDEG 								    VARCHAR2(20)
 DEC_LAT_MIN								    VARCHAR2(255)
 LATMIN 								    VARCHAR2(255)
 LATSEC 								    VARCHAR2(255)
 LATDIR 								    VARCHAR2(50)
 LONGDEG								    VARCHAR2(20)
 DEC_LONG_MIN								    VARCHAR2(255)
 LONGMIN								    VARCHAR2(255)
 LONGSEC								    VARCHAR2(255)
 LONGDIR								    VARCHAR2(50)
 DATUM									    VARCHAR2(255)
 GEOREFERENCE_SOURCE							    VARCHAR2(255)
 MAX_ERROR_DISTANCE							    VARCHAR2(255)
 MAX_ERROR_UNITS							    VARCHAR2(255)
 GEOREFERENCE_PROTOCOL							    VARCHAR2(255)
 EVENT_ASSIGNED_BY_AGENT						    VARCHAR2(255)
 EVENT_ASSIGNED_DATE							    VARCHAR2(20)
 VERIFICATIONSTATUS							    VARCHAR2(255)
 MAXIMUM_ELEVATION							    VARCHAR2(20)
 MINIMUM_ELEVATION							    VARCHAR2(20)
 ORIG_ELEV_UNITS							    VARCHAR2(255)
 LOCALITY_REMARKS							    VARCHAR2(4000)
 HABITAT								    VARCHAR2(4000)
 COLL_EVENT_REMARKS							    VARCHAR2(4000)
 COLLECTOR_AGENT_1							    VARCHAR2(255)
 COLLECTOR_ROLE_1							    VARCHAR2(255)
 COLLECTOR_AGENT_2							    VARCHAR2(255)
 COLLECTOR_ROLE_2							    VARCHAR2(255)
 COLLECTOR_AGENT_3							    VARCHAR2(255)
 COLLECTOR_ROLE_3							    VARCHAR2(255)
 COLLECTOR_AGENT_4							    VARCHAR2(255)
 COLLECTOR_ROLE_4							    VARCHAR2(50)
 COLLECTOR_AGENT_5							    VARCHAR2(255)
 COLLECTOR_ROLE_5							    VARCHAR2(255)
 COLLECTOR_AGENT_6							    VARCHAR2(255)
 COLLECTOR_ROLE_6							    VARCHAR2(255)
 COLLECTOR_AGENT_7							    VARCHAR2(255)
 COLLECTOR_ROLE_7							    VARCHAR2(255)
 COLLECTOR_AGENT_8							    VARCHAR2(255)
 COLLECTOR_ROLE_8							    VARCHAR2(255)
 GUID_PREFIX								    VARCHAR2(40)
 FLAGS									    VARCHAR2(20)
 COLL_OBJECT_REMARKS							    VARCHAR2(4000)
 OTHER_ID_NUM_2 							    VARCHAR2(255)
 OTHER_ID_NUM_TYPE_2							    VARCHAR2(255)
 OTHER_ID_NUM_3 							    VARCHAR2(255)
 OTHER_ID_NUM_TYPE_3							    VARCHAR2(255)
 OTHER_ID_NUM_4 							    VARCHAR2(255)
 OTHER_ID_NUM_TYPE_4							    VARCHAR2(255)
 PART_NAME_1								    VARCHAR2(255)
 PART_CONDITION_1							    VARCHAR2(255)
 PART_BARCODE_1 							    VARCHAR2(50)
 PART_CONTAINER_LABEL_1 						    VARCHAR2(50)
 PART_LOT_COUNT_1							    VARCHAR2(5)
 PART_DISPOSITION_1							    VARCHAR2(255)
 PART_REMARK_1								    VARCHAR2(4000)
 PART_NAME_2								    VARCHAR2(255)
 PART_CONDITION_2							    VARCHAR2(255)
 PART_BARCODE_2 							    VARCHAR2(50)
 PART_CONTAINER_LABEL_2 						    VARCHAR2(50)
 PART_LOT_COUNT_2							    VARCHAR2(5)
 PART_DISPOSITION_2							    VARCHAR2(255)
 PART_REMARK_2								    VARCHAR2(255)
 PART_NAME_3								    VARCHAR2(255)
 PART_CONDITION_3							    VARCHAR2(255)
 PART_BARCODE_3 							    VARCHAR2(50)
 PART_CONTAINER_LABEL_3 						    VARCHAR2(50)
 PART_LOT_COUNT_3							    VARCHAR2(2)
 PART_DISPOSITION_3							    VARCHAR2(255)
 PART_REMARK_3								    VARCHAR2(255)
 PART_NAME_4								    VARCHAR2(255)
 PART_CONDITION_4							    VARCHAR2(255)
 PART_BARCODE_4 							    VARCHAR2(50)
 PART_CONTAINER_LABEL_4 						    VARCHAR2(50)
 PART_LOT_COUNT_4							    VARCHAR2(2)
 PART_DISPOSITION_4							    VARCHAR2(255)
 PART_REMARK_4								    VARCHAR2(255)
 PART_NAME_5								    VARCHAR2(255)
 PART_CONDITION_5							    VARCHAR2(255)
 PART_BARCODE_5 							    VARCHAR2(50)
 PART_CONTAINER_LABEL_5 						    VARCHAR2(50)
 PART_LOT_COUNT_5							    VARCHAR2(2)
 PART_DISPOSITION_5							    VARCHAR2(255)
 PART_REMARK_5								    VARCHAR2(255)
 PART_NAME_6								    VARCHAR2(255)
 PART_CONDITION_6							    VARCHAR2(255)
 PART_BARCODE_6 							    VARCHAR2(50)
 PART_CONTAINER_LABEL_6 						    VARCHAR2(50)
 PART_LOT_COUNT_6							    VARCHAR2(2)
 PART_DISPOSITION_6							    VARCHAR2(255)
 PART_REMARK_6								    VARCHAR2(255)
 PART_NAME_7								    VARCHAR2(255)
 PART_CONDITION_7							    VARCHAR2(255)
 PART_BARCODE_7 							    VARCHAR2(50)
 PART_CONTAINER_LABEL_7 						    VARCHAR2(50)
 PART_LOT_COUNT_7							    VARCHAR2(2)
 PART_DISPOSITION_7							    VARCHAR2(255)
 PART_REMARK_7								    VARCHAR2(255)
 PART_NAME_8								    VARCHAR2(255)
 PART_CONDITION_8							    VARCHAR2(255)
 PART_BARCODE_8 							    VARCHAR2(50)
 PART_CONTAINER_LABEL_8 						    VARCHAR2(50)
 PART_LOT_COUNT_8							    VARCHAR2(2)
 PART_DISPOSITION_8							    VARCHAR2(255)
 PART_REMARK_8								    VARCHAR2(255)
 PART_NAME_9								    VARCHAR2(255)
 PART_CONDITION_9							    VARCHAR2(255)
 PART_BARCODE_9 							    VARCHAR2(50)
 PART_CONTAINER_LABEL_9 						    VARCHAR2(50)
 PART_LOT_COUNT_9							    VARCHAR2(50)
 PART_DISPOSITION_9							    VARCHAR2(255)
 PART_REMARK_9								    VARCHAR2(255)
 PART_NAME_10								    VARCHAR2(255)
 PART_CONDITION_10							    VARCHAR2(255)
 PART_BARCODE_10							    VARCHAR2(50)
 PART_CONTAINER_LABEL_10						    VARCHAR2(50)
 PART_LOT_COUNT_10							    VARCHAR2(50)
 PART_DISPOSITION_10							    VARCHAR2(255)
 PART_REMARK_10 							    VARCHAR2(255)
 PART_NAME_11								    VARCHAR2(255)
 PART_CONDITION_11							    VARCHAR2(255)
 PART_BARCODE_11							    VARCHAR2(50)
 PART_CONTAINER_LABEL_11						    VARCHAR2(50)
 PART_LOT_COUNT_11							    VARCHAR2(50)
 PART_DISPOSITION_11							    VARCHAR2(255)
 PART_REMARK_11 							    VARCHAR2(255)
 PART_NAME_12								    VARCHAR2(255)
 PART_CONDITION_12							    VARCHAR2(255)
 PART_BARCODE_12							    VARCHAR2(50)
 PART_CONTAINER_LABEL_12						    VARCHAR2(50)
 PART_LOT_COUNT_12							    VARCHAR2(50)
 PART_DISPOSITION_12							    VARCHAR2(255)
 PART_REMARK_12 							    VARCHAR2(255)
 ATTRIBUTE_1								    VARCHAR2(50)
 ATTRIBUTE_VALUE_1							    VARCHAR2(4000)
 ATTRIBUTE_UNITS_1							    VARCHAR2(255)
 ATTRIBUTE_REMARKS_1							    VARCHAR2(255)
 ATTRIBUTE_DATE_1							    VARCHAR2(20)
 ATTRIBUTE_DET_METH_1							    VARCHAR2(255)
 ATTRIBUTE_DETERMINER_1 						    VARCHAR2(255)
 ATTRIBUTE_2								    VARCHAR2(50)
 ATTRIBUTE_VALUE_2							    VARCHAR2(4000)
 ATTRIBUTE_UNITS_2							    VARCHAR2(50)
 ATTRIBUTE_REMARKS_2							    VARCHAR2(255)
 ATTRIBUTE_DATE_2							    VARCHAR2(20)
 ATTRIBUTE_DET_METH_2							    VARCHAR2(255)
 ATTRIBUTE_DETERMINER_2 						    VARCHAR2(255)
 ATTRIBUTE_3								    VARCHAR2(50)
 ATTRIBUTE_VALUE_3							    VARCHAR2(4000)
 ATTRIBUTE_UNITS_3							    VARCHAR2(50)
 ATTRIBUTE_REMARKS_3							    VARCHAR2(255)
 ATTRIBUTE_DATE_3							    VARCHAR2(20)
 ATTRIBUTE_DET_METH_3							    VARCHAR2(50)
 ATTRIBUTE_DETERMINER_3 						    VARCHAR2(255)
 ATTRIBUTE_4								    VARCHAR2(50)
 ATTRIBUTE_VALUE_4							    VARCHAR2(4000)
 ATTRIBUTE_UNITS_4							    VARCHAR2(50)
 ATTRIBUTE_REMARKS_4							    VARCHAR2(255)
 ATTRIBUTE_DATE_4							    VARCHAR2(20)
 ATTRIBUTE_DET_METH_4							    VARCHAR2(50)
 ATTRIBUTE_DETERMINER_4 						    VARCHAR2(255)
 ATTRIBUTE_5								    VARCHAR2(50)
 ATTRIBUTE_VALUE_5							    VARCHAR2(4000)
 ATTRIBUTE_UNITS_5							    VARCHAR2(50)
 ATTRIBUTE_REMARKS_5							    VARCHAR2(255)
 ATTRIBUTE_DATE_5							    VARCHAR2(20)
 ATTRIBUTE_DET_METH_5							    VARCHAR2(50)
 ATTRIBUTE_DETERMINER_5 						    VARCHAR2(255)
 ATTRIBUTE_6								    VARCHAR2(50)
 ATTRIBUTE_VALUE_6							    VARCHAR2(4000)
 ATTRIBUTE_UNITS_6							    VARCHAR2(50)
 ATTRIBUTE_REMARKS_6							    VARCHAR2(4000)
 ATTRIBUTE_DATE_6							    VARCHAR2(20)
 ATTRIBUTE_DET_METH_6							    VARCHAR2(50)
 ATTRIBUTE_DETERMINER_6 						    VARCHAR2(255)
 ATTRIBUTE_7								    VARCHAR2(50)
 ATTRIBUTE_VALUE_7							    VARCHAR2(4000)
 ATTRIBUTE_UNITS_7							    VARCHAR2(50)
 ATTRIBUTE_REMARKS_7							    VARCHAR2(255)
 ATTRIBUTE_DATE_7							    VARCHAR2(20)
 ATTRIBUTE_DET_METH_7							    VARCHAR2(50)
 ATTRIBUTE_DETERMINER_7 						    VARCHAR2(255)
 ATTRIBUTE_8								    VARCHAR2(50)
 ATTRIBUTE_VALUE_8							    VARCHAR2(4000)
 ATTRIBUTE_UNITS_8							    VARCHAR2(50)
 ATTRIBUTE_REMARKS_8							    VARCHAR2(255)
 ATTRIBUTE_DATE_8							    VARCHAR2(20)
 ATTRIBUTE_DET_METH_8							    VARCHAR2(50)
 ATTRIBUTE_DETERMINER_8 						    VARCHAR2(255)
 ATTRIBUTE_9								    VARCHAR2(50)
 ATTRIBUTE_VALUE_9							    VARCHAR2(4000)
 ATTRIBUTE_UNITS_9							    VARCHAR2(50)
 ATTRIBUTE_REMARKS_9							    VARCHAR2(255)
 ATTRIBUTE_DATE_9							    VARCHAR2(50)
 ATTRIBUTE_DET_METH_9							    VARCHAR2(50)
 ATTRIBUTE_DETERMINER_9 						    VARCHAR2(255)
 ATTRIBUTE_10								    VARCHAR2(50)
 ATTRIBUTE_VALUE_10							    VARCHAR2(4000)
 ATTRIBUTE_UNITS_10							    VARCHAR2(50)
 ATTRIBUTE_REMARKS_10							    VARCHAR2(255)
 ATTRIBUTE_DATE_10							    VARCHAR2(50)
 ATTRIBUTE_DET_METH_10							    VARCHAR2(50)
 ATTRIBUTE_DETERMINER_10						    VARCHAR2(255)
 MIN_DEPTH								    VARCHAR2(20)
 MAX_DEPTH								    VARCHAR2(20)
 DEPTH_UNITS								    VARCHAR2(30)
 COLLECTING_METHOD							    VARCHAR2(255)
 COLLECTING_SOURCE							    VARCHAR2(255)
 ASSOCIATED_SPECIES							    VARCHAR2(4000)
 LOCALITY_ID								    VARCHAR2(20)
 UTM_ZONE								    VARCHAR2(3)
 UTM_EW 								    VARCHAR2(60)
 UTM_NS 								    VARCHAR2(60)
 GEOLOGY_ATTRIBUTE_1							    VARCHAR2(255)
 GEO_ATT_VALUE_1							    VARCHAR2(255)
 GEO_ATT_DETERMINER_1							    VARCHAR2(255)
 GEO_ATT_DETERMINED_DATE_1						    VARCHAR2(255)
 GEO_ATT_DETERMINED_METHOD_1						    VARCHAR2(255)
 GEO_ATT_REMARK_1							    VARCHAR2(4000)
 GEOLOGY_ATTRIBUTE_2							    VARCHAR2(255)
 GEO_ATT_VALUE_2							    VARCHAR2(255)
 GEO_ATT_DETERMINER_2							    VARCHAR2(255)
 GEO_ATT_DETERMINED_DATE_2						    VARCHAR2(255)
 GEO_ATT_DETERMINED_METHOD_2						    VARCHAR2(255)
 GEO_ATT_REMARK_2							    VARCHAR2(4000)
 GEOLOGY_ATTRIBUTE_3							    VARCHAR2(255)
 GEO_ATT_VALUE_3							    VARCHAR2(255)
 GEO_ATT_DETERMINER_3							    VARCHAR2(255)
 GEO_ATT_DETERMINED_DATE_3						    VARCHAR2(255)
 GEO_ATT_DETERMINED_METHOD_3						    VARCHAR2(255)
 GEO_ATT_REMARK_3							    VARCHAR2(4000)
 GEOLOGY_ATTRIBUTE_4							    VARCHAR2(255)
 GEO_ATT_VALUE_4							    VARCHAR2(255)
 GEO_ATT_DETERMINER_4							    VARCHAR2(255)
 GEO_ATT_DETERMINED_DATE_4						    VARCHAR2(255)
 GEO_ATT_DETERMINED_METHOD_4						    VARCHAR2(255)
 GEO_ATT_REMARK_4							    VARCHAR2(4000)
 GEOLOGY_ATTRIBUTE_5							    VARCHAR2(255)
 GEO_ATT_VALUE_5							    VARCHAR2(255)
 GEO_ATT_DETERMINER_5							    VARCHAR2(255)
 GEO_ATT_DETERMINED_DATE_5						    VARCHAR2(255)
 GEO_ATT_DETERMINED_METHOD_5						    VARCHAR2(255)
 GEO_ATT_REMARK_5							    VARCHAR2(4000)
 GEOLOGY_ATTRIBUTE_6							    VARCHAR2(255)
 GEO_ATT_VALUE_6							    VARCHAR2(255)
 GEO_ATT_DETERMINER_6							    VARCHAR2(255)
 GEO_ATT_DETERMINED_DATE_6						    VARCHAR2(255)
 GEO_ATT_DETERMINED_METHOD_6						    VARCHAR2(255)
 GEO_ATT_REMARK_6							    VARCHAR2(4000)
 COLLECTING_EVENT_ID							    NUMBER
 COLLECTION_ID							   NOT NULL NUMBER
 ENTERED_AGENT_ID						   NOT NULL NUMBER
 ENTEREDTOBULKDATE							    TIMESTAMP(6)
 SPECIMEN_EVENT_REMARK							    VARCHAR2(255)
 SPECIMEN_EVENT_TYPE							    VARCHAR2(255)
 LOCALITY_NAME								    VARCHAR2(255)
 C$LAT									    NUMBER(12,10)
 C$LONG 								    NUMBER(13,10)
 COLLECTING_EVENT_NAME							    VARCHAR2(255)
 OTHER_ID_REFERENCES_1							    VARCHAR2(255)
 OTHER_ID_REFERENCES_2							    VARCHAR2(255)
 OTHER_ID_REFERENCES_3							    VARCHAR2(255)
 OTHER_ID_REFERENCES_4							    VARCHAR2(255)
 OTHER_ID_REFERENCES_5							    VARCHAR2(255)
 WKT_POLYGON								    CLOB



  3  
C


commit;




