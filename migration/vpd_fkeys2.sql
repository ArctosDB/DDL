/*
alter table ATTRIBUTES rename constraint FK_CATALOGED_ITEM to FK_ATTRIBUTES_CATITEM;
alter table ATTRIBUTES rename constraint FK_DETERMINED_BY_AGENT_ID to FK_ATTRIBUTES_AGENT;
alter table BINARY_OBJECT rename constraint FK_BINARY_OBJECT to FK_BINARY_OBJECT_BINARY_OBJECT;
alter table BIOL_INDIV_RELATIONS rename constraint FK_RELATED_ITEM to FK_BIOLINDIVRELN_CATITEM_COID;
alter table BIOL_INDIV_RELATIONS rename constraint FK_RELATED_TO_ITEM to FK_BIOLINDIVRELN_CATITEM_RCOID;
alter table CATALOGED_ITEM rename constraint FK_COLLECTING_EVENT to FK_CATITEM_COLLEVENT;
alter table CATALOGED_ITEM rename constraint FK_COLLECTION to FK_CATITEM_COLLECTION;
alter table CATALOGED_ITEM rename constraint FK_COLL_OBJECT to FK_CATITEM_COLLOBJECT;
alter table CITATION rename constraint FK_CIT_CAT_ITEM to FK_CITATION_CATITEM;
alter table CITATION rename constraint FK_CIT_PUBLICATION to FK_CITATION_PUBLICATION;
alter table COLLECTING_EVENT rename constraint FK_LOCALITY_ID to FK_COLLEVENT_LOCALITY;
alter table COLLECTOR rename constraint FK_COLL_AGENT to FK_COLLECTOR_AGENT;
alter table COLLECTOR rename constraint FK_COLL_CAT_ITEM to FK_COLLECTOR_CATITEM;
alter table CONTAINER_CHECK rename constraint FKEY_CONT_AGNT_AGENT to FK_CONTAINERCHECK_AGENT;
alter table CONTAINER_CHECK rename constraint FKEY_CONT_CHK_CONTAINER to FK_CONTAINERCHECK_CONTAINER_ID;
alter table ENCUMBRANCE rename constraint FK_ENCUMBR_AGNT to FK_ENCUMBRANCE_AGENT;
alter table GEOLOGY_ATTRIBUTES rename constraint FK_GEOLOGY_LOCALITY to FK_GEOLATTRIBUTES_LOCALITY;
alter table GEOLOGY_ATTRIBUTE_HIERARCHY rename constraint FK_GEOLOGY_ATTRIBUTE_HIERARCHY to FK_GEOLATTRHIER_GEOLATTRHIER;
alter table IDENTIFICATION_AGENT rename constraint FK_ID_AGNT_ID to FK_IDAGENT_AGENT;
alter table IDENTIFICATION_AGENT rename constraint FK_IDENTIFICATION_ID to FK_IDAGENT_IDENTIFICATION;
alter table IDENTIFICATION_TAXONOMY rename constraint FK_IDENTIFICATION to FK_IDTAXONOMY_IDENTIFICATION;
alter table IDENTIFICATION_TAXONOMY rename constraint FK_TAXONOMY to FK_IDTAXONOMY_TAXONOMY;
alter table LAT_LONG rename constraint FK_DETERMINRE to FK_LATLONG_AGENT;
alter table LAT_LONG rename constraint FK_LOCALITY to FK_LATLONG_LOCALITY;
alter table LOAN_ITEM rename constraint FK_LOAN_ITEM_ITEM to FK_LOANITEM_COLLOBJECT;
alter table LOCALITY rename constraint FK_GEOG to FK_LOCALITY_GEOGAUTHREC;
alter table MEDIA rename constraint FK_MIME_TYPE to FK_MEDIA_CTMIMETYPE;
alter table MEDIA_LABELS rename constraint FK_MEDIA_AGENT to FK_MEDIALABELS_AGENT;
alter table MEDIA_LABELS rename constraint FK_MEDIA_LABEL to FK_MEDIALABELS_MEDIA;
alter table MEDIA_RELATIONS rename constraint FK_CREATED_BY_AGENT_ID to FK_MEDIARELATIONS_AGENT;
alter table MEDIA_RELATIONS rename constraint FK_MEDIA_ID to FK_MEDIARELATIONS_MEDIA;
alter table MEDIA_RELATIONS rename constraint FK_MEDIA_RELATIONSHIP to FK_MEDIARELATIONS_CTMEDIARELN;
alter table OBJECT_CONDITION rename constraint FK_OBJ_CONDITION_COLL_OBJECT to FK_OBJECTCONDITION_COLLOBJECT;
alter table PROJECT_SPONSOR rename constraint FK_AGENT_NAME_ID to FK_PROJECTSPONSOR_AGENTNAME;
alter table PROJECT_SPONSOR rename constraint FK_PROJECT_ID to FK_PROJECTSPONSOR_PROJECT;
alter table SHIPMENT rename constraint SHIPMENT_SHIPFROM_FK to FK_SHIPMENT_ADDR_SHIPPEDFROM;
alter table SHIPMENT rename constraint SHIPMENT_SHIPTO_FK to FK_SHIPMENT_ADDR_SHIPPEDTO;
alter table SPECIMEN_PART rename constraint FK_COLL_OBJ_PART to FK_SPECIMENPART_COLL_OBJECT;
alter table SPECIMEN_PART rename constraint FK_PART_CAT_ITEM to FK_SPECIMENPART_CAT_ITEM;
alter table TAB_MEDIA_REL_FKEY rename constraint FK_MR_AGENT to FK_TABMEDIAREL_AGENT;
alter table TAB_MEDIA_REL_FKEY rename constraint FK_MR_CATALOGED_ITEM to FK_TABMEDIAREL_CATITEM;
alter table TAXON_RELATIONS rename constraint FK_TAXONOMY2 to FK_TAXONRELN_TAXONOMY_RTNID;
alter table TAXON_RELATIONS rename constraint FK_TAXONOMY1 to FK_TAXONRELN_TAXONOMY_TNID;
alter table TRANS_AGENT rename constraint FK_TRANS_AGNT_AGNT to FK_TRANSAGENT_AGENT;
alter table TRANS_AGENT rename constraint FK_TRANS_AGNT_TRANS to FK_TRANSAGENT_TRANS;

alter table LOAN_ITEM DROP constraint FK_LOAN_ITEM_LOAN;
*/

