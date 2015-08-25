alter table ADDR rename constraint ADDR_PK to PK_ADDR;
alter table AGENT rename constraint SYS_C0018746 to PK_AGENT;
alter table AGENT_NAME rename constraint SYS_C0018754 to PK_AGENT_NAME;
alter table ATTRIBUTES rename constraint SYS_C0018774 to PK_ATTRIBUTES;
alter table CATALOGED_ITEM rename constraint SYS_C0018831 to PK_CATALOGED_ITEM;
alter table CITATION rename constraint SYS_C0019121 to PK_CITATION;
alter table COLLECTING_EVENT rename constraint SYS_C0019133 to PK_COLLECTING_EVENT;
alter table COLLECTION rename constraint SYS_C0019137 to PK_COLLECTION;
alter table COLL_OBJECT rename constraint SYS_C0019156 to PK_COLL_OBJECT;
alter table IDENTIFICATION rename constraint SYS_C0019449 to PK_IDENTIFICATION;
alter table LAT_LONG rename constraint SYS_C0019474 to PK_LAT_LONG;
alter table LOCALITY rename constraint SYS_C0019500 to PK_LOCALITY;
alter table PROJECT rename constraint SYS_C0019539 to PK_PROJECT;
alter table PROJECT_SPONSOR rename constraint SYS_C0019553 to PK_PROJECT_SPONSOR;
alter table TAXONOMY rename constraint SYS_C0019590 to PK_TAXONOMY;
alter table TRANS rename constraint SYS_C0019601 to PK_TRANS;
alter table TRANS_AGENT rename constraint TRANS_AGENT_PKEY to PK_TRANS_AGENT;



alter table ACCN
   add constraint PK_ACCN primary key (TRANSACTION_ID);

alter table ADDR
   add constraint PK_ADDR primary key (ADDR_ID);

alter table AGENT
   add constraint PK_AGENT primary key (AGENT_ID);

alter table AGENT_NAME
   add constraint PK_AGENT_NAME primary key (AGENT_NAME_ID);

alter table AGENT_NAME_PENDING_DELETE
   add constraint PK_AGENT_NAME_PENDING_DELETE primary key (AGENT_NAME_ID, AGENT_ID);


---------------- missing column
alter table AGENT_RELATIONS
   add constraint PK_AGENT_RELATIONS primary key (AGENT_RELATIONS_ID);

alter table ATTRIBUTES
   add constraint PK_ATTRIBUTES primary key (ATTRIBUTE_ID);
---------------------------- missing column
alter table BIOL_INDIV_RELATIONS
   add constraint PK_BIOL_INDIV_RELATIONS primary key (BIOL_INDIV_RELATIONS_ID);
--------------------------------------------
alter table BOOK
   add constraint PK_BOOK primary key (PUBLICATION_ID);

alter table BOOK_SECTION
   add constraint PK_BOOK_SECTION primary key (PUBLICATION_ID);

alter table BORROW
   add constraint PK_BORROW primary key (TRANSACTION_ID);

alter table CATALOGED_ITEM
   add constraint PK_CATALOGED_ITEM primary key (COLLECTION_OBJECT_ID);

alter table CITATION
   add constraint PK_CITATION primary key (COLLECTION_OBJECT_ID, PUBLICATION_ID);

alter table COLLECTING_EVENT
   add constraint PK_COLLECTING_EVENT primary key (COLLECTING_EVENT_ID);

alter table COLLECTION
   add constraint PK_COLLECTION primary key (COLLECTION_ID);

alter table COLLECTION_CONTACTS
   add constraint PK_COLLECTION_CONTACTS primary key (COLLECTION_CONTACT_ID);
---------------------------missing column
alter table COLLECTOR
   add constraint PK_COLLECTOR primary key (COLLECTOR_ID);
---------------------------------------------
alter table COLL_OBJECT
   add constraint PK_COLL_OBJECT primary key (COLLECTION_OBJECT_ID);

alter table COLL_OBJECT_ENCUMBRANCE
   add constraint PK_COLL_OBJECT_ENCUMBRANCE primary key (ENCUMBRANCE_ID, COLLECTION_OBJECT_ID);

