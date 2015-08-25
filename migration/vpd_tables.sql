/*
	Now "just" hook up THE ROLES AND TABLES WITH VPD policies...
	Start by define status OF ALL THE TABLES
	Need to get to collection (where institution + collection_cde defines the primary VPD partitions)
	Some tables are just openly shared (join="none"). Access to these is controlled by non-VPD roles and
	training.
	Some tables will have no policies immediately, but will/may need them in the future:
		We've agreed to share taxonomy and play nicely
		Agents, and stuff about agents, can probably be shared - let's give it a try
	Some tables will have overly restrictive policies that may be loosened up in the future:
		locality and friends will begin unshared, but certainly need to be shared. The question is only how to do so.
	Many tables will be controlled only by usage. So, anyone is free to create an encumbrance ( or project
	or permit or publication or ...), alter it, then 
	delete it. However, once that encumbrance is used, it will be controlled via
	coll_object_encumbrance-->cataloged_item-->collection
	

**********************************************************************************************************************/  
/*
-- get record counts for tables.
declare c number;
begin
    for tn in (
        select table_name from user_tables
        where table_name not like 'LAM%'
        and table_name not like 'LKV%'
        and table_name not like '%_BAK'
--        and table_name not like 'CCT%'
--        and table_name not like 'CT%'
--        and table_name not like 'CF%'
        and table_name not like 'PLSQL%'
        and table_name not like 'PLAN%'
--        and table_name not like 'BULK%'
--        and table_name not like 'FLAT%'
--        and table_name not like 'GREF%'
        order by table_name
    ) loop
        execute immediate 'select count(*) from ' || tn.table_name into c;      
        if c > 0 then
            dbms_output.put_line(c || chr(9) || tn.table_name);
        end if;
    end loop;
end;
/

-- get primary keys 
select table_name, constraint_name
from user_constraints
where constraint_type = 'P'
and table_name not like 'LAM%'
and table_name not like 'LKV%'
--and table_name not like 'CCT%'
--and table_name not like 'CT%'
--and table_name not like 'CF%'
and table_name not like 'PLSQL%'
and table_name not like 'PLAN%'
--and table_name not like 'BULK%'
--and table_name not like 'FLAT%'
--and table_name not like 'GREF%'
order by table_name;

-- get foreign keys
select table_name, constraint_name, r_constraint_name                           
from user_constraints
where constraint_type = 'R'
and table_name in (
    select table_name from user_constraints
    where constraint_type = 'P'
    and table_name not like 'LAM%'
    and table_name not like 'LKV%'
    and table_name not like '%BAK'
--    and table_name not like 'CCT%'
--    and table_name not like 'CT%'
--    and table_name not like 'CF%'
    and table_name not like 'PLSQL%'
    and table_name not like 'PLAN%'
--    and table_name not like 'BULK%'
--    and table_name not like 'FLAT%'
--    and table_name not like 'GREF%'
)
order by table_name

select distinct('update ' || table_name || ' set ' || column_name || ' = ' || column_name || ' + 10000000;')
from user_cons_columns
where constraint_name in (
    select constraint_name
    from user_constraints
    where constraint_type in ('P','R')
)
and table_name not like 'CT%'
order by 'update table ' || table_name || ' set ' || column_name || ' = ' || column_name || ' + 10000000;'
*/

/*prod TABLES
ACCN
ADDR
AGENT
AGENT_NAME
AGENT_NAME_PENDING_DELETE
AGENT_RELATIONS
ATTRIBUTES
BINARY_OBJECT
BIOL_INDIV_RELATIONS
BOOK
BOOK_SECTION
BORROW
BSCIT_IMAGE_SUBJECT
CATALOGED_ITEM
CDATA
CGLOBAL
CITATION
COLLECTING_EVENT
COLLECTION
COLLECTION_CONTACTS
COLLECTOR
COLL_OBJECT
COLL_OBJECT_ENCUMBRANCE
COLL_OBJECT_REMARK
COLL_OBJ_CONT_HIST
COLL_OBJ_OTHER_ID_NUM
COMMON_NAME
CONTAINER
CONTAINER_CHECK
CONTAINER_HISTORY
CORRESPONDENCE
DGR_LOCATOR
ELECTRONIC_ADDRESS
ENCUMBRANCE
FIELD_NOTEBOOK_SECTION
FLUID_CONTAINER_HISTORY
FMP_IMAGE_DATA
GEOG_AUTH_REC
GEOLOGY_ATTRIBUTES
GEOLOGY_ATTRIBUTE_HIERARCHY
GROUP_MEMBER
IDENTIFICATION
IDENTIFICATION_AGENT
IDENTIFICATION_TAXONOMY
IMAGE_CONTENT
IMAGE_OBJECT
IMAGE_SUBJECT_REMARKS
JOURNAL
JOURNAL_ARTICLE
LAT_LONG
LOAN
LOAN_INSTALLMENT
LOAN_ITEM
LOCALITY
MEDIA
MEDIA_LABELS
MEDIA_RELATIONS
MIGRATECT
MIGRATECT_MVZ
MIGRATECT_UAM
NUMS
OBJECT_CONDITION
PAGE
PERMIT
PERMIT_TRANS
PERSON
PROC_BL_STATUS
PROJECT
PROJECT_AGENT
PROJECT_PUBLICATION
PROJECT_REMARK
PROJECT_SPONSOR
PROJECT_TRANS
PUBLICATION
PUBLICATION_AUTHOR_NAME
PUBLICATION_URL
REARING_EVENT
SHIPMENT
SPECIMEN_ANNOTATIONS
SPECIMEN_PART
STILL_IMAGE
TAB_MEDIA_REL_FKEY
TAXONOMY
TAXONOMY_ARCHIVE
TAXON_RELATIONS
TEMP_ALLOW_CF_USER
TRANS
TRANS_AGENT
USER_DATA
USER_LOAN_ITEM
USER_LOAN_REQUEST
USER_ROLES
USER_TABLE_ACCESS
VESSEL
VIEWER

97 rows selected.

*/

update ACCN set TRANSACTION_ID = TRANSACTION_ID + 10000000;

update ADDR set 
    ADDR_ID = ADDR_ID + 10000000,
    AGENT_ID = AGENT_ID + 10000000;

update AGENT set 
    AGENT_ID = AGENT_ID + 10000000;
    -- preferred_agent_name_id not used, but updated for consistency.
    PREFERRED_AGENT_NAME_ID = PREFERRED_AGENT_NAME_ID + 10000000;

update AGENT_NAME set 
    AGENT_ID = AGENT_ID + 10000000,
    AGENT_NAME_ID = AGENT_NAME_ID + 10000000;

update AGENT_RELATIONS set 
    AGENT_ID = AGENT_ID + 10000000,
    RELATED_AGENT_ID = RELATED_AGENT_ID + 10000000;

update ATTRIBUTES set 
    ATTRIBUTE_ID = ATTRIBUTE_ID + 10000000,
    COLLECTION_OBJECT_ID = COLLECTION_OBJECT_ID + 10000000,
    DETERMINED_BY_AGENT_ID = DETERMINED_BY_AGENT_ID + 10000000;

update BINARY_OBJECT set 
    COLLECTION_OBJECT_ID = COLLECTION_OBJECT_ID + 10000000,
    DERIVED_FROM_CAT_ITEM = DERIVED_FROM_CAT_ITEM + 10000000,
    DERIVED_FROM_COLL_OBJ = DERIVED_FROM_COLL_OBJ + 10000000,
    MADE_AGENT_ID = MADE_AGENT_ID + 10000000,
    VIEWER_ID = VIEWER_ID + 10000000;

update BIOL_INDIV_RELATIONS set 
    COLLECTION_OBJECT_ID = COLLECTION_OBJECT_ID + 10000000,
    RELATED_COLL_OBJECT_ID = RELATED_COLL_OBJECT_ID + 10000000;

update BOOK set PUBLICATION_ID = PUBLICATION_ID + 10000000;

update BOOK_SECTION set 
    BOOK_ID = BOOK_ID + 10000000,
    PUBLICATION_ID = PUBLICATION_ID + 10000000;

update BORROW set TRANSACTION_ID = TRANSACTION_ID + 10000000;

update CATALOGED_ITEM set 
    ACCN_ID = ACCN_ID + 10000000,
    COLLECTING_EVENT_ID = COLLECTING_EVENT_ID + 10000000,
    COLLECTION_ID = COLLECTION_ID + 10000000,
    COLLECTION_OBJECT_ID = COLLECTION_OBJECT_ID + 10000000;

update CITATION set 
    CITATION_ID = CITATION_ID + 10000000,    -- not at test
    CITED_TAXON_NAME_ID = CITED_TAXON_NAME_ID + 10000000,
    COLLECTION_OBJECT_ID = COLLECTION_OBJECT_ID + 10000000,
    PUBLICATION_ID = PUBLICATION_ID + 10000000;

update COLLECTING_EVENT set 
    COLLECTING_EVENT_ID = COLLECTING_EVENT_ID + 10000000,
    LOCALITY_ID = LOCALITY_ID + 10000000,
    DATE_DETERMINED_BY_AGENT_ID = DATE_DETERMINED_BY_AGENT_ID + 10000000;

update COLLECTION set COLLECTION_ID = COLLECTION_ID + 10000000;

update COLLECTION_CONTACTS set 
    COLLECTION_CONTACT_ID = COLLECTION_CONTACT_ID + 10000000,
    COLLECTION_ID = COLLECTION_ID + 10000000,
    CONTACT_AGENT_ID = CONTACT_AGENT_ID + 10000000;

update COLLECTOR set 
    AGENT_ID = AGENT_ID + 10000000,
    COLLECTION_OBJECT_ID = COLLECTION_OBJECT_ID + 10000000;

update COLL_OBJECT set 
    COLLECTION_OBJECT_ID = COLLECTION_OBJECT_ID + 10000000,
    ENTERED_PERSON_ID = ENTERED_PERSON_ID + 10000000,
    LAST_EDITED_PERSON_ID = LAST_EDITED_PERSON_ID + 10000000;

update COLL_OBJECT_ENCUMBRANCE set 
    COLLECTION_OBJECT_ID = COLLECTION_OBJECT_ID + 10000000,
    ENCUMBRANCE_ID = ENCUMBRANCE_ID + 10000000;

update COLL_OBJECT_REMARK set COLLECTION_OBJECT_ID = COLLECTION_OBJECT_ID + 10000000;

update COLL_OBJ_CONT_HIST set 
    COLLECTION_OBJECT_ID = COLLECTION_OBJECT_ID + 10000000,
    CONTAINER_ID = CONTAINER_ID + 10000000;

update COLL_OBJ_OTHER_ID_NUM set 
    COLLECTION_OBJECT_ID = COLLECTION_OBJECT_ID + 10000000,
    COLL_OBJ_OTHER_ID_NUM_ID = COLL_OBJ_OTHER_ID_NUM_ID + 10000000;

update COMMON_NAME set TAXON_NAME_ID = TAXON_NAME_ID + 10000000;

update CONTAINER set
    CONTAINER_ID = CONTAINER_ID + 10000000,
    PARENT_CONTAINER_ID = PARENT_CONTAINER_ID + 10000000; -- not done at test :(

-- must verify that mvz has no data in container_check table.
--update CONTAINER_CHECK set 
--    CHECKED_AGENT_ID = CHECKED_AGENT_ID + 10000000,
--    CONTAINER_CHECK_ID = CONTAINER_CHECK_ID + 10000000,
--    CONTAINER_ID = CONTAINER_ID + 10000000;

-- must verify that mvz has no data in container_history table.
--update CONTAINER_HISTORY set CONTAINER_ID = CONTAINER_ID + 10000000;

update ELECTRONIC_ADDRESS set AGENT_ID = AGENT_ID + 10000000;

update ENCUMBRANCE set 
    ENCUMBERING_AGENT_ID = ENCUMBERING_AGENT_ID + 10000000,
    ENCUMBRANCE_ID = ENCUMBRANCE_ID + 10000000;

update FIELD_NOTEBOOK_SECTION set PUBLICATION_ID = PUBLICATION_ID + 10000000;

update FLUID_CONTAINER_HISTORY set CONTAINER_ID = CONTAINER_ID + 10000000;

update GEOG_AUTH_REC set GEOG_AUTH_REC_ID = GEOG_AUTH_REC_ID + 10000000;

-- must verify that mvz has no data in geology_attributes table.
--update GEOLOGY_ATTRIBUTES set 
--    GEOLOGY_ATTRIBUTE_ID = GEOLOGY_ATTRIBUTE_ID + 10000000,
--    LOCALITY_ID = LOCALITY_ID + 10000000;

-- must verify that mvz has no data in geology_attribute_hierarchy table.
--update GEOLOGY_ATTRIBUTE_HIERARCHY set 
--    GEOLOGY_ATTRIBUTE_HIERARCHY_ID = GEOLOGY_ATTRIBUTE_HIERARCHY_ID + 10000000,
--    PARENT_ID = PARENT_ID + 10000000;

update GROUP_MEMBER set 
    GROUP_AGENT_ID = GROUP_AGENT_ID + 10000000,
    MEMBER_AGENT_ID = MEMBER_AGENT_ID + 10000000;

update IDENTIFICATION set 
    COLLECTION_OBJECT_ID = COLLECTION_OBJECT_ID + 10000000,
    IDENTIFICATION_ID = IDENTIFICATION_ID + 10000000;
    
update IDENTIFICATION_AGENT set 
    AGENT_ID = AGENT_ID + 10000000,
    IDENTIFICATION_AGENT_ID = IDENTIFICATION_AGENT_ID + 10000000,
	IDENTIFICATION_ID = IDENTIFICATION_ID + 10000000;
    
update IDENTIFICATION_TAXONOMY set 
    IDENTIFICATION_ID = IDENTIFICATION_ID + 10000000,
    TAXON_NAME_ID = TAXON_NAME_ID + 10000000;
    
update JOURNAL set JOURNAL_ID = JOURNAL_ID + 10000000;

update JOURNAL_ARTICLE set 
    JOURNAL_ID = JOURNAL_ID + 10000000,
    PUBLICATION_ID = PUBLICATION_ID + 10000000;

update LAT_LONG set 
    DETERMINED_BY_AGENT_ID = DETERMINED_BY_AGENT_ID + 10000000,
    LAT_LONG_ID = LAT_LONG_ID + 10000000,
    LOCALITY_ID = LOCALITY_ID + 10000000;

update LOAN set TRANSACTION_ID = TRANSACTION_ID + 10000000;

update LOAN_ITEM set 
    COLLECTION_OBJECT_ID = COLLECTION_OBJECT_ID + 10000000,
    RECONCILED_BY_PERSON_ID = RECONCILED_BY_PERSON_ID + 10000000,
    TRANSACTION_ID = TRANSACTION_ID + 10000000;

update LOCALITY set 
    GEOG_AUTH_REC_ID = GEOG_AUTH_REC_ID + 10000000,
    LOCALITY_ID = LOCALITY_ID + 10000000;

update MEDIA set MEDIA_ID = MEDIA_ID + 10000000;

update MEDIA_LABELS set 
    ASSIGNED_BY_AGENT_ID = ASSIGNED_BY_AGENT_ID + 10000000,
    MEDIA_ID = MEDIA_ID + 10000000,
    MEDIA_LABEL_ID = MEDIA_LABEL_ID + 10000000;

update MEDIA_RELATIONS set 
    CREATED_BY_AGENT_ID = CREATED_BY_AGENT_ID + 10000000,
    MEDIA_ID = MEDIA_ID + 10000000,
	MEDIA_RELATIONS_ID = MEDIA_RELATIONS_ID + 10000000,
	RELATED_PRIMARY_KEY = RELATED_PRIMARY_KEY + 10000000;

update OBJECT_CONDITION set 
    COLLECTION_OBJECT_ID = COLLECTION_OBJECT_ID + 10000000,
	DETERMINED_AGENT_ID = DETERMINED_AGENT_ID + 10000000,
    OBJECT_CONDITION_ID = OBJECT_CONDITION_ID + 10000000;

update PAGE set 
    PAGE_ID = PAGE_ID + 10000000,
    PUBLICATION_ID = PUBLICATION_ID + 10000000;

update PERMIT set 
    CONTACT_AGENT_ID = CONTACT_AGENT_ID + 10000000,
	ISSUED_BY_AGENT_ID = ISSUED_BY_AGENT_ID + 10000000,
	ISSUED_TO_AGENT_ID = ISSUED_TO_AGENT_ID + 10000000,
	PERMIT_ID = PERMIT_ID + 10000000;

update PERMIT_TRANS set 
    PERMIT_ID = PERMIT_ID + 10000000,
    TRANSACTION_ID = TRANSACTION_ID + 10000000;

update PERSON set PERSON_ID = PERSON_ID + 10000000;

update PROJECT set PROJECT_ID = PROJECT_ID + 10000000;

update PROJECT_AGENT set 
    AGENT_NAME_ID = AGENT_NAME_ID + 10000000,
    PROJECT_ID = PROJECT_ID + 10000000;

update PROJECT_PUBLICATION set 
    PROJECT_ID = PROJECT_ID + 10000000,
	PUBLICATION_ID = PUBLICATION_ID + 10000000;

-- must verify that mvz has no data in project_remark table.
-- this table update was missing from test.
--update PROJECT_REMARK set 
--    PROJECT_ID = PROJECT_ID + 10000000;

-- must verify that mvz has no data in project_sponsor table.
--update PROJECT_SPONSOR set 
--    AGENT_NAME_ID = AGENT_NAME_ID + 10000000,
--    PROJECT_ID = PROJECT_ID + 10000000,
--    PROJECT_SPONSOR_ID = PROJECT_SPONSOR_ID + 10000000;

update PROJECT_TRANS set 
    PROJECT_ID = PROJECT_ID + 10000000,
	TRANSACTION_ID = TRANSACTION_ID + 10000000;

update PUBLICATION set PUBLICATION_ID = PUBLICATION_ID + 10000000;

update PUBLICATION_AUTHOR_NAME set 
    AGENT_NAME_ID = AGENT_NAME_ID + 10000000,
    PUBLICATION_ID = PUBLICATION_ID + 10000000;

update PUBLICATION_URL set 
    PUBLICATION_ID = PUBLICATION_ID + 10000000,
	PUBLICATION_URL_ID = PUBLICATION_URL_ID + 10000000;

update SHIPMENT set 
    CONTAINER_ID = CONTAINER_ID + 10000000,
    PACKED_BY_AGENT_ID = PACKED_BY_AGENT_ID + 10000000,
	SHIPPED_FROM_ADDR_ID = SHIPPED_FROM_ADDR_ID + 10000000,
	SHIPPED_TO_ADDR_ID = SHIPPED_TO_ADDR_ID + 10000000,
	TRANSACTION_ID = TRANSACTION_ID + 10000000;

-- must verify that mvz has no data in specimen_annotations table.
--update SPECIMEN_ANNOTATIONS set 
--    ANNOTATION_ID = ANNOTATION_ID + 10000000,
--	COLLECTION_OBJECT_ID = COLLECTION_OBJECT_ID + 10000000;

ALTER TABLE SPECIMEN_ANNOTATIONS ADD REVIEWER_AGENT_ID NUMBER;
ALTER TABLE SPECIMEN_ANNOTATIONS ADD REVIEWER_FG NUMBER(1) DEFAULT 0 NOT NULL;
ALTER TABLE SPECIMEN_ANNOTATIONS ADD REVIEWER_COMMENT VARCHAR2(255);
grant all on specimen_annotations to manage_collection;

update SPECIMEN_PART set 
    COLLECTION_OBJECT_ID = COLLECTION_OBJECT_ID + 10000000,
    DERIVED_FROM_CAT_ITEM = DERIVED_FROM_CAT_ITEM + 10000000,
	SAMPLED_FROM_OBJ_ID = SAMPLED_FROM_OBJ_ID + 10000000;

update TAB_MEDIA_REL_FKEY set 
    MEDIA_RELATIONS_ID = MEDIA_RELATIONS_ID + 10000000, -- not at test?
    CFK_AGENT = CFK_AGENT + 10000000,
    CFK_CATALOGED_ITEM = CFK_CATALOGED_ITEM + 10000000,
	CFK_COLLECTING_EVENT = CFK_COLLECTING_EVENT + 10000000,
	CFK_LOCALITY = CFK_LOCALITY + 10000000;

update TAXONOMY set TAXON_NAME_ID = TAXON_NAME_ID + 10000000;

-- did not implement at test.
update TAXONOMY_ARCHIVE set TAXON_NAME_ID = TAXON_NAME_ID + 10000000;

update TAXON_RELATIONS set 
    RELATED_TAXON_NAME_ID = RELATED_TAXON_NAME_ID + 10000000,
    TAXON_NAME_ID = TAXON_NAME_ID + 10000000;

-- check on trans; tab structure not the same.
update TRANS set 
    COLLECTION_ID = COLLECTION_ID + 10000000, -- not at prod
    TRANSACTION_ID = TRANSACTION_ID + 10000000,
    -- these below are not used anymore, but added to prod to keep consistent.
	AUTH_AGENT_ID = AUTH_AGENT_ID + 10000000,
	TRANS_ENTERED_AGENT_ID = TRANS_ENTERED_AGENT_ID + 10000000,
	RECEIVED_AGENT_ID = RECEIVED_AGENT_ID + 10000000,
	TRANS_AGENCY_ID = TRANS_AGENCY_ID + 10000000;

update TRANS_AGENT set 
    AGENT_ID = AGENT_ID + 10000000,
    TRANSACTION_ID = TRANSACTION_ID + 10000000,
	TRANS_AGENT_ID = TRANS_AGENT_ID + 10000000;

-- must verify that mvz has no url table, and hence, no data.
--update URL set URL_ID = URL_ID + 10000000;

update VIEWER set VIEWER_ID = VIEWER_ID + 10000000;
--5) END: update main tables