alter table ACCN
   add constraint FK_ACCN_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID);

alter table ADDR
   add constraint FK_ADDR_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID);

alter table AGENT_NAME
   add constraint FK_AGENTNAME_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID);

alter table AGENT_NAME_PENDING_DELETE
   add constraint FK_AGENTNAMEPENDEL_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID);

alter table AGENT_NAME_PENDING_DELETE
   add constraint FK_AGENTNAMEPENDEL_AGENTNAME foreign key (AGENT_NAME_ID)
      references AGENT_NAME (AGENT_NAME_ID);

alter table AGENT_RELATIONS
   add constraint FK_AGENTRELATIONS_AGENT_ANID foreign key (AGENT_ID)
      references AGENT (AGENT_ID);
      
alter table AGENT_RELATIONS
   add constraint FK_AGENTRELATIONS_AGENT_RANID foreign key (RELATED_AGENT_ID)
      references AGENT (AGENT_ID);

alter table ATTRIBUTES
   add constraint FK_ATTRIBUTES_AGENT foreign key (DETERMINED_BY_AGENT_ID)
      references AGENT (AGENT_ID);

alter table ATTRIBUTES
   add constraint FK_ATTRIBUTES_CATITEM foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table BIOL_INDIV_RELATIONS
   add constraint FK_BIOLINDIVRELN_CATITEM_COID foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table BIOL_INDIV_RELATIONS
   add constraint FK_BIOLINDIVRELN_CATITEM_RCOID foreign key (RELATED_COLL_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

-- ORA-02298: cannot validate (UAM.FK_BOOK_PUBLICATION) - parent keys not found
-- record for "unpublished"
-- delete from book where publication_id = 0; 
alter table BOOK
   add constraint FK_BOOK_PUBLICATION foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);

