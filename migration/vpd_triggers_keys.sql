--disable all triggers on UAM
select table_name || chr(9) || 'alter trigger ' || trigger_name || ' disable;'
from user_triggers where status = 'ENABLED'
order by table_name, trigger_name

ACCN    
alter trigger TD_ACCN disable;
alter trigger TI_ACCN disable;
alter trigger TU_ACCN disable;
alter trigger UP_FLAT_ACCN disable;
alter trigger BUILD_FORMATTED_ADDR disable;
alter trigger TD_ADDR disable;
alter trigger TR_ADDR_AU disable;
alter trigger TU_ADDR disable;

AGENT_NAME      
alter trigger DEL_AGENT_NAME disable;
alter trigger PRE_DEL_AGENT_NAME disable;
alter trigger TI_AGENT_NAME disable;
alter trigger UP_FLAT_AGENTNAME disable;
alter trigger UP_INS_AGENT_NAME disable;

AGENT_RELATIONS 
alter trigger TI_AGENT_RELATIONS disable;
alter trigger TU_AGENT_RELATIONS disable;

--ALA_PLANT_IMAGING       
alter trigger ALA_PLANT_IMAGING_KEY disable;

ATTRIBUTES      
alter trigger ATTRIBUTE_CT_CHECK disable;
alter trigger ATTRIBUTE_DATA_CHECK disable;
alter trigger UP_FLAT_SEX disable;

BINARY_OBJECT   
alter trigger TI_BINARY_OBJECT disable;
alter trigger TU_BINARY_OBJECT disable;

BIOL_INDIV_RELATIONS    
alter trigger RELATIONSHIP_CT_CHECK disable;
alter trigger TI_BIOL_INDIV_RELATIONS disable;
alter trigger TU_BIOL_INDIV_RELATIONS disable;
alter trigger UP_FLAT_RELN disable;

BOOK    
alter trigger TD_BOOK disable;
alter trigger TI_BOOK disable;
alter trigger TU_BOOK disable;

BOOK_SECTION    
alter trigger TI_BOOK_SECTION disable;
alter trigger TU_BOOK_SECTION disable;

--BULKLOADER      
alter trigger TD_BULKLOADER disable;

CATALOGED_ITEM  
alter trigger AD_FLAT_CATITEM disable;
alter trigger A_FLAT_CATITEM disable;
alter trigger TI_FLAT_CATITEM disable;
alter trigger TU_FLAT_CATITEM disable;

--CFRELEASE_NOTES 
alter trigger CFRELEASE_NOTES_ID disable;

--CF_CANNED_SEARCH        
alter trigger CF_CANNED_SEARCH_TRG disable;

--CF_COLLECTION   
alter trigger CF_CF_COLLECTION_KEY disable;

--CF_FORM_PERMISSIONS     
alter trigger CF_FORM_PERMISSIONS_KEY disable;
    
--CF_LOG  
alter trigger CF_LOG_ID disable;

--CF_REPORT_SQL   
alter trigger CF_REPORT_SQL_KEY disable;

--CF_SPEC_RES_COLS        
alter trigger TRG_CF_SPEC_RES_COLS_ID disable;

--CF_TEMP_AGENTS  
alter trigger CF_TEMP_AGENTS_KEY disable;

--CF_TEMP_ATTRIBUTES      
alter trigger CF_TEMP_ATTRIBUTES_KEY disable;

--CF_TEMP_CITATION        
alter trigger CF_TEMP_CITATION_KEY disable;

--CF_TEMP_ID      
alter trigger CF_TEMP_ID_KEY disable;

--CF_TEMP_LOAN_ITEM       
alter trigger CF_TEMP_LOAN_ITEM_KEY disable;

--CF_TEMP_OIDS    
alter trigger CF_TEMP_OIDS_KEY disable;

--CF_TEMP_PARTS   
alter trigger CF_TEMP_PARTS_KEY disable;

--CF_TEMP_PART_SAMPLE     
alter trigger CF_TEMP_PART_SAMPLE_KEY disable;

--CF_TEMP_TAXONOMY        
alter trigger CF_TEMP_TAXONOMY_KEY disable;

--CF_VERSION      
alter trigger CF_VERSION_PKEY_TRG disable;

--CF_VERSION_LOG  
alter trigger CF_VERSION_LOG_PKEY_TRG disable;

CITATION        
alter trigger TI_CITATION disable;
alter trigger TU_CITATION disable;
alter trigger UP_FLAT_CITATION disable;

COLLECTING_EVENT        
alter trigger A_FLAT_COLLEVNT disable;
alter trigger COLLECTING_EVENT_CT_CHECK disable;

COLLECTION      
alter trigger CF_COLLECTION_SYNC disable;
alter trigger TD_COLLECTION disable;
alter trigger TU_COLLECTION disable;

COLLECTOR       
alter trigger TI_COLLECTOR disable;
alter trigger UP_FLAT_COLLECTOR disable;

COLL_OBJECT     
alter trigger COLL_OBJECT_CT_CHECK disable;
alter trigger TRG_OBJECT_CONDITION disable;
alter trigger UP_FLAT_COLLOBJ disable;

COLL_OBJECT_ENCUMBRANCE 
alter trigger TI_COLL_OBJECT_ENCUMBRANCE disable;
alter trigger TU_COLL_OBJECT_ENCUMBRANCE disable;
alter trigger UP_FLAT_COLL_OBJ_ENCUMBER disable;