--6) merge main data tables

--a) disable TRIGGERS
BEGIN
    FOR tn IN (
        SELECT trigger_name 
        FROM user_triggers 
        WHERE status = 'ENABLED' 
        ORDER BY table_name, trigger_name
    ) LOOP
        EXECUTE IMMEDIATE 'alter trigger ' || tn.trigger_name  || ' disable'; 
        dbms_output.put_line('alter trigger ' || tn.trigger_name  || ' disable;'); 
    END LOOP;
END;

alter trigger UP_FLAT_ACCN disable;
alter trigger BUILD_FORMATTED_ADDR disable;
alter trigger DEL_AGENT_NAME disable;
alter trigger INS_AGENT_NAME disable;
alter trigger PRE_DEL_AGENT_NAME disable;
alter trigger PRE_UP_INS_AGENT_NAME disable;
alter trigger UP_FLAT_AGENTNAME disable;
alter trigger UP_INS_AGENT_NAME disable;
alter trigger ALA_PLANT_IMAGING_KEY disable;
alter trigger ATTRIBUTE_CT_CHECK disable;
alter trigger ATTRIBUTE_DATA_CHECK disable;
alter trigger UP_FLAT_SEX disable;
alter trigger RELATIONSHIP_CT_CHECK disable;
alter trigger UP_FLAT_RELN disable;
alter trigger TD_BULKLOADER disable;
alter trigger AD_FLAT_CATITEM disable;
alter trigger A_FLAT_CATITEM disable;
alter trigger TI_FLAT_CATITEM disable;
alter trigger TU_FLAT_CATITEM disable;
alter trigger CF_CANNED_SEARCH_TRG disable;
alter trigger CF_FORM_PERMISSIONS_KEY disable;
alter trigger CF_LOG_ID disable;
alter trigger CF_REPORT_SQL_KEY disable;
alter trigger TRG_CF_SPEC_RES_COLS_ID disable;
alter trigger CF_TEMP_AGENTS_KEY disable;
alter trigger CF_TEMP_ATTRIBUTES_KEY disable;
alter trigger CF_TEMP_CITATION_KEY disable;
alter trigger CF_TEMP_LOAN_ITEM_KEY disable;
alter trigger CF_TEMP_OIDS_KEY disable;
alter trigger CF_TEMP_PARTS_KEY disable;
alter trigger CF_TEMP_TAXONOMY_KEY disable;
alter trigger CF_PW_CHANGE disable;
alter trigger CF_VERSION_PKEY_TRG disable;
alter trigger CF_VERSION_LOG_PKEY_TRG disable;
alter trigger UP_FLAT_CITATION disable;
alter trigger A_FLAT_COLLEVNT disable;
alter trigger COLLECTING_EVENT_CT_CHECK disable;
alter trigger UP_FLAT_COLLECTOR disable;
alter trigger COLL_OBJECT_CT_CHECK disable;
alter trigger TRG_OBJECT_CONDITION disable;
alter trigger UP_FLAT_COLLOBJ disable;
alter trigger UP_FLAT_COLL_OBJ_ENCUMBER disable;
alter trigger UP_FLAT_REMARK disable;
alter trigger COLL_OBJ_DATA_CHECK disable;
alter trigger COLL_OBJ_DISP_VAL disable;
alter trigger OTHER_ID_CT_CHECK disable;
alter trigger UP_FLAT_OTHERIDS disable;
alter trigger GET_CONTAINER_HISTORY disable;
alter trigger MOVE_CONTAINER disable;
alter trigger CONTAINER_CHECK_ID disable;
alter trigger MEDIA_RELATIONS_CT disable;
alter trigger TI_FLUID_CONTAINER_HISTORY disable;
alter trigger TU_FLUID_CONTAINER_HISTORY disable;
alter trigger TRG_MK_HIGHER_GEOG disable;
alter trigger UP_FLAT_GEOG disable;
alter trigger GEOLOGY_ATTRIBUTES_CHECK disable;
alter trigger GEOLOGY_ATTRIBUTES_SEQ disable;
alter trigger CTGEOLOGY_ATTRIBUTES_CHECK disable;
alter trigger GEOL_ATT_HIERARCHY_SEQ disable;
alter trigger IDENTIFICATION_CT_CHECK disable;
alter trigger UP_FLAT_ID disable;
alter trigger IDENTIFICATION_AGENT_TRG disable;
alter trigger UP_FLAT_AGNT_ID disable;
alter trigger UP_FLAT_ID_TAX disable;
alter trigger LAT_LONG_CT_CHECK disable;
alter trigger UPDATECOORDINATES disable;
alter trigger UP_FLAT_LAT_LONG disable;
alter trigger LOCALITY_CT_CHECK disable;
alter trigger UP_FLAT_LOCALITY disable;
alter trigger MEDIA_SEQ disable;
alter trigger MEDIA_LABELS_SEQ disable;
alter trigger MEDIA_RELATIONS_AFTER disable;
alter trigger MEDIA_RELATIONS_CHK disable;
alter trigger MEDIA_RELATIONS_SEQ disable;
alter trigger TRIG_PROJECT_SPONSOR_ID disable;
alter trigger SPECIMEN_ANNOTATIONS_KEY disable;
alter trigger IS_TISSUE_DEFAULT disable;
alter trigger MAKE_PART_COLL_OBJ_CONT disable;
alter trigger SPECIMEN_PART_CT_CHECK disable;
alter trigger TR_SPECIMENPART_AD disable;
alter trigger UP_FLAT_PART disable;
alter trigger UP_SPEC_WITH_LOC disable;
alter trigger TRG_MK_SCI_NAME disable;
alter trigger TRG_UP_TAX disable;
alter trigger UPDATE_ID_AFTER_TAXON_CHANGE disable;
alter trigger TRANS_AGENT_ENTERED disable;
alter trigger TRANS_AGENT_PRE disable;
--must remember to re-enable these triggers!!!

--b) drop foreign keys
SELECT dbms_metadata.get_ddl('TABLE',table_name) 
FROM user_tables 
WHERE table_name IN (
    SELECT DISTINCT table_name FROM USEr_constraints
    WHERE constraint_type = 'R');
    
begin
for cn in (
    select table_name, constraint_name 
    from user_constraints 
    where constraint_type = 'R' 
    order by table_name, constraint_name
) loop
    execute immediate 'alter table ' || cn.table_name || ' drop constraint ' || cn.constraint_name;
    dbms_output.put_line ('alter table ' || cn.table_name || ' drop constraint ' || cn.constraint_name || ';');
end loop;
end;

alter table ACCN drop constraint FK_ACCN_TRANS;
alter table ADDR drop constraint FK_ADDR_AGENT;
alter table AGENT_NAME drop constraint FK_AGENTNAME_AGENT;
alter table AGENT_RELATIONS drop constraint FK_AGENTRELATIONS_AGENT_ANID;
alter table AGENT_RELATIONS drop constraint FK_AGENTRELATIONS_AGENT_RANID;
alter table ATTRIBUTES drop constraint FK_ATTRIBUTES_AGENT;
alter table ATTRIBUTES drop constraint FK_ATTRIBUTES_CATITEM;
alter table BINARY_OBJECT drop constraint FK_BINARYOBJECT_BINARYOBJECT;
alter table BIOL_INDIV_RELATIONS drop constraint FK_BIOLINDIVRELN_CATITEM_COID;
alter table BIOL_INDIV_RELATIONS drop constraint FK_BIOLINDIVRELN_CATITEM_RCOID;
alter table BOOK drop constraint FK_BOOK_PUBLICATION;
alter table BOOK_SECTION drop constraint FK_BOOKSECTION_BOOK;
alter table BOOK_SECTION drop constraint FK_BOOKSECTION_PUBLICATION;
alter table BORROW drop constraint FK_BORROW_TRANS;
alter table CATALOGED_ITEM drop constraint FK_CATITEM_COLLECTION;
alter table CATALOGED_ITEM drop constraint FK_CATITEM_COLLEVENT;
alter table CATALOGED_ITEM drop constraint FK_CATITEM_COLLOBJECT;
alter table CATALOGED_ITEM drop constraint FK_CATITEM_TRANS;
alter table CF_COLLECTION_APPEARANCE drop constraint FK_CFCOLLAPPEAR_COLLECTION;
alter table CITATION drop constraint FK_CITATION_CATITEM;
alter table CITATION drop constraint FK_CITATION_PUBLICATION;
alter table CITATION drop constraint FK_CITATION_TAXONOMY;
alter table COLLECTING_EVENT drop constraint FK_COLLEVENT_AGENT;
alter table COLLECTING_EVENT drop constraint FK_COLLEVENT_LOCALITY;
alter table COLLECTION_CONTACTS drop constraint FK_COLLCONTACTS_AGENT;
alter table COLLECTION_CONTACTS drop constraint FK_COLLCONTACTS_COLLECTION;
alter table COLLECTOR drop constraint FK_COLLECTOR_AGENT;
alter table COLLECTOR drop constraint FK_COLLECTOR_CATITEM;
alter table COLL_OBJECT drop constraint FK_COLLOBJECT_AGENT_EDITED;
alter table COLL_OBJECT drop constraint FK_COLLOBJECT_AGENT_ENTERED;
alter table COLL_OBJECT_ENCUMBRANCE drop constraint FK_COLLOBJENC_COLLOBJECT;
alter table COLL_OBJECT_ENCUMBRANCE drop constraint FK_COLLOBJENC_ENCUMBRANCE;
alter table COLL_OBJECT_REMARK drop constraint FK_COLLOBJREM_COLLOBJECT;
alter table COLL_OBJ_CONT_HIST drop constraint FK_COLLOBJCONTHIST_COLLOBJ;
alter table COLL_OBJ_CONT_HIST drop constraint FK_COLLOBJCONTHIST_CONTAINER;
alter table COLL_OBJ_OTHER_ID_NUM drop constraint FK_COLLOBJOTHERIDNUM_CATITEM;
alter table COMMON_NAME drop constraint FK_COMMONNAME_TAXONOMY;
alter table CONTAINER_CHECK drop constraint FK_CONTAINERCHECK_AGENT;
alter table CONTAINER_CHECK drop constraint FK_CONTAINERCHECK_CONTAINER;
alter table CONTAINER_HISTORY drop constraint FK_CONTAINERHIST_CONTAINER;
alter table ELECTRONIC_ADDRESS drop constraint FK_ELECTRONICADDR_AGENT;
alter table ENCUMBRANCE drop constraint FK_ENCUMBRANCE_AGENT;
alter table FIELD_NOTEBOOK_SECTION drop constraint FK_FIELDNOTESEC_BOOKSEC;
alter table GEOLOGY_ATTRIBUTES drop constraint FK_GEOLATTRIBUTES_LOCALITY;
alter table GEOLOGY_ATTRIBUTE_HIERARCHY drop constraint FK_GEOLATTRHIER_GEOLATTR
HIER;
alter table GROUP_MEMBER drop constraint FK_GROUPMEMBER_AGENT_GROUP;
alter table GROUP_MEMBER drop constraint FK_GROUPMEMBER_AGENT_MEMBER;
alter table IDENTIFICATION drop constraint FK_IDENTIFICATION_CATITEM;
alter table IDENTIFICATION_AGENT drop constraint FK_IDAGENT_AGENT;
alter table IDENTIFICATION_AGENT drop constraint FK_IDAGENT_IDENTIFICATION;
alter table IDENTIFICATION_TAXONOMY drop constraint FK_IDTAXONOMY_IDENTIFICATION
;
alter table IDENTIFICATION_TAXONOMY drop constraint FK_IDTAXONOMY_TAXONOMY;
alter table JOURNAL_ARTICLE drop constraint FK_JOURNALARTICLE_JOURNAL;
alter table JOURNAL_ARTICLE drop constraint FK_JOURNALARTICLE_PUBLICATION;
alter table LAT_LONG drop constraint FK_LATLONG_AGENT;
alter table LAT_LONG drop constraint FK_LATLONG_LOCALITY;
alter table LOAN drop constraint FK_LOAN_TRANS;
alter table LOAN_INSTALLMENT drop constraint FK_LOANINSTALLMENT_LOAN;
alter table LOAN_ITEM drop constraint FK_LOANITEM_AGENT;
alter table LOAN_ITEM drop constraint FK_LOANITEM_COLLOBJECT;
alter table LOAN_ITEM drop constraint FK_LOANITEM_LOAN;
alter table LOCALITY drop constraint FK_LOCALITY_GEOGAUTHREC;
alter table MEDIA drop constraint FK_MEDIA_CTMIMETYPE;
alter table MEDIA_LABELS drop constraint FK_MEDIALABELS_AGENT;
alter table MEDIA_LABELS drop constraint FK_MEDIALABELS_MEDIA;
alter table MEDIA_RELATIONS drop constraint FK_MEDIARELNS_AGENT;
alter table MEDIA_RELATIONS drop constraint FK_MEDIARELNS_CTMEDIARELNS;
alter table MEDIA_RELATIONS drop constraint FK_MEDIARELNS_MEDIA;
alter table OBJECT_CONDITION drop constraint FK_OBJECTCONDITION_AGENT;
alter table OBJECT_CONDITION drop constraint FK_OBJECTCONDITION_COLLOBJECT;
alter table PAGE drop constraint FK_PAGE_PUBLICATION;
alter table PERMIT drop constraint FK_PERMIT_AGENT_CONTACT;
alter table PERMIT drop constraint FK_PERMIT_AGENT_ISSUEDBY;
alter table PERMIT drop constraint FK_PERMIT_AGENT_ISSUEDTO;
alter table PERMIT_TRANS drop constraint FK_PERMITTRANS_PERMIT;
alter table PERMIT_TRANS drop constraint FK_PERMITTRANS_TRANS;
alter table PERSON drop constraint FK_PERSON_AGENT;
alter table PLSQL_PROFILER_DATA drop constraint SYS_C0019670;
alter table PLSQL_PROFILER_UNITS drop constraint SYS_C0019671;
alter table PROJECT_AGENT drop constraint FK_PROJECTAGENT_AGENTNAME;
alter table PROJECT_AGENT drop constraint FK_PROJECTAGENT_PROJECT;
alter table PROJECT_PUBLICATION drop constraint FK_PROJECTPUB_PROJECT;
alter table PROJECT_PUBLICATION drop constraint FK_PROJECTPUB_PUBLICATION;
alter table PROJECT_SPONSOR drop constraint FK_PROJECTSPONSOR_AGENTNAME;
alter table PROJECT_SPONSOR drop constraint FK_PROJECTSPONSOR_PROJECT;
alter table PROJECT_TRANS drop constraint FK_PROJECTTRANS_PROJECT;
alter table PROJECT_TRANS drop constraint FK_PROJECTTRANS_TRANS;
alter table PUBLICATION_AUTHOR_NAME drop constraint FK_PUBAUTHNAME_PUBLICATION;
alter table PUBLICATION_URL drop constraint FK_PUBLICATIONURL_PUBLICATION;
alter table SHIPMENT drop constraint FK_SHIPMENT_ADDR_SHIPPEDFROM;
alter table SHIPMENT drop constraint FK_SHIPMENT_ADDR_SHIPPEDTO;
alter table SHIPMENT drop constraint FK_SHIPMENT_AGENT;
alter table SHIPMENT drop constraint FK_SHIPMENT_CONTAINER;
alter table SHIPMENT drop constraint FK_SHIPMENT_TRANS;
alter table SPECIMEN_ANNOTATIONS drop constraint FK_SPECIMENANNO_CATITEM;
alter table SPECIMEN_PART drop constraint FK_SPECIMENPART_CATITEM;
alter table SPECIMEN_PART drop constraint FK_SPECIMENPART_COLLOBJECT;
alter table SPECIMEN_PART drop constraint FK_SPECIMENPART_SPECIMENPART;
alter table TAB_MEDIA_REL_FKEY drop constraint FK_MR_MEDIA;
alter table TAB_MEDIA_REL_FKEY drop constraint FK_TABMEDIARELFKEY_AGENT;
alter table TAB_MEDIA_REL_FKEY drop constraint FK_TABMEDIARELFKEY_CATITEM;
alter table TAXON_RELATIONS drop constraint FK_TAXONRELN_TAXONOMY_RTNID;
alter table TAXON_RELATIONS drop constraint FK_TAXONRELN_TAXONOMY_TNID;
alter table TRANS drop constraint FK_TRANS_COLLN;
alter table TRANS_AGENT drop constraint FK_TRANSAGENT_AGENT;
alter table TRANS_AGENT drop constraint FK_TRANSAGENT_TRANS;

