alter table ACCN
   add constraint FK_ACCN_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID)
      not deferrable;

alter table ADDR
   add constraint FK_ADDR_FK_ADDR_A_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID);

alter table AGENT_NAME
   add constraint FK_AGENT_NAME_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID)
      not deferrable;

alter table AGENT_NAME_PENDING_DELETE
   add constraint FK_AGENT_NA_FK_AGENTN_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID);

alter table AGENT_NAME_PENDING_DELETE
   add constraint FK_AGENT_NA_FK_AGENTN_AGENT_NA foreign key (AGENT_NAME_ID)
      references AGENT_NAME (AGENT_NAME_ID);

alter table AGENT_RELATIONS
   add constraint FK_AGENT_RE_FK_AGENTR_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID);

alter table AGENT_RELATIONS
   add constraint FK_AGENT_RE_FK_AGENTR_AGENT_NA foreign key (AGENT_NAME_ID)
      references AGENT_NAME (AGENT_NAME_ID);

alter table ATTRIBUTES
   add constraint FK_ATTRIBUT_FK_ATTRIB_AGENT foreign key (DETERMINED_BY_AGENT_ID)
      references AGENT (AGENT_ID);

alter table ATTRIBUTES
   add constraint FK_ATTRIBUTES_CATALOGED_ITEM foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID)
      not deferrable;

alter table BIOL_INDIV_RELATIONS
   add constraint FK_BIOL_IND_FK_BIOLIN_CATALOGE foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table BIOL_INDIV_RELATIONS
   add constraint FK_BIOL_IND_FK_BIOLIN_CATALOGE foreign key (RELATED_COLL_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table BOOK
   add constraint FK_BOOK_FK_BOOK_P_PUBLICAT foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);

alter table BOOK_SECTION
   add constraint FK_BOOK_SEC_FK_BOOKSE_BOOK foreign key (BOOK_ID)
      references BOOK (PUBLICATION_ID);

alter table BOOK_SECTION
   add constraint FK_BOOK_SEC_FK_BOOKSE_PUBLICAT foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);

alter table BORROW
   add constraint FK_BORROW_FK_BORROW_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID);

alter table CATALOGED_ITEM
   add constraint FK_CATALOGED_ITEM_COLLECTION foreign key (COLLECTION_ID)
      references COLLECTION (COLLECTION_ID)
      not deferrable;

alter table CATALOGED_ITEM
   add constraint FK_CATALOGED_ITEM_COLL_EVENT foreign key (COLLECTING_EVENT_ID)
      references COLLECTING_EVENT (COLLECTING_EVENT_ID)
      not deferrable;

alter table CATALOGED_ITEM
   add constraint FK_CATALOGED_ITEM_COLL_OBJECT foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID)
      not deferrable;

alter table CATALOGED_ITEM
   add constraint FK_CATALOGE_FK_CATITE_TRANS foreign key (ACCN_ID)
      references TRANS (TRANSACTION_ID);

alter table CITATION
   add constraint FK_CITATION_CATALOGED_ITEM foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID)
      not deferrable;

alter table CITATION
   add constraint FK_CITATION_PUBLICATION foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID)
      not deferrable;

alter table CITATION
   add constraint FK_CITATION_FK_CITATI_TAXONOMY foreign key (CITED_TAXON_NAME_ID)
      references TAXONOMY (TAXON_NAME_ID);

alter table COLLECTING_EVENT
   add constraint FK_COLLECTI_FK_COLLEV_AGENT foreign key (DATE_DETERMINED_BY_AGENT_ID)
      references AGENT (AGENT_ID);

alter table COLLECTING_EVENT
   add constraint FK_COLLECTING_EVENT_LOCALITY foreign key (LOCALITY_ID)
      references LOCALITY (LOCALITY_ID)
      not deferrable;

alter table COLLECTION_CONTACTS
   add constraint FK_COLLECTI_FK_COLLCO_AGENT foreign key (CONTACT_AGENT_ID)
      references AGENT (AGENT_ID);

alter table COLLECTION_CONTACTS
   add constraint FK_COLLECTI_FK_COLLCO_COLLECTI foreign key (COLLECTION_ID)
      references COLLECTION (COLLECTION_ID);

alter table COLLECTOR
   add constraint FK_COLLECTOR_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID)
      not deferrable;