COLL_OBJECT_REMARK      
alter trigger TI_COLL_OBJECT_REMARK disable;
alter trigger TU_COLL_OBJECT_REMARK disable;
alter trigger UP_FLAT_REMARK disable;

COLL_OBJ_CONT_HIST      
alter trigger TI_COLL_OBJ_CONT_HIST disable;

COLL_OBJ_OTHER_ID_NUM   
alter trigger COLL_OBJ_DATA_CHECK disable;
alter trigger COLL_OBJ_DISP_VAL disable;
alter trigger OTHER_ID_CT_CHECK disable;
alter trigger TR_COLL_OBJ_OTHER_ID_NUM_SQ disable;
alter trigger UP_FLAT_OTHERIDS disable;

COMMON_NAME     
alter trigger TI_COMMON_NAME disable;
alter trigger TU_COMMON_NAME disable;

CONTAINER       
alter trigger GET_CONTAINER_HISTORY disable;
alter trigger MOVE_CONTAINER disable;

CONTAINER_CHECK 
alter trigger CONTAINER_CHECK_ID disable;

CORRESPONDENCE  
alter trigger TD_CORRESPONDENCE disable;

CTMEDIA_RELATIONSHIP    
alter trigger MEDIA_RELATIONS_CT disable;

DEACCN  
alter trigger TD_DEACCN disable;

DEACC_ITEM      
alter trigger TI_DEACC_ITEM disable;
alter trigger TU_DEACC_ITEM disable;

DEV_TASK        
alter trigger DEV_TASK_DEF disable;

DOCUMENTATION   
alter trigger DOCUMENTATION_PKEY disable;

ELECTRONIC_ADDRESS      
alter trigger TI_ELECTRONIC_ADDRESS disable;
alter trigger TU_ELECTRONIC_ADDRESS disable;

ENCUMBRANCE     
alter trigger TD_ENCUMBRANCE disable;
alter trigger TI_ENCUMBRANCE disable;
alter trigger TU_ENCUMBRANCE disable;

FIELD_NOTEBOOK_SECTION  
alter trigger TD_FIELD_NOTEBOOK_SECTION disable;
alter trigger TI_FIELD_NOTEBOOK_SECTION disable;
alter trigger TU_FIELD_NOTEBOOK_SECTION disable;

GEOG_AUTH_REC   
alter trigger TD_GEOG_AUTH_REC disable;
alter trigger TRG_MK_HIGHER_GEOG disable;
alter trigger TU_GEOG_AUTH_REC disable;
alter trigger UP_FLAT_GEOG disable;

GEOG_RELATIONS  
alter trigger TI_GEOG_RELATIONS disable;
alter trigger TU_GEOG_RELATIONS disable;

GEOLOGY_ATTRIBUTES      
alter trigger GEOLOGY_ATTRIBUTES_CHECK disable;
alter trigger GEOLOGY_ATTRIBUTES_SEQ disable;

GEOLOGY_ATTRIBUTE_HIERARCHY     
alter trigger CTGEOLOGY_ATTRIBUTES_CHECK disable;
alter trigger GEOL_ATT_HIERARCHY_SEQ disable;

GROUP_MASTER    
alter trigger TI_GROUP_MASTER disable;

IDENTIFICATION  
alter trigger IDENTIFICATION_CT_CHECK disable;
alter trigger UP_FLAT_ID disable;
    
IDENTIFICATION_AGENT    
alter trigger IDENTIFICATION_AGENT_TRG disable;
alter trigger UP_FLAT_AGNT_ID disable;
    
IDENTIFICATION_TAXONOMY 
alter trigger UP_FLAT_ID_TAX disable;
    
JOURNAL 
alter trigger TD_JOURNAL disable;
alter trigger TU_JOURNAL disable;

JOURNAL_ARTICLE 
alter trigger TU_JOURNAL_ARTICLE disable;

LAT_LONG        
alter trigger LAT_LONG_CT_CHECK disable;
alter trigger TU_LAT_LONG disable;
alter trigger UPDATECOORDINATES disable;
alter trigger UP_FLAT_LAT_LONG disable;

LOAN    
alter trigger TD_LOAN disable;
alter trigger TU_LOAN disable;

LOAN_ITEM       
alter trigger TI_LOAN_ITEM disable;
alter trigger TU_LOAN_ITEM disable;

LOCALITY        
alter trigger LOCALITY_CT_CHECK disable;
alter trigger TI_LOCALITY disable;
alter trigger UP_FLAT_LOCALITY disable;

MEDIA   
alter trigger MEDIA_SEQ disable;

MEDIA_LABELS    
alter trigger MEDIA_LABELS_SEQ disable;

MEDIA_RELATIONS 
alter trigger MEDIA_RELATIONS_AFTER disable;
alter trigger MEDIA_RELATIONS_CHK disable;
alter trigger MEDIA_RELATIONS_SEQ disable;

MODEL   
alter trigger TI_MODEL disable;
alter trigger TU_MODEL disable;

NOTES_OF_COLL_EVENT     
alter trigger TU_NOTES_OF_COLL_EVENT disable;

ORG     
alter trigger TI_ORG disable;
alter trigger TU_ORG disable;

PAGE    
alter trigger TI_PAGE disable;
alter trigger TU_PAGE disable;

