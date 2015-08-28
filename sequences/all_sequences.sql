drop sequence bulkloader_pkey;
select max(collection_object_id) + 1 from bulkloader;
create sequence bulkloader_pkey start with 56812;
drop public synonym bulkloader_pkey;
create public synonym bulkloader_pkey for bulkloader_pkey;
grant select on bulkloader_pkey to public;


/* 20081013
CREATE SEQUENCE  "UAM"."BOB"  
	START WITH 543; 

CREATE SEQUENCE  "UAM"."PART_HIERARCHY_SEQ"  
	START WITH 201;

CREATE SEQUENCE  "UAM"."BARCODE_VALUES"  
	START WITH 126020;

CREATE SEQUENCE  "UAM"."ENCUMBRANCE_ID"  
	START WITH 430;

CREATE SEQUENCE  "UAM"."TAXNUM"  
	START WITH 1;

CREATE SEQUENCE  "UAM"."SEQCONTAINER_ID"  
	START WITH 151232;

CREATE SEQUENCE  "UAM"."CO"  
	START WITH 508541;

CREATE SEQUENCE  "UAM"."BLONLINE_PKEY"  
	START WITH 181;

CREATE SEQUENCE  "UAM"."BULKLOADER_PKEY"  
	START WITH 68310;

CREATE SEQUENCE  "UAM"."DGR_LOCATOR_SEQ"  
	START WITH 263561;

CREATE SEQUENCE  "UAM"."OBJCONDID"  
	START WITH 2740460;

CREATE SEQUENCE  "UAM"."SEQ_CF_USER_LOAN"  
	START WITH 181;

CREATE SEQUENCE  "UAM"."JUSTNUMBERS"  
	START WITH 881;

CREATE SEQUENCE  "UAM"."DEV_TASK_SEQ"  
	START WITH 221;

CREATE SEQUENCE  "UAM"."SOMERANDOMSEQUENCE"  
	START WITH 288878;

CREATE SEQUENCE  "UAM"."CANNED_ID_SEQ"  
	START WITH 1806;

CREATE SEQUENCE  "UAM"."TOAD_SEQ"  
	START WITH 1;

CREATE SEQUENCE  "UAM"."CF_VERSION_SEQ"  
	START WITH 81;

CREATE SEQUENCE  "UAM"."CF_VERSION_LOG_SEQ"  
	START WITH 61;

CREATE SEQUENCE  "UAM"."LLIDSEQ"  
	START WITH 1146544;

CREATE SEQUENCE  "UAM"."IDENTIFICATION_ID_SEQ"  
	START WITH 835113 NOCACHE;

CREATE SEQUENCE  "UAM"."LOCALITY_ID_SEQ"  
	START WITH 113973;

CREATE SEQUENCE  "UAM"."LAT_LONG_ID_SEQ"  
	START WITH 108651;

CREATE SEQUENCE  "UAM"."PROJECT_SPONSOR_SEQ"  
	START WITH 1;

CREATE SEQUENCE  "UAM"."HIBERNATE_SEQUENCE"  
	START WITH 220761;

CREATE SEQUENCE  "UAM"."SPECIMEN_ANNOTATIONS_SEQ"  
	START WITH 1;

CREATE SEQUENCE  "UAM"."QUERYSTATS_SEQ"  
	START WITH 84188;

CREATE SEQUENCE  "UAM"."SQ_COLL_OBJ_OTHER_ID_NUM_ID"  
	START WITH 2985803;

create or replace trigger tr_coll_obj_other_id_num_sq
before insert on coll_obj_other_id_nuM
for each row
begin
    IF :new.coll_obj_other_id_num_id IS NULL THEN
	    select sq_coll_obj_other_id_num_id.nextval 
	    into :new.coll_obj_other_id_num_id 
	    from dual;
    END IF;
end;


CREATE SEQUENCE  "UAM"."TRANS_AGENT_SEQ"  
	START WITH 45921;

CREATE SEQUENCE  "UAM"."SEQ_GEOLOGY_ATTRIBUTES"  
	START WITH 1;

CREATE SEQUENCE  "UAM"."IDENTIFICATION_AGENT_SEQ"  
	START WITH 760121;

CREATE SEQUENCE  "UAM"."SEQ_MEDIA"  
	START WITH 8525;

CREATE SEQUENCE  "UAM"."SEQ_MEDIA_LABELS"  
	START WITH 25641;

CREATE SEQUENCE  "UAM"."SEQ_MEDIA_RELATIONS"  
	START WITH 17101;

CREATE SEQUENCE  "UAM"."SQ_CITATION_ID"  
	START WITH 2681;

*/