alter table BOOK_SECTION
   add constraint FK_BOOKSECTION_BOOK foreign key (BOOK_ID)
      references BOOK (PUBLICATION_ID);

alter table BOOK_SECTION
   add constraint FK_BOOKSECTION_PUBLICATION foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);

alter table BORROW
   add constraint FK_BORROW_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID);

alter table CATALOGED_ITEM
   add constraint FK_CATITEM_COLLECTION foreign key (COLLECTION_ID)
      references COLLECTION (COLLECTION_ID);

alter table CATALOGED_ITEM
   add constraint FK_CATITEM_COLLEVENT foreign key (COLLECTING_EVENT_ID)
      references COLLECTING_EVENT (COLLECTING_EVENT_ID);

alter table CATALOGED_ITEM
   add constraint FK_CATITEM_COLLOBJECT foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID);

alter table CATALOGED_ITEM
   add constraint FK_CATITEM_TRANS foreign key (ACCN_ID)
      references TRANS (TRANSACTION_ID);

alter table CITATION
   add constraint FK_CITATION_CATITEM foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table CITATION
   add constraint FK_CITATION_PUBLICATION foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);

--ORA-02298: cannot validate (UAM.FK_CITATION_TAXONOMY) - parent keys not found
-- fixed 10/02/08. lkv.
alter table CITATION
   add constraint FK_CITATION_TAXONOMY foreign key (CITED_TAXON_NAME_ID)
      references TAXONOMY (TAXON_NAME_ID);

--ORA-02298: cannot validate (UAM.FK_COLLEVENT_AGENT) - parent keys not found
--date_determined_by_agent_id to be deprecated.
--alter table COLLECTING_EVENT
--   add constraint FK_COLLEVENT_AGENT foreign key (DATE_DETERMINED_BY_AGENT_ID)
--      references AGENT (AGENT_ID);

alter table COLLECTING_EVENT
   add constraint FK_COLLEVENT_LOCALITY foreign key (LOCALITY_ID)
      references LOCALITY (LOCALITY_ID);

alter table COLLECTION_CONTACTS
   add constraint FK_COLLCONTACTS_AGENT foreign key (CONTACT_AGENT_ID)
      references AGENT (AGENT_ID);

--ORA-02298: cannot validate (UAM.FK_COLLCONTACTS_COLLECTION) - parent keys not found
--delete from collection_contacts
--where collection_id not in (select collection_id from collection);

alter table COLLECTION_CONTACTS
   add constraint FK_COLLCONTACTS_COLLECTION foreign key (COLLECTION_ID)
      references COLLECTION (COLLECTION_ID);

alter table COLLECTOR
   add constraint FK_COLLECTOR_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID);

alter table COLLECTOR
   add constraint FK_COLLECTOR_CATITEM foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table COLL_OBJECT
   add constraint FK_COLLOBJECT_AGENT_EDITED foreign key (LAST_EDITED_PERSON_ID)
      references AGENT (AGENT_ID);

alter table COLL_OBJECT
   add constraint FK_COLLOBJECT_AGENT_ENTERED foreign key (ENTERED_PERSON_ID)
      references AGENT (AGENT_ID);

alter table COLL_OBJECT_ENCUMBRANCE
   add constraint FK_COLLOBJENC_COLLOBJECT foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID);

alter table COLL_OBJECT_ENCUMBRANCE
   add constraint FK_COLLOBJENC_ENCUMBRANCE foreign key (ENCUMBRANCE_ID)
      references ENCUMBRANCE (ENCUMBRANCE_ID);