PERMIT  
alter trigger TD_PERMIT disable;
alter trigger TI_PERMIT disable;

PERMIT_SHIPMENT 
alter trigger TI_PERMIT_SHIPMENT disable;
alter trigger TU_PERMIT_SHIPMENT disable;

PERSON  
alter trigger TI_PERSON disable;

PROJECT 
alter trigger TD_PROJECT disable;
alter trigger TU_PROJECT disable;

PROJECT_AGENT   
alter trigger TI_PROJECT_AGENT disable;
alter trigger TU_PROJECT_AGENT disable;

PROJECT_COLL_EVENT      
alter trigger TU_PROJECT_COLL_EVENT disable;

PROJECT_PUBLICATION     
alter trigger TI_PROJECT_PUBLICATION disable;
alter trigger TU_PROJECT_PUBLICATION disable;

PROJECT_SPONSOR 
alter trigger TRIG_PROJECT_SPONSOR_ID disable;

PUBLICATION     
alter trigger TU_PUBLICATION disable;

PUBLICATION_AUTHOR_NAME 
alter trigger TI_PUBLICATION_AUTHOR_NAME disable;
alter trigger TU_PUBLICATION_AUTHOR_NAME disable;

PUBLICATION_YEAR        
alter trigger TI_PUBLICATION_YEAR disable;
alter trigger TU_PUBLICATION_YEAR disable;

SPECIMEN_ANNOTATIONS    
alter trigger SPECIMEN_ANNOTATIONS_KEY disable;

SPECIMEN_PART   
alter trigger IS_TISSUE_DEFAULT disable;
alter trigger MAKE_PART_COLL_OBJ_CONT disable;
alter trigger SPECIMEN_PART_CT_CHECK disable;
alter trigger SPECIMEN_PART_DELETE_CLEANUP disable;
alter trigger UP_FLAT_PART disable;

TAXONOMY        
alter trigger TD_TAXONOMY disable;
alter trigger TRG_MK_SCI_NAME disable;
alter trigger TRG_UP_TAX disable;
alter trigger UPDATE_ID_AFTER_TAXON_CHANGE disable;

TAXON_RELATIONS 
alter trigger TI_TAXON_RELATIONS disable;
alter trigger TU_TAXON_RELATIONS disable;

TRANS   
alter trigger TRANS_AGENT_ENTERED disable;

TRANS_AGENT     
alter trigger TRANS_AGENT_PRE disable;

VIEWER  
alter trigger TD_VIEWER disable;
alter trigger TU_VIEWER disable;


-- drop foreign keys
--YYYY

PK_ACCN
alter table CATALOGED_ITEM drop constraint FK_CATITEM_ACCN;

alter table CATALOGED_ITEM
   add constraint FK_CATITEM_ACCN foreign key (ACCN_ID)
      references ACCN (TRANSACTION_ID);

PK_ADDR 
alter table SHIPMENT drop constraint FK_SHIPMENT_ADDR_SHIPPEDFROM;
alter table SHIPMENT drop constraint FK_SHIPMENT_ADDR_SHIPPEDTO;

alter table SHIPMENT
   add constraint FK_SHIPMENT_ADDR_SHIPPEDFROM foreign key (SHIPPED_FROM_ADDR_ID)
      references ADDR (ADDR_ID);

alter table SHIPMENT
   add constraint FK_SHIPMENT_ADDR_SHIPPEDTO foreign key (SHIPPED_TO_ADDR_ID)
      references ADDR (ADDR_ID);

PK_AGENT        
alter table ADDR drop constraint FK_ADDR_AGENT;
alter table AGENT_NAME drop constraint FK_AGENTNAME_AGENT;
alter table AGENT_RELATIONS drop constraint FK_AGENTRELATIONS_AGENT_ANID;
alter table AGENT_RELATIONS drop constraint FK_AGENTRELATIONS_AGENT_RANID;
alter table ATTRIBUTES drop constraint FK_ATTRIBUTES_AGENT;
alter table COLLECTION_CONTACTS drop constraint FK_COLLCONTACTS_AGENT;
alter table COLLECTOR drop constraint FK_COLLECTOR_AGENT;
alter table COLL_OBJECT drop constraint FK_COLLOBJECT_AGENT_EDITED;
alter table COLL_OBJECT drop constraint FK_COLLOBJECT_AGENT_ENTERED;
alter table CONTAINER_CHECK drop constraint FK_CONTAINERCHECK_AGENT;
alter table ELECTRONIC_ADDRESS drop constraint FK_ELECTRONICADDR_AGENT;
alter table ENCUMBRANCE drop constraint FK_ENCUMBRANCE_AGENT;
alter table GROUP_MEMBER drop constraint FK_GROUPMEMBER_AGENT_GROUP;
alter table GROUP_MEMBER drop constraint FK_GROUPMEMBER_AGENT_MEMBER;
alter table IDENTIFICATION_AGENT drop constraint FK_IDAGENT_AGENT;
alter table LAT_LONG drop constraint FK_LATLONG_AGENT;
alter table LOAN_ITEM drop constraint FK_LOANITEM_AGENT;
alter table MEDIA_LABELS drop constraint FK_MEDIALABELS_AGENT;
alter table MEDIA_RELATIONS drop constraint FK_MEDIARELNS_AGENT;
alter table OBJECT_CONDITION drop constraint FK_OBJECTCONDITION_AGENT;
alter table PERMIT drop constraint FK_PERMIT_AGENT_CONTACT;
alter table PERMIT drop constraint FK_PERMIT_AGENT_ISSUEDBY;
alter table PERMIT drop constraint FK_PERMIT_AGENT_ISSUEDTO;
alter table PERSON drop constraint FK_PERSON_AGENT;
alter table SHIPMENT drop constraint FK_SHIPMENT_AGENT;
alter table TAB_MEDIA_REL_FKEY drop constraint FK_TABMEDIARELFKEY_AGENT;
alter table TRANS_AGENT drop constraint FK_TRANSAGENT_AGENT;