create sequence SQ_ADDR_ID nocache;
create sequence SQ_AGENT_ID nocache;
create sequence SQ_AGENT_NAME_ID nocache;
create sequence SQ_AGENT_RELATIONS_ID nocache;
create sequence SQ_ANNOTATION_ID nocache;
--create sequence SQ_ATTRIBUTE_ID nocache;
create sequence SQ_BIOL_INDIV_RELATIONS_ID nocache;
create sequence SQ_COLLECTING_EVENT_ID nocache;
create sequence SQ_COLLECTION_CONTACT_ID nocache;
create sequence SQ_COLLECTION_ID nocache;
create sequence SQ_COLLECTION_OBJECT_ID nocache;
create sequence SQ_COLLECTOR_ID nocache;
create sequence SQ_COLL_OBJ_CONT_HIST_ID nocache;
create sequence SQ_COLL_OBJ_OTHER_ID_NUM_ID nocache;
create sequence SQ_CONTAINER_CHECK_ID nocache;
create sequence SQ_CONTAINER_HISTORY_ID nocache;
create sequence SQ_CONTAINER_ID nocache;
create sequence SQ_ELECTRONIC_ADDRESS_ID nocache;
create sequence SQ_ENCUMBRANCE_ID nocache;
create sequence SQ_FLUID_CONTAINER_HISTORY_ID nocache;
create sequence SQ_GEOG_AUTH_REC_ID nocache;
create sequence SQ_GEOLOGY_ATTRIBUTE_HIER_ID nocache;
create sequence SQ_GEOLOGY_ATTRIBUTE_ID nocache;
create sequence SQ_GROUP_MEMBER_ID nocache;
create sequence SQ_IDENTIFICATION_AGENT_ID nocache;
--create sequence SQ_IDENTIFICATION_ID nocache;
create sequence SQ_IDENTIFICATION_TAXONOMY_ID nocache;
create sequence SQ_JOURNAL_ID nocache;
create sequence SQ_LAT_LONG_ID nocache;
create sequence SQ_LOCALITY_ID nocache;
create sequence SQ_MEDIA_ID nocache;
create sequence SQ_MEDIA_LABEL_ID nocache;
create sequence SQ_MEDIA_RELATIONS_ID nocache;
create sequence SQ_OBJECT_CONDITION_ID nocache;
create sequence SQ_PAGE_ID nocache;
create sequence SQ_PERMIT_ID nocache;
create sequence SQ_PROJECT_AGENT_ID nocache;
create sequence SQ_PROJECT_ID nocache;
create sequence SQ_PROJECT_PUBLICATION_ID nocache;
create sequence SQ_PROJECT_SPONSOR_ID nocache;
create sequence SQ_PROJECT_TRANS_ID nocache;
create sequence SQ_PUBLICATION_AUTHOR_NAME_ID nocache;
create sequence SQ_PUBLICATION_ID nocache;
create sequence SQ_SHIPMENT_ID nocache;
create sequence SQ_TAXON_NAME_ID nocache;
create sequence SQ_TRANSACTION_ID nocache;
create sequence SQ_TRANS_AGENT_ID nocache;
create sequence SQ_VESSEL_ID nocache;
create sequence SQ_VIEWER_ID nocache;