alter table COLLECTOR
   add constraint FK_COLLECTOR_CATALOGED_ITEM foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID)
      not deferrable;

alter table COLL_OBJECT
   add constraint FK_COLL_OBJ_FK_COLLOB_AGENT foreign key (LAST_EDITED_PERSON_ID)
      references AGENT (AGENT_ID);

alter table COLL_OBJECT
   add constraint FK_COLL_OBJ_FK_COLLOB_AGENT foreign key (ENTERED_PERSON_ID)
      references AGENT (AGENT_ID);

alter table COLL_OBJECT_ENCUMBRANCE
   add constraint FK_COLL_OBJ_FK_COLLOB_COLL_OBJ foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID);

alter table COLL_OBJECT_ENCUMBRANCE
   add constraint FK_COLL_OBJ_FK_COLLOB_ENCUMBRA foreign key (ENCUMBRANCE_ID)
      references ENCUMBRANCE (ENCUMBRANCE_ID);

alter table COLL_OBJECT_REMARK
   add constraint FK_COLL_OBJ_FK_COLLOB_COLL_OBJ foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID);

alter table COLL_OBJ_CONT_HIST
   add constraint FK_COLL_OBJ_FK_COLLOB_COLL_OBJ foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID);

alter table COLL_OBJ_CONT_HIST
   add constraint FK_COLL_OBJ_FK_COLLOB_CONTAINE foreign key (CONTAINER_ID)
      references CONTAINER (CONTAINER_ID);

alter table COLL_OBJ_OTHER_ID_NUM
   add constraint FK_COLL_OBJ_FK_COLLOB_CATALOGE foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table COMMON_NAME
   add constraint FK_COMMON_N_FK_COMMON_TAXONOMY foreign key (TAXON_NAME_ID)
      references TAXONOMY (TAXON_NAME_ID);

alter table CONTAINER
   add constraint FK_CONTAINE_FK_CONTAI_CONTAINE foreign key (PARENT_CONTAINER_ID)
      references CONTAINER (CONTAINER_ID);


alter table ELECTRONIC_ADDRESS
   add constraint FK_ELECTRON_FK_ELECTR_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID);

alter table FIELD_NOTEBOOK_SECTION
   add constraint FK_FIELD_NO_FK_FIELDN_BOOK_SEC foreign key (PUBLICATION_ID)
      references BOOK_SECTION (PUBLICATION_ID);



alter table GEOLOGY_ATTRIBUTES
   add constraint FK_GEOLOGY_LOCALITY foreign key (LOCALITY_ID)
      references LOCALITY (LOCALITY_ID)
      not deferrable;

alter table GEOLOGY_ATTRIBUTE_HIERARCHY
   add constraint FK_GEOLOGY_ATTRIBUTE_HIERARCHY foreign key (PARENT_ID)
      references GEOLOGY_ATTRIBUTE_HIERARCHY (GEOLOGY_ATTRIBUTE_HIERARCHY_ID)
      not deferrable;

alter table GREF_REFSET_NG
   add constraint REFSET_NG_PAGE_ID_FKEY foreign key (PAGE_ID)
      references PAGE (PAGE_ID)
      not deferrable;

alter table GREF_REFSET_ROI_NG
   add constraint REFSET_ROI_NG_REFSET_NG_ID_FK foreign key (REFSET_NG_ID)
      references GREF_REFSET_NG (ID)
      not deferrable;

alter table GREF_REFSET_ROI_NG
   add constraint REFSET_ROI_NG_ROI_NG_ID_FK foreign key (ROI_NG_ID)
      references GREF_ROI_NG (ID)
      not deferrable;

alter table GREF_ROI_NG
   add constraint ROI_NG_PAGE_ID_FKEY foreign key (PAGE_ID)
      references PAGE (PAGE_ID)
      not deferrable;

alter table GREF_ROI_NG
   add constraint SYS_C0018607 foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID)
      not deferrable;

alter table GREF_ROI_NG
   add constraint ROI_NG_ROI_VALUE_NG_ID_FK foreign key (ROI_VALUE_NG_ID)
      references GREF_ROI_VALUE_NG (ID)
      not deferrable;

alter table GREF_ROI_VALUE_NG
   add constraint ROI_VALUE_NG_AGENT_ID_FK foreign key (AGENT_ID)
      references AGENT_NAME (AGENT_NAME_ID)
      not deferrable;