--c) insert mvz data into uam tables.
--ACCN    
DESC accn;
DESC mvz.accn;
SELECT COUNT(*) FROM uam.accn;
SELECT COUNT(*) FROM mvz.accn;

-- different column order at uam and mvz.
INSERT INTO uam.accn (
 TRANSACTION_ID,
 ACCN_TYPE,
 ACCN_NUM_PREFIX,
 ACCN_NUM,
 ACCN_NUM_SUFFIX,
 ACCN_STATUS,
 ACCN_NUMBER,
 RECEIVED_DATE)
SELECT
 TRANSACTION_ID,
 ACCN_TYPE,
 ACCN_NUM_PREFIX,
 ACCN_NUM,
 ACCN_NUM_SUFFIX,
 ACCN_STATUS,
 ACCN_NUMBER,
 RECEIVED_DATE
 FROM mvz.accn;
 
SELECT COUNT(*) FROM uam.accn;
     
--ADDR
DESC addr;
DESC mvz.addr;
SELECT COUNT(*) FROM uam.addr;
SELECT COUNT(*) FROM mvz.addr;

alter table uam.addr modify state null;
alter table uam.addr modify zip null;
    
INSERT INTO uam.addr SELECT * FROM mvz.addr;

SELECT COUNT(*) FROM uam.addr;

--AGENT
DESC agent;
DESC mvz.agent;
SELECT COUNT(*) FROM uam.agent;
SELECT COUNT(*) FROM mvz.agent;
 
INSERT INTO uam.agent SELECT * FROM mvz.agent;

SELECT COUNT(*) FROM uam.agent;

CREATE OR REPLACE TRIGGER TR_ADDR_AU
AFTER UPDATE ON Addr
FOR EACH ROW
DECLARE
    numrows INTEGER;
    new_data VARCHAR2(4000);
    old_data VARCHAR2(4000);
BEGIN
    SELECT :new.ADDR_ID || :new.STREET_ADDR1 || :new.STREET_ADDR2 || :new.CITY ||
        :new.STATE || :new.ZIP || :new.COUNTRY_CDE || :new.MAIL_STOP ||
        :new.AGENT_ID || :new.ADDR_TYPE || :new.JOB_TITLE ||
        :new.ADDR_REMARKS || :new.INSTITUTION || :new.DEPARTMENT
    INTO new_data FROM dual;

    SELECT  :old.ADDR_ID || :old.STREET_ADDR1 || :old.STREET_ADDR2 || :old.CITY ||
        :old.STATE || :old.ZIP || :old.COUNTRY_CDE || :old.MAIL_STOP ||
        :old.AGENT_ID || :old.ADDR_TYPE || :old.JOB_TITLE ||
        :old.ADDR_REMARKS || :old.INSTITUTION || :old.DEPARTMENT
    INTO old_data FROM dual;

--        dbms_output.put_line('old valid_addr_fg: ' || :OLD.valid_addr_fg);
--        dbms_output.put_line('new valid_addr_fg: ' || :new.valid_addr_fg);
--        dbms_output.put_line('old data: ' || old_data);
--        dbms_output.put_line('new data: ' || new_data);

    IF :new.valid_addr_fg != :old.valid_addr_fg AND old_data = new_data THEN
        dbms_output.put_line('Okay to update: only trying to change valid_addr flag');
    ELSE
        SELECT COUNT(*) INTO numrows
        FROM Shipment
        WHERE Shipment.Shipped_To_Addr_id = :old.Addr_id;

        IF (numrows > 0) THEN
            raise_application_error(
                -20005, 
                'Cannot UPDATE "Addr" because "Shipment" exists.');
        END IF;
        
        SELECT COUNT(*) INTO numrows
        FROM Correspondence
        WHERE Correspondence.To_Agent_Addr_id = :old.Addr_id;

        IF (numrows > 0) THEN
                raise_application_error(
                -20005,
                'Cannot UPDATE "Addr" because "Correspondence" exists.');
        END IF;
    END IF;
END;
/

--AGENT_NAME
DESC agent_name;
DESC mvz.agent_name;
SELECT COUNT(*) FROM uam.AGENT_NAME;
SELECT COUNT(*) FROM mvz.AGENT_NAME;

INSERT INTO uam.agent_name SELECT * FROM mvz.agent_name;

SELECT COUNT(*) FROM uam.AGENT_NAME;

--AGENT_RELATIONS
DESC agent_relations;
DESC mvz.agent_relations;
SELECT COUNT(*) FROM uam.agent_relations;
SELECT COUNT(*) FROM mvz.agent_relations;

INSERT INTO uam.agent_relations SELECT * FROM mvz.agent_relations;

SELECT COUNT(*) FROM uam.agent_relations;

--ATTRIBUTES
DESC attributes;
DESC mvz.attributes;
SELECT COUNT(*) FROM uam.attributes;
SELECT COUNT(*) FROM mvz.attributes;

INSERT INTO uam.attributes SELECT * FROM mvz.attributes;

SELECT COUNT(*) FROM uam.attributes;

--BINARY_OBJECT
DESC binary_object;
DESC mvz.binary_object;
SELECT COUNT(*) FROM uam.binary_object;
SELECT COUNT(*) FROM mvz.binary_object;

INSERT INTO uam.binary_object SELECT * FROM mvz.binary_object;

SELECT COUNT(*) FROM uam.binary_object;

--BIOL_INDIV_RELATIONS
DESC biol_indiv_relations;
DESC mvz.biol_indiv_relations;
SELECT COUNT(*) FROM uam.BIOL_INDIV_RELATIONS;
SELECT COUNT(*) FROM mvz.BIOL_INDIV_RELATIONS;

INSERT INTO uam.biol_indiv_relations SELECT * FROM mvz.biol_indiv_relations;

SELECT COUNT(*) FROM uam.BIOL_INDIV_RELATIONS;

--BOOK
DESC uam.book;
DESC mvz.book;
SELECT COUNT(*) FROM uam.book;
SELECT COUNT(*) FROM mvz.book;

INSERT INTO uam.book SELECT * FROM mvz.book;

SELECT COUNT(*) FROM uam.book;

--BOOK_SECTION
DESC uam.book_section;
DESC mvz.book_section;
SELECT COUNT(*) FROM uam.book_section;
SELECT COUNT(*) FROM mvz.book_section;

INSERT INTO uam.book_section SELECT * FROM mvz.book_section;

SELECT COUNT(*) FROM uam.book_section;

--BORROW
DESC uam.borrow;
DESC mvz.borrow;
SELECT COUNT(*) FROM uam.borrow;
SELECT COUNT(*) FROM mvz.borrow;

INSERT INTO uam.borrow SELECT * FROM mvz.borrow;

SELECT COUNT(*) FROM uam.borrow;

--BSCIT_IMAGE_SUBJECT
-- !!table does not exist at UAM
-- did not bring over to prod.
CREATE TABLE UAM.BSCIT_IMAGE_SUBJECT AS SELECT * FROM mvz.BSCIT_IMAGE_SUBJECT;
update bscit_image_subject set collection_object_id = collection_object_id + 10000000;

--CATALOGED_ITEM
DESC uam.cataloged_item;
DESC mvz.cataloged_item;
SELECT COUNT(*) FROM uam.cataloged_item;
SELECT COUNT(*) FROM mvz.cataloged_item;

INSERT INTO uam.cataloged_item SELECT * FROM mvz.cataloged_item;

SELECT COUNT(*) FROM uam.cataloged_item;

--CITATION
DESC uam.citation;
DESC mvz.citation;
SELECT COUNT(*) FROM uam.citation;
SELECT COUNT(*) FROM mvz.citation;

-- mvz has citation_id which does not exist at uam test/prod.
INSERT INTO uam.citation (
 PUBLICATION_ID,
 COLLECTION_OBJECT_ID,
 CITED_TAXON_NAME_ID,
 CIT_CURRENT_FG,
 OCCURS_PAGE_NUMBER,
 TYPE_STATUS,
 CITATION_REMARKS,
 CITATION_TEXT,
 REP_PUBLISHED_YEAR)
SELECT
 PUBLICATION_ID,
 COLLECTION_OBJECT_ID,
 CITED_TAXON_NAME_ID,
 CIT_CURRENT_FG,
 OCCURS_PAGE_NUMBER,
 TYPE_STATUS,
 CITATION_REMARKS,
 CITATION_TEXT,
 REP_PUBLISHED_YEAR
FROM mvz.citation;

alter table citation modify CITED_TAXON_NAME_ID not null;

SELECT COUNT(*) FROM uam.citation;

--COLLECTING_EVENT
DESC uam.collecting_event;
DESC mvz.collecting_event;
SELECT COUNT(*) FROM uam.collecting_event;
SELECT COUNT(*) FROM mvz.collecting_event;

ALTER TABLE uam.collecting_event MODIFY verbatim_locality VARCHAR2(260);
--look AT collecting_event_id 10210358 (21183176, Herp 245952, 21183177, Herp 245953)

INSERT INTO uam.collecting_event SELECT * FROM mvz.collecting_event;

SELECT COUNT(*) FROM uam.collecting_event;

--COLLECTION
DESC uam.collection;
DESC mvz.collection;
SELECT COUNT(*) FROM uam.collection;
SELECT COUNT(*) FROM mvz.collection;

alter table uam.collection modify collection varchar2(30);
    
INSERT INTO uam.collection SELECT * FROM mvz.collection;

SELECT COUNT(*) FROM uam.collection;

-- fixe collection_ids, which are too long to make collection code tables.

UPDATE collection set collection_id = 28 where collection_id = 10000001;
update collection set collection_id = 29 where collection_id = 10000002;
update collection set collection_id = 30 where collection_id = 10000003;
update collection set collection_id = 31 where collection_id = 10000005;
update collection set collection_id = 32 where collection_id = 10000006;
update collection set collection_id = 33 where collection_id = 10000007;
update collection set collection_id = 34 where collection_id = 10000008;
update collection set collection_id = 35 where collection_id = 10000009;
update collection set collection_id = 36 where collection_id = 10000010;
update collection set collection_id = 37 where collection_id = 10000011;

UPDATE cataloged_item set collection_id = 28 where collection_id = 10000001;
update cataloged_item set collection_id = 29 where collection_id = 10000002;
update cataloged_item set collection_id = 30 where collection_id = 10000003;
update cataloged_item set collection_id = 31 where collection_id = 10000005;
update cataloged_item set collection_id = 32 where collection_id = 10000006;
update cataloged_item set collection_id = 33 where collection_id = 10000007;
update cataloged_item set collection_id = 34 where collection_id = 10000008;
update cataloged_item set collection_id = 35 where collection_id = 10000009;
update cataloged_item set collection_id = 36 where collection_id = 10000010;
update cataloged_item set collection_id = 37 where collection_id = 10000011;

UPDATE collection_contacts set collection_id = 28 where collection_id = 10000001;
update collection_contacts set collection_id = 29 where collection_id = 10000002;
update collection_contacts set collection_id = 30 where collection_id = 10000003;
update collection_contacts set collection_id = 31 where collection_id = 10000005;
update collection_contacts set collection_id = 32 where collection_id = 10000006;
update collection_contacts set collection_id = 33 where collection_id = 10000007;
update collection_contacts set collection_id = 34 where collection_id = 10000008;
update collection_contacts set collection_id = 35 where collection_id = 10000009;
update collection_contacts set collection_id = 36 where collection_id = 10000010;
update collection_contacts set collection_id = 37 where collection_id = 10000011;

UPDATE trans set collection_id = 28 where collection_id = 10000001;
update trans set collection_id = 29 where collection_id = 10000002;
update trans set collection_id = 30 where collection_id = 10000003;
update trans set collection_id = 31 where collection_id = 10000005;
update trans set collection_id = 32 where collection_id = 10000006;
update trans set collection_id = 33 where collection_id = 10000007;
update trans set collection_id = 34 where collection_id = 10000008;
update trans set collection_id = 35 where collection_id = 10000009;
update trans set collection_id = 36 where collection_id = 10000010;
update trans set collection_id = 37 where collection_id = 10000011;

-- update collection, cf_collection and flat. new collection names are:
MVZ Birds
MVZ Egg/Nest
MVZ Herps
MVZ Hildebrand
MVZ Images
MVZ Mammals
MVZ Notebook Pages
MVZ Observations-Bird
MVZ Observations-Herp
MVZ Observations-Mammal

update collection set collection = 'MVZ Images' where collection = 'Image Catalog';
update cf_collection set collection = 'MVZ Images' where collection = 'Image Catalog';
update collection set collection = 'MVZ Notebook Pages' where collection = 'Notebook Page';
update cf_collection set collection = 'MVZ Notebook Pages' where collection = 'Notebook Page';

/*
update collection set collection='MVZ Birds' where collection='Bird Specimen Catalog';
update collection set collection='MVZ Egg/Nest' where collection='Egg/Nest Specimen Catalog';
update collection set collection='MVZ Herps' where collection='Herp Specimen Catalog';
update collection set collection='MVZ Mammals' where collection='Mammal Specimen Catalog';
update collection set collection='MVZ Hildebrand' where collection='Milton Hildebrand Catalog';
update collection set collection='MVZ Observations-Bird' where collection='Bird Observational Catalog';
update collection set collection='MVZ Observations-Herp' where collection='Herp Observational Catalog';
update collection set collection='MVZ Observations-Mammal' where collection='Mammal Observational Catalog';
update collection set collection='MVZ Image' where collection='Mammal Observational Catalog';
update collection set collection='MVZ Notebook Page' where collection='Mammal Observational Catalog';
*/

--COLLECTION_CONTACTS
DESC uam.collection_contacts;
DESC mvz.collection_contacts;
SELECT COUNT(*) FROM uam.collection_contacts;
SELECT COUNT(*) FROM mvz.collection_contacts;
    
INSERT INTO uam.collection_contacts SELECT * FROM mvz.collection_contacts;

SELECT COUNT(*) FROM uam.collection_contacts;

--COLLECTOR
DESC uam.collector;
DESC mvz.collector;
SELECT COUNT(*) FROM uam.collector;
SELECT COUNT(*) FROM mvz.collector;
    
INSERT INTO uam.collector SELECT * FROM mvz.collector;

SELECT COUNT(*) FROM uam.collector;