DROP SEQUENCE SQ_ATTRIBUTE_ID;
drop SEQUENCE SQ_IDENTIFICATION_ID;
drop SEQUENCE SQ_COLLECTION_OBJECT_ID;
drop SEQUENCE SQ_TRANSACTION_ID;
drop SEQUENCE SQ_CONTAINER_ID;
drop SEQUENCE SQ_AGENT_ID;
drop SEQUENCE SQ_AGENT_NAME_ID;
drop SEQUENCE SQ_PUBLICATION_URL_ID;
drop SEQUENCE SQ_PUBLICATION_ID;
drop SEQUENCE SQ_JOURNAL_ID;
drop SEQUENCE SQ_LAT_LONG_ID;
drop SEQUENCE SQ_GEOG_AUTH_REC_ID;
drop SEQUENCE SQ_COLLECTING_EVENT_ID;
drop SEQUENCE SQ_LOCALITY_ID;
drop SEQUENCE SQ_COLLECTION_CONTACT_ID;
drop SEQUENCE SQ_PROJECT_ID;
drop SEQUENCE SQ_ENCUMBRANCE_ID;
drop SEQUENCE SQ_PERMIT_ID;
drop SEQUENCE SQ_TAXON_NAME_ID;

DECLARE mid NUMBER;
BEGIN
    FOR tc IN (
        SELECT ucc.table_name, ucc.column_name 
        FROM user_cons_columns ucc, user_constraints uc
        WHERE ucc.table_name IN (
			'ATTRIBUTES',
			'IDENTIFICATION',
			'COLL_OBJECT',
			'TRANS',
			'CONTAINER',
			'AGENT',
			'AGENT_NAME',
			'PUBLICATION_URL',
			'PUBLICATION',
			'JOURNAL',
			'LAT_LONG',
			'GEOG_AUTH_REC',
			'COLLECTING_EVENT',
			'LOCALITY',
			'COLLECTION_CONTACTS',
			'PROJECT',
			'ENCUMBRANCE',
			'PERMIT',
            'TAXONOMY'
	    )
		AND ucc.constraint_name = uc.constraint_name
        AND uc.constraint_type = 'P'
    ) LOOP
        dbms_output.put_line (tc.table_name);
        
        EXECUTE IMMEDIATE 'select max(' || tc.column_name || ') + 1 from ' || tc.table_name INTO mid;
        dbms_output.put_line (chr(9) || 'select max(' || tc.column_name || ') + 1 from ' || tc.table_name || ' : ' || mid);
       
        EXECUTE IMMEDIATE 'CREATE SEQUENCE SQ_' || tc.column_name || ' nocache start with ' || mid;
        dbms_output.put_line (chr(9) || 'create sequence SQ_' || tc.column_name || 
           ' nocache start with ' || mid);
       
        EXECUTE IMMEDIATE 'create or replace public synonym SQ_' || tc.column_name || ' for SQ_' || tc.column_name;
        dbms_output.put_line (chr(9) || 'create or replace public synonym SQ_' || tc.column_name || 
			' for SQ_' || tc.column_name);
       
        EXECUTE IMMEDIATE 'grant select on SQ_' || tc.column_name || ' to public';
        dbms_output.put_line (chr(9) || 'grant select on SQ_' || tc.column_name || ' to public');
    END LOOP;
END;


SELECT MAX(ATTRIBUTE_ID) FROM ATTRIBUTES;
SELECT MAX(IDENTIFICATION_ID) FROM IDENTIFICATION;
SELECT MAX(COLLECTION_OBJECT_ID) FROM COLL_OBJECT
SELECT MAX(TRANSACTION_ID) FROM TRANS;
SELECT MAX(CONTAINER_ID) FROM CONTAINER;
SELECT MAX(AGENT_ID) FROM AGENT;
SELECT MAX(AGENT_NAME_ID) FROM AGENT_NAME;
SELECT MAX(PUBLICATION_URL_ID) FROM PUBLICATION_URL;
SELECT MAX(PUBLICATION_ID) FROM PUBLICATION;
SELECT MAX(JOURNAL_ID) FROM JOURNAL;
SELECT MAX(LAT_LONG_ID) FROM LAT_LONG;
SELECT MAX(GEOG_AUTH_REC_ID) FROM GEOG_AUTH_REC;
SELECT MAX(COLLECTING_EVENT_ID) FROM COLLECTING_EVENT;
SELECT MAX(LOCALITY_ID) FROM LOCALITY;
SELECT MAX(COLLECTION_CONTACT_ID) FROM COLLECTION_CONTACTS;
SELECT MAX(PROJECT_ID) FROM PROJECT;
SELECT MAX(ENCUMBRANCE_ID) FROM ENCUMBRANCE;
SELECT MAX(PERMIT_ID) FROM PERMIT;
SELECT MAX(TAXON_NAME_ID) FROM TAXONOMY;