alter table ADDR
   add constraint FK_ADDR_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID);

alter table AGENT_NAME
   add constraint FK_AGENTNAME_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID);

alter table AGENT_RELATIONS
   add constraint FK_AGENTRELATIONS_AGENT_ANID foreign key (AGENT_ID)
      references AGENT (AGENT_ID);

alter table AGENT_RELATIONS
   add constraint FK_AGENTRELATIONS_AGENT_RANID foreign key (RELATED_AGENT_ID)
      references AGENT (AGENT_ID);

alter table ATTRIBUTES
   add constraint FK_ATTRIBUTES_AGENT foreign key (DETERMINED_BY_AGENT_ID)
      references AGENT (AGENT_ID);

alter table COLLECTION_CONTACTS
   add constraint FK_COLLCONTACTS_AGENT foreign key (CONTACT_AGENT_ID)
      references AGENT (AGENT_ID);
      
alter table COLLECTOR
   add constraint FK_COLLECTOR_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID);

alter table COLL_OBJECT
   add constraint FK_COLLOBJECT_AGENT_EDITED foreign key (LAST_EDITED_PERSON_ID)
      references AGENT (AGENT_ID);

alter table COLL_OBJECT
   add constraint FK_COLLOBJECT_AGENT_ENTERED foreign key (ENTERED_PERSON_ID)
      references AGENT (AGENT_ID);

-- !!!mvz has no data in container_check.
alter table CONTAINER_CHECK
   add constraint FK_CONTAINERCHECK_AGENT foreign key (CHECKED_AGENT_ID)
      references AGENT (AGENT_ID);

alter table ELECTRONIC_ADDRESS
   add constraint FK_ELECTRONICADDR_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID);

alter table ENCUMBRANCE
   add constraint FK_ENCUMBRANCE_AGENT foreign key (ENCUMBERING_AGENT_ID)
      references AGENT (AGENT_ID);

alter table GROUP_MEMBER
   add constraint FK_GROUPMEMBER_AGENT_GROUP foreign key (GROUP_AGENT_ID)
      references AGENT (AGENT_ID);

alter table GROUP_MEMBER
   add constraint FK_GROUPMEMBER_AGENT_MEMBER foreign key (MEMBER_AGENT_ID)
      references AGENT (AGENT_ID);
      
alter table IDENTIFICATION_AGENT
   add constraint FK_IDAGENT_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID);

alter table LAT_LONG
   add constraint FK_LATLONG_AGENT foreign key (DETERMINED_BY_AGENT_ID)
      references AGENT (AGENT_ID);
      
alter table LOAN_ITEM
   add constraint FK_LOANITEM_AGENT foreign key (RECONCILED_BY_PERSON_ID)
      references AGENT (AGENT_ID);

alter table MEDIA_LABELS
   add constraint FK_MEDIALABELS_AGENT foreign key (ASSIGNED_BY_AGENT_ID)
      references AGENT (AGENT_ID);

alter table MEDIA_RELATIONS
   add constraint FK_MEDIARELNS_AGENT foreign key (CREATED_BY_AGENT_ID)
      references AGENT (AGENT_ID);

alter table OBJECT_CONDITION
   add constraint FK_OBJECTCONDITION_AGENT foreign key (DETERMINED_AGENT_ID)
      references AGENT (AGENT_ID);

alter table PERMIT
   add constraint FK_PERMIT_AGENT_CONTACT foreign key (CONTACT_AGENT_ID)
      references AGENT (AGENT_ID);

alter table PERMIT
   add constraint FK_PERMIT_AGENT_ISSUEDBY foreign key (ISSUED_BY_AGENT_ID)
      references AGENT (AGENT_ID);

alter table PERMIT
   add constraint FK_PERMIT_AGENT_ISSUEDTO foreign key (ISSUED_TO_AGENT_ID)
      references AGENT (AGENT_ID);

alter table PERSON
   add constraint FK_PERSON_AGENT foreign key (PERSON_ID)
      references AGENT (AGENT_ID);
      
alter table SHIPMENT
   add constraint FK_SHIPMENT_AGENT foreign key (PACKED_BY_AGENT_ID)
      references AGENT (AGENT_ID);

alter table TAB_MEDIA_REL_FKEY
   add constraint FK_TABMEDIARELFKEY_AGENT foreign key (CFK_AGENT)
      references AGENT (AGENT_ID);
      
alter table TRANS_AGENT
   add constraint FK_TRANSAGENT_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID);


PK_AGENT_NAME   
alter table PROJECT_AGENT drop constraint FK_PROJECTAGENT_AGENTNAME;
alter table PROJECT_SPONSOR drop constraint FK_PROJECTSPONSOR_AGENTNAME;
alter table PUBLICATION_AUTHOR_NAME drop constraint FK_PUBAUTHNAME_AGENTNAME;