--COLL_OBJECT
DESC uam.coll_object;
DESC mvz.coll_object;
SELECT COUNT(*) FROM uam.coll_object;
SELECT COUNT(*) FROM mvz.coll_object;
    
INSERT INTO uam.coll_object SELECT * FROM mvz.coll_object;

SELECT COUNT(*) FROM uam.coll_object;

--COLL_OBJECT_ENCUMBRANCE
DESC uam.coll_object_encumbrance;
DESC mvz.coll_object_encumbrance;
SELECT COUNT(*) FROM uam.coll_object_encumbrance;
SELECT COUNT(*) FROM mvz.coll_object_encumbrance;
    
INSERT INTO uam.coll_object_encumbrance SELECT * FROM mvz.coll_object_encumbrance;

SELECT COUNT(*) FROM uam.coll_object_encumbrance;

--COLL_OBJECT_REMARK
DESC uam.coll_object_remark;
DESC mvz.coll_object_remark;
SELECT COUNT(*) FROM uam.coll_object_remark;
SELECT COUNT(*) FROM mvz.coll_object_remark;
    
INSERT INTO uam.coll_object_remark SELECT * FROM mvz.coll_object_remark;

SELECT COUNT(*) FROM uam.coll_object_remark;

--check this first from vpd_db_mig.sql
-- no remarks where collection_object_id not in coll_object table.
--DELETE FROM coll_object_remark 
--WHERE collection_object_id NOT IN (SELECT collection_object_id FROM coll_object);

--COLL_OBJ_CONT_HIST
DESC uam.coll_obj_cont_hist;
DESC mvz.coll_obj_cont_hist;
SELECT COUNT(*) FROM uam.coll_obj_cont_hist;
SELECT COUNT(*) FROM mvz.coll_obj_cont_hist;
    
INSERT INTO uam.coll_obj_cont_hist SELECT * FROM mvz.coll_obj_cont_hist;

SELECT COUNT(*) FROM uam.coll_obj_cont_hist;

--COLL_OBJ_OTHER_ID_NUM
DESC uam.coll_obj_other_id_num;
DESC mvz.coll_obj_other_id_num;
SELECT COUNT(*) FROM uam.coll_obj_other_id_num;
SELECT COUNT(*) FROM mvz.coll_obj_other_id_num;
    
-- mvz has other_id_num which does not exist at uam-test. okay at prod.
/*
INSERT INTO uam.coll_obj_other_id_num (
 COLLECTION_OBJECT_ID,
 OTHER_ID_TYPE,
 OTHER_ID_PREFIX,
 OTHER_ID_NUMBER,
 OTHER_ID_SUFFIX,
 DISPLAY_VALUE,
 COLL_OBJ_OTHER_ID_NUM_ID)
SELECT 
 COLLECTION_OBJECT_ID,
 OTHER_ID_TYPE,
 OTHER_ID_PREFIX,
 OTHER_ID_NUMBER,
 OTHER_ID_SUFFIX,
 DISPLAY_VALUE,
 COLL_OBJ_OTHER_ID_NUM_ID
FROM mvz.coll_obj_other_id_num;
*/

INSERT INTO uam.coll_obj_other_id_num SELECT * FROM mvz.coll_obj_other_id_num;

SELECT COUNT(*) FROM uam.coll_obj_other_id_num;

-- sequence does not exist at prod.
/*
select sq_coll_obj_other_id_num_id.nextval from dual;
select max(coll_obj_other_id_num_id) from coll_obj_other_id_num;

alter sequence sq_coll_obj_other_id_num_id increment by  ???;

select sq_coll_obj_other_id_num_id.nextval from dual;
alter sequence sq_coll_obj_other_id_num_id increment by 1;
select sq_coll_obj_other_id_num_id.nextval from dual;
*/

ALTER TABLE COLL_OBJ_OTHER_ID_NUM DROP COLUMN OTHER_ID_NUM;

-- rebuild CONCATSINGLEOTHERIDINT
CREATE OR REPLACE FUNCTION CONCATSINGLEOTHERIDINT (
    p_key_val IN number,
    p_other_col_name IN varchar2)
RETURN number
AS
    oidnum NUMBER;
    r NUMBER;
BEGIN
    SELECT COUNT(*) INTO r
	FROM coll_obj_other_id_num
	WHERE other_id_type = p_other_col_name
	AND collection_object_id = p_key_val;
	IF r = 1 THEN
        SELECT display_value INTO oidnum
        FROM coll_obj_other_id_num
        WHERE other_id_type = p_other_col_name
        AND collection_object_id = p_key_val;
	ELSE
    	oidnum := NULL;
	END IF;
    RETURN oidnum;
END;
/
/* at prod:looks the same, but not exactly sure, so rebuilt anyway.
  CREATE OR REPLACE FUNCTION "UAM"."CONCATSINGLEOTHERIDINT" (
        p_key_val IN number,
        p_other_col_name IN varchar2)
RETURN number
AS
        oidnum NUMBER;
        r NUMBER;
BEGIN
    SELECT COUNT(*) INTO r
    FROM coll_obj_other_id_num
    WHERE other_id_type = p_other_col_name
    AND collection_object_id = p_key_val;
    IF r = 1 THEN
                SELECT other_id_number INTO oidnum
                FROM coll_obj_other_id_num
                WHERE other_id_type = p_other_col_name
                AND collection_object_id = p_key_val;
    ELSE
        oidnum := NULL;
    END IF;
        RETURN oidnum;
END;
*/
   
--COMMON_NAME
DESC uam.common_name;
DESC mvz.common_name;
SELECT COUNT(*) FROM uam.common_name;
SELECT COUNT(*) FROM mvz.common_name;
    
INSERT INTO uam.common_name SELECT * FROM mvz.common_name;

SELECT COUNT(*) FROM uam.common_name;

--CONTAINER
DESC uam.container;
DESC mvz.container;
SELECT COUNT(*) FROM uam.container;
SELECT COUNT(*) FROM mvz.container;
    
INSERT INTO uam.container SELECT * FROM mvz.container;

SELECT COUNT(*) FROM uam.container;

--ELECTRONIC_ADDRESS
DESC uam.electronic_address;
DESC mvz.electronic_address;
SELECT COUNT(*) FROM uam.electronic_address;
SELECT COUNT(*) FROM mvz.electronic_address;
    
INSERT INTO uam.electronic_address SELECT * FROM mvz.electronic_address;

SELECT COUNT(*) FROM uam.electronic_address;

--ENCUMBRANCE
DESC uam.encumbrance;
DESC mvz.encumbrance;
SELECT COUNT(*) FROM uam.encumbrance;
SELECT COUNT(*) FROM mvz.encumbrance;
    
INSERT INTO uam.encumbrance SELECT * FROM mvz.encumbrance;

SELECT COUNT(*) FROM uam.encumbrance;

--FIELD_NOTEBOOK_SECTION
DESC uam.field_notebook_section;
DESC mvz.field_notebook_section;
SELECT COUNT(*) FROM uam.field_notebook_section;
SELECT COUNT(*) FROM mvz.field_notebook_section;
    
INSERT INTO uam.field_notebook_section SELECT * FROM mvz.field_notebook_section;

SELECT COUNT(*) FROM uam.field_notebook_section;

--FLUID_CONTAINER_HISTORY
DESC uam.fluid_container_history;
DESC mvz.fluid_container_history;
SELECT COUNT(*) FROM uam.fluid_container_history;
SELECT COUNT(*) FROM mvz.fluid_container_history;
    
INSERT INTO uam.fluid_container_history SELECT * FROM mvz.fluid_container_history;

SELECT COUNT(*) FROM uam.fluid_container_history;

--FMP_IMAGE_DATA
-- !!!do not migrate.

--GEOG_AUTH_REC
DESC uam.geog_auth_rec;
DESC mvz.geog_auth_rec;
SELECT COUNT(*) FROM uam.geog_auth_rec;
SELECT COUNT(*) FROM mvz.geog_auth_rec;

CREATE TABLE geog_auth_rec_lookup AS
select 
    m.GEOG_AUTH_REC_ID as mvz_geog_auth_rec_id,
    u.GEOG_AUTH_REC_ID as uam_geog_auth_rec_id, 
    m.HIGHER_GEOG 
from mvz.geog_auth_rec m, uam.geog_auth_rec u 
where u.higher_geog = m.higher_geog;

INSERT INTO uam.geog_auth_rec 
SELECT * FROM mvz.geog_auth_rec
WHERE geog_auth_rec_id NOT IN (SELECT mvz_geog_auth_rec_id FROM geog_auth_rec_lookup);

-- see locality section for update to locality.geog_auth_rec_id.

SELECT COUNT(*) FROM uam.geog_auth_rec;

--GROUP_MEMBER
DESC uam.group_member;
DESC mvz.group_member;
SELECT COUNT(*) FROM uam.group_member;
SELECT COUNT(*) FROM mvz.group_member;
    
INSERT INTO uam.group_member SELECT * FROM mvz.group_member;

SELECT COUNT(*) FROM uam.group_member;

--IDENTIFICATION
DESC uam.identification;
DESC mvz.identification;
SELECT COUNT(*) FROM uam.identification;
SELECT COUNT(*) FROM mvz.identification;
    
INSERT INTO uam.identification SELECT * FROM mvz.identification;

SELECT COUNT(*) FROM uam.identification;
    
--IDENTIFICATION_AGENT
DESC uam.identification_agent;
DESC mvz.identification_agent;
SELECT COUNT(*) FROM uam.identification_agent;
SELECT COUNT(*) FROM mvz.identification_agent;
    
INSERT INTO uam.identification_agent SELECT * FROM mvz.identification_agent;

SELECT COUNT(*) FROM uam.identification_agent;
    
--IDENTIFICATION_TAXONOMY
DESC uam.identification_taxonomy;
DESC mvz.identification_taxonomy;
SELECT COUNT(*) FROM uam.identification_taxonomy;
SELECT COUNT(*) FROM mvz.identification_taxonomy;
    
INSERT INTO uam.identification_taxonomy SELECT * FROM mvz.identification_taxonomy;

SELECT COUNT(*) FROM uam.identification_taxonomy;
    
-- !!!migrate these later?!
--IMAGE_CONTENT
--IMAGE_OBJECT
--IMAGE_SUBJECT_REMARKS

--JOURNAL
DESC uam.journal;
DESC mvz.journal;
SELECT COUNT(*) FROM uam.journal;
SELECT COUNT(*) FROM mvz.journal;
    
INSERT INTO uam.journal SELECT * FROM mvz.journal;

SELECT COUNT(*) FROM uam.journal;

--JOURNAL_ARTICLE
DESC uam.journal_article;
DESC mvz.journal_article;
SELECT COUNT(*) FROM uam.journal_article;
SELECT COUNT(*) FROM mvz.journal_article;
    
INSERT INTO uam.journal_article SELECT * FROM mvz.journal_article;

SELECT COUNT(*) FROM uam.journal_article;

--LAT_LONG
DESC uam.lat_long;
DESC mvz.lat_long;
SELECT COUNT(*) FROM uam.lat_long;
SELECT COUNT(*) FROM mvz.lat_long;

--do not bring over lat_long_source_type
ALTER TABLE uam.lat_long ADD spatialfit NUMBER(4,3);

--!!! Carla needs to review these.
--fixed before migration to prod
-- 762 mvz records with no determined_date.
--update mvz.lat_long set determined_date = '01-01-1001' 
--where determined_date is null;

-- 89 mvz records with no lat_long_ref_source.
--update mvz.lat_long set LAT_LONG_REF_SOURCE = 'I should not be null' 
--where LAT_LONG_REF_SOURCE is null;

-- 56 mvz records with 21 chars in orig_lat_long_untis.
--update mvz.lat_long set ORIG_LAT_LONG_UNITS = 'Rijksdriehoeksmeetin' 
--where ORIG_LAT_LONG_UNITS = 'Rijksdriehoeksmeeting';

INSERT INTO uam.lat_long (
 LAT_LONG_ID,
 LOCALITY_ID,
 LAT_DEG,
 DEC_LAT_MIN,
 LAT_MIN,
 LAT_SEC,
 LAT_DIR,
 LONG_DEG,
 DEC_LONG_MIN,
 LONG_MIN,
 LONG_SEC,
 LONG_DIR,
 DEC_LAT,
 DEC_LONG,
 DATUM,
 UTM_ZONE,
 UTM_EW,
 UTM_NS,
 ORIG_LAT_LONG_UNITS,
 DETERMINED_BY_AGENT_ID,
 DETERMINED_DATE,
 LAT_LONG_REF_SOURCE,
 LAT_LONG_REMARKS,
 MAX_ERROR_DISTANCE,
 MAX_ERROR_UNITS,
 NEAREST_NAMED_PLACE,
 LAT_LONG_FOR_NNP_FG,
 FIELD_VERIFIED_FG,
 ACCEPTED_LAT_LONG_FG,
 EXTENT,
 GPSACCURACY,
 GEOREFMETHOD,
 VERIFICATIONSTATUS,
 SPATIALFIT)
SELECT
 LAT_LONG_ID,
 LOCALITY_ID,
 LAT_DEG,
 DEC_LAT_MIN,
 LAT_MIN,
 LAT_SEC,
 LAT_DIR,
 LONG_DEG,
 DEC_LONG_MIN,
 LONG_MIN,
 LONG_SEC,
 LONG_DIR,
 DEC_LAT,
 DEC_LONG,
 DATUM,
 UTM_ZONE,
 UTM_EW,
 UTM_NS,
 ORIG_LAT_LONG_UNITS,
 DETERMINED_BY_AGENT_ID,
 DETERMINED_DATE,
 LAT_LONG_REF_SOURCE,
 LAT_LONG_REMARKS,
 MAX_ERROR_DISTANCE,
 MAX_ERROR_UNITS,
 NEAREST_NAMED_PLACE,
 LAT_LONG_FOR_NNP_FG,
 FIELD_VERIFIED_FG,
 ACCEPTED_LAT_LONG_FG,
 EXTENT,
 GPSACCURACY,
 GEOREFMETHOD,
 VERIFICATIONSTATUS,
 SPATIALFIT
FROM mvz.lat_long;

SELECT COUNT(*) FROM uam.lat_long;

--LOAN
DESC uam.loan;
DESC mvz.loan;
SELECT COUNT(*) FROM uam.loan;
SELECT COUNT(*) FROM mvz.loan;
    
INSERT INTO uam.loan SELECT * FROM mvz.loan;

SELECT COUNT(*) FROM uam.loan;

--LOAN_ITEM
DESC uam.loan_item;
DESC mvz.loan_item;
SELECT COUNT(*) FROM uam.loan_item;
SELECT COUNT(*) FROM mvz.loan_item;
    
INSERT INTO uam.loan_item SELECT * FROM mvz.loan_item;

SELECT COUNT(*) FROM uam.loan_item;

--LOCALITY
DESC uam.locality;
DESC mvz.locality;
SELECT COUNT(*) FROM uam.locality;
SELECT COUNT(*) FROM mvz.locality;
    
INSERT INTO uam.locality SELECT * FROM mvz.locality;

SELECT COUNT(*) FROM uam.locality;

-- not migrating higher geog that already exists at uam. updating these mvz ids to uam ids.
UPDATE uam.locality ul SET ul.geog_auth_rec_id = (
    SELECT gl.uam_geog_auth_rec_id 
    FROM geog_auth_rec_lookup gl
    WHERE ul.geog_auth_rec_id = gl.mvz_geog_auth_rec_id)
WHERE ul.geog_auth_rec_id IN (SELECT mvz_geog_auth_rec_id FROM geog_auth_rec_lookup);

--MEDIA
DESC uam.media;
DESC mvz.media;
SELECT COUNT(*) FROM uam.media;
SELECT COUNT(*) FROM mvz.media;
    
INSERT INTO uam.media SELECT * FROM mvz.media;

SELECT COUNT(*) FROM uam.media;

select seq_media.nextval from dual;
select max(media_id) from media;
alter sequence seq_media increment by ???;
select seq_media.nextval from dual;
alter sequence seq_media increment by 1;
select seq_media.nextval from dual;

--MEDIA_LABELS
DESC uam.media_labels;
DESC mvz.media_labels;
SELECT COUNT(*) FROM uam.media_labels;
SELECT COUNT(*) FROM mvz.media_labels;
    
INSERT INTO uam.media_labels SELECT * FROM mvz.media_labels;

SELECT COUNT(*) FROM uam.media_labels;

select seq_media_labels.nextval from dual;
select max(media_label_id) from uam.media_labels;
alter sequence seq_media_labels increment by ???;
select seq_media_labels.nextval from dual;
alter sequence seq_media_labels increment by 1;
select seq_media_labels.nextval from dual;

--MEDIA_RELATIONS
DESC uam.media_relations;
DESC mvz.media_relations;
SELECT COUNT(*) FROM uam.media_relations;
SELECT COUNT(*) FROM mvz.media_relations;
    
INSERT INTO uam.media_relations SELECT * FROM mvz.media_relations;

SELECT COUNT(*) FROM uam.media_relations;

--OBJECT_CONDITION
DESC uam.object_condition;
DESC mvz.object_condition;
SELECT COUNT(*) FROM uam.object_condition;
SELECT COUNT(*) FROM mvz.object_condition;
    
INSERT INTO uam.object_condition SELECT * FROM mvz.object_condition;

SELECT COUNT(*) FROM uam.object_condition;

--LEFT OFF HERE!!!

--PAGE
DESC uam.page;
DESC mvz.page;
SELECT COUNT(*) FROM uam.page;
SELECT COUNT(*) FROM mvz.page;
    