CREATE SEQUENCE SQ_ATTRIBUTE_ID NOCACHE START WITH;
CREATE SEQUENCE SQ_IDENTIFICATION_ID NOCACHE start with;
CREATE SEQUENCE SQ_COLLECTION_OBJECT_ID NOCACHE start with;
CREATE SEQUENCE SQ_TRANSACTION_ID NOCACHE start with;
CREATE SEQUENCE SQ_CONTAINER_ID NOCACHE start with;
CREATE SEQUENCE SQ_AGENT_ID NOCACHE start with;
CREATE SEQUENCE SQ_AGENT_NAME_ID NOCACHE start with;
CREATE SEQUENCE SQ_PUBLICATION_URL_ID NOCACHE start with;
CREATE SEQUENCE SQ_PUBLICATION_ID NOCACHE start with;
CREATE SEQUENCE SQ_JOURNAL_ID NOCACHE start with;
CREATE SEQUENCE SQ_LAT_LONG_ID NOCACHE start with;
CREATE SEQUENCE SQ_GEOG_AUTH_REC_ID NOCACHE start with;
CREATE SEQUENCE SQ_COLLECTING_EVENT_ID NOCACHE start with;
CREATE SEQUENCE SQ_LOCALITY_ID NOCACHE start with;
CREATE SEQUENCE SQ_COLLECTION_CONTACT_ID NOCACHE start with;
CREATE SEQUENCE SQ_PROJECT_ID NOCACHE start with;
CREATE SEQUENCE SQ_ENCUMBRANCE_ID NOCACHE start with;
CREATE SEQUENCE SQ_PERMIT_ID NOCACHE start with;
CREATE SEQUENCE SQ_TAXON_NAME_ID NOCACHE start with;
    
CREATE PUBLIC SYNONYM SQ_ATTRIBUTE_ID FOR SQ_ATTRIBUTE_ID;
CREATE PUBLIC SYNONYM SQ_IDENTIFICATION_ID FOR SQ_IDENTIFICATION_ID;
CREATE PUBLIC SYNONYM SQ_COLLECTION_OBJECT_ID FOR SQ_COLLECTION_OBJECT_ID;
CREATE PUBLIC SYNONYM SQ_TRANSACTION_ID FOR SQ_TRANSACTION_ID;
CREATE PUBLIC SYNONYM SQ_CONTAINER_ID FOR SQ_CONTAINER_ID;
CREATE PUBLIC SYNONYM SQ_AGENT_ID FOR SQ_AGENT_ID;
CREATE PUBLIC SYNONYM SQ_AGENT_NAME_ID FOR SQ_AGENT_NAME_ID;
CREATE PUBLIC SYNONYM SQ_PUBLICATION_URL_ID FOR SQ_PUBLICATION_URL_ID;
CREATE PUBLIC SYNONYM SQ_PUBLICATION_ID FOR SQ_PUBLICATION_ID;
CREATE PUBLIC SYNONYM SQ_JOURNAL_ID FOR SQ_JOURNAL_ID;
CREATE PUBLIC SYNONYM SQ_LAT_LONG_ID FOR SQ_LAT_LONG_ID;
CREATE PUBLIC SYNONYM SQ_GEOG_AUTH_REC_ID FOR SQ_GEOG_AUTH_REC_ID;
CREATE PUBLIC SYNONYM SQ_COLLECTING_EVENT_ID FOR SQ_COLLECTING_EVENT_ID;
CREATE PUBLIC SYNONYM SQ_LOCALITY_ID FOR SQ_LOCALITY_ID;
CREATE PUBLIC SYNONYM SQ_COLLECTION_CONTACT_ID FOR SQ_COLLECTION_CONTACT_ID;
CREATE PUBLIC SYNONYM SQ_PROJECT_ID FOR SQ_PROJECT_ID;
CREATE PUBLIC SYNONYM SQ_ENCUMBRANCE_ID FOR SQ_ENCUMBRANCE_ID;
CREATE PUBLIC SYNONYM SQ_PERMIT_ID FOR SQ_PERMIT_ID;
CREATE PUBLIC SYNONYM SQ_TAXON_NAME_ID FOR SQ_TAXON_NAME_ID;