alter table COLL_OBJECT_REMARK
   add constraint PK_COLL_OBJECT_REMARK primary key (COLLECTION_OBJECT_ID);
------------missing
alter table COLL_OBJ_CONT_HIST
   add constraint PK_COLL_OBJ_CONT_HIST primary key (COLL_OBJ_CONT_HIST_ID);

alter table COLL_OBJ_OTHER_ID_NUM
   add constraint PK_COLL_OBJ_OTHER_ID_NUM primary key (COLL_OBJ_OTHER_ID_NUM_ID);

alter table COMMON_NAME
   add constraint PK_COMMON_NAME primary key (TAXON_NAME_ID, COMMON_NAME);

alter table CONTAINER
   add constraint PK_CONTAINER primary key (CONTAINER_ID);

alter table CONTAINER_CHECK
   add constraint PK_CONTAINER_CHECK primary key (CONTAINER_CHECK_ID);
--- missing
alter table CONTAINER_HISTORY
   add constraint PK_CONTAINER_HISTORY primary key (CONTAINER_HISTORY_ID);
   
alter table CTMIME_TYPE 
   add constraint PK_CTMIME_TYPE primary key (MIME_TYPE);
   
alter table CTMEDIA_RELATIONSHIP 
   add constraint PK_CTMEDIA_RELATIONSHIP primary key (MEDIA_RELATIONSHIP);
   
-- missing
alter table ELECTRONIC_ADDRESS
   add constraint PK_ELECTRONIC_ADDRESS primary key (ELECTRONIC_ADDRESS_ID);

alter table ENCUMBRANCE
   add constraint PK_ENCUMBRANCE primary key (ENCUMBRANCE_ID);

alter table FIELD_NOTEBOOK_SECTION
   add constraint PK_FIELD_NOTEBOOK_SECTION primary key (PUBLICATION_ID);

alter table FLAT
   add constraint PK_FLAT primary key (COLLECTION_OBJECT_ID);
-- missing
alter table FLUID_CONTAINER_HISTORY
   add constraint PK_FLUID_CONTAINER_HISTORY primary key (FLUID_CONTAINER_HISTORY_ID);

alter table GEOG_AUTH_REC
   add constraint PK_GEOG_AUTH_REC primary key (GEOG_AUTH_REC_ID);

alter table GEOLOGY_ATTRIBUTES
   add constraint PK_GEOLOGY_ATTRIBUTES primary key (GEOLOGY_ATTRIBUTE_ID);

alter table GEOLOGY_ATTRIBUTE_HIERARCHY
   add constraint PK_GEOLOGY_ATTRIBUTE_HIERARCHY primary key (GEOLOGY_ATTRIBUTE_HIERARCHY_ID);

/*
alter table GREF_REFSET_NG
   add constraint PK_REFSET_NG primary key (ID);

alter table GREF_ROI_NG
   add constraint PK_ROI_NG primary key (ID);

alter table GREF_ROI_VALUE_NG
   add constraint PK_ROI_VALUE_NG primary key (ID);

alter table GREF_USER
   add constraint PK_GREF_USER primary key (ID);
*/

-- missing
alter table GROUP_MEMBER
   add constraint PK_GROUP_MEMBER primary key (GROUP_MEMBER_ID);

alter table IDENTIFICATION
   add constraint PK_IDENTIFICATION primary key (IDENTIFICATION_ID);

alter table IDENTIFICATION_AGENT
   add constraint PK_IDENTIFICATION_AGENT primary key (IDENTIFICATION_AGENT_ID);
-- missing
alter table IDENTIFICATION_TAXONOMY
   add constraint PK_IDENTIFICATION_TAXONOMY primary key (IDENTIFICATION_TAXONOMY_ID);
-- junk
alter table IMAGE_CONTENT
   add constraint PK_IMAGE_CONTENT primary key (IMAGE_CONTENT_ID);
-- junk
alter table IMAGE_OBJECT
   add constraint PK_IMAGE_OBJECT primary key (COLLECTION_OBJECT_ID);
-- junk
alter table IMAGE_SUBJECT
   add constraint PK_IMAGE_SUBJECT primary key (IMAGE_SUBJECT_ID);
-- junk
alter table IMAGE_SUBJECT_REMARKS
   add constraint PK_IMAGE_SUBJECT_REMARKS primary key (IMAGE_SUBJECT_ID);