alter table PROJECT_AGENT
   add constraint FK_PROJECTAGENT_AGENTNAME foreign key (AGENT_NAME_ID)
      references AGENT_NAME (AGENT_NAME_ID);
      
--!! mvz does not have data in project_sponsor
alter table PROJECT_SPONSOR
   add constraint FK_PROJECTSPONSOR_AGENTNAME foreign key (AGENT_NAME_ID)
      references AGENT_NAME (AGENT_NAME_ID);
      
/* !!! Dusty fixed these at uam.
select agent_name_id from PUBLICATION_AUTHOR_NAME where agent_name_id not in (select agent_name_id from agent_name);

AGENT_NAME_ID
-------------
         4733
         4736
         4783
         4786
         5662

5 rows selected.
*/

alter table PUBLICATION_AUTHOR_NAME
   add constraint FK_PUBAUTHNAME_AGENTNAME foreign key (AGENT_NAME_ID)
      references AGENT_NAME (AGENT_NAME_ID);

PK_BOOK 
alter table BOOK_SECTION drop constraint FK_BOOKSECTION_BOOK;

alter table BOOK_SECTION
   add constraint FK_BOOKSECTION_BOOK foreign key (BOOK_ID)
      references BOOK (PUBLICATION_ID);

PK_BOOK_SECTION 
alter table FIELD_NOTEBOOK_SECTION drop constraint FK_FIELDNOTESEC_BOOKSEC;

alter table FIELD_NOTEBOOK_SECTION
   add constraint FK_FIELDNOTESEC_BOOKSEC foreign key (PUBLICATION_ID)
      references BOOK_SECTION (PUBLICATION_ID);


PK_CATALOGED_ITEM       
alter table ATTRIBUTES drop constraint FK_ATTRIBUTES_CATITEM;
alter table BIOL_INDIV_RELATIONS drop constraint FK_BIOLINDIVRELN_CATITEM_COID;
alter table BIOL_INDIV_RELATIONS drop constraint FK_BIOLINDIVRELN_CATITEM_RCOID;
alter table CITATION drop constraint FK_CITATION_CATITEM;
alter table COLLECTOR drop constraint FK_COLLECTOR_CATITEM;
alter table COLL_OBJ_OTHER_ID_NUM drop constraint FK_COLLOBJOTHERIDNUM_CATITEM;
alter table IDENTIFICATION drop constraint FK_IDENTIFICATION_CATITEM;
alter table SPECIMEN_ANNOTATIONS drop constraint FK_SPECIMENANNO_CATITEM;
alter table SPECIMEN_PART drop constraint FK_SPECIMENPART_CATITEM;
alter table TAB_MEDIA_REL_FKEY drop constraint FK_TABMEDIARELFKEY_CATITEM;

alter table ATTRIBUTES
   add constraint FK_ATTRIBUTES_CATITEM foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table BIOL_INDIV_RELATIONS
   add constraint FK_BIOLINDIVRELN_CATITEM_COID foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table BIOL_INDIV_RELATIONS
   add constraint FK_BIOLINDIVRELN_CATITEM_RCOID foreign key (RELATED_COLL_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table CITATION
   add constraint FK_CITATION_CATITEM foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table COLLECTOR
   add constraint FK_COLLECTOR_CATITEM foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table COLL_OBJ_OTHER_ID_NUM
   add constraint FK_COLLOBJOTHERIDNUM_CATITEM foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table IDENTIFICATION
   add constraint FK_IDENTIFICATION_CATITEM foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

--!!! mvz has no data in specimen_annotations
alter table SPECIMEN_ANNOTATIONS
   add constraint FK_SPECIMENANNO_CATITEM foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table SPECIMEN_PART
   add constraint FK_SPECIMENPART_CATITEM foreign key (DERIVED_FROM_CAT_ITEM)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table TAB_MEDIA_REL_FKEY
   add constraint FK_TABMEDIARELFKEY_CATITEM foreign key (CFK_CATALOGED_ITEM)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);


PK_COLLECTING_EVENT     
alter table CATALOGED_ITEM drop constraint FK_CATITEM_COLLEVENT;
alter table TAB_MEDIA_REL_FKEY drop constraint FK_TABMEDIARELFKEY_COLLEVENT;
--alter table VESSEL_ARCHIVE drop constraint FK_VESSEL_COLLEVENT;

alter table CATALOGED_ITEM
   add constraint FK_CATITEM_COLLEVENT foreign key (COLLECTING_EVENT_ID)
      references COLLECTING_EVENT (COLLECTING_EVENT_ID);

alter table TAB_MEDIA_REL_FKEY
   add constraint FK_TABMEDIARELFKEY_COLLEVENT foreign key (CFK_COLLECTING_EVENT)
      references COLLECTING_EVENT (COLLECTING_EVENT_ID);

--!! mvz has no data in vessel
-- vessel no longer exists
--alter table VESSEL
--   add constraint FK_VESSEL_COLLEVENT foreign key (COLLECTING_EVENT_ID)
--      references COLLECTING_EVENT (COLLECTING_EVENT_ID);


PK_COLLECTION   
alter table CATALOGED_ITEM drop constraint FK_CATITEM_COLLECTION;
alter table COLLECTION_CONTACTS drop constraint FK_COLLCONTACTS_COLLECTION;
alter table TRANS drop constraint FK_TRANS_COLLECTION;