--alter table COLL_OBJECT_REMARK
--   add constraint FK_COLLOBJREM_COLLOBJ_COID foreign key (COLLECTION_OBJECT_ID)
--      references COLL_OBJECT (COLLECTION_OBJECT_ID);

alter table COLL_OBJECT_REMARK
   DROP constraint FK_COLLOBJREM_COLLOBJ_COID;

alter table COLL_OBJECT_REMARK
   add constraint FK_COLLOBJREM_COLLOBJECT foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID)
      ON DELETE CASCADE;

--- modified 2/10/09 LKV
--alter table COLL_OBJ_CONT_HIST
--   add constraint FK_COLLOBJCONTHIST_COLLOBJ foreign key (COLLECTION_OBJECT_ID)
--      references COLL_OBJECT (COLLECTION_OBJECT_ID);

      
ALTER TABLE coll_obj_cont_hist
DROP CONSTRAINT FK_COLLOBJCONTHIST_COLLOBJ
      
alter table COLL_OBJ_CONT_HIST
   add constraint FK_COLLOBJCONTHIST_SPECPART foreign key (COLLECTION_OBJECT_ID)
      references SPECIMEN_PART (COLLECTION_OBJECT_ID)
      ON DELETE CASCADE;
      
--- modified 2/10/09

alter table COLL_OBJ_CONT_HIST
   add constraint FK_COLLOBJCONTHIST_CONTAINER foreign key (CONTAINER_ID)
      references CONTAINER (CONTAINER_ID);

alter table COLL_OBJ_OTHER_ID_NUM
   add constraint FK_COLLOBJOTHERIDNUM_CATITEM foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table COMMON_NAME
   add constraint FK_COMMONNAME_TAXONOMY foreign key (TAXON_NAME_ID)
      references TAXONOMY (TAXON_NAME_ID);

--ORA-02298: cannot validate (UAM.FK_CONTAINER_CONTAINER) - parent keys not found
--do not implement!
--alter table CONTAINER
--   add constraint FK_CONTAINER_CONTAINER foreign key (PARENT_CONTAINER_ID)
--      references CONTAINER (CONTAINER_ID);

alter table CONTAINER_CHECK
   add constraint FK_CONTAINERCHECK_AGENT foreign key (CHECKED_AGENT_ID)
      references AGENT (AGENT_ID);

alter table CONTAINER_CHECK
   add constraint FK_CONTAINERCHECK_CONTAINER foreign key (CONTAINER_ID)
      references CONTAINER (CONTAINER_ID);

alter table CONTAINER_HISTORY
   add constraint FK_CONTAINERHIST_CONTAINER foreign key (CONTAINER_ID)
      references CONTAINER (CONTAINER_ID);

/* do not implement
alter table CONTAINER_HISTORY
   add constraint FK_CONTAINHIST_CONTAINER_PCID foreign key (PARENT_CONTAINER_ID)
      references CONTAINER (CONTAINER_ID);
*/

alter table ELECTRONIC_ADDRESS
   add constraint FK_ELECTRONICADDR_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID);

alter table ENCUMBRANCE
   add constraint FK_ENCUMBRANCE_AGENT foreign key (ENCUMBERING_AGENT_ID)
      references AGENT (AGENT_ID);

alter table FIELD_NOTEBOOK_SECTION
   add constraint FK_FIELDNOTESEC_BOOKSEC foreign key (PUBLICATION_ID)
      references BOOK_SECTION (PUBLICATION_ID);

--ORA-02298: cannot validate (UAM.FK_FLUIDCONTHIST_CONTAINER) - parent keys not found
--delete from fluid_container_history 
--where container_id not in (select container_id from container);

alter table FLUID_CONTAINER_HISTORY
   add constraint FK_FLUIDCONTHIST_CONTAINER foreign key (CONTAINER_ID)
      references CONTAINER (CONTAINER_ID);