alter table GREF_ROI_VALUE_NG
   add constraint SYS_C0018621 foreign key (COLLECTING_EVENT_ID)
      references COLLECTING_EVENT (COLLECTING_EVENT_ID)
      not deferrable;

alter table GREF_ROI_VALUE_NG
   add constraint ROI_VALUE_NG_ROI_NG_ID_FK foreign key (ROI_NG_ID)
      references GREF_ROI_NG (ID)
      not deferrable;



alter table GROUP_MEMBER
   add constraint FK_GROUP_ME_FK_GROUPM_AGENT foreign key (MEMBER_AGENT_ID)
      references AGENT (AGENT_ID);

alter table IDENTIFICATION
   add constraint FK_IDENTIFI_FK_IDENTI_CATALOGE foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table IDENTIFICATION_AGENT
   add constraint FK_ID_AGENT_ID foreign key (AGENT_ID)
      references AGENT (AGENT_ID)
      not deferrable;

alter table IDENTIFICATION_AGENT
   add constraint FK_IDENTIFICATION_ID foreign key (IDENTIFICATION_ID)
      references IDENTIFICATION (IDENTIFICATION_ID)
      not deferrable;

alter table IDENTIFICATION_TAXONOMY
   add constraint FK_IDENT_TAXONOMY_IDENT foreign key (IDENTIFICATION_ID)
      references IDENTIFICATION (IDENTIFICATION_ID)
      not deferrable;

alter table IDENTIFICATION_TAXONOMY
   add constraint FK_IDENT_TAXONOMY_TAXONOMY foreign key (TAXON_NAME_ID)
      references TAXONOMY (TAXON_NAME_ID)
      not deferrable;

alter table IMAGE_CONTENT
   add constraint FK_IMAGE_CO_FK_IMAGEC_AGENT foreign key (AGENT_ID)
      references AGENT (AGENT_ID);

alter table IMAGE_CONTENT
   add constraint FK_IMAGE_CO_FK_IMAGEC_COLL_OBJ foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID);

alter table IMAGE_CONTENT
   add constraint FK_IMAGE_CO_FK_IMAGEC_IMAGE_OB foreign key (REFERENCED_IMAGE_OBJECT_ID)
      references IMAGE_OBJECT (COLLECTION_OBJECT_ID);

alter table IMAGE_CONTENT
   add constraint FK_IMAGE_CO_FK_IMAGEC_IMAGE_SU foreign key (IMAGE_SUBJECT_ID)
      references IMAGE_SUBJECT (IMAGE_SUBJECT_ID);

alter table IMAGE_CONTENT
   add constraint FK_IMAGE_CO_FK_IMAGEC_LOCALITY foreign key (LOCALITY_ID)
      references LOCALITY (LOCALITY_ID);

alter table IMAGE_CONTENT
   add constraint FK_IMAGE_CO_FK_IMAGEC_PAGE foreign key (PAGE_ID)
      references PAGE (PAGE_ID);

alter table IMAGE_CONTENT
   add constraint FK_IMAGE_CO_FK_IMAGEC_TAXONOMY foreign key (TAXON_NAME_ID)
      references TAXONOMY (TAXON_NAME_ID);

alter table IMAGE_OBJECT
   add constraint FK_IMAGE_OB_FK_IMAGEO_COLL_OBJ foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID);

alter table IMAGE_OBJECT
   add constraint FK_IMAGE_OB_FK_IMAGEO_IMAGE_OB foreign key (MADE_FROM_IMAGE_OBJECT_ID)
      references IMAGE_OBJECT (COLLECTION_OBJECT_ID);

alter table IMAGE_OBJECT
   add constraint FK_IMAGE_OB_FK_IMAGEO_IMAGE_SU foreign key (IMAGE_SUBJECT_ID)
      references IMAGE_SUBJECT (IMAGE_SUBJECT_ID);

alter table IMAGE_SUBJECT_REMARKS
   add constraint FK_IMAGE_SU_FK_IMGSUB_IMAGE_SU foreign key (IMAGE_SUBJECT_ID)
      references IMAGE_SUBJECT (IMAGE_SUBJECT_ID);

alter table JOURNAL_ARTICLE
   add constraint FK_JOURNAL__FK_JOURNA_JOURNAL foreign key (JOURNAL_ID)
      references JOURNAL (JOURNAL_ID);