INSERT INTO uam.page SELECT * FROM mvz.page;

SELECT COUNT(*) FROM uam.page;

--PERMIT
DESC uam.permit;
DESC mvz.permit;
SELECT COUNT(*) FROM uam.permit;
SELECT COUNT(*) FROM mvz.permit;
    
--!! mvz has permit_remark with 285 char.
ALTER TABLE uam.permit MODIFY permit_remarks VARCHAR2(300);
INSERT INTO uam.permit SELECT * FROM mvz.permit;

SELECT COUNT(*) FROM uam.permit;

--PERMIT_TRANS
DESC uam.permit_trans;
DESC mvz.permit_trans;
SELECT COUNT(*) FROM uam.permit_trans;
SELECT COUNT(*) FROM mvz.permit_trans;
    
INSERT INTO uam.permit_trans SELECT * FROM mvz.permit_trans;

SELECT COUNT(*) FROM uam.permit_trans;

--PERSON
DESC uam.person;
DESC mvz.person;
SELECT COUNT(*) FROM uam.person;
SELECT COUNT(*) FROM mvz.person;
    
INSERT INTO uam.person SELECT * FROM mvz.person;

SELECT COUNT(*) FROM uam.person;

--PROJECT
DESC uam.project;
DESC mvz.project;
SELECT COUNT(*) FROM uam.project;
SELECT COUNT(*) FROM mvz.project;
    
INSERT INTO uam.project SELECT * FROM mvz.project;

SELECT COUNT(*) FROM uam.project;

--PROJECT_AGENT
DESC uam.project_agent;
DESC mvz.project_agent;
SELECT COUNT(*) FROM uam.project_agent;
SELECT COUNT(*) FROM mvz.project_agent;
    
INSERT INTO uam.project_agent SELECT * FROM mvz.project_agent;

SELECT COUNT(*) FROM uam.project_agent;

--PROJECT_PUBLICATION
DESC uam.project_publication;
DESC mvz.project_publication;
SELECT COUNT(*) FROM uam.project_publication;
SELECT COUNT(*) FROM mvz.project_publication;
    
INSERT INTO uam.project_publication SELECT * FROM mvz.project_publication;

SELECT COUNT(*) FROM uam.project_publication;

--PROJECT_TRANS
DESC uam.project_trans;
DESC mvz.project_trans;
SELECT COUNT(*) FROM uam.project_trans;
SELECT COUNT(*) FROM mvz.project_trans;
    
INSERT INTO uam.project_trans SELECT * FROM mvz.project_trans;

SELECT COUNT(*) FROM uam.project_trans;

--PUBLICATION
DESC uam.publication;
DESC mvz.publication;
SELECT COUNT(*) FROM uam.publication;
SELECT COUNT(*) FROM mvz.publication;
    
INSERT INTO uam.publication SELECT * FROM mvz.publication;

SELECT COUNT(*) FROM uam.publication;

--PUBLICATION_AUTHOR_NAME
DESC uam.publication_author_name;
DESC mvz.publication_author_name;
SELECT COUNT(*) FROM uam.publication_author_name;
SELECT COUNT(*) FROM mvz.publication_author_name;
    
INSERT INTO uam.publication_author_name SELECT * FROM mvz.publication_author_name;

SELECT COUNT(*) FROM uam.publication_author_name;

--PUBLICATION_URL
DESC uam.publication_url;
DESC mvz.publication_url;
SELECT COUNT(*) FROM uam.publication_url;
SELECT COUNT(*) FROM mvz.publication_url;
    
INSERT INTO uam.publication_url SELECT * FROM mvz.publication_url;

SELECT COUNT(*) FROM uam.publication_url;

-- missing from prod
alter table PUBLICATION_URL 
add constraint PK_PUBLICATION_URL 
primary key (PUBLICATION_URL_ID);

--SHIPMENT
DESC uam.shipment;
DESC mvz.shipment;
SELECT COUNT(*) FROM uam.shipment;
SELECT COUNT(*) FROM mvz.shipment;
    
INSERT INTO uam.shipment SELECT * FROM mvz.shipment;

SELECT COUNT(*) FROM uam.shipment;

--SPECIMEN_PART
DESC uam.specimen_part;
DESC mvz.specimen_part;
SELECT COUNT(*) FROM uam.specimen_part;
SELECT COUNT(*) FROM mvz.specimen_part;

-- must remove bad sampled_from_obj_id numbers.
create table bad_sampled_from_obj_id as 
select collection_object_id, derived_from_cat_item, sampled_from_obj_id 
from mvz.specimen_part where sampled_from_obj_id not in (
    select collection_object_id from mvz.specimen_part);

select count(*) from bad_sampled_from_obj_id;

INSERT INTO uam.specimen_part SELECT * FROM mvz.specimen_part;

update specimen_part set SAMPLED_FROM_OBJ_ID = null 
where SAMPLED_FROM_OBJ_ID in (
    select SAMPLED_FROM_OBJ_ID from bad_sampled_from_obj_id);

select count(*) from specimen_part  
where sampled_from_obj_id not in (
    select collection_object_id from specimen_part);

SELECT COUNT(*) FROM uam.specimen_part;

-- need to rebuild trigger make_part_coll_obj_cont'

DROP TRIGGER MAKE_PART_COLL_OBJ_CONT;

select max(container_id) from container;

create sequence sq_container_id nocache start with 11760685;

CREATE OR REPLACE TRIGGER TR_SPECIMENPART_AI
after insert ON specimen_part
FOR EACH ROW
declare
label varchar2(255);
institution_acronym varchar2(255);
BEGIN
    select
        collection.institution_acronym,
        collection.collection || ' ' || cataloged_item.cat_num || ' ' || :NEW.part_name
    INTO
        institution_acronym,
        label
    FROM
        collection,
        cataloged_item
    WHERE collection.collection_id = cataloged_item.collection_id 
    AND cataloged_item.collection_object_id = :NEW.derived_from_cat_item;
    
    INSERT INTO container (
        CONTAINER_ID,
		PARENT_CONTAINER_ID,
		CONTAINER_TYPE,
		LABEL,
		locked_position,
		institution_acronym)
    VALUES (
		sq_container_id.nextval,
		0,
		'collection object',
		label,
		0,
		institution_acronym);

    INSERT INTO coll_obj_cont_hist (
        COLLECTION_OBJECT_ID,
		CONTAINER_ID,
		INSTALLED_DATE,
		CURRENT_CONTAINER_FG)
    VALUES (
		:NEW.collection_object_id,
		sq_container_id.currval,
		sysdate,
		1);
EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20000, 'trigger problems: ' || SQLERRM);
end;
/

/* trigger at prod:
  CREATE OR REPLACE TRIGGER "UAM"."MAKE_PART_COLL_OBJ_CONT"
after insert ON specimen_part
FOR EACH ROW
declare
        CONTAINER_ID number;
        label varchar2(255);
        institution_acronym varchar2(255);
BEGIN

        select max(container_id) + 1 into container_id from container;

        select
                collection.institution_acronym,
                collection.collection || ' ' || cataloged_item.cat_num || ' ' || :NEW.part_nam
e
        INTO
                institution_acronym,
                label
        FROM
                collection,
                cataloged_item
        WHERE
                collection.collection_id = cataloged_item.collection_id AND
                cataloged_item.collection_object_id = :NEW.derived_from_cat_item
        ;
        INSERT INTO container (
                CONTAINER_ID,
                PARENT_CONTAINER_ID,
                CONTAINER_TYPE,
                LABEL,
                locked_position,
                institution_acronym)
        VALUES (
                container_id,
                0,
                'collection object',
                label,
                0,
                institution_acronym
                );

        INSERT INTO coll_obj_cont_hist (
                COLLECTION_OBJECT_ID,
                CONTAINER_ID,
                INSTALLED_DATE,
                CURRENT_CONTAINER_FG)
        VALUES (
                :NEW.collection_object_id,
                container_id,
                sysdate,
                1);
EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20000, 'trigger problems: ' || SQLERRM);
end;
*/

-- !!! migrate later?
--STILL_IMAGE

--TAB_MEDIA_REL_FKEY
DESC uam.tab_media_rel_fkey;
DESC mvz.tab_media_rel_fkey;
SELECT COUNT(*) FROM uam.tab_media_rel_fkey;
SELECT COUNT(*) FROM mvz.tab_media_rel_fkey;
    
ALTER TABLE uam.tab_media_rel_fkey ADD cfk_locality NUMBER;
ALTER TABLE uam.tab_media_rel_fkey ADD cfk_collecting_event NUMBER;

INSERT INTO uam.tab_media_rel_fkey (
    MEDIA_RELATIONS_ID,
    CFK_CATALOGED_ITEM,
    CFK_AGENT,
    CFK_LOCALITY,
    CFK_COLLECTING_EVENT)
SELECT
    MEDIA_RELATIONS_ID,
    CFK_CATALOGED_ITEM,
    CFK_AGENT,
    CFK_LOCALITY,
    CFK_COLLECTING_EVENT
FROM mvz.tab_media_rel_fkey;

SELECT COUNT(*) FROM uam.tab_media_rel_fkey;

--need to run code to merge uam/mvz taxonomy.
run migrate_taxonomy.sql

--TAXONOMY
DESC uam.taxonomy;
DESC mvz.taxonomy;
SELECT COUNT(*) FROM uam.taxonomy;
SELECT COUNT(*) FROM mvz.taxonomy;

SELECT COUNT(*) FROM uam.taxonomy;

select max(taxon_name_id) from uam.taxonomy;
select max(taxon_name_id) from mvz.taxonomy;

--TAXON_RELATIONS
DESC uam.taxon_relations;
DESC mvz.taxon_relations;
SELECT COUNT(*) FROM uam.taxon_relations;
SELECT COUNT(*) FROM mvz.taxon_relations;
    
INSERT INTO uam.taxon_relations SELECT * FROM mvz.taxon_relations;

SELECT COUNT(*) FROM uam.taxon_relations;

--TRANS
DESC uam.trans;
DESC mvz.trans;
SELECT COUNT(*) FROM uam.trans;
SELECT COUNT(*) FROM mvz.trans;

--update all trans.collection_ids for mvz
alter table trans add collection_id number;

update trans set collection_id = 29
where transaction_id in (
    select a.transaction_id from cataloged_item ci, accn a
    where a.transaction_id = ci.accn_id (+)
    and ci.accn_id is null);
--271 records updated

create table lkv_collid_transid as
select distinct collection_id, accn_id
from cataloged_item;

select count(*) from lkv_collid_transid;
--16128 records

create table lkv_coll_id_transid_single as
select * from lkv_collid_transid 
where accn_id in (
select accn_id
from lkv_collid_transid
group by accn_id having count(*) = 1);

select count(*) from lkv_coll_id_transid_single;
--12369 records

update trans t set t.collection_id = (
    select l.collection_id from lkv_coll_id_transid_single l
    where l.accn_id = t.transaction_id)
where exists (
    select t.transaction_id
    from trans t, lkv_coll_id_transid_single l
    where t.transaction_id = l.accn_id)
and t.collection_id is null;
--12369 records updated

create table lkv_coll_id_transid_multiple as
select * from lkv_collid_transid 
where accn_id in (
select accn_id 
from lkv_collid_transid 
group by accn_id having count(*) > 1);

select count(*) from lkv_coll_id_transid_multiple;
--3759 records

create table lkv_coll_id_transid_mult_count as
select count(*) as cnt, collection_id, accn_id
from cataloged_item
where accn_id in (
    select distinct accn_id
    from lkv_coll_id_transid_multiple)
group by collection_id, accn_id;

select count(*) from lkv_coll_id_transid_mult_cnt_r;
--3759 records

alter table lkv_coll_id_transid_mult_cnt_r add fg number(1);

declare c number;
begin
    for an in (
        select distinct accn_id
        from lkv_coll_id_transid_mult_cnt_r
        order by accn_id
    ) loop
        select max(cnt) into c 
        from lkv_coll_id_transid_mult_cnt_r
        where accn_id = an.accn_id;
        
        update lkv_coll_id_transid_mult_cnt_r
        set fg = 1
        where cnt = c
        and accn_id = an.accn_id;
    end loop;
end;

select count(*) from (
    select count(*), accn_id, fg
    from lkv_coll_id_transid_mult_cnt_r
    WHERE fg = 1
    group by accn_id, fg
    having count(*) = 1);
--1437 records

create table lkv_coll_id_transid_mult_cnt1 as
select * from lkv_coll_id_transid_mult_cnt_r
where accn_id in (
    select accn_id from (
        select accn_id, fg
        from lkv_coll_id_transid_mult_cnt_r
        where fg = 1
        group by accn_id, fg
        having count(*) = 1
    )
)
and fg = 1;

update trans t set t.collection_id = (
    select l.collection_id
    from lkv_coll_id_transid_mult_cnt1 l
    where l.accn_id = t.transaction_id)
where t.collection_id is null
and t.transaction_id in (
    select accn_id from lkv_coll_id_transid_mult_cnt1);
--1437 records updated.

create table lkv_coll_id_transid_mult_cnt2 as
select * from lkv_coll_id_transid_mult_cnt_r
where accn_id in (
    select accn_id from (
        select accn_id, fg
        from lkv_coll_id_transid_mult_cnt_r
        where fg = 1
        group by accn_id, fg
        having count(*) > 1
    )
)
and fg = 1;
--331 records.

update trans set collection_id = 29 
where collection_id is null
and transaction_id in (
select distinct accn_id from lkv_coll_id_transid_mult_cnt_2);
--163 records

create table lkv_loan_zerospec as 
select * from loan
where transaction_id in (
    select l.transaction_id 
    from loan l, loan_item li
    where l.transaction_id = li.transaction_id (+)
    and li.transaction_id is null);
--98 records

update trans set collection_id = 29
where transaction_id in (
    select l.transaction_id from loan l, loan_item li
    where l.transaction_id = li.transaction_id (+)
    and li.transaction_id is null
)
and collection_id is null

create table lkv_collid_loanid as
select distinct ci.collection_id, li.transaction_id
from cataloged_item ci, loan_item li, specimen_part sp
where li.collection_object_id = sp.collection_object_id
and sp.derived_from_cat_item = ci.collection_object_id

mvz@arctos> update trans t set t.collection_id = (
  2  select l.collection_id
  3  from lkv_collid_loanid l
  4  where t.transaction_id = l.transaction_id)
  5  where t.transaction_id != 21063205
  6  and t.collection_id is null;

update trans set collection_id = 28 where transaction_id = 21063205;

/* !!! Carla needs to review these transactions.
in trans as loan and accn, but not in loan, accn tables.
  1  select transaction_type, transaction_id from trans where collection_id is null
  2* order by transaction_type, transaction_id
mvz@arctos> /

TRANSACTION_TYPE   TRANSACTION_ID
------------------ --------------
accn                     10013418
accn                     10013665
accn                     10013667
accn                     10013676
accn                     10013677
accn                     10013678
accn                     10013679
accn                     10013693
accn                     10013694
accn                     10013754
accn                     10013812
accn                     10013818
accn                     10014167
accn                     21039185
accn                     21062376
accn                     21062495
accn                     21062711
accn                     21062816
loan                     10013686
loan                     10013688
loan                     10013689
loan                     10013690
loan                     10013691
loan                     10013700
loan                     10013706
loan                     21062911

26 rows selected.

Elapsed: 00:00:00.00
*/

update trans set collection_id = 29 where collection_id is null;
/* fixes zero specimen loans:

select l.transaction_id || chr(9) || t.transaction_type || chr(9) || l.loan_number || chr(9) || substr(l.loan_number,11,14)
from trans t, loan l, loan_item li
where t.transaction_id = l.transaction_id
and l.transaction_id = li.transaction_id (+)
and li.transaction_id is null
and t.collection_id > 27
order by substr(l.loan_number,11,14), l.transaction_id

update trans set collection_id = 30
where collection_id = 29
and transaction_id in (
	select l.transaction_id
	from trans t, loan l, loan_item li
	where t.transaction_id = l.transaction_id
	and l.transaction_id = li.transaction_id (+)
	and li.transaction_id is null
	and t.collection_id > 27
	and substr(l.loan_number,11,14) = 'Herp'
);

update trans set collection_id = 28
where collection_id = 29
and transaction_id in (
	select l.transaction_id
	from trans t, loan l, loan_item li
	where t.transaction_id = l.transaction_id
	and l.transaction_id = li.transaction_id (+)
	and li.transaction_id is null
	and t.collection_id > 27
	and substr(l.loan_number,11,14) = 'Mamm'
);
 
update trans set collection_id = 33 where transaction_id = 21062765;

-- bird loans were already set to collection_id=29
*/
-- end of collection_id population for mvz stuff.

INSERT INTO uam.trans SELECT * FROM mvz.trans;

SELECT COUNT(*) FROM uam.trans;

-- populate trans.collection_id
ALTER TABLE trans ADD collection_id NUMBER;