GRANT SELECT ON SQ_ATTRIBUTE_ID TO PUBLIC;
GRANT SELECT ON SQ_IDENTIFICATION_ID TO PUBLIC;
GRANT SELECT ON SQ_COLLECTION_OBJECT_ID TO PUBLIC;
GRANT SELECT ON SQ_TRANSACTION_ID TO PUBLIC;
GRANT SELECT ON SQ_ADDR_ID TO PUBLIC;
GRANT SELECT ON SQ_AGENT_ID TO PUBLIC;
GRANT SELECT ON SQ_AGENT_NAME_ID TO PUBLIC;
GRANT SELECT ON SQ_PUBLICATION_URL_ID TO PUBLIC;
GRANT SELECT ON SQ_PUBLICATION_ID TO PUBLIC;
GRANT SELECT ON SQ_JOURNAL_ID TO PUBLIC;
GRANT SELECT ON SQ_LAT_LONG_ID TO PUBLIC;
GRANT SELECT ON SQ_GEOG_AUTH_REC_ID TO PUBLIC;
GRANT SELECT ON SQ_COLLECTING_EVENT_ID TO PUBLIC;
GRANT SELECT ON SQ_LOCALITY_ID TO PUBLIC;
GRANT SELECT ON SQ_COLLECTION_CONTACT_ID TO PUBLIC;
GRANT SELECT ON SQ_PROJECT_ID TO PUBLIC;
GRANT SELECT ON SQ_ENCUMBRANCE_ID TO PUBLIC;
GRANT SELECT ON SQ_PERMIT_ID TO PUBLIC;
GRANT SELECT ON SQ_TAXON_NAME_ID TO PUBLIC;
    
    
    
ADDR    create sequence SQ_ADDR_ID nocache;
AGENT   create sequence SQ_AGENT_ID nocache;
AGENT_NAME      create sequence SQ_AGENT_NAME_ID nocache;
SPECIMEN_ANNOTATIONS    create sequence SQ_ANNOTATION_ID nocache;
ATTRIBUTES      create sequence SQ_ATTRIBUTE_ID nocache;
CF_SPEC_RES_COLS        create sequence SQ_CF_SPEC_RES_COLS_ID nocache;
COLLECTING_EVENT        create sequence SQ_COLLECTING_EVENT_ID nocache;
COLLECTION_CONTACTS     create sequence SQ_COLLECTION_CONTACT_ID nocache;
COLLECTION      create sequence SQ_COLLECTION_ID nocache;

create sequence SQ_COLLECTION_OBJECT_ID nocache;
BINARY_OBJECT
CATALOGED_ITEM
CITATION
COLL_OBJECT
--COLL_OBJECT_ENCUMBRANCE create sequence SQ_COLLECTION_OBJECT_ID nocache;
--COLL_OBJECT_REMARK      create sequence SQ_COLLECTION_OBJECT_ID nocache;
FLAT    create sequence SQ_COLLECTION_OBJECT_ID nocache;
FLAT_NOPART     create sequence SQ_COLLECTION_OBJECT_ID nocache;
SPECIMEN_PART   create sequence SQ_COLLECTION_OBJECT_ID nocache;