alter table LAT_LONG
   add constraint FK_LAT_LONG_AGENT foreign key (DETERMINED_BY_AGENT_ID)
      references AGENT (AGENT_ID)
      not deferrable;

alter table LAT_LONG
   add constraint FK_LAT_LONG_LOCALITY foreign key (LOCALITY_ID)
      references LOCALITY (LOCALITY_ID)
      not deferrable;

alter table LOAN
   add constraint FK_LOAN_FK_LOAN_T_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID);

alter table LOAN_INSTALLMENT
   add constraint FK_LOAN_INS_FK_LOANIN_LOAN foreign key (TRANSACTION_ID)
      references LOAN (TRANSACTION_ID);

alter table LOAN_ITEM
   add constraint FK_LOAN_ITE_FK_LOANIT_AGENT foreign key (RECONCILED_BY_PERSON_ID)
      references AGENT (AGENT_ID);

alter table LOAN_ITEM
   add constraint FK_LOAN_ITE_FK_LOANIT_COLL_OBJ foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID);



alter table LOCALITY
   add constraint FK_GEOG foreign key (GEOG_AUTH_REC_ID)
      references GEOG_AUTH_REC (GEOG_AUTH_REC_ID)
      not deferrable;

alter table MEDIA_LABELS
   add constraint FK_MEDIA_AGENT foreign key (ASSIGNED_BY_AGENT_ID)
      references AGENT (AGENT_ID)
      not deferrable;

alter table MEDIA_LABELS
   add constraint FK_MEDIA_LABEL foreign key (MEDIA_ID)
      references MEDIA (MEDIA_ID)
      not deferrable;

alter table MEDIA_RELATIONS
   add constraint FK_CREATED_BY_AGENT_ID foreign key (CREATED_BY_AGENT_ID)
      references AGENT (AGENT_ID)
      not deferrable;

alter table MEDIA_RELATIONS
   add constraint FK_MEDIA_ID foreign key (MEDIA_ID)
      references MEDIA (MEDIA_ID)
      not deferrable;

alter table OBJECT_CONDITION
   add constraint FK_OBJECT_C_FK_OBJECT_AGENT foreign key (DETERMINED_AGENT_ID)
      references AGENT (AGENT_ID);

alter table OBJECT_CONDITION
   add constraint FK_OBJ_CONDITION_COLL_OBJECT foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID)
      on delete cascade not deferrable;

alter table PAGE
   add constraint FK_PAGE_FK_PAGE_P_PUBLICAT foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);

alter table PERMIT
   add constraint FK_PERMIT_FK_PERMIT_AGENT foreign key (CONTACT_AGENT_ID)
      references AGENT (AGENT_ID);

alter table PERMIT
   add constraint FK_PERMIT_FK_PERMIT_AGENT foreign key (ISSUED_BY_AGENT_ID)
      references AGENT (AGENT_ID);

alter table PERMIT
   add constraint FK_PERMIT_FK_PERMIT_AGENT foreign key (ISSUED_TO_AGENT_ID)
      references AGENT (AGENT_ID);

alter table PERMIT_TRANS
   add constraint FK_PERMIT_T_FK_PERMIT_PERMIT foreign key (PERMIT_ID)
      references PERMIT (PERMIT_ID);

alter table PERMIT_TRANS
   add constraint FK_PERMIT_T_FK_PERMIT_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID);

alter table PERSON
   add constraint FK_PERSON_AGENT foreign key (PERSON_ID)
      references AGENT (AGENT_ID)
      not deferrable;

alter table PROJECT_AGENT
   add constraint FK_PROJECT__FK_PROJEC_AGENT_NA foreign key (AGENT_NAME_ID)
      references AGENT_NAME (AGENT_NAME_ID);

alter table PROJECT_AGENT
   add constraint FK_PROJECT__FK_PROJEC_PROJECT foreign key (PROJECT_ID)
      references PROJECT (PROJECT_ID);

alter table PROJECT_PUBLICATION
   add constraint FK_PROJECT__FK_PROJEC_PROJECT foreign key (PROJECT_ID)
      references PROJECT (PROJECT_ID);



alter table PROJECT_SPONSOR
   add constraint FK_AGENT_NAME_ID foreign key (AGENT_NAME_ID)
      references AGENT_NAME (AGENT_NAME_ID)
      not deferrable;