alter table GEOLOGY_ATTRIBUTES
   add constraint FK_GEOLATTRIBUTES_LOCALITY foreign key (LOCALITY_ID)
      references LOCALITY (LOCALITY_ID);

alter table GEOLOGY_ATTRIBUTE_HIERARCHY
   add constraint FK_GEOLATTRHIER_GEOLATTRHIER foreign key (PARENT_ID)
      references GEOLOGY_ATTRIBUTE_HIERARCHY (GEOLOGY_ATTRIBUTE_HIERARCHY_ID);

--ORA-02298: cannot validate (UAM.FK_GROUPMEMBER_AGENT_GROUP) - parent keys not found
--DELETE FROM GROUP_MEMBER 
--WHERE GROUP_AGENT_ID NOT IN (SELECT agent_id FROM agent);

alter table GROUP_MEMBER
   add constraint FK_GROUPMEMBER_AGENT_GROUP foreign key (GROUP_AGENT_ID)
      references AGENT (AGENT_ID);

alter table GROUP_MEMBER
   add constraint FK_GROUPMEMBER_AGENT_MEMBER foreign key (MEMBER_AGENT_ID)
      references AGENT (AGENT_ID);

--ORA-02298: cannot validate (UAM.FK_IDENTIFICATION_CATITEM) - parent keys not found
--delete from identification 
--where collection_object_id not in (select collection_object_id from cataloged_item);

alter table IDENTIFICATION
   add constraint FK_IDENTIFICATION_CATITEM foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table IDENTIFICATION_AGENT
   add constraint FK_IDAGENT_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID);

alter table IDENTIFICATION_AGENT
   add constraint FK_IDAGENT_IDENTIFICATION foreign key (IDENTIFICATION_ID)
      references IDENTIFICATION (IDENTIFICATION_ID);

alter table IDENTIFICATION_TAXONOMY
   add constraint FK_IDTAXONOMY_IDENTIFICATION foreign key (IDENTIFICATION_ID)
      references IDENTIFICATION (IDENTIFICATION_ID);

alter table IDENTIFICATION_TAXONOMY
   add constraint FK_IDTAXONOMY_TAXONOMY foreign key (TAXON_NAME_ID)
      references TAXONOMY (TAXON_NAME_ID);

--ORA-02298: cannot validate (UAM.FK_IMAGECONTENT_AGENT) - parent keys not found
--agent_id 12315
--update image_content set agent_id = 9995 
--where image_content_id = 76944;
alter table IMAGE_CONTENT
   add constraint FK_IMAGECONTENT_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID);

alter table IMAGE_CONTENT
   add constraint FK_IMAGECONTENT_COLLOBJECT foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID);

alter table IMAGE_CONTENT
   add constraint FK_IMAGECONTENT_IMAGEOBJECT foreign key (REFERENCED_IMAGE_OBJECT_ID)
      references IMAGE_OBJECT (COLLECTION_OBJECT_ID);

--ORA-04020: deadlock detected while trying to lock object UAM.IMAGE_SUBJECT
--table image_subject dropped
--alter table IMAGE_CONTENT
--   add constraint FK_IMAGECONTENT_IMAGESUBJECT foreign key (IMAGE_SUBJECT_ID)
--      references IMAGE_SUBJECT (IMAGE_SUBJECT_ID);

--ORA-02298: cannot validate (UAM.FK_IMAGECONTENT_LOCALITY) - parent keys not found
--need to come back to fix!!!
alter table IMAGE_CONTENT
   add constraint FK_IMAGECONTENT_LOCALITY foreign key (LOCALITY_ID)
      references LOCALITY (LOCALITY_ID);

alter table IMAGE_CONTENT
   add constraint FK_IMAGECONTENT_PAGE foreign key (PAGE_ID)
      references PAGE (PAGE_ID);