-- update for those transactions that use only one collection
DECLARE cid NUMBER;
c NUMBER;
BEGIN
-- loans
    FOR r IN (SELECT transaction_id FROM trans WHERE transaction_type='loan') LOOP
        SELECT COUNT(distinct(collection_id)) INTO c FROM 
            loan_item,
            specimen_part,
            cataloged_item
        WHERE loan_item.transaction_id=r.transaction_id 
        AND loan_item.collection_object_id = specimen_part.collection_object_id 
        AND specimen_part.derived_from_cat_item = cataloged_item.collection_object_id;
        
        IF c=1 THEN
            SELECT collection_id INTO cid FROM 
                loan_item,
                specimen_part,
                cataloged_item
            WHERE loan_item.transaction_id=r.transaction_id 
            AND loan_item.collection_object_id = specimen_part.collection_object_id 
            AND specimen_part.derived_from_cat_item = cataloged_item.collection_object_id
            GROUP BY collection_id;
            
            UPDATE trans SET collection_id = cid WHERE transaction_id=r.transaction_id;
        END IF;
            
        --- same thing for UAM's retarded cataloged item loans
        SELECT COUNT(DISTINCT(collection_id)) INTO c 
        FROM 
            loan_item,
            cataloged_item
        WHERE loan_item.transaction_id=r.transaction_id 
        AND loan_item.collection_object_id = cataloged_item.collection_object_id;
        
        IF c=1 then
            SELECT collection_id INTO cid 
            FROM
                loan_item,
                cataloged_item
            WHERE loan_item.transaction_id=r.transaction_id 
            AND loan_item.collection_object_id = cataloged_item.collection_object_id
            GROUP BY collection_id;
            
            UPDATE trans SET collection_id=cid WHERE transaction_id=r.transaction_id;
        END IF;
    END LOOP;
    
-- accessions
    FOR r IN (SELECT transaction_id FROM trans WHERE transaction_type = 'accn') LOOP
        SELECT COUNT(DISTINCT(collection_id)) INTO c 
        FROM cataloged_item
        WHERE cataloged_item.accn_id = r.transaction_id;
        
        IF c = 1 THEN
            SELECT collection_id INTO cid 
            FROM cataloged_item
            WHERE cataloged_item.accn_id=r.transaction_id
            GROUP BY collection_id;
            
            UPDATE trans SET collection_id=cid WHERE transaction_id=r.transaction_id;
        END IF;
  END LOOP;
END;
/

SELECT COUNT(*), transaction_type 
FROM trans 
WHERE collection_id IS NULL 
GROUP BY transaction_type;

--- see if we can figure out what we missed
SELECT * FROM borrow, trans 
WHERE borrow.transaction_id = trans.transaction_id 
AND collection_id IS NULL;

--- MVZ Dev borrows are all fake; kill em
-- begin useless block
DELETE FROM trans_agent WHERE transaction_id IN (SELECT transaction_id FROM borrow);

CREATE TABLE tt AS SELECT transaction_id FROM borrow;

DELETE FROM borrow;

DELETE FROM trans WHERE transaction_id IN (SELECT transaction_id FROM tt);

DELETE FROM trans where transaction_type = 'borrow';
-- and one borrow was actually an accn - craps - above code is useless...

-- little sloppier, but see what else we can get by number + acronym
BEGIN
    FOR c IN (SELECT collection_id, collection_cde, institution_acronym FROM collection) LOOP
        FOR t IN (
            SELECT trans.transaction_id, accn_number, institution_acronym
            FROM accn, trans 
            WHERE accn.transaction_id=trans.transaction_id 
            AND collection_id IS NULL) LOOP
                
            IF (c.institution_acronym = t.institution_acronym) 
                AND (instr(t.accn_number, c.collection_cde) > 0
            ) THEN
                 UPDATE trans SET collection_id = c.collection_id 
                 WHERE transaction_id=t.transaction_id;
                 --dbms_output.put_line('c.institution_acronym=' || c.institution_acronym || '; t.institution_acronym=' || t.institution_acronym || '; t.accn_number=' || t.accn_number || '; c.collection_cde=' || c.collection_cde);
            END IF;                   
        END LOOP;
    END LOOP;
END;
/

-- even sloppier, revert to (now defunct but still present) ACCN_NUM_SUFFIX
BEGIN
    FOR c IN (SELECT collection_id, collection_cde, institution_acronym FROM collection) LOOP
        FOR t IN (
            SELECT trans.transaction_id, accn_num_suffix, institution_acronym 
            FROM accn, trans 
            WHERE accn.transaction_id = trans.transaction_id 
            AND collection_id IS NULL
        ) LOOP
            IF (c.institution_acronym = t.institution_acronym) 
                AND (instr(t.accn_num_suffix, c.collection_cde) > 0
            ) THEN
                UPDATE trans SET collection_id = c.collection_id 
                WHERE transaction_id = t.transaction_id;
                --dbms_output.put_line('c.institution_acronym=' || c.institution_acronym || '; t.institution_acronym=' || t.institution_acronym || '; t.accn_num_suffix=' || t.accn_num_suffix || '; c.collection_cde=' || c.collection_cde);
            END IF;                   
        END LOOP;
    END LOOP;
END;
/
-- the rest of the accns probably have to be dealt with manually.
-- these are multi-collection accns at MVZ - OK to just pick a collection?
-- Collection_id
SELECT accn_number || chr(9) || nature_of_material || chr(9) || collection || chr(9) || COUNT(collection_object_id)
FROM
    accn,
	trans,
	cataloged_item,
	collection
WHERE accn.transaction_id = trans.transaction_id 
AND accn.transaction_id=cataloged_item.accn_id (+) 
AND cataloged_item.collection_id = collection.collection_id (+) 
AND trans.collection_id IS NULL
GROUP BY accn_number, nature_of_material, collection
ORDER BY accn_number;

---- USGS accns are MSB:
UPDATE trans SET collection_id = (
    SELECT collection_id FROM collection WHERE collection_cde = 'Mamm' AND institution_acronym = 'MSB')
WHERE transaction_id IN (SELECT transaction_id FROM accn WHERE accn_number LIKE '%USGS%');

--- same drill for loans
BEGIN
    FOR c IN (SELECT collection_id,collection_cde,institution_acronym FROM collection) LOOP
        FOR t IN (
            SELECT trans.transaction_id, loan_number, institution_acronym 
            FROM loan,trans 
            WHERE loan.transaction_id = trans.transaction_id 
            AND collection_id IS NULL
        ) LOOP
            IF (c.institution_acronym = t.institution_acronym) 
                AND (instr(t.loan_number,c.collection_cde) > 0
            ) THEN
                UPDATE trans SET collection_id = c.collection_id 
                WHERE transaction_id=t.transaction_id;
                --dbms_output.put_line('c.institution_acronym=' || c.institution_acronym || '; t.institution_acronym=' || t.institution_acronym || '; t.loan_number=' || t.loan_number || '; c.collection_cde=' || c.collection_cde);
             END IF;                   
        END LOOP;
    END LOOP;
END;
/
-- gets all but 8 MVZ loans - hope we get so lucky at UAM....

SELECT loan_number || chr(9) || nature_of_material || chr(9) || collection || chr(9) || COUNT(cataloged_item.collection_object_id)
FROM
    loan,
	trans,
	loan_item,
	specimen_part,
	cataloged_item,
	collection
WHERE trans.transaction_id = loan.transaction_id 
AND loan.transaction_id=loan_item.transaction_id (+) 
AND loan_item.collection_object_id = specimen_part.collection_object_id (+) 
AND specimen_part.derived_from_cat_item = cataloged_item.collection_object_id (+) 
AND cataloged_item.collection_id = collection.collection_id (+) 
AND trans.collection_id IS NULL
GROUP BY loan_number, nature_of_material, collection
UNION
SELECT loan_number || chr(9) || nature_of_material || chr(9) || collection || chr(9) || COUNT(cataloged_item.collection_object_id)
FROM
    loan,
	trans,
    loan_item,
	cataloged_item,
	collection
WHERE trans.transaction_id = loan.transaction_id 
AND loan.transaction_id=loan_item.transaction_id (+) 
AND loan_item.collection_object_id = cataloged_item.collection_object_id (+) 
AND cataloged_item.collection_id = collection.collection_id (+) 
AND trans.collection_id IS NULL
GROUP BY loan_number, nature_of_material, collection;

UPDATE trans SET collection_id = (
    SELECT collection_id FROM collection WHERE collection_cde='VPal' AND institution_acronym='UAM')
WHERE transaction_id IN (SELECT transaction_id FROM loan WHERE loan_number LIKE '%Paleo%');

---- The above gets all but a handful of transactions. Clean up the rest manually in prod.
---- Absolutely no reason to worry about them in dev.
---- To make dev happy, run the following.
---- DO NOT RUN THIS IN A PRODUCTION ENVIRONMENT
---- update trans set collection_id=1 where collection_id is null;
---- after all is clean, seal it up

ALTER TABLE trans MODIFY collection_id NOT NULL;
    
ALTER TABLE trans
add CONSTRAINT fk_trans_colln
FOREIGN KEY (collection_id)
REFERENCES collection(collection_id);    
alter table trans modify INSTITUTION_ACRONYM null;
    


--TRANS_AGENT
DESC uam.trans_agent;
DESC mvz.trans_agent;
SELECT COUNT(*) FROM uam.trans_agent;
SELECT COUNT(*) FROM mvz.trans_agent;
    
INSERT INTO uam.trans_agent SELECT * FROM mvz.trans_agent;

SELECT COUNT(*) FROM uam.trans_agent;

/* DLM already dropped this table 
--VIEWER
DESC uam.viewer;
DESC mvz.viewer;
SELECT COUNT(*) FROM uam.viewer;
SELECT COUNT(*) FROM mvz.viewer;
    
INSERT INTO uam.viewer SELECT * FROM mvz.viewer;

SELECT COUNT(*) FROM uam.viewer;
*/

-- re-enable triggers

alter trigger UP_FLAT_ACCN enable;
alter trigger BUILD_FORMATTED_ADDR enable;
alter trigger DEL_AGENT_NAME enable;
alter trigger INS_AGENT_NAME enable;
alter trigger PRE_DEL_AGENT_NAME enable;
alter trigger PRE_UP_INS_AGENT_NAME enable;
alter trigger UP_FLAT_AGENTNAME enable;
alter trigger UP_INS_AGENT_NAME enable;
alter trigger ALA_PLANT_IMAGING_KEY enable;
alter trigger ATTRIBUTE_CT_CHECK enable;
alter trigger ATTRIBUTE_DATA_CHECK enable;
alter trigger UP_FLAT_SEX enable;
alter trigger RELATIONSHIP_CT_CHECK enable;
alter trigger UP_FLAT_RELN enable;
alter trigger TD_BULKLOADER enable;
alter trigger AD_FLAT_CATITEM enable;
alter trigger A_FLAT_CATITEM enable;
alter trigger TI_FLAT_CATITEM enable;
alter trigger TU_FLAT_CATITEM enable;
alter trigger CF_CANNED_SEARCH_TRG enable;
alter trigger CF_FORM_PERMISSIONS_KEY enable;
alter trigger CF_LOG_ID enable;
alter trigger CF_REPORT_SQL_KEY enable;
alter trigger TRG_CF_SPEC_RES_COLS_ID enable;
alter trigger CF_TEMP_AGENTS_KEY enable;
alter trigger CF_TEMP_ATTRIBUTES_KEY enable;
alter trigger CF_TEMP_CITATION_KEY enable;
alter trigger CF_TEMP_LOAN_ITEM_KEY enable;
alter trigger CF_TEMP_OIDS_KEY enable;
alter trigger CF_TEMP_PARTS_KEY enable;
alter trigger CF_TEMP_TAXONOMY_KEY enable;
alter trigger CF_PW_CHANGE enable;
alter trigger CF_VERSION_PKEY_TRG enable;
alter trigger CF_VERSION_LOG_PKEY_TRG enable;
alter trigger UP_FLAT_CITATION enable;
alter trigger A_FLAT_COLLEVNT enable;
alter trigger COLLECTING_EVENT_CT_CHECK enable;
alter trigger UP_FLAT_COLLECTOR enable;
alter trigger COLL_OBJECT_CT_CHECK enable;
alter trigger TRG_OBJECT_CONDITION enable;
alter trigger UP_FLAT_COLLOBJ enable;
alter trigger UP_FLAT_COLL_OBJ_ENCUMBER enable;
alter trigger UP_FLAT_REMARK enable;
alter trigger COLL_OBJ_DATA_CHECK enable;
alter trigger COLL_OBJ_DISP_VAL enable;
alter trigger OTHER_ID_CT_CHECK enable;
alter trigger UP_FLAT_OTHERIDS enable;
alter trigger GET_CONTAINER_HISTORY enable;
alter trigger MOVE_CONTAINER enable;
alter trigger CONTAINER_CHECK_ID enable;
alter trigger MEDIA_RELATIONS_CT enable;
alter trigger TI_FLUID_CONTAINER_HISTORY enable;
alter trigger TU_FLUID_CONTAINER_HISTORY enable;
alter trigger TRG_MK_HIGHER_GEOG enable;
alter trigger UP_FLAT_GEOG enable;
alter trigger GEOLOGY_ATTRIBUTES_CHECK enable;
alter trigger GEOLOGY_ATTRIBUTES_SEQ enable;
alter trigger CTGEOLOGY_ATTRIBUTES_CHECK enable;
alter trigger GEOL_ATT_HIERARCHY_SEQ enable;
alter trigger IDENTIFICATION_CT_CHECK enable;
alter trigger UP_FLAT_ID enable;
alter trigger IDENTIFICATION_AGENT_TRG enable;
alter trigger UP_FLAT_AGNT_ID enable;
alter trigger UP_FLAT_ID_TAX enable;
alter trigger LAT_LONG_CT_CHECK enable;
alter trigger UPDATECOORDINATES enable;
alter trigger UP_FLAT_LAT_LONG enable;
alter trigger LOCALITY_CT_CHECK enable;
alter trigger UP_FLAT_LOCALITY enable;
alter trigger MEDIA_SEQ enable;
alter trigger MEDIA_LABELS_SEQ enable;
alter trigger MEDIA_RELATIONS_AFTER enable;
alter trigger MEDIA_RELATIONS_CHK enable;
alter trigger MEDIA_RELATIONS_SEQ enable;
alter trigger TRIG_PROJECT_SPONSOR_ID enable;
alter trigger SPECIMEN_ANNOTATIONS_KEY enable;
alter trigger IS_TISSUE_DEFAULT enable;
alter trigger MAKE_PART_COLL_OBJ_CONT enable;
alter trigger SPECIMEN_PART_CT_CHECK enable;
alter trigger TR_SPECIMENPART_AD enable;
alter trigger UP_FLAT_PART enable;
alter trigger UP_SPEC_WITH_LOC enable;
alter trigger TRG_MK_SCI_NAME enable;
alter trigger TRG_UP_TAX enable;
alter trigger UPDATE_ID_AFTER_TAXON_CHANGE enable;
alter trigger TRANS_AGENT_ENTERED enable;
alter trigger TRANS_AGENT_PRE enable;
-- rebuild foreign keys
see vpd_triggers_keys.sql

    
-- next step: get rid OF junk objects
/* original notes by dlm 
--ACCN
--ADDR
--AGENT
DROP TABLE AGENT20080110;
--AGENT_NAME
DROP TABLE AGENT_NAME20080110;
-- used by trigger that (poorly) controls 1 preferred name: AGENT_NAME_PENDING_DELETE
--AGENT_RELATIONS
ALA_PLANT_IMAGING
DROP TABLE ALA_PLANT_IMAGING20070619;
-- may be junk?? ALERT_LOG
-- ditto ALERT_LOG_DISK
--ATTRIBUTES
DROP TABLE ATTRIBUTES20071204;
DROP TABLE BARCODE;
--BINARY_OBJECT
--BIOL_INDIV_RELATIONS
DROP TABLE BIOL_INDIV_REMARK;
DROP TABLE BO;
--BOOK
--BOOK_SECTION
--BORROW
--BULKLOADER
-- used by the data entry app: BULKLOADER_ATTEMPTS
-- used by data entry: BULKLOADER_CLONE
-- archive of loaded things: BULKLOADER_DELETES
-- temp storage for load process: BULKLOADER_KEYS
-- BULKLOADER_STAGE
DROP TABLE BULKLOADER_TEMPLATE;
--CATALOGED_ITEM
--cct_bla TABLES are dynamically created FOR USE BY THE search screen
-- used by ColdFions: CDATA
-- used by coldfusion: CFFLAGS
DROP TABLE CFRELEASE_NOTES;
-- cf_bla tables are used by coldfusion
DROP TABLE CF_FORM_PERMISSIONS080323;
-- used by CF: CGLOBAL
--CITATION
DROP TABLE CITATION20071101;
DROP TABLE COLD_FUSION_USERS;
--COLLECTING_EVENT
--COLLECTION
--COLLECTION_CONTACTS
--COLLECTOR
--COLLECTOR_FORMATTED
--COLL_OBJECT
--COLL_OBJECT_ENCUMBRANCE
--COLL_OBJECT_REMARK
DROP TABLE COLL_OBJECT_RESTRICTION;
--COLL_OBJ_CONT_HIST
COLL_OBJ_OTHER_ID_NUM
DROP TABLE COLL_OBJ_OTHER_ID_NUM111307;
DROP TABLE COLL_OBJ_OTHER_ID_NUM20080220;
DROP TABLE COLL_OBJ_OTHER_ID_NUM_OLD;
--COMMON_NAME
--CONTAINER
--CONTAINER_CHECK
--CONTAINER_HISTORY
--CORRESPONDENCE
DROP TABLE CSN;
-- all ctbla table are code tables
-- special CT: CT_ATTRIBUTE_CODE_TABLES
DROP TABLE DEACCN;
DROP TABLE DEACC_ITEM;
DROP TABLE DEV_TASK;
--used by DGR to track non-unique barcodes: DGR_LOCATOR
DROP TABLE DGR_LOCATOR_20071126;
DROP TABLE DGR_LOCATOR_20071210;
DROP TABLE DGR_LOC_F3;
DROP TABLE DOCUMENTATION;
--ELECTRONIC_ADDRESS
--ENCUMBRANCE
DROP TABLE FIB;
--FIELD_NOTEBOOK_SECTION
--FLAT
-- used by procedure: FLAT_IS_BROKEN
--FLUID_CONTAINER_HISTORY
--GEOG_AUTH_REC
DROP TABLE GEOG_RELATIONS;
--GEOLOGY_ATTRIBUTES
--GEOLOGY_ATTRIBUTE_HIERARCHY
DROP TABLE GROUP_MASTER;
GROUP_MEMBER
DROP TABLE GROUP_PERSON;
DROP TABLE HIERARCHICAL_PART_NAME;
DROP TABLE I;
--IDENTIFICATION
--IDENTIFICATION_AGENT
--IDENTIFICATION_TAXONOMY
DROP TABLE IPNI;
DROP TABLE IPNI_ALREADY_THERE;
DROP TABLE IPNI_DUPS;
DROP TABLE IPNI_FIX;
DROP TABLE IPNI_GOTSDUPS;
--JOURNAL
--JOURNAL_ARTICLE
--LAT_LONG
--LOAN
--LOAN_INSTALLMENT
--LOAN_ITEM
--LOAN_REQUEST
--LOCALITY
DROP TABLE MODEL;
DROP TABLE NOTES_OF_COLL_EVENT;
DROP TABLE NUMBERS;
--used IN gap-finding: NUMS
--OBJECT_CONDITION
DROP table OIDN;
DROP TABLE ORG;
-- maybe not used?? MVZ?? PAGE
DROP TABLE PART_HIERARCHY;
--PERMIT
--PERMIT_SHIPMENT
--PERMIT_TRANS
--PERSON
DROP TABLE PERSON20080110;
-- oracle SQL optimizer: PLAN_TABLE
-- beats me?? PLSQL_PROFILER_DATA
-- ditto: PLSQL_PROFILER_RUNS
-- ?? PLSQL_PROFILER_UNITS
-- used by bulk procedure: PROC_BL_STATUS
--PROJECT
--PROJECT_AGENT
DROP TABLE PROJECT_COLL_EVENT;
--PROJECT_PUBLICATION
DROP TABLE PROJECT_REMARK;
--PROJECT_SPONSOR
--PROJECT_TRANS
--PUBLICATION
--PUBLICATION_AUTHOR_NAME
--PUBLICATION_URL
DROP TABLE PUBLICATION_YEAR;
-- can maybe go to attributes? Nevermind...going for it!
DROP TABLE REARING_EVENT;
--SHIPMENT
--SPECIMEN_ANNOTATIONS
--SPECIMEN_PART
DROP TABLE T;
--TAXONOMY
--used by trigger when updating taxonomy: TAXONOMY_ARCHIVE
--TAXON_RELATIONS
DROP TABLE TEMPAGENT;
-- used by CF: TEMP_ALLOW_CF_USER
--TRANS
--TRANS_AGENT
DROP TABLE TRANS_AGENT_ADDR;
DROP TABLE URL;
-- CF User table: USER_DATA
-- CF User table: USER_LOAN_ITEM
-- CF User table: USER_LOAN_REQUEST
-- CF User table: USER_ROLES
-- CF User table: USER_TABLE_ACCESS
--VESSEL
DROP TABLE VIEWER;
*/