alter table PROJECT_SPONSOR
   add constraint FK_PROJECT_ID foreign key (PROJECT_ID)
      references PROJECT (PROJECT_ID)
      not deferrable;

alter table PROJECT_TRANS
   add constraint FK_PROJECT__FK_PROJEC_PROJECT foreign key (PROJECT_ID)
      references PROJECT (PROJECT_ID);

alter table PROJECT_TRANS
   add constraint FK_PROJECT__FK_PROJEC_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID);






alter table SHIPMENT
   add constraint SHIPMENT_SHIPFROM_FK foreign key (SHIPPED_FROM_ADDR_ID)
      references ADDR (ADDR_ID)
      not deferrable;

alter table SHIPMENT
   add constraint SHIPMENT_SHIPTO_FK foreign key (SHIPPED_TO_ADDR_ID)
      references ADDR (ADDR_ID)
      not deferrable;

alter table SHIPMENT
   add constraint FK_SHIPMENT_FK_SHIPME_AGENT foreign key (PACKED_BY_AGENT_ID)
      references AGENT (AGENT_ID);

alter table SHIPMENT
   add constraint FK_SHIPMENT_FK_SHIPME_CONTAINE foreign key (CONTAINER_ID)
      references CONTAINER (CONTAINER_ID);

alter table SHIPMENT
   add constraint FK_SHIPMENT_FK_SHIPME_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID);

alter table SPECIMEN_ANNOTATIONS
   add constraint FK_SPECIMEN_FK_SPECIM_CATALOGE foreign key (COLLECTION_OBJECT_ID)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

alter table SPECIMEN_PART
   add constraint FK_SPECIMEN_PART_CAT_ITEM foreign key (DERIVED_FROM_CAT_ITEM)
      references CATALOGED_ITEM (COLLECTION_OBJECT_ID)
      not deferrable;

alter table SPECIMEN_PART
   add constraint FK_SPECIMEN_PART_COLL_OBJECT foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID)
      not deferrable;



alter table TAXON_RELATIONS
   add constraint FK_TAXONOMY2 foreign key (RELATED_TAXON_NAME_ID)
      references TAXONOMY (TAXON_NAME_ID)
      not deferrable;

alter table TAXON_RELATIONS
   add constraint FK_TAXONOMY1 foreign key (TAXON_NAME_ID)
      references TAXONOMY (TAXON_NAME_ID)
      not deferrable;

alter table TRANS
   add constraint FK_TRANS_FK_TRANS__COLLECTI foreign key (COLLECTION_ID)
      references COLLECTION (COLLECTION_ID);

alter table TRANS_AGENT
   add constraint FK_TRANS_AGNT_AGNT foreign key (AGENT_ID)
      references AGENT (AGENT_ID)
      not deferrable;

alter table TRANS_AGENT
   add constraint FK_TRANS_AGNT_TRANS foreign key (TRANSACTION_ID)
      references TRANS (TRANSACTION_ID)
      not deferrable;


      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
test-uam> test-uam>   2    3     add constraint FK_CITATION_FK_CITATI_TAXONOMY foreign key (CITED_TAXON_NAME_ID)
                  *
ERROR at line 2:
ORA-02298: cannot validate (UAM.FK_CITATION_FK_CITATI_TAXONOMY) - parent keys not found

alter table CITATION
   add constraint FK_CITATION_FK_CITATI_TAXONOMY foreign key (CITED_TAXON_NAME_ID)
      references TAXONOMY (TAXON_NAME_ID);      
SELECT * FROM citation WHERE CITED_TAXON_NAME_ID NOT IN (SELECT taxon_name_id FROM taxonomy);

---- these need chased down and cleaned up in PROD

SELECT * FROM citation WHERE cited_taxon_name_id NOT IN (SELECT taxon_name_id FROM taxonomy);

test-uam> test-uam>   2    3     add constraint FK_COLL_OBJ_FK_COLLOB_COLL_OBJ foreign key (COLLECTION_OBJECT_ID)
                  *
ERROR at line 2:
ORA-02298: cannot validate (UAM.FK_COLL_OBJ_FK_COLLOB_COLL_OBJ) - parent keys not found
-- ORA-02264: name already used by an existing constraint
-- can't find it:
--  select OBJECT_TYPE from all_objects where object_name='FK_COLL_OBJ_FK_COLLOB_COLL_OBJ';
-- no rows selected
-- rename and try again
alter table COLL_OBJECT_ENCUMBRANCE
   add constraint FK_COLL_OBJ_encumbrance foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID);