--ORA-02298: cannot validate (UAM.FK_IMAGECONTENT_TAXONOMY) - parent keys not found
-- need to come back to fix!!!
alter table IMAGE_CONTENT
   add constraint FK_IMAGECONTENT_TAXONOMY foreign key (TAXON_NAME_ID)
      references TAXONOMY (TAXON_NAME_ID);

alter table IMAGE_OBJECT
   add constraint FK_IMAGEOBJECT_COLLOBJECT foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID);

alter table IMAGE_OBJECT
   add constraint FK_IMAGEOBJECT_IMAGEOBJECT foreign key (MADE_FROM_IMAGE_OBJECT_ID)
      references IMAGE_OBJECT (COLLECTION_OBJECT_ID);

--ORA-04020: deadlock detected while trying to lock object UAM.IMAGE_SUBJECT
-- image_subject table dropped
--alter table IMAGE_OBJECT
--   add constraint FK_IMAGEOBJECT_IMAGESUBJECT foreign key (IMAGE_SUBJECT_ID)
--      references IMAGE_SUBJECT (IMAGE_SUBJECT_ID);
      
--ORA-04020: deadlock detected while trying to lock object UAM.IMAGE_SUBJECT
-- image_subject table dropped
--alter table IMAGE_SUBJECT_REMARKS
--   add constraint FK_IMGSUBREM_IMGSUB_IMGSUBID foreign key (IMAGE_SUBJECT_ID)
--      references IMAGE_SUBJECT (IMAGE_SUBJECT_ID);

alter table JOURNAL_ARTICLE
   add constraint FK_JOURNALARTICLE_JOURNAL foreign key (JOURNAL_ID)
      references JOURNAL (JOURNAL_ID);
      
--ORA-02298: cannot validate (UAM.FK_JOURNALARTICLE_PUBLICATION) - parent keys not found
--delete from journal_article
--where publication_id not in (select publication_id from publication)
alter table JOURNAL_ARTICLE
   add constraint FK_JOURNALARTICLE_PUBLICATION foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);

alter table LAT_LONG
   add constraint FK_LATLONG_AGENT foreign key (DETERMINED_BY_AGENT_ID)
      references AGENT (AGENT_ID);

alter table LAT_LONG
   add constraint FK_LATLONG_LOCALITY foreign key (LOCALITY_ID)
      references LOCALITY (LOCALITY_ID);

alter table LOAN
   add constraint FK_LOAN_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID);

alter table LOAN_ITEM
   add constraint FK_LOANITEM_AGENT foreign key (RECONCILED_BY_PERSON_ID)
      references AGENT (AGENT_ID);

--ORA-02298: cannot validate (UAM.FK_LOANITEM_COLLOBJECT) - parent keys not found
-- fixed 10/15/08. see emails.
alter table LOAN_ITEM
   add constraint FK_LOANITEM_COLLOBJECT foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID);

alter table LOAN_ITEM
   add constraint FK_LOANITEM_LOAN foreign key (TRANSACTION_ID)
      references LOAN (TRANSACTION_ID);

alter table LOCALITY
   add constraint FK_LOCALITY_GEOGAUTHREC foreign key (GEOG_AUTH_REC_ID)
      references GEOG_AUTH_REC (GEOG_AUTH_REC_ID);

alter table MEDIA
    add constraint FK_MEDIA_CTMIMETYPE foreign key (MIME_TYPE)
    references CTMIME_TYPE (MIME_TYPE);

alter table MEDIA_LABELS
   add constraint FK_MEDIALABELS_AGENT foreign key (ASSIGNED_BY_AGENT_ID)
      references AGENT (AGENT_ID);

alter table MEDIA_LABELS
   add constraint FK_MEDIALABELS_MEDIA foreign key (MEDIA_ID)
      references MEDIA (MEDIA_ID);

alter table MEDIA_RELATIONS
   add constraint FK_MEDIARELNS_AGENT foreign key (CREATED_BY_AGENT_ID)
      references AGENT (AGENT_ID);