/* list of valid tables
--ACCN
--ADDR
--AGENT
--AGENT_NAME
--AGENT_NAME_PENDING_DELETE /* used by trigger that (poorly) controls 1 preferred name */
--AGENT_RELATIONS
--ATTRIBUTES
--BINARY_OBJECT /* to be dropped upon implementation of media */
--BIOL_INDIV_RELATIONS
--BOOK
--BOOK_SECTION
--BORROW
--CATALOGED_ITEM
--CITATION
--COLLECTING_EVENT
--COLLECTION
--COLLECTION_CONTACTS
--COLLECTOR
--COLL_OBJECT
--COLL_OBJECT_ENCUMBRANCE
--COLL_OBJECT_REMARK
--COLL_OBJ_CONT_HIST
--COLL_OBJ_OTHER_ID_NUM
--COMMON_NAME
--CONTAINER
--CONTAINER_CHECK
--CONTAINER_HISTORY
--ELECTRONIC_ADDRESS
--ENCUMBRANCE
--FIELD_NOTEBOOK_SECTION
--FLUID_CONTAINER_HISTORY
--GEOG_AUTH_REC
--GEOLOGY_ATTRIBUTES
--GEOLOGY_ATTRIBUTE_HIERARCHY
--GROUP_MEMBER
--IDENTIFICATION
--IDENTIFICATION_AGENT
--IDENTIFICATION_TAXONOMY
--JOURNAL
--JOURNAL_ARTICLE
--LAT_LONG
--LOAN
--LOAN_INSTALLMENT
--LOAN_ITEM
--LOCALITY
--OBJECT_CONDITION
--PAGE maybe not used?? MVZ??
--PERMIT
--PERMIT_TRANS
--PERSON
--PROJECT
--PROJECT_AGENT
--PROJECT_PUBLICATION
--PROJECT_SPONSOR
--PROJECT_TRANS
--PUBLICATION
--PUBLICATION_AUTHOR_NAME
--PUBLICATION_URL
--SHIPMENT
--SPECIMEN_ANNOTATIONS
--SPECIMEN_PART
--TAXONOMY
--TAXONOMY_ARCHIVE /* does not exist at MVZ; used by trigger when updating taxonomy  */
--TAXON_RELATIONS
--TRANS
--TRANS_AGENT
--VESSEL
--VIEWER to be dropped upon implementation of media

/* ALA plant imaging */
--ALA_PLANT_IMAGING /* uam only */

/* bulkloader */
--BULKLOADER
--BULKLOADER_ATTEMPTS /* used by the data entry app */
--BULKLOADER_CLONE /* used by data entry */
--BULKLOADER_DELETES /* archive of loaded things */
--BULKLOADER_KEYS /* does not exist at mvz; temp storage for load process */
--BULKLOADER_STAGE
--PROC_BL_STATUS used by bulk procedure:

/* code tables */
--CCT_* /* collection code tables; dynamically created FOR USE BY THE search screen */
--CT*  /* code tables */
--CTATTRIBUTE_CODE_TABLES special CT:

/* digir */
--DGR_LOCATOR  /*used by DGR to track non-unique barcodes:

/* flat */
--FLAT
--FLAT_IS_BROKEN /* does not exist in MVZ; used by procedure */

/* reports */
--NUMS used IN gap-finding:

/* CF/user tables */
--CDATA
--CFFLAGS
--CF_*
--CGLOBAL
--TEMP_ALLOW_CF_USER
--USER_DATA
--USER_LOAN_ITEM
--USER_LOAN_REQUEST
--USER_ROLES
--USER_TABLE_ACCESS

/* used by oracle; alerts, explain plans, dbms_profiler */
--ALERT_LOG /* does not exist at MVZ */
--ALERT_LOG_DISK /* does not exist at MVZ */
--PLAN_TABLE
--PLSQL_PROFILER_DATA
--PLSQL_PROFILER_RUNS
--PLSQL_PROFILER_UNITS

DROP TABLE AGENT20080110;
DROP TABLE AGENT_NAME20080110;
DROP TABLE ALA_PLANT_IMAGING20070619;
DROP TABLE ATTRIBUTES20071204;
DROP TABLE BARCODE;
DROP TABLE BIOL_INDIV_REMARK;
DROP TABLE BO;
DROP TABLE BULKLOADER_TEMPLATE;
DROP TABLE CFRELEASE_NOTES;
DROP TABLE CF_FORM_PERMISSIONS080323;
DROP TABLE CITATION20071101;
DROP TABLE COLD_FUSION_USERS;
DROP TABLE COLL_OBJECT_RESTRICTION;
DROP TABLE COLLECTOR_FORMATTED
DROP TABLE COLL_OBJ_OTHER_ID_NUM111307;
DROP TABLE COLL_OBJ_OTHER_ID_NUM20080220;
DROP TABLE COLL_OBJ_OTHER_ID_NUM_OLD;
DROP TABLE CORRESPONDENCE
DROP TABLE CSN;
DROP TABLE DEACCN;
DROP TABLE DEACC_ITEM;
DROP TABLE DEV_TASK;
DROP TABLE DGR_LOCATOR_20071126;
DROP TABLE DGR_LOCATOR_20071210;
DROP TABLE DGR_LOC_F3;
DROP TABLE DOCUMENTATION;
DROP TABLE FIB;
DROP TABLE GEOG_RELATIONS;
DROP TABLE GROUP_MASTER;
DROP TABLE GROUP_PERSON;
DROP TABLE HIERARCHICAL_PART_NAME;
DROP TABLE I;
DROP TABLE IPNI;
DROP TABLE IPNI_ALREADY_THERE;
DROP TABLE IPNI_DUPS;
DROP TABLE IPNI_FIX;
DROP TABLE IPNI_GOTSDUPS;
DROP TABLE LOAN_REQUEST
DROP TABLE MODEL;
DROP TABLE NOTES_OF_COLL_EVENT;
DROP TABLE NUMBERS;
DROP table OIDN;
DROP TABLE ORG;
DROP TABLE PART_HIERARCHY;
DROP TABLE PERMIT_SHIPMENT
DROP TABLE PERSON20080110;
DROP TABLE PROJECT_COLL_EVENT;
DROP TABLE PROJECT_REMARK;
DROP TABLE PUBLICATION_YEAR;
DROP TABLE REARING_EVENT;
DROP TABLE T;
DROP TABLE TEMPAGENT;
DROP TABLE TRANS_AGENT_ADDR;
DROP TABLE URL;
DROP TABLE VIEWER;

/* model modifications 

missing from model
--GEOLOGY_ATTRIBUTES
--GEOLOGY_ATTRIBUTE_HIERARCHY
--PUBLICATION_URL
--TAXONOMY_ARCHIVE used by trigger when updating taxonomy: 11g should be able to do this in auditing.  whenever there is update delete insert on specific tables, needs to be audited; write change log, to xml file?

exist in model
DROP TABLE PROJECT_COLL_EVENT;
DROP TABLE PROJECT_REMARK;
DROP TABLE REARING_EVENT;

*/

/* to be dropped upon implementation of media */
--DROP TABLE BINARY_OBJECT;
--DROP TABLE VIEWER;