SELECT * FROM COLL_OBJECT_ENCUMBRANCE WHERE COLLECTION_OBJECT_ID NOT IN (SELECT COLLECTION_OBJECT_ID FROM cataloged_item);    
-- no way to recover these
DELETE FROM COLL_OBJECT_ENCUMBRANCE WHERE COLLECTION_OBJECT_ID NOT IN (SELECT COLLECTION_OBJECT_ID FROM cataloged_item); 


test-uam> test-uam>   2    3     add constraint FK_COMMON_N_FK_COMMON_TAXONOMY foreign key (TAXON_NAME_ID)
                  *
ERROR at line 2:
ORA-02298: cannot validate (UAM.FK_COMMON_N_FK_COMMON_TAXONOMY) - parent keys not found

DELETE FROM common_name WHERE TAXON_NAME_ID NOT IN (SELECT TAXON_NAME_ID FROM taxonomy);

alter table COMMON_NAME
   add constraint FK_COMMON_N_FK_COMMON_TAXONOMY foreign key (TAXON_NAME_ID)
      references TAXONOMY (TAXON_NAME_ID);
      
      
      
Elapsed: 00:00:00.43
test-uam> test-uam>   2    3     add constraint FK_CONTAINE_FK_CONTAI_CONTAINE foreign key (PARENT_CONTAINER_ID)
                  *
ERROR at line 2:
ORA-02298: cannot validate (UAM.FK_CONTAINE_FK_CONTAI_CONTAINE) - parent keys not found


test-uam> test-uam>   2    3     add constraint FK_CONTAINE_FK_CONTAI_CONTAINE foreign key (CONTAINER_ID)
                  *
ERROR at line 2:
ORA-02298: cannot validate (UAM.FK_CONTAINE_FK_CONTAI_CONTAINE) - parent keys not found


Elapsed: 00:00:10.53
test-uam> test-uam>   2    3     add constraint FK_CONTAINE_FK_CONTAI_CONTAINE foreign key (PARENT_CONTAINER_ID)
                  *
ERROR at line 2:
ORA-02298: cannot validate (UAM.FK_CONTAINE_FK_CONTAI_CONTAINE) - parent keys not found


-- this is a mess. There are at least 2 generated keys with the same names
ALTER TABLE container MODIFY parent_container_id NULL;
UPDATE container SET parent_container_id=NULL WHERE parent_container_id=0;
SELECT   connect_by_iscycle "cycle",
CONTAINER_ID,
PARENT_CONTAINER_ID
from container
where connect_by_iscycle=1
connect by nocycle prior parent_container_id = container_id
;
    
 

      
SELECT COUNT(*) FROM container 
WHERE parent_container_id NOT IN (SELECT CONTAINER_ID FROM container) AND
 parent_container_id !=0;

SELECT container_type,count(*) FROM container 
WHERE parent_container_id NOT IN (SELECT CONTAINER_ID FROM container) 
group by container_type;

--- there is no way to recover the orphaned containers, so put them in never-never land
UPDATE container SET parent_container_id=NULL WHERE container_id IN (
    SELECT container_id FROM container 
    WHERE parent_container_id NOT IN (
        SELECT CONTAINER_ID FROM container
        )
    )
; 
alter table CONTAINER
   add constraint fk_container_selfref foreign key (PARENT_CONTAINER_ID)
      references CONTAINER (CONTAINER_ID);

alter table COLL_OBJ_CONT_HIST
   add constraint FK_COLL_OBJ_FK_COLLOB_CONTAINE foreign key (CONTAINER_ID)
      references CONTAINER (CONTAINER_ID);
      

alter table CONTAINER_CHECK
   add constraint FKEY_CONT_AGNT_AGENT foreign key (CHECKED_AGENT_ID)
      references AGENT (AGENT_ID)
      not deferrable;

alter table CONTAINER_CHECK
   add constraint FKEY_CONT_CHK_CONTAINER foreign key (CONTAINER_ID)
      references CONTAINER (CONTAINER_ID)
      not deferrable;

-- unrecoverable, so...
DELETE FROM CONTAINER_HISTORY WHERE CONTAINER_ID NOT IN (SELECT CONTAINER_ID FROM CONTAINER);