alter table MEDIA_RELATIONS                                                   
    add constraint FK_MEDIARELNS_CTMEDIARELNS foreign key (MEDIA_RELATIONSHIP)
    references CTMEDIA_RELATIONSHIP (MEDIA_RELATIONSHIP);

alter table MEDIA_RELATIONS
   add constraint FK_MEDIARELNS_MEDIA foreign key (MEDIA_ID)
      references MEDIA (MEDIA_ID);

alter table OBJECT_CONDITION
   add constraint FK_OBJECTCONDITION_AGENT foreign key (DETERMINED_AGENT_ID)
      references AGENT (AGENT_ID);

--modified 2/10/09 LKV
--alter table OBJECT_CONDITION
--   add constraint FK_OBJECTCONDITION_COLLOBJECT foreign key (COLLECTION_OBJECT_ID)
--      references COLL_OBJECT (COLLECTION_OBJECT_ID);

alter table OBJECT_CONDITION
   DROP constraint FK_OBJECTCONDITION_COLLOBJECT;
      
alter table OBJECT_CONDITION
   add constraint FK_OBJECTCONDITION_COLLOBJECT foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID)
      ON DELETE CASCADE;
--^^modified 2/10/09 LKV

alter table PAGE
   add constraint FK_PAGE_PUBLICATION foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);

alter table PERMIT
   add constraint FK_PERMIT_AGENT_CONTACT foreign key (CONTACT_AGENT_ID)
      references AGENT (AGENT_ID);

alter table PERMIT
   add constraint FK_PERMIT_AGENT_ISSUEDBY foreign key (ISSUED_BY_AGENT_ID)
      references AGENT (AGENT_ID);

alter table PERMIT
   add constraint FK_PERMIT_AGENT_ISSUEDTO foreign key (ISSUED_TO_AGENT_ID)
      references AGENT (AGENT_ID);

alter table PERMIT_TRANS
   add constraint FK_PERMITTRANS_PERMIT foreign key (PERMIT_ID)
      references PERMIT (PERMIT_ID);

alter table PERMIT_TRANS
   add constraint FK_PERMITTRANS_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID);

alter table PERSON
   add constraint FK_PERSON_AGENT foreign key (PERSON_ID)
      references AGENT (AGENT_ID);

--ORA-02298: cannot validate (UAM.FK_PROJECTAGENT_AGENTNAME) - parent keys not found
-- fixed 10/02/08. lkv.
alter table PROJECT_AGENT
   add constraint FK_PROJECTAGENT_AGENTNAME foreign key (AGENT_NAME_ID)
      references AGENT_NAME (AGENT_NAME_ID);

alter table PROJECT_AGENT
   add constraint FK_PROJECTAGENT_PROJECT foreign key (PROJECT_ID)
      references PROJECT (PROJECT_ID);

alter table PROJECT_PUBLICATION
   add constraint FK_PROJECTPUB_PROJECT foreign key (PROJECT_ID)
      references PROJECT (PROJECT_ID);

alter table PROJECT_PUBLICATION
   add constraint FK_PROJECTPUB_PUBLICATION foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);

alter table PROJECT_SPONSOR
   add constraint FK_PROJECTSPONSOR_AGENTNAME foreign key (AGENT_NAME_ID)
      references AGENT_NAME (AGENT_NAME_ID);

alter table PROJECT_SPONSOR
   add constraint FK_PROJECTSPONSOR_PROJECT foreign key (PROJECT_ID)
      references PROJECT (PROJECT_ID);

alter table PROJECT_TRANS
   add constraint FK_PROJECTTRANS_PROJECT foreign key (PROJECT_ID)
      references PROJECT (PROJECT_ID);

alter table PROJECT_TRANS
   add constraint FK_PROJECTTRANS_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID);

--ORA-02298: cannot validate (UAM.FK_PUBAUTHNAME_AGENTNAME) - parent keys not found
-- fixed 10/02/08. lkv.
alter table PUBLICATION_AUTHOR_NAME
   add constraint FK_PUBAUTHNAME_AGENTNAME foreign key (AGENT_NAME_ID)
      references AGENT_NAME (AGENT_NAME_ID);