/* get rid of junk tables at MVZ */
--ACCN
DROP TABLE ACCN_COLLECTOR;
--ADDR
--AGENT
--AGENT_NAME
--AGENT_NAME_PENDING_DELETE
--AGENT_RELATIONS
--ATTRIBUTES
DROP TABLE BARCODE ;
--BINARY_OBJECT
DROP TABLE BIOL_INDIV;
--BIOL_INDIV_RELATIONS
DROP TABLE BIOL_INDIV_REMARK;
DROP TABLE BIRD;
--BOOK
--BOOK_SECTION
--BORROW
--BSCIT_IMAGE_SUBJECT /* will go away with media tables */
--BULKLOADER
--BULKLOADER_ATTEMPTS
--BULKLOADER_CLONE
--BULKLOADER_DELETES
--BULKLOADER_STAGE
DROP TABLE BULKLOADER_TEMPLATE;
--CATALOGED_ITEM
--CCTCOLL_OTHER_ID_TYPE1
--CCTCOLL_OTHER_ID_TYPE10
--CCTCOLL_OTHER_ID_TYPE1000003
--CCTCOLL_OTHER_ID_TYPE1000004
--CCTCOLL_OTHER_ID_TYPE1000005
--CCTCOLL_OTHER_ID_TYPE1000006
--CCTCOLL_OTHER_ID_TYPE1000007
--CCTCOLL_OTHER_ID_TYPE1000008
--CCTCOLL_OTHER_ID_TYPE1000009
--CCTCOLL_OTHER_ID_TYPE11
--CCTCOLL_OTHER_ID_TYPE12
--CCTCOLL_OTHER_ID_TYPE13
--CCTCOLL_OTHER_ID_TYPE14
--CCTCOLL_OTHER_ID_TYPE15
--CCTCOLL_OTHER_ID_TYPE16
--CCTCOLL_OTHER_ID_TYPE17
--CCTCOLL_OTHER_ID_TYPE18
--CCTCOLL_OTHER_ID_TYPE19
--CCTCOLL_OTHER_ID_TYPE2
--CCTCOLL_OTHER_ID_TYPE20
--CCTCOLL_OTHER_ID_TYPE21
--CCTCOLL_OTHER_ID_TYPE3
--CCTCOLL_OTHER_ID_TYPE4
--CCTCOLL_OTHER_ID_TYPE5
--CCTCOLL_OTHER_ID_TYPE6
--CCTCOLL_OTHER_ID_TYPE7
--CCTCOLL_OTHER_ID_TYPE8
--CCTCOLL_OTHER_ID_TYPE9
--CCTSPECIMEN_PART_MODIFIER1
--CCTSPECIMEN_PART_MODIFIER10
--CCTSPECIMEN_PART_MODIFIER11
--CCTSPECIMEN_PART_MODIFIER12
--CCTSPECIMEN_PART_MODIFIER13
--CCTSPECIMEN_PART_MODIFIER14
--CCTSPECIMEN_PART_MODIFIER15
--CCTSPECIMEN_PART_MODIFIER16
--CCTSPECIMEN_PART_MODIFIER17
--CCTSPECIMEN_PART_MODIFIER18
--CCTSPECIMEN_PART_MODIFIER19
--CCTSPECIMEN_PART_MODIFIER2
--CCTSPECIMEN_PART_MODIFIER20
--CCTSPECIMEN_PART_MODIFIER21
--CCTSPECIMEN_PART_MODIFIER3
--CCTSPECIMEN_PART_MODIFIER4
--CCTSPECIMEN_PART_MODIFIER5
--CCTSPECIMEN_PART_MODIFIER6
--CCTSPECIMEN_PART_MODIFIER7
--CCTSPECIMEN_PART_MODIFIER8
--CCTSPECIMEN_PART_MODIFIER9
--CCTSPECIMEN_PART_NAME1
--CCTSPECIMEN_PART_NAME10
--CCTSPECIMEN_PART_NAME1000003
--CCTSPECIMEN_PART_NAME1000004
--CCTSPECIMEN_PART_NAME1000005
--CCTSPECIMEN_PART_NAME1000006
--CCTSPECIMEN_PART_NAME1000007
--CCTSPECIMEN_PART_NAME1000008
--CCTSPECIMEN_PART_NAME1000009
--CCTSPECIMEN_PART_NAME11
--CCTSPECIMEN_PART_NAME12
--CCTSPECIMEN_PART_NAME13
--CCTSPECIMEN_PART_NAME14
--CCTSPECIMEN_PART_NAME15
--CCTSPECIMEN_PART_NAME16
--CCTSPECIMEN_PART_NAME17
--CCTSPECIMEN_PART_NAME18
--CCTSPECIMEN_PART_NAME19
--CCTSPECIMEN_PART_NAME2
--CCTSPECIMEN_PART_NAME20
--CCTSPECIMEN_PART_NAME21
--CCTSPECIMEN_PART_NAME3
--CCTSPECIMEN_PART_NAME4
--CCTSPECIMEN_PART_NAME5
--CCTSPECIMEN_PART_NAME6
--CCTSPECIMEN_PART_NAME7
--CCTSPECIMEN_PART_NAME8
--CCTSPECIMEN_PART_NAME9
--CCTSPECIMEN_PRESERV_METHOD1
--CCTSPECIMEN_PRESERV_METHOD10
--CCTSPECIMEN_PRESERV_METHOD11
--CCTSPECIMEN_PRESERV_METHOD12
--CCTSPECIMEN_PRESERV_METHOD13
--CCTSPECIMEN_PRESERV_METHOD14
--CCTSPECIMEN_PRESERV_METHOD15
--CCTSPECIMEN_PRESERV_METHOD16
--CCTSPECIMEN_PRESERV_METHOD17
--CCTSPECIMEN_PRESERV_METHOD18
--CCTSPECIMEN_PRESERV_METHOD19
--CCTSPECIMEN_PRESERV_METHOD2
--CCTSPECIMEN_PRESERV_METHOD20
--CCTSPECIMEN_PRESERV_METHOD21
--CCTSPECIMEN_PRESERV_METHOD3
--CCTSPECIMEN_PRESERV_METHOD4
--CCTSPECIMEN_PRESERV_METHOD5
--CCTSPECIMEN_PRESERV_METHOD6
--CCTSPECIMEN_PRESERV_METHOD7
--CCTSPECIMEN_PRESERV_METHOD8
--CCTSPECIMEN_PRESERV_METHOD9
--CDATA
--CFFLAGS
DROP TABLE CFRELEASE_NOTES;
--CF_ADDR
--CF_ADDRESS
--CF_BUGS
--CF_CANNED_SEARCH
--CF_COLLECTION_APPEARANCE
--CF_CTUSER_ROLES
--CF_DATABASE_ACTIVITY
--CF_DOWNLOAD
--CF_FORM_PERMISSIONS
--CF_GENBANK_INFO
--CF_LABEL
--CF_LOAN
--CF_LOAN_ITEM
--CF_LOG
--CF_PROJECT
--CF_SEARCH_RESULTS
--CF_SPEC_RES_COLS
--CF_TEMP_ATTRIBUTES
--CF_TEMP_BARCODE_PARTS
--CF_TEMP_CITATION
--CF_TEMP_CONTAINER_LOCATION
--CF_TEMP_CONTAINER_LOCATION_TWO
--CF_TEMP_LOAN_ITEM
--CF_TEMP_OIDS
--CF_TEMP_PARTS
--CF_TEMP_RELATIONS
--CF_TEMP_SCANS
--CF_USERS
--CF_USER_DATA
--CF_USER_LOAN
--CF_USER_LOG
--CF_USER_ROLES
--CF_VERSION
--CF_VERSION_LOG
--CGLOBAL
--CITATION
DROP TABLE COLD_FUSION_USERS;
--COLLECTING_EVENT
DROP TABLE COLLECTING_EVENT_BAK;
--COLLECTION
--COLLECTION_CONTACTS
--COLLECTOR
DROP TABLE COLLECTOR_FORMATTED;
--COLL_OBJECT
DROP TABLE COLL_OBJECT_BAK;
--COLL_OBJECT_ENCUMBRANCE
--COLL_OBJECT_REMARK
DROP TABLE COLL_OBJECT_REMARK_BAK;
DROP TABLE COLL_OBJECT_RESTRICTION;
--COLL_OBJ_CONT_HIST
--COLL_OBJ_OTHER_ID_NUM
DROP TABLE COLL_OBJ_OTHER_ID_NUM041105;
--COMMON_NAME
--CONTAINER
--CONTAINER_CHECK
--CONTAINER_HISTORY
DROP TABLE CORRESPONDENCE;
--CTACCN_STATUS
--CTACCN_TYPE
--CTADDR_TYPE
--CTAGENT_NAME_TYPE
--CTAGENT_RELATIONSHIP
--CTAGENT_TYPE
--CTAGE_CLASS
--CTATTRIBUTE_CODE_TABLES
--CTATTRIBUTE_TYPE
--CTBIN_OBJ_ASPECT
--CTBIN_OBJ_SUBJECT
--CTBIOL_RELATIONS
--CTBORROW_STATUS
--CTCF_LOAN_USE_TYPE
--CTCITATION_TYPE_STATUS
--CTCLASS
--CTCOLLECTING_SOURCE
--CTCOLLECTION_CDE
--CTCOLLECTOR_ROLE
--CTCOLL_CONTACT_ROLE
--CTCOLL_OBJ_DISP
--CTCOLL_OBJ_FLAGS
--CTCOLL_OTHER_ID_TYPE
--CTCONTAINER_TYPE
--CTCONTINENT
--CTDATUM
--CTDEPTH_UNITS
--CTDOWNLOAD_PURPOSE
--CTELECTRONIC_ADDR_TYPE
--CTENCUMBRANCE_ACTION
--CTEW
--CTFEATURE
--CTFLAGS
--CTFLUID_CONCENTRATION
--CTFLUID_TYPE
--CTGEOG_SOURCE_AUTHORITY
--CTGEOREFMETHOD
--CTINFRASPECIFIC_RANK
--CTISLAND_GROUP
--CTLAT_LONG_ERROR_UNITS
--CTLAT_LONG_REF_SOURCE
--CTLAT_LONG_UNITS
--CTLENGTH_UNITS
--CTLOAN_STATUS
--CTLOAN_TYPE
--CTNATURE_OF_ID
--CTNS
--CTNUMERIC_AGE_UNITS
--CTORIG_ELEV_UNITS
--CTPERMIT_TYPE
--CTPREFIX
--CTPROJECT_AGENT_ROLE
--CTPUBLICATION_TYPE
--CTSEX_CDE
--CTSHIPPED_CARRIER_METHOD
--CTSPECIMEN_PART_LIST_ORDER
--CTSPECIMEN_PART_MODIFIER
--CTSPECIMEN_PART_NAME
--CTSPECIMEN_PRESERV_METHOD
--CTSUFFIX
--CTTAXA_FORMULA
--CTTAXONOMIC_AUTHORITY
--CTTAXON_RELATION
--CTTRANS_AGENT_ROLE
--CTVERIFICATIONSTATUS
--CTWEIGHT_UNITS
--CTYES_NO
DROP TABLE DARWINCORE;
DROP TABLE DARWINDATA;
DROP TABLE DEACCN;
DROP TABLE DEACC_ITEM;
DROP TABLE DEV_TASK;
--DGR_LOCATOR
DROP TABLE DIFF_IMAGE_DATA;
DROP TABLE DIFF_IMAGE_DATA2;
DROP TABLE DIGIR;
DROP TABLE DIGIRDATA;
DROP TABLE DIGITAL_AUDIO_FILE;
DROP TABLE EGG_NEST;
DROP TABLE EGG_NEST_PARASITE;
DROP TABLE EGG_NEST_REMARK;
DROP TABLE EGG_NEST_TEMP_REMARK;
--ELECTRONIC_ADDRESS
--ENCUMBRANCE
--FIELD_NOTEBOOK_SECTION
DROP TABLE FILM;
DROP TABLE FILM_CLIP;
DROP TABLE FILM_CLIP_IN_FILM;
--FLAT
DROP TABLE FLAT_BAK;
DROP TABLE FLAT_COLLECTOR;
--FLUID_CONTAINER_HISTORY
--FMP_IMAGE_DATA /* goes away with new media tables */
DROP TABLE FORMPUB;
DROP TABLE FORMPUBS;
DROP TABLE FORM_PUBS;
DROP TABLE GEOGRAPHYINDEX;
--GEOG_AUTH_REC
DROP TABLE GEOG_INDEX;
DROP TABLE GEOG_RELATIONS;
--GEOLOGY_ATTRIBUTES
--GEOLOGY_ATTRIBUTE_HIERARCHY
--GREF_PAGE_REFSET_NG /* gref table */
--GREF_REFSET_NG /* gref table */
--GREF_REFSET_ROI_NG /* gref table */
--GREF_ROI_NG /* gref table */
--GREF_ROI_VALUE_NG /* gref table */
--GREF_USER /* gref table */
DROP TABLE GROUP_MASTER;
--GROUP_MEMBER
DROP TABLE GROUP_PERSON;
DROP TABLE HEAP_CACHE;
DROP TABLE HERP;
DROP TABLE HIERARCHICAL_PART_NAME;
DROP TABLE HISTO_SLIDE_SERIES;
--IDENTIFICATION
--IDENTIFICATION_AGENT
--IDENTIFICATION_TAXONOMY
--IMAGE_CONTENT /* will go away with media tables */
--IMAGE_OBJECT /* will go away with media tables */
--IMAGE_SUBJECT /* will go away with media tables */
--IMAGE_SUBJECT_REMARKS /* will go away with media tables */
--JOURNAL
--JOURNAL_ARTICLE
DROP TABLE KARYO_SLIDE;
DROP TABLE LAM_ACCN_DUP;
DROP TABLE LAM_BINARY_OBJECT_BAK;
DROP TABLE LAM_CITATION_BAK;
DROP TABLE LAM_COLLECTING_EVENT_BAK;
DROP TABLE LAM_COLL_OBJECT_BAK;
DROP TABLE LAM_COMMON_NAME_BAK;
DROP TABLE LAM_COM_NAME_BAK;
DROP TABLE LAM_FMP_IMAGE_DATA;
DROP TABLE LAM_ID_TAXONOMY_BAK;
DROP TABLE LAM_IMAGE_DATA_BAD_DESC;
DROP TABLE LAM_IMAGE_DATA_BAD_DESC2;
DROP TABLE LAM_LAT_LONG_BAK;
DROP TABLE LAM_LOCALITY_BAK;
--LAM_MVZ_CTDATA /* temp table; drop after migration to vpd */
DROP TABLE LAM_TAXONOMY_BAK;
DROP TABLE LAM_TAXONOMY_DUPERR;
DROP TABLE LAM_TAXON_NAME_IDS;
DROP TABLE LAM_TAX_BAK;
DROP TABLE LAM_TAX_BAK_071009;
--LAT_LONG
DROP TABLE LEXICON;
DROP TABLE LEXICON_SORT_ORDER;
DROP TABLE LEXICON_TERM_RELATION;
DROP TABLE LEXICON_TERM_TOKENS;
DROP TABLE LINK;
--LOAN
--LOAN_INSTALLMENT
--LOAN_ITEM
DROP TABLE LOAN_REQUEST;
--LOCALITY
DROP TABLE MAMMAL;
DROP TABLE MAMMALCATNUMS;
DROP TABLE MAMMALPARTS;
DROP TABLE MAMMPARTS;
DROP TABLE MANISCOLLS;
DROP TABLE MANISGEOREFS;
DROP TABLE MANIS_COLLECTOR;
DROP TABLE MANIS_READYTOGO;
DROP TABLE MDC2;
DROP TABLE MERGEPARTS;
DROP TABLE MLL_ALLTHEREST;
DROP TABLE MLL_HASACCLATLONG;
DROP TABLE MLL_REMBYCATNUM;
DROP TABLE MMLYNX;
DROP TABLE MODEL;
DROP TABLE MRTG;
DROP TABLE MRTG2;
DROP TABLE MRTG_BADLOCID;
DROP TABLE MSB_ACCN;
DROP TABLE NEWOLDDETS;
DROP TABLE NEXT_PKEY;
DROP TABLE NODE_TYPE_CODE;
DROP TABLE NOTES_OF_COLL_EVENT;
--NUMS
--OBJECT_CONDITION
DROP TABLE ONEBULK;
DROP TABLE ORG;
--PAGE
DROP TABLE PARTS_FORMATTED;
DROP TABLE PART_HIERARCHY;
DROP TABLE PART_MATRIX;
--PERMIT
DROP TABLE PERMIT_SHIPMENT;
--PERMIT_TRANS
--PERSON
DROP TABLE PH;
DROP TABLE PHANTOM_BIOL_INDIV;
DROP TABLE PHANTOM_RELATIONS;
DROP TABLE PLANTHAB;
--PLAN_TABLE
--PLSQL_PROFILER_DATA
--PLSQL_PROFILER_RUNS
--PLSQL_PROFILER_UNITS
--PROC_BL_STATUS
--PROJECT
--PROJECT_AGENT
DROP TABLE PROJECT_COLL_EVENT;
--PROJECT_PUBLICATION
DROP TABLE PROJECT_REMARK;
--PROJECT_SPONSOR
--PROJECT_TRANS
--PUBLICATION
--PUBLICATION_AUTHOR_NAME
--PUBLICATION_URL
DROP TABLE PUBLICATION_YEAR;
DROP TABLE REARING_EVENT;
DROP TABLE RELATION_TYPE_CODE;
DROP TABLE SCANS;
DROP TABLE SCOPE_NOTES;
DROP TABLE SEARCHTERMS;
DROP TABLE SECDET;
DROP TABLE SECTION;
DROP TABLE SEQUENCE_REPOSITORY;
DROP TABLE SEQUENCE_REPOSITORY_ARTICLE;
DROP TABLE SEQUENCE_REPOS_ARTICLE;
--SHIPMENT
DROP TABLE SPECIES_TAPE;
--SPECIMEN_ANNOTATIONS
--SPECIMEN_PART
--STILL_IMAGE /* maybe goes away with media tables? does not exist at UAM */
DROP TABLE STRING_SERIES;
DROP TABLE TAPE;
DROP TABLE TAXONBYGEOGINDEX;
--TAXONOMY
DROP TABLE TAXONOMYINDEX;
--TAXON_RELATIONS
DROP TABLE TAX_PROTECT_STATUS;
DROP TABLE TCONTAINER;
DROP TABLE TEMP;
DROP TABLE TEMPBL;
DROP TABLE TEMPCONT;
--TEMP_ALLOW_CF_USER
DROP TABLE TISSUES_FORMATTED;
DROP TABLE TISSUE_COUNT;
DROP TABLE TISSUE_PREP;
DROP TABLE TISSUE_SAMPLE_TYPE;
DROP TABLE TOAD_PLAN_SQL;
DROP TABLE TOAD_PLAN_TABLE;
DROP TABLE TOKENS;
DROP TABLE TPOTHERID;
--TRANS
--TRANS_AGENT
DROP TABLE TRANS_AGENT_ADDR;
DROP TABLE TRANS_CLOSURE;
DROP TABLE TRANS_ITEM;
DROP TABLE TRANS_RELATIONS;
DROP TABLE UAM_TYPES;
DROP TABLE UPDATE_CATNUMS;
DROP TABLE URL;
--USER_DATA
--USER_LOAN_ITEM
--USER_LOAN_REQUEST
--USER_ROLES
--USER_TABLE_ACCESS
--VESSEL
--VIEWER
DROP TABLE VISITATION;
DROP TABLE VOCAL_SERIES;
DROP TABLE VOCAL_SERIES_CUT_HISTORY;
DROP TABLE VOCAL_SERIES_ON_TAPE;
DROP TABLE "VSVBTableVersions";
DROP TABLE VTEST;
DROP TABLE YLYNX;

/* end of getting rid of junk tables */

*/
ACCN
-->trans-->collection
ADDR
-- none
AGENT
-- none
AGENT_NAME
-- none
AGENT_RELATIONS
-- none
ELECTRONIC_ADDRESS
-- none
GROUP_MEMBER
-- none
PERSON
--none
ALA_PLANT_IMAGING
-- none
ATTRIBUTES
-->cataloged_item-->collection
--BINARY_OBJECT
-- going away - no need to develop formal policies
BIOL_INDIV_RELATIONS
-->cataloged_item-->collection
-- SPECIAL NOTE: related individuals may be in different collections, and
-- we may therefore need very open INSERT roles, or ?????
-- This can be explored later if need be - initial policy will be collection-specific control.
BOOK
-- none
BOOK_SECTION
-- none
BORROW
-->trans-->collection
BULKLOADER
-- already controlled by data entry groups. That needs revised to use DB roles, but not immediately
CATALOGED_ITEM
-->collection
cct_bla TABLES
-- none
cf_bla tables
-- none
CITATION
-->cataloged_item-->collection
COLLECTING_EVENT
-->cataloged_item->collection
COLLECTION
-- durrrr.....
COLLECTION_CONTACTS
-->collection
COLLECTOR
-->cataloged_item-->collection
COLL_OBJECT
-->cataloged_item-->collection
--  OR
-->specimen_part-->cataloged_item-->collection
COLL_OBJECT_ENCUMBRANCE
-->cataloged_item-->collection
COLL_OBJECT_REMARK
-->cataloged_item-->collection
COLL_OBJ_CONT_HIST
-->cataloged_item-->collection
COLL_OBJ_OTHER_ID_NUM
-->cataloged_item-->collection
COMMON_NAME
-- none
CONTAINER
-- none - will need policies later
all ctbla tables
-- none
CT_ATTRIBUTE_CODE_TABLES
-- none
DGR_LOCATOR
-- none; already cntrolled by restrictive role
-- OR
-- MSB_*
ENCUMBRANCE
-->coll_object_encumbrance-->cataloged_item-->collection
FIELD_NOTEBOOK_SECTION
-- none?
FLAT
-- none
FLUID_CONTAINER_HISTORY
-- none
GEOG_AUTH_REC
-- none
GEOLOGY_ATTRIBUTES
-->locality-->collecting_event->cataloged_item-->collection
GEOLOGY_ATTRIBUTE_HIERARCHY
-->geology_attributes-->locality-->collecting_event->cataloged_item-->collection
IDENTIFICATION
-->cataloged_item-->collection
IDENTIFICATION_AGENT
-->identification-->cataloged_item-->collection
IDENTIFICATION_TAXONOMY
-->identification-->cataloged_item-->collection
JOURNAL
-- none
JOURNAL_ARTICLE
-- none
LAT_LONG
-->locality-->collecting_event-->cataloged_item-->collection
LOAN
-->trans-->collection
LOAN_INSTALLMENT
-->loan-->trans-->collection
LOAN_ITEM
-->loan-->trans-->collection
LOAN_REQUEST
-->loan-->trans-->collection
LOCALITY
-->collecting_event-->cataloged_item-->collection
OBJECT_CONDITION
-->coll_object-->specimen_part-->cataloged_item-->collection
PERMIT
-->permit_trans-->trans-->collection
PERMIT_TRANS
-->trans-->collection
PROJECT
--project_trans-->trans-->collection
PROJECT_AGENT
-->project_trans-->trans-->collection
PROJECT_PUBLICATION
-->project_trans-->trans-->collection
PROJECT_SPONSOR
-->project_trans-->trans-->collection
PROJECT_TRANS
-->trans-->collection
PUBLICATION
-->citation-->cataloged_item-->collection
PUBLICATION_AUTHOR_NAME
-->publication-->citation-->cataloged_item-->collection
PUBLICATION_URL
-->publication-->citation-->cataloged_item-->collection
SHIPMENT
-->trans-->collection
SPECIMEN_ANNOTATIONS
-->cataloged_item-->collection
SPECIMEN_PART
-->cataloged_item-->collection
TAXONOMY
--none
TAXON_RELATIONS
-- none
TRANS
-->collection
TRANS_AGENT
-->trans-->collection
VESSEL
-->collecting_event-->cataloged_item-->collection




/*
FORM strategy:
* 
* Change all logins to user_login
* Assign guest users a login based on the URL they come into the app from and/or session.exclusive_collection_id

* While we're here, create a CF user that has access to the CF tables (and nothing else)
*/

-- this is done below! lkv. 2/14/09
create user cf_dbuser identified by "cfdbuser.1";
grant connect to cf_dbuser;
grant create session to cf_dbuser;
grant all on cf_users to cf_dbuser;
grant all on cf_user_data to cf_dbuser;
grant all on user_loan_request to cf_dbuser;
grant all on cf_user_loan to cf_dbuser;
grant all on cf_user_log to cf_dbuser;