alter table CONTAINER_HISTORY
   add constraint FK_CONTAINE_FK_CONTAI_CONTAINE foreign key (CONTAINER_ID)
      references CONTAINER (CONTAINER_ID);

alter table CONTAINER_HISTORY
   add constraint FK_CONTAINE_FK_CONTAI_CONTAINE foreign key (PARENT_CONTAINER_ID)
      references CONTAINER (CONTAINER_ID);
      
                 
Elapsed: 00:00:00.03
test-uam> test-uam>   2    3     add constraint FK_FLUID_CO_FK_FLUIDC_CONTAINE foreign key (CONTAINER_ID)
    ERROR at line 2:
ORA-02298: cannot validate (UAM.FK_FLUID_CO_FK_FLUIDC_CONTAINE) - parent keys not found
DELETE FROM FLUID_CONTAINER_HISTORY WHERE CONTAINER_ID NOT IN (SELECT CONTAINER_ID FROM CONTAINER);
alter table FLUID_CONTAINER_HISTORY
   add constraint FK_FLUID_CO_FK_FLUIDC_CONTAINE foreign key (CONTAINER_ID)
      references CONTAINER (CONTAINER_ID);
     

                  *


test-uam> test-uam>   2    3     add constraint FK_GROUP_ME_FK_GROUPM_AGENT foreign key (GROUP_AGENT_ID)
                  *
ERROR at line 2:
ORA-02298: cannot validate (UAM.FK_GROUP_ME_FK_GROUPM_AGENT) - parent keys not found
test-uam> desc 
 Name                                                  Null?    Type
 ----------------------------------------------------- -------- ------------------------------------
ALTER TABLE GROUP_MEMBER MODIFY GROUP_AGENT_ID NUMBER;
ALTER TABLE GROUP_MEMBER MODIFY MEMBER_AGENT_ID NUMBER;
ALTER TABLE GROUP_MEMBER MODIFY MEMBER_ORDER NUMBER;
                                      

DELETE FROM GROUP_MEMBER WHERE GROUP_AGENT_ID NOT IN (SELECT agent_id FROM agent);

alter table GROUP_MEMBER
   add constraint FK_GROUP_MEmber_grp foreign key (GROUP_AGENT_ID)
      references AGENT (AGENT_ID);

alter table GROUP_MEMBER
   add constraint FK_GROUP_MEmber_member foreign key (MEMBER_AGENT_ID)
      references AGENT (AGENT_ID);    
      

Elapsed: 00:00:00.04
test-uam> test-uam>   2    3     add constraint FK_JOURNAL__FK_JOURNA_PUBLICAT foreign key (PUBLICATION_ID)
                  *
ERROR at line 2:
ORA-02298: cannot validate (UAM.FK_JOURNAL__FK_JOURNA_PUBLICAT) - parent keys not found

DELETE FROM JOURNAL_ARTICLE WHERE PUBLICATION_ID NOT IN (SELECT PUBLICATION_ID FROM PUBLICATION);

alter table JOURNAL_ARTICLE
   add constraint FK_JOURNAL__FK_JOURNA_PUBLICAT foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);
      
      
Elapsed: 00:00:00.01
test-uam> test-uam>   2    3     add constraint FK_LOAN_ITE_FK_LOANIT_LOAN foreign key (TRANSACTION_ID)
                  *
ERROR at line 2:
ORA-02298: cannot validate (UAM.FK_LOAN_ITE_FK_LOANIT_LOAN) - parent keys not found
DELETE FROM loan_item WHERE transaction_id NOT IN (SELECT transaction_id FROM loan);

alter table LOAN_ITEM
   add constraint FK_LOAN_ITE_FK_LOANIT_LOAN foreign key (TRANSACTION_ID)
      references LOAN (TRANSACTION_ID);


  2    3     add constraint FK_PROJECT__FK_PROJEC_PUBLICAT foreign key (PUBLICATION_ID)
                  *
ERROR at line 2:
ORA-02298: cannot validate (UAM.FK_PROJECT__FK_PROJEC_PUBLICAT) - parent keys not found
DELETE FROM PROJECT_PUBLICATION WHERE PUBLICATION_ID NOT IN (SELECT PUBLICATION_ID FROM PUBLICATION);
alter table PROJECT_PUBLICATION
   add constraint FK_PROJECT__FK_PROJEC_PUBLICAT foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);
      
     