COLL_OBJ_OTHER_ID_NUM   create sequence SQ_COLL_OBJ_OTHER_ID_NUM_ID nocache;
COMMON_NAME     create sequence SQ_COMMON_NAME nocache;
CONTAINER_CHECK create sequence SQ_CONTAINER_CHECK_ID nocache;
CONTAINER       create sequence SQ_CONTAINER_ID nocache;
COLL_OBJECT_ENCUMBRANCE create sequence SQ_ENCUMBRANCE_ID nocache;
ENCUMBRANCE     create sequence SQ_ENCUMBRANCE_ID nocache;
GEOG_AUTH_REC   create sequence SQ_GEOG_AUTH_REC_ID nocache;
GEOLOGY_ATTRIBUTE_HIERARCHY     create sequence SQ_GEOLOGY_ATTRIBUTE_HIERARCHY_ID nocache;
GEOLOGY_ATTRIBUTES      create sequence SQ_GEOLOGY_ATTRIBUTE_ID nocache;
GREF_REFSET_NG  create sequence SQ_ID nocache;
GREF_ROI_NG     create sequence SQ_ID nocache;
GREF_ROI_VALUE_NG       create sequence SQ_ID nocache;
GREF_USER       create sequence SQ_ID nocache;
IDENTIFICATION_AGENT    create sequence SQ_IDENTIFICATION_AGENT_ID nocache;
IDENTIFICATION  create sequence SQ_IDENTIFICATION_ID nocache;
JOURNAL create sequence SQ_JOURNAL_ID nocache;
LAT_LONG        create sequence SQ_LAT_LONG_ID nocache;
LOCALITY        create sequence SQ_LOCALITY_ID nocache;
VPD_COLLECTION_LOCALITY create sequence SQ_LOCALITY_ID nocache;
MEDIA   create sequence SQ_MEDIA_ID nocache;
MEDIA_LABELS    create sequence SQ_MEDIA_LABEL_ID nocache;
MEDIA_RELATIONS create sequence SQ_MEDIA_RELATIONS_ID nocache;
DR$TIX_SCINAME$N        create sequence SQ_NLT_DOCID nocache;
OBJECT_CONDITION        create sequence SQ_OBJECT_CONDITION_ID nocache;
PAGE    create sequence SQ_PAGE_ID nocache;
PERMIT  create sequence SQ_PERMIT_ID nocache;
PERMIT_TRANS    create sequence SQ_PERMIT_ID nocache;
PERSON  create sequence SQ_PERSON_ID nocache;
PROJECT create sequence SQ_PROJECT_ID nocache;
PROJECT_SPONSOR create sequence SQ_PROJECT_SPONSOR_ID nocache;
BOOK    create sequence SQ_PUBLICATION_ID nocache;
BOOK_SECTION    create sequence SQ_PUBLICATION_ID nocache;
CITATION        create sequence SQ_PUBLICATION_ID nocache;
FIELD_NOTEBOOK_SECTION  create sequence SQ_PUBLICATION_ID nocache;
JOURNAL_ARTICLE create sequence SQ_PUBLICATION_ID nocache;
PUBLICATION     create sequence SQ_PUBLICATION_ID nocache;
PUBLICATION_URL create sequence SQ_PUBLICATION_URL_ID nocache;
CF_REPORT_SQL   create sequence SQ_REPORT_ID nocache;
DEV_TASK        create sequence SQ_TASK_ID nocache;
COMMON_NAME     create sequence SQ_TAXON_NAME_ID nocache;
TAXONOMY        create sequence SQ_TAXON_NAME_ID nocache;
DR$TIX_SCINAME$K        create sequence SQ_TEXTKEY nocache;
ACCN    create sequence SQ_TRANSACTION_ID nocache;
BORROW  create sequence SQ_TRANSACTION_ID nocache;
LOAN    create sequence SQ_TRANSACTION_ID nocache;
PERMIT_TRANS    create sequence SQ_TRANSACTION_ID nocache;
TRANS   create sequence SQ_TRANSACTION_ID nocache;
TRANS_AGENT     create sequence SQ_TRANS_AGENT_ID nocache;
URL     create sequence SQ_URL_ID nocache;
VIEWER  create sequence SQ_VIEWER_ID nocache;


create sequence SQ_REDIRECT_ID;