alter table CATALOGED_ITEM
   add constraint FK_CATITEM_COLLECTION foreign key (COLLECTION_ID)
      references COLLECTION (COLLECTION_ID);

alter table COLLECTION_CONTACTS
   add constraint FK_COLLCONTACTS_COLLECTION foreign key (COLLECTION_ID)
      references COLLECTION (COLLECTION_ID);

alter table TRANS
   add constraint FK_TRANS_COLLECTION foreign key (COLLECTION_ID)
      references COLLECTION (COLLECTION_ID);


PK_COLL_OBJECT  
alter table CATALOGED_ITEM drop constraint FK_CATITEM_COLLOBJECT;
alter table COLL_OBJECT_ENCUMBRANCE drop constraint FK_COLLOBJENC_COLLOBJECT;
alter table COLL_OBJECT_REMARK drop constraint FK_COLLOBJREM_COLLOBJ_COID;
alter table COLL_OBJ_CONT_HIST drop constraint FK_COLLOBJCONTHIST_COLLOBJ;
alter table LOAN_ITEM drop constraint FK_LOANITEM_SPECIMENPART;
alter table OBJECT_CONDITION drop constraint FK_OBJECTCONDITION_COLLOBJECT;
alter table SPECIMEN_PART drop constraint FK_SPECIMENPART_COLLOBJECT;

alter table CATALOGED_ITEM
   add constraint FK_CATITEM_COLLOBJECT foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID);

alter table COLL_OBJECT_ENCUMBRANCE
   add constraint FK_COLLOBJENC_COLLOBJECT foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID);

alter table COLL_OBJECT_REMARK
   add constraint FK_COLLOBJREM_COLLOBJ_COID foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID);

alter table COLL_OBJ_CONT_HIST
   add constraint FK_COLLOBJCONTHIST_COLLOBJ foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID);
      
alter table LOAN_ITEM
   add constraint FK_LOANITEM_COLLOBJECT foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID);

alter table OBJECT_CONDITION
   add constraint FK_OBJECTCONDITION_COLLOBJECT foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID)
      ON DELETE CASCADE;

alter table SPECIMEN_PART
   add constraint FK_SPECIMENPART_COLLOBJECT foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID);


PK_CONTAINER    
alter table COLL_OBJ_CONT_HIST drop constraint FK_COLLOBJCONTHIST_CONTAINER;
alter table CONTAINER_CHECK drop constraint FK_CONTAINERCHECK_CONTAINER;
alter table CONTAINER_HISTORY drop constraint FK_CONTAINERHIST_CONTAINER;
alter table FLUID_CONTAINER_HISTORY drop constraint FK_FLUIDCONTHIST_CONTAINER;
alter table SHIPMENT drop constraint FK_SHIPMENT_CONTAINER;

alter table COLL_OBJ_CONT_HIST
   add constraint FK_COLLOBJCONTHIST_CONTAINER foreign key (CONTAINER_ID)
      references CONTAINER (CONTAINER_ID);

--!! mvz has no data in container_check
alter table CONTAINER_CHECK
   add constraint FK_CONTAINERCHECK_CONTAINER foreign key (CONTAINER_ID)
      references CONTAINER (CONTAINER_ID);

--!! mvz has no data in container_check
alter table CONTAINER_HISTORY
   add constraint FK_CONTAINERHIST_CONTAINER foreign key (CONTAINER_ID)
      references CONTAINER (CONTAINER_ID);

/*
 select container_id from FLUID_CONTAINER_HISTORY where container_id not in (select container_id from container);

CONTAINER_ID
------------
      485105
    11571472

uam@arctos> select * from FLUID_CONTAINER_HISTORY where container_id in (485105, 11571472);

CONTAINER_ID CHECKED_DA FLUID_TYPE                     CONCENTRATION
------------ ---------- ------------------------------ -------------
FLUID_REMARKS
--------------------------------------------------------------------------------
      485105 01-01-2002 ethanol                                   .7
    11571472 01-01-1908 ethanol                                  .95

uam@arctos> delete from FLUID_CONTAINER_HISTORY where container_id in (485105, 11571472);

*/
alter table FLUID_CONTAINER_HISTORY
   add constraint FK_FLUIDCONTHIST_CONTAINER foreign key (CONTAINER_ID)
      references CONTAINER (CONTAINER_ID);

alter table SHIPMENT
   add constraint FK_SHIPMENT_CONTAINER foreign key (CONTAINER_ID)
      references CONTAINER (CONTAINER_ID);


PK_CTMEDIA_RELATIONSHIP 
alter table MEDIA_RELATIONS drop constraint FK_MEDIARELNS_CTMEDIARELNS;

alter table MEDIA_RELATIONS                                                   
    add constraint FK_MEDIARELNS_CTMEDIARELNS foreign key (MEDIA_RELATIONSHIP)
    references CTMEDIA_RELATIONSHIP (MEDIA_RELATIONSHIP);


PK_CTMIME_TYPE  
alter table MEDIA drop constraint FK_MEDIA_CTMIMETYPE;

alter table MEDIA
    add constraint FK_MEDIA_CTMIMETYPE foreign key (MIME_TYPE)
    references CTMIME_TYPE (MIME_TYPE);


PK_ENCUMBRANCE  
alter table COLL_OBJECT_ENCUMBRANCE drop constraint FK_COLLOBJENC_ENCUMBRANCE;

alter table COLL_OBJECT_ENCUMBRANCE
   add constraint FK_COLLOBJENC_ENCUMBRANCE foreign key (ENCUMBRANCE_ID)
      references ENCUMBRANCE (ENCUMBRANCE_ID);


PK_GEOG_AUTH_REC        
alter table LOCALITY drop constraint FK_LOCALITY_GEOGAUTHREC;

alter table LOCALITY
   add constraint FK_LOCALITY_GEOGAUTHREC foreign key (GEOG_AUTH_REC_ID)
      references GEOG_AUTH_REC (GEOG_AUTH_REC_ID);


PK_GEOLOGY_ATTRIBUTE_HIERARCHY  
alter table GEOLOGY_ATTRIBUTE_HIERARCHY drop constraint FK_GEOLATTRHIER_GEOLATTRHIER;

--!! mvz has no data in geology_attribute_hierarchy
alter table GEOLOGY_ATTRIBUTE_HIERARCHY
   add constraint FK_GEOLATTRHIER_GEOLATTRHIER foreign key (PARENT_ID)
      references GEOLOGY_ATTRIBUTE_HIERARCHY (GEOLOGY_ATTRIBUTE_HIERARCHY_ID);


PK_IDENTIFICATION       
alter table IDENTIFICATION_AGENT drop constraint FK_IDAGENT_IDENTIFICATION;
alter table IDENTIFICATION_TAXONOMY drop constraint FK_IDTAXONOMY_IDENTIFICATION;

alter table IDENTIFICATION_AGENT
   add constraint FK_IDAGENT_IDENTIFICATION foreign key (IDENTIFICATION_ID)
      references IDENTIFICATION (IDENTIFICATION_ID);

alter table IDENTIFICATION_TAXONOMY
   add constraint FK_IDTAXONOMY_IDENTIFICATION foreign key (IDENTIFICATION_ID)
      references IDENTIFICATION (IDENTIFICATION_ID);


PK_JOURNAL      
alter table JOURNAL_ARTICLE drop constraint FK_JOURNALARTICLE_JOURNAL;

alter table JOURNAL_ARTICLE
   add constraint FK_JOURNALARTICLE_JOURNAL foreign key (JOURNAL_ID)
      references JOURNAL (JOURNAL_ID);
      

PK_LOAN 
alter table LOAN_ITEM drop constraint FK_LOANITEM_LOAN;

alter table LOAN_ITEM
   add constraint FK_LOANITEM_LOAN foreign key (TRANSACTION_ID)
      references LOAN (TRANSACTION_ID);


PK_LOCALITY     
alter table COLLECTING_EVENT drop constraint FK_COLLEVENT_LOCALITY;
alter table GEOLOGY_ATTRIBUTES drop constraint FK_GEOLATTRIBUTES_LOCALITY;
alter table LAT_LONG drop constraint FK_LATLONG_LOCALITY;
alter table TAB_MEDIA_REL_FKEY drop constraint FK_MR_LOCALITY;

alter table COLLECTING_EVENT
   add constraint FK_COLLEVENT_LOCALITY foreign key (LOCALITY_ID)
      references LOCALITY (LOCALITY_ID);

--!! mvz has no data in geology_attributes
alter table GEOLOGY_ATTRIBUTES
   add constraint FK_GEOLATTRIBUTES_LOCALITY foreign key (LOCALITY_ID)
      references LOCALITY (LOCALITY_ID);

alter table LAT_LONG
   add constraint FK_LATLONG_LOCALITY foreign key (LOCALITY_ID)
      references LOCALITY (LOCALITY_ID);

alter table TAB_MEDIA_REL_FKEY
   add constraint FK_TABMEDIARELFKEY_LOCALITY foreign key (CFK_LOCALITY)
      references LOCALITY (LOCALITY_ID);


PK_MEDIA        
alter table MEDIA_LABELS drop constraint FK_MEDIALABELS_MEDIA;
alter table MEDIA_RELATIONS drop constraint FK_MEDIARELNS_MEDIA;

alter table MEDIA_LABELS
   add constraint FK_MEDIALABELS_MEDIA foreign key (MEDIA_ID)
      references MEDIA (MEDIA_ID);

alter table MEDIA_RELATIONS
   add constraint FK_MEDIARELNS_MEDIA foreign key (MEDIA_ID)
      references MEDIA (MEDIA_ID);


PK_PERMIT       
alter table PERMIT_TRANS drop constraint FK_PERMITTRANS_PERMIT;

alter table PERMIT_TRANS
   add constraint FK_PERMITTRANS_PERMIT foreign key (PERMIT_ID)
      references PERMIT (PERMIT_ID);


PK_PROJECT      
alter table PROJECT_AGENT drop constraint FK_PROJECTAGENT_PROJECT;
alter table PROJECT_PUBLICATION drop constraint FK_PROJECTPUB_PROJECT;
alter table PROJECT_SPONSOR drop constraint FK_PROJECTSPONSOR_PROJECT;
alter table PROJECT_TRANS drop constraint FK_PROJECTTRANS_PROJECT;

alter table PROJECT_AGENT
   add constraint FK_PROJECTAGENT_PROJECT foreign key (PROJECT_ID)
      references PROJECT (PROJECT_ID);

alter table PROJECT_PUBLICATION
   add constraint FK_PROJECTPUB_PROJECT foreign key (PROJECT_ID)
      references PROJECT (PROJECT_ID);

--!! mvz has no data in project_sponsor
alter table PROJECT_SPONSOR
   add constraint FK_PROJECTSPONSOR_PROJECT foreign key (PROJECT_ID)
      references PROJECT (PROJECT_ID);

alter table PROJECT_TRANS
   add constraint FK_PROJECTTRANS_PROJECT foreign key (PROJECT_ID)
      references PROJECT (PROJECT_ID);


PK_PUBLICATION  
alter table BOOK drop constraint FK_BOOK_PUBLICATION;
alter table BOOK_SECTION drop constraint FK_BOOKSECTION_PUBLICATION;
alter table CITATION drop constraint FK_CITATION_PUBLICATION;
alter table JOURNAL_ARTICLE drop constraint FK_JOURNALARTICLE_PUBLICATION;
alter table PAGE drop constraint FK_PAGE_PUBLICATION;
alter table PROJECT_PUBLICATION drop constraint FK_PROJECTPUB_PUBLICATION;
alter table PUBLICATION_AUTHOR_NAME drop constraint FK_PUBAUTHNAME_PUBLICATION;
alter table PUBLICATION_URL drop constraint FK_PUBLICATIONURL_PUBLICATION;

alter table BOOK
   add constraint FK_BOOK_PUBLICATION foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);

alter table BOOK_SECTION
   add constraint FK_BOOKSECTION_PUBLICATION foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);

alter table CITATION
   add constraint FK_CITATION_PUBLICATION foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);

alter table JOURNAL_ARTICLE
   add constraint FK_JOURNALARTICLE_PUBLICATION foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);

alter table PAGE
   add constraint FK_PAGE_PUBLICATION foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);

alter table PROJECT_PUBLICATION
   add constraint FK_PROJECTPUB_PUBLICATION foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);

alter table PUBLICATION_AUTHOR_NAME
   add constraint FK_PUBAUTHNAME_PUBLICATION foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);

alter table PUBLICATION_URL
   add constraint FK_PUBLICATIONURL_PUBLICATION foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);


PK_SPECIMEN_PART        
alter table SPECIMEN_PART drop constraint FK_SPECIMENPART_SPECIMENPART;

alter table SPECIMEN_PART
   add constraint FK_SPECIMENPART_SPECIMENPART foreign key (SAMPLED_FROM_OBJ_ID)
      references SPECIMEN_PART (COLLECTION_OBJECT_ID);


PK_TAXONOMY     
alter table CITATION drop constraint FK_CITATION_TAXONOMY;
alter table COMMON_NAME drop constraint FK_COMMONNAME_TAXONOMY;
alter table IDENTIFICATION_TAXONOMY drop constraint FK_IDTAXONOMY_TAXONOMY;
alter table TAXON_RELATIONS drop constraint FK_TAXONRELN_TAXONOMY_RTNID;
alter table TAXON_RELATIONS drop constraint FK_TAXONRELN_TAXONOMY_TNID;

alter table CITATION
   add constraint FK_CITATION_TAXONOMY foreign key (CITED_TAXON_NAME_ID)
      references TAXONOMY (TAXON_NAME_ID);

alter table COMMON_NAME
   add constraint FK_COMMONNAME_TAXONOMY foreign key (TAXON_NAME_ID)
      references TAXONOMY (TAXON_NAME_ID);

alter table IDENTIFICATION_TAXONOMY
   add constraint FK_IDTAXONOMY_TAXONOMY foreign key (TAXON_NAME_ID)
      references TAXONOMY (TAXON_NAME_ID);

alter table TAXON_RELATIONS
   add constraint FK_TAXONRELN_TAXONOMY_RTNID foreign key (RELATED_TAXON_NAME_ID)
      references TAXONOMY (TAXON_NAME_ID);

alter table TAXON_RELATIONS
   add constraint FK_TAXONRELN_TAXONOMY_TNID foreign key (TAXON_NAME_ID)
      references TAXONOMY (TAXON_NAME_ID);


PK_TRANS        
alter table ACCN drop constraint FK_ACCN_TRANS;
alter table BORROW drop constraint FK_BORROW_TRANS;
alter table LOAN drop constraint FK_LOAN_TRANS;
alter table PERMIT_TRANS drop constraint FK_PERMITTRANS_TRANS;
alter table PROJECT_TRANS drop constraint FK_PROJECTTRANS_TRANS;
alter table SHIPMENT drop constraint FK_SHIPMENT_TRANS;
alter table TRANS_AGENT drop constraint FK_TRANSAGENT_TRANS;

alter table ACCN
   add constraint FK_ACCN_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID);

alter table BORROW
   add constraint FK_BORROW_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID);

alter table LOAN
   add constraint FK_LOAN_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID);

alter table PERMIT_TRANS
   add constraint FK_PERMITTRANS_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID);

alter table PROJECT_TRANS
   add constraint FK_PROJECTTRANS_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID);

alter table SHIPMENT
   add constraint FK_SHIPMENT_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID);

alter table TRANS_AGENT
   add constraint FK_TRANSAGENT_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID);

      
      
      