alter table PUBLICATION_AUTHOR_NAME
   add constraint FK_PUBAUTHNAME_PUBLICATION foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);

alter table PUBLICATION_URL
   add constraint FK_PUBLICATIONURL_PUBLICATION foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);

alter table SHIPMENT
   add constraint FK_SHIPMENT_ADDR_SHIPPEDFROM foreign key (SHIPPED_FROM_ADDR_ID)
      references ADDR (ADDR_ID);

alter table SHIPMENT
   add constraint FK_SHIPMENT_ADDR_SHIPPEDTO foreign key (SHIPPED_TO_ADDR_ID)
      references ADDR (ADDR_ID);

alter table SHIPMENT
   add constraint FK_SHIPMENT_AGENT foreign key (PACKED_BY_AGENT_ID)
      references AGENT (AGENT_ID);

alter table SHIPMENT
   add constraint FK_SHIPMENT_CONTAINER foreign key (CONTAINER_ID)
      references CONTAINER (CONTAINER_ID);

alter table SHIPMENT
   add constraint FK_SHIPMENT_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID);

alter table SPECIMEN_ANNOTATIONS
   add constraint FK_SPECIMENANNO_CATITEM foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table SPECIMEN_PART
   add constraint FK_SPECIMENPART_CATITEM foreign key (DERIVED_FROM_CAT_ITEM)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table SPECIMEN_PART
   add constraint FK_SPECIMENPART_COLLOBJECT foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID);

--ORA-02298: cannot validate (UAM.FK_SPECIMENPART_SPECIMENPART) - parent keys not found
alter table SPECIMEN_PART
   add constraint FK_SPECIMENPART_SPECIMENPART foreign key (SAMPLED_FROM_OBJ_ID)
      references SPECIMEN_PART (COLLECTION_OBJECT_ID);

alter table TAB_MEDIA_REL_FKEY
   add constraint FK_TABMEDIARELFKEY_AGENT foreign key (CFK_AGENT)
      references AGENT (AGENT_ID);
      
alter table TAB_MEDIA_REL_FKEY
   add constraint FK_TABMEDIARELFKEY_CATITEM foreign key (CFK_CATALOGED_ITEM)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table TAB_MEDIA_REL_FKEY
   add constraint FK_TABMEDIARELFKEY_COLLEVENT foreign key (CFK_COLLECTING_EVENT)
      references COLLECTING_EVENT (COLLECTING_EVENT_ID);

-- does not exist at UAM; mvz okay.
alter table TAB_MEDIA_REL_FKEY
   add constraint FK_TABMEDIARELFKEY_LOCALITY foreign key (CFK_LOCALITY)
      references LOCALITY (LOCALITY_ID);
      
alter table TAXON_RELATIONS
   add constraint FK_TAXONRELN_TAXONOMY_RTNID foreign key (RELATED_TAXON_NAME_ID)
      references TAXONOMY (TAXON_NAME_ID);

alter table TAXON_RELATIONS
   add constraint FK_TAXONRELN_TAXONOMY_TNID foreign key (TAXON_NAME_ID)
      references TAXONOMY (TAXON_NAME_ID);

--ORA-00904: "COLLECTION_ID": invalid identifier
alter table TRANS
   add constraint FK_TRANS_COLLECTION foreign key (COLLECTION_ID)
      references COLLECTION (COLLECTION_ID);

alter table TRANS_AGENT
   add constraint FK_TRANSAGENT_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID);

alter table TRANS_AGENT
   add constraint FK_TRANSAGENT_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID);

alter table VESSEL
   add constraint FK_VESSEL_COLLEVENT foreign key (COLLECTING_EVENT_ID)
      references COLLECTING_EVENT (COLLECTING_EVENT_ID);