alter table JOURNAL
   add constraint PK_JOURNAL primary key (JOURNAL_ID);

alter table JOURNAL_ARTICLE
   add constraint PK_JOURNAL_ARTICLE primary key (PUBLICATION_ID);

alter table LAT_LONG
   add constraint PK_LAT_LONG primary key (LAT_LONG_ID);

alter table LOAN
   add constraint PK_LOAN primary key (TRANSACTION_ID);
-- missing
alter table LOAN_ITEM
   add constraint PK_LOAN_ITEM primary key (LOAN_ITEM_ID);

alter table LOCALITY
   add constraint PK_LOCALITY primary key (LOCALITY_ID);

alter table MEDIA
   add constraint PK_MEDIA primary key (MEDIA_ID);

alter table MEDIA_LABELS
   add constraint PK_MEDIA_LABELS primary key (MEDIA_LABEL_ID);

alter table MEDIA_RELATIONS
   add constraint PK_MEDIA_RELATIONS primary key (MEDIA_RELATIONS_ID);

alter table OBJECT_CONDITION
   add constraint PK_OBJECT_CONDITION primary key (OBJECT_CONDITION_ID);

alter table PAGE
   add constraint PK_PAGE primary key (PAGE_ID);

alter table PERMIT
   add constraint PK_PERMIT primary key (PERMIT_ID);

alter table PERMIT_TRANS
   add constraint PK_PERMIT_TRANS primary key (PERMIT_ID, TRANSACTION_ID);

alter table PERSON
   add constraint PK_PERSON primary key (PERSON_ID);

alter table PROJECT
   add constraint PK_PROJECT primary key (PROJECT_ID);
   
-- missing
alter table PROJECT_AGENT
   add constraint PK_PROJECT_AGENT primary key (PROJECT_AGENT_ID);
   
-- missing
alter table PROJECT_PUBLICATION
   add constraint PK_PROJECT_PUBLICATION primary key (PROJECT_PUBLICATION_ID);

alter table PROJECT_SPONSOR
   add constraint PK_PROJECT_SPONSOR primary key (PROJECT_SPONSOR_ID);
   
--missing
alter table PROJECT_TRANS
   add constraint PK_PROJECT_TRANS primary key (PROJECT_TRANS_ID);

alter table PUBLICATION
   add constraint PK_PUBLICATION primary key (PUBLICATION_ID);
   
--missing from prod
alter table PUBLICATION_URL
   add constraint PK_PUBLICATION_URL primary key (PUBLICATION_URL_ID);
   
-- missing
alter table PUBLICATION_AUTHOR_NAME
   add constraint PK_PUBLICATION_AUTHOR_NAME primary key (PUBLICATION_AUTHOR_NAME_ID);
   
-- duplicate IDs: cannot validate (UAM.PK_PUBLICATION_URL) - primary key violated
-- okay at mvz
alter table PUBLICATION_URL
   add constraint PK_PUBLICATION_URL primary key (PUBLICATION_URL_ID);
-- missing
alter table SHIPMENT
   add constraint PK_SHIPMENT primary key (SHIPMENT_ID);

alter table SPECIMEN_ANNOTATIONS
   add constraint PK_SPECIMEN_ANNOTATIONS primary key (ANNOTATION_ID);

alter table SPECIMEN_PART
   add constraint PK_SPECIMEN_PART primary key (COLLECTION_OBJECT_ID);

alter table TAXONOMY
   add constraint PK_TAXONOMY primary key (TAXON_NAME_ID);
-- is and should be invalid: this table will have dup rows
--alter table TAXONOMY_ARCHIVE
--   add constraint PK_TAXONOMY_ARCHIVE primary key (TAXON_NAME_ID);
-- missing
alter table TAXON_RELATIONS
   add constraint PK_TAXON_RELATIONS primary key (TAXON_RELATIONS_ID);

alter table TRANS
   add constraint PK_TRANS primary key (TRANSACTION_ID);

alter table TRANS_AGENT
   add constraint PK_TRANS_AGENT primary key (TRANS_AGENT_ID);
-- missing
alter table VESSEL
   add constraint PK_VESSEL primary key (VESSEL_ID);