Elapsed: 00:00:00.02
test-uam> test-uam>   2    3     add constraint FK_PUBLICAT_FK_PUBAUT_AGENT_NA foreign key (AGENT_NAME_ID)
                  *
ERROR at line 2:
ORA-02298: cannot validate (UAM.FK_PUBLICAT_FK_PUBAUT_AGENT_NA) - parent keys not found
----- need to clean this one up in PROD
SELECT * FROM PUBLICATION_AUTHOR_NAME WHERE AGENT_NAME_ID NOT IN (SELECT AGENT_NAME_ID FROM AGENT_NAME);
DELETE FROM PUBLICATION_AUTHOR_NAME WHERE AGENT_NAME_ID NOT IN (SELECT AGENT_NAME_ID FROM AGENT_NAME);

alter table PUBLICATION_AUTHOR_NAME
   add constraint FK_PUBLICAT_FK_PUBAUT_AGENT_NA foreign key (AGENT_NAME_ID)
      references AGENT_NAME (AGENT_NAME_ID);

Elapsed: 00:00:00.02
test-uam> test-uam>   2    3     add constraint FK_PUBLICAT_FK_PUBAUT_PUBLICAT foreign key (PUBLICATION_ID)
                  *
ERROR at line 2:
ORA-02298: cannot validate (UAM.FK_PUBLICAT_FK_PUBAUT_PUBLICAT) - parent keys not found
DELETE FROM PUBLICATION_AUTHOR_NAME WHERE PUBLICATION_ID NOT IN (SELECT PUBLICATION_ID FROM PUBLICATION);

alter table PUBLICATION_AUTHOR_NAME
   add constraint FK_PUBLICAT_FK_PUBAUT_PUBLICAT foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);


Elapsed: 00:00:00.02
test-uam> test-uam>   2    3     add constraint FK_PUBLICAT_FK_PUBLIC_PUBLICAT foreign key (PUBLICATION_ID)
                  *
ERROR at line 2:
ORA-02298: cannot validate (UAM.FK_PUBLICAT_FK_PUBLIC_PUBLICAT) - parent keys not found
DELETE FROM PUBLICATION_URL WHERE PUBLICATION_ID NOT IN (SELECT PUBLICATION_ID FROM PUBLICATION);

alter table PUBLICATION_URL
   add constraint FK_PUBLICAT_FK_PUBLIC_PUBLICAT foreign key (PUBLICATION_ID)
      references PUBLICATION (PUBLICATION_ID);
      
      
Elapsed: 00:00:00.01
test-uam> test-uam>   2    3     add constraint FK_SPECIMEN_FK_SPECIM_SPECIMEN foreign key (SAMPLED_FROM_OBJ_ID)
                  *
ERROR at line 2:
ORA-02298: cannot validate (UAM.FK_SPECIMEN_FK_SPECIM_SPECIMEN) - parent keys not found

-- no way to recover, so....
UPDATE SPECIMEN_PART SET SAMPLED_FROM_OBJ_ID=NULL WHERE SAMPLED_FROM_OBJ_ID NOT IN (SELECT COLLECTION_OBJECT_ID FROM SPECIMEN_PART);

alter table SPECIMEN_PART
   add constraint FK_SPECIMEN_FK_SPECIM_SPECIMEN foreign key (SAMPLED_FROM_OBJ_ID)
      references SPECIMEN_PART (COLLECTION_OBJECT_ID);
      
      
Elapsed: 00:00:00.01
test-uam> test-uam>   2    3     add constraint FK_VESSEL_FK_VESSEL_COLLECTI foreign key (COLLECTING_EVENT_ID)
                  *
ERROR at line 2:
ORA-02298: cannot validate (UAM.FK_VESSEL_FK_VESSEL_COLLECTI) - parent keys not found
DELETE FROM vessel WHERE COLLECTING_EVENT_ID NOT IN (SELECT COLLECTING_EVENT_ID FROM collecting_event);

alter table VESSEL
   add constraint FK_VESSEL_FK_VESSEL_COLLECTI foreign key (COLLECTING_EVENT_ID)
      references COLLECTING_EVENT (COLLECTING_EVENT_ID);


--- encumbrance patch
alter table encumbrance
   add constraint FK_encumbr_agnt foreign key (ENCUMBERING_AGENT_ID)
      references agent (agent_id);
    