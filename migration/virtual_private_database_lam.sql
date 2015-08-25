-- outlines THE code AND procedures NEEDED TO get us INTO a VPD
-- DLM 21-may-2008

/*
    Basic idea:
    Somehow, perhaps involving striping tables with a collection_id (hopefully temporarily), develop policies
    about what collection owns which data.
    Some data will be shared, and some users will have access to multiple collections. So, MVZ accns that have
    herps and mammals work because the herp folks have mvz_herp and mvz_mamm roles. Goofiness: One collection must "own"
    shared resources. Little goofy, but should work out OK.
    
    Interfaces: Nothing changes for "us" users. WHERE clauses dynamically added to SQL. So, 
    
*/
-- major structural change that will drastically simplify this and needs done anyway: change trans.institution_acronym to 
-- trans.collection_id
-- will require some user mucking around to find and assign accns/loans/borrows correctly
-- although we can get most of it programatically by existing data.
-- Particularly at MVZ, there are some shared transactions. They won't hurt anything as MVZ curators will have VPD access
-- through multiple collections anyway
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
        WHERE
            loan_item.transaction_id=r.transaction_id AND
            loan_item.collection_object_id = specimen_part.collection_object_id AND
            specimen_part.derived_from_cat_item = cataloged_item.collection_object_id
        ;
        IF c=1 then
            SELECT collection_id INTO cid FROM 
                loan_item,
                specimen_part,
                cataloged_item
            WHERE
                loan_item.transaction_id=r.transaction_id AND
                loan_item.collection_object_id = specimen_part.collection_object_id AND
                specimen_part.derived_from_cat_item = cataloged_item.collection_object_id
            GROUP BY 
                collection_id
            ;
            UPDATE trans SET collection_id=cid WHERE transaction_id=r.transaction_id;
        END IF;
        --- same thing for UAM's retarded cataloged item loans
        SELECT COUNT(distinct(collection_id)) INTO c FROM 
            loan_item,
            cataloged_item
        WHERE
            loan_item.transaction_id=r.transaction_id AND
            loan_item.collection_object_id = cataloged_item.collection_object_id
        ;
        IF c=1 then
            SELECT collection_id INTO cid FROM 
                loan_item,
                cataloged_item
            WHERE
                loan_item.transaction_id=r.transaction_id AND
                loan_item.collection_object_id = cataloged_item.collection_object_id
            GROUP BY 
                collection_id
            ;
            UPDATE trans SET collection_id=cid WHERE transaction_id=r.transaction_id;
        END IF;
    END LOOP;
 -- accessions
    FOR r IN (SELECT transaction_id FROM trans WHERE transaction_type='accn') LOOP
      SELECT 
          COUNT(distinct(collection_id)) INTO c FROM cataloged_item
      WHERE
          cataloged_item.accn_id=r.transaction_id
      ;
          IF c=1 THEN
              SELECT 
                  collection_id INTO cid FROM cataloged_item
              WHERE
                  cataloged_item.accn_id=r.transaction_id
              GROUP BY collection_id
              ;
              UPDATE trans SET collection_id=cid WHERE transaction_id=r.transaction_id;
          END IF;
  END LOOP;
END;
/
SELECT COUNT(*),transaction_type FROM trans WHERE collection_id IS NULL GROUP BY transaction_type;

--- see if we can figure out what we missed
SELECT * FROM borrow,trans WHERE borrow.transaction_id=trans.transaction_id AND collection_id IS NULL;
--- MVZ Dev borrows are all fake; kill em
-- begin useless block
DELETE FROM trans_agent WHERE transaction_id IN (SELECT transaction_id FROM borrow);
CREATE TABLE tt AS SELECT transaction_id FROM borrow;
DELETE FROM borrow;
DELETE FROM trans WHERE transaction_id IN (SELECT transaction_id FROM tt);
delete from trans where transaction_type='borrow';
-- and one borrow was actually an accn - craps - above code is useless...



-- little sloppier, but see what else we can get by number + acronym
BEGIN
    FOR c IN (SELECT collection_id,collection_cde,institution_acronym FROM collection) LOOP
        FOR t IN (SELECT trans.transaction_id,accn_number,institution_acronym FROM accn,trans WHERE
                 accn.transaction_id=trans.transaction_id AND
                 collection_id IS NULL) LOOP
             IF (c.institution_acronym=t.institution_acronym) AND (instr(t.accn_number,c.collection_cde)>0) THEN
                 UPDATE trans SET collection_id=c.collection_id WHERE transaction_id=t.transaction_id;
                 --dbms_output.put_line('c.institution_acronym=' || c.institution_acronym || '; t.institution_acronym=' || t.institution_acronym || '; t.accn_number=' || t.accn_number || '; c.collection_cde=' || c.collection_cde);
             END IF;                   
        END LOOP;
    END LOOP;
END;
/
-- even sloppier, revert to (now defunct but still present) ACCN_NUM_SUFFIX
BEGIN
    FOR c IN (SELECT collection_id,collection_cde,institution_acronym FROM collection) LOOP
        FOR t IN (SELECT trans.transaction_id,accn_num_suffix,institution_acronym FROM accn,trans WHERE
                 accn.transaction_id=trans.transaction_id AND
                 collection_id IS NULL) LOOP
             IF (c.institution_acronym=t.institution_acronym) AND (instr(t.accn_num_suffix,c.collection_cde)>0) THEN
                 UPDATE trans SET collection_id=c.collection_id WHERE transaction_id=t.transaction_id;
                 --dbms_output.put_line('c.institution_acronym=' || c.institution_acronym || '; t.institution_acronym=' || t.institution_acronym || '; t.accn_num_suffix=' || t.accn_num_suffix || '; c.collection_cde=' || c.collection_cde);
             END IF;                   
        END LOOP;
    END LOOP;
END;
/
-- the rest of the accns probably have to be dealt with manually.
--- these are multi-collection accns at MVZ - OK to just pick a collection?
-- Collection_id
SELECT accn_number || chr(9) || nature_of_material || chr(9) || collection || chr(9) || COUNT(collection_object_id)
FROM
accn,
trans,
cataloged_item,
collection
WHERE
accn.transaction_id=trans.transaction_id AND
accn.transaction_id=cataloged_item.accn_id (+) AND
cataloged_item.collection_id=collection.collection_id (+) AND
trans.collection_id IS NULL
GROUP BY
accn_number, nature_of_material,collection
ORDER BY accn_number
;

---- USGS accns are MSB:
UPDATE trans SET collection_id=(SELECT collection_id FROM collection WHERE collection_cde='Mamm' AND institution_acronym='MSB')
WHERE transaction_id IN (SELECT transaction_id FROM accn WHERE accn_number LIKE '%USGS%');

--- same drill for loans
BEGIN
    FOR c IN (SELECT collection_id,collection_cde,institution_acronym FROM collection) LOOP
        FOR t IN (SELECT trans.transaction_id,loan_number,institution_acronym FROM loan,trans WHERE
                 loan.transaction_id=trans.transaction_id AND
                 collection_id IS NULL) LOOP
             IF (c.institution_acronym=t.institution_acronym) AND (instr(t.loan_number,c.collection_cde)>0) THEN
                 UPDATE trans SET collection_id=c.collection_id WHERE transaction_id=t.transaction_id;
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
WHERE
trans.transaction_id=loan.transaction_id AND
loan.transaction_id=loan_item.transaction_id (+) AND
loan_item.collection_object_id = specimen_part.collection_object_id (+) AND
specimen_part.derived_from_cat_item = cataloged_item.collection_object_id (+) AND
cataloged_item.collection_id=collection.collection_id (+) AND
trans.collection_id IS NULL
GROUP BY
loan_number, nature_of_material,collection
UNION
SELECT loan_number || chr(9) || nature_of_material || chr(9) || collection || chr(9) || COUNT(cataloged_item.collection_object_id)
FROM
loan,
trans,
loan_item,
cataloged_item,
collection
WHERE
trans.transaction_id=loan.transaction_id AND
loan.transaction_id=loan_item.transaction_id (+) AND
loan_item.collection_object_id =  cataloged_item.collection_object_id (+) AND
cataloged_item.collection_id=collection.collection_id (+) AND
trans.collection_id IS NULL
GROUP BY
loan_number, nature_of_material,collection
;


UPDATE trans SET collection_id=(SELECT collection_id FROM collection WHERE collection_cde='ES' AND institution_acronym='UAM')
WHERE transaction_id IN (SELECT transaction_id FROM loan WHERE loan_number LIKE '%Paleo%');

---- The above gets all but a handful of transactions. Clean up the rest manually in prod. Absolutely no reason to worry about them in dev.
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
-- next step: get rid OF junk objects
/* original notes by dlm 
SELECT TABLE_name FROM USEr_tables;
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
-- used by ColdFusion: CDATA
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

/* get rid of junk tables at UAM */
/* arctos data model */
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
DROP TABLE COLLECTOR_FORMATTED;
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
DROP TABLE BARCODE; -- empty
--BINARY_OBJECT
DROP TABLE BIOL_INDIV;
--BIOL_INDIV_RELATIONS
DROP TABLE BIOL_INDIV_REMARK;
DROP TABLE BIRD; -- not empty
--BOOK
--BOOK_SECTION
--BORROW
--BSCIT_IMAGE_SUBJECT /* will go away with media tables */
--BULKLOADER
--BULKLOADER_ATTEMPTS
--BULKLOADER_CLONE
--BULKLOADER_DELETES
--BULKLOADER_STAGE
--BULKLOADER_TEMPLATE;
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
DROP TABLE CFRELEASE_NOTES; -- empty
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
DROP TABLE COLD_FUSION_USERS; -- empty
--COLLECTING_EVENT
--COLLECTION
--COLLECTION_CONTACTS
--COLLECTOR
DROP TABLE COLLECTOR_FORMATTED; -- empty
--COLL_OBJECT
--COLL_OBJECT_ENCUMBRANCE
--COLL_OBJECT_REMARK
DROP TABLE COLL_OBJECT_RESTRICTION; -- empty
--COLL_OBJ_CONT_HIST
--COLL_OBJ_OTHER_ID_NUM
DROP TABLE COLL_OBJ_OTHER_ID_NUM041105; -- empty
--COMMON_NAME
--CONTAINER
--CONTAINER_CHECK
--CONTAINER_HISTORY
--CORRESPONDENCE;
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
DROP TABLE DARWINCORE; -- empty
DROP TABLE DARWINDATA; -- empty
DROP TABLE DEACCN; -- empty
DROP TABLE DEACC_ITEM; -- empty
DROP TABLE DEV_TASK; -- empty
--DGR_LOCATOR
DROP TABLE DIFF_IMAGE_DATA;
DROP TABLE DIFF_IMAGE_DATA2;
DROP TABLE DIGIR; -- empty
DROP TABLE DIGIRDATA; -- empty
DROP TABLE DIGITAL_AUDIO_FILE; -- empty
DROP TABLE EGG_NEST; -- empty
DROP TABLE EGG_NEST_PARASITE; -- empty
DROP TABLE EGG_NEST_REMARK; -- empty
DROP TABLE EGG_NEST_TEMP_REMARK;
--ELECTRONIC_ADDRESS
--ENCUMBRANCE
--FIELD_NOTEBOOK_SECTION
DROP TABLE FILM; -- empty
DROP TABLE FILM_CLIP; -- empty
DROP TABLE FILM_CLIP_IN_FILM; -- empty
--FLAT
DROP TABLE FLAT_COLLECTOR; -- empty
--FLUID_CONTAINER_HISTORY
--FMP_IMAGE_DATA /* goes away with new media tables */
DROP TABLE FORMPUB; -- empty
DROP TABLE FORMPUBS; -- empty
DROP TABLE FORM_PUBS; -- empty
DROP TABLE GEOGRAPHYINDEX; -- empty
--GEOG_AUTH_REC
DROP TABLE GEOG_INDEX; -- empty
DROP TABLE GEOG_RELATIONS; -- empty
--GEOLOGY_ATTRIBUTES
--GEOLOGY_ATTRIBUTE_HIERARCHY
--GREF_PAGE_REFSET_NG /* gref table */
--GREF_REFSET_NG /* gref table */
--GREF_REFSET_ROI_NG /* gref table */
--GREF_ROI_NG /* gref table */
--GREF_ROI_VALUE_NG /* gref table */
--GREF_USER /* gref table */
DROP TABLE GROUP_MASTER; -- empty
--GROUP_MEMBER
DROP TABLE GROUP_PERSON; -- empty
DROP TABLE HEAP_CACHE; -- empty
DROP TABLE HERP;
DROP TABLE HIERARCHICAL_PART_NAME; -- empty
DROP TABLE HISTO_SLIDE_SERIES; -- empty
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
--LAT_LONG
DROP TABLE LEXICON; -- empty
DROP TABLE LEXICON_SORT_ORDER; -- empty
DROP TABLE LEXICON_TERM_RELATION; -- empty
DROP TABLE LEXICON_TERM_TOKENS; -- empty
DROP TABLE LINK; -- empty
--LOAN
--LOAN_INSTALLMENT
--LOAN_ITEM
DROP TABLE LOAN_REQUEST; -- empty
--LOCALITY
DROP TABLE MAMMAL;
DROP TABLE MAMMALCATNUMS; -- empty
DROP TABLE MAMMALPARTS; -- empty
DROP TABLE MAMMPARTS; -- empty
DROP TABLE MANISCOLLS; -- empty
DROP TABLE MANISGEOREFS -- empty;
DROP TABLE MANIS_COLLECTOR; -- empty
DROP TABLE MANIS_READYTOGO; -- empty
DROP TABLE MDC2; -- empty
DROP TABLE MERGEPARTS; -- empty
DROP TABLE MLL_ALLTHEREST; -- empty
DROP TABLE MLL_HASACCLATLONG; -- empty
DROP TABLE MLL_REMBYCATNUM; -- empty
DROP TABLE MMLYNX; -- empty
DROP TABLE MODEL;
DROP TABLE MRTG; -- empty
DROP TABLE MRTG2; -- empty
DROP TABLE MRTG_BADLOCID; -- empty
DROP TABLE MSB_ACCN; -- empty
DROP TABLE NEWOLDDETS -- empty;
DROP TABLE NEXT_PKEY; -- empty
DROP TABLE NODE_TYPE_CODE; -- empty
DROP TABLE NOTES_OF_COLL_EVENT; -- empty
--NUMS
--OBJECT_CONDITION
DROP TABLE ONEBULK; -- empty
DROP TABLE ORG;
--PAGE
DROP TABLE PARTS_FORMATTED; -- empty
DROP TABLE PART_HIERARCHY; -- empty
DROP TABLE PART_MATRIX; -- empty
--PERMIT
DROP TABLE PERMIT_SHIPMENT; -- empty
--PERMIT_TRANS
--PERSON
DROP TABLE PH; -- empty
DROP TABLE PHANTOM_BIOL_INDIV; -- empty
DROP TABLE PHANTOM_RELATIONS; -- empty
DROP TABLE PLANTHAB; -- empty
--PLAN_TABLE
--PLSQL_PROFILER_DATA
--PLSQL_PROFILER_RUNS
--PLSQL_PROFILER_UNITS
--PROC_BL_STATUS
--PROJECT
--PROJECT_AGENT
DROP TABLE PROJECT_COLL_EVENT; -- empty
--PROJECT_PUBLICATION
--PROJECT_REMARK;
--PROJECT_SPONSOR
--PROJECT_TRANS
--PUBLICATION
--PUBLICATION_AUTHOR_NAME
--PUBLICATION_URL
DROP TABLE PUBLICATION_YEAR;
--REARING_EVENT;
DROP TABLE RELATION_TYPE_CODE; -- empty
DROP TABLE SCANS; -- empty
DROP TABLE SCOPE_NOTES; -- empty
DROP TABLE SEARCHTERMS; -- empty
DROP TABLE SECDET; -- empty
DROP TABLE SECTION; -- empty
DROP TABLE SEQUENCE_REPOSITORY; -- empty
DROP TABLE SEQUENCE_REPOSITORY_ARTICLE; -- empty
DROP TABLE SEQUENCE_REPOS_ARTICLE; -- empty
--SHIPMENT
DROP TABLE SPECIES_TAPE; -- empty
--SPECIMEN_ANNOTATIONS
--SPECIMEN_PART
--STILL_IMAGE /* maybe goes away with media tables? does not exist at UAM */
DROP TABLE STRING_SERIES; -- empty
DROP TABLE TAPE; -- empty
DROP TABLE TAXONBYGEOGINDEX; -- empty
--TAXONOMY
DROP TABLE TAXONOMYINDEX; -- empty
--TAXON_RELATIONS
DROP TABLE TAX_PROTECT_STATUS; -- empty
DROP TABLE TCONTAINER; -- empty
DROP TABLE TEMP;
DROP TABLE TEMPBL; -- empty
DROP TABLE TEMPCONT; -- empty
--TEMP_ALLOW_CF_USER
DROP TABLE TISSUES_FORMATTED; -- empty
DROP TABLE TISSUE_COUNT; -- empty
DROP TABLE TISSUE_PREP; -- empty
DROP TABLE TISSUE_SAMPLE_TYPE; -- empty
DROP TABLE TOAD_PLAN_SQL; -- empty
DROP TABLE TOAD_PLAN_TABLE; -- empty
DROP TABLE TOKENS; -- empty
DROP TABLE TPOTHERID; -- empty
--TRANS
--TRANS_AGENT
DROP TABLE TRANS_AGENT_ADDR; -- empty
DROP TABLE TRANS_CLOSURE; -- empty
DROP TABLE TRANS_ITEM; -- empty
DROP TABLE TRANS_RELATI -- emptyONS;
DROP TABLE UAM_TYPES; -- empty
DROP TABLE UPDATE_CATN -- emptyUMS;
DROP TABLE URL; -- empty
--USER_DATA
--USER_LOAN_ITEM
--USER_LOAN_REQUEST
--USER_ROLES
--USER_TABLE_ACCESS
--VESSEL
--VIEWER
DROP TABLE VISITATION; -- empty
DROP TABLE VOCAL_SERIES; -- empty
DROP TABLE VOCAL_SERIES_CUT_HISTORY; -- empty
DROP TABLE VOCAL_SERIES_ON_TAPE; -- empty
DROP TABLE "VSVBTableVersions"; -- empty
DROP TABLE VTEST; -- empty
DROP TABLE YLYNX; -- empty

/* end of getting rid of junk tables */

-----------------------------------------------------------------------
-- need a ROLE FOR every collection. EACH "us" USER will be given one OR more OF these ROLES
-- create SQL for them with:
-- also need a PUBLIC USER FOR every one OF these ROLES TO deal WITH NOT-us people looking
-- FOR a specific ENTRY point. So, go TO ..../uam_mamm AS a REAL USER, AND you (now) get a USErname {you}.
-- same point AS nobody, AND you run queries AS uam_query. Need TO CHANGE CF TO assign a (generic access-point specific) 
-- username to every user. This role will have SELECT ONLY on collection-specific parts of the VPD.
-- make very sure to have good Oracle security policies - it WILL get hacked.
-- and the revised plan:
-- each collection has a role: UAM_MAMM
-- each collection has a user: PUB_USR_UAM_MAMM
-- each of those public users need a role: grant UAM_MAMM to PUB_USR_UAM_MAMM;
-- each "us" user gets 1 or more roles: grant UAM_MAMM to dlm;
-- may create multi-role public users:
-- 	grant uam_mamm to pub_usr_all_all;
--	grant uam_bird to pub_usr_all_all;
-- etc.




DECLARE 
    s VARCHAR2(4000);
    r VARCHAR2(3000);
    u VARCHAR2(30);
    ir VARCHAR2(30);
BEGIN
    FOR q IN (SELECT * FROM collection) LOOP
       BEGIN
        ir:=upper(q.institution_acronym) || '_' || upper(q.collection_cde);
        --s:='create role ' || ir;
        --EXECUTE IMMEDIATE s;
        --r:='create user PUB_USR_' || ir || ' identified by "userpw.' || q.collection_id || '"';
       -- EXECUTE IMMEDIATE r;
        r:='grant ' || ir || ' to PUB_USR_' || ir;    
                EXECUTE IMMEDIATE r;
       EXCEPTION when OTHERS THEN 
           dbms_output.put_line('bad ' || ir);
       END;
    END LOOP;
END;
/


--- and a all-collection VPD-bypassing super-public-role-thingee
--- stick with the institution_collection syntax.
CREATE USER PUB_USR_ALL_ALL identified by "userpw.00";
grant connect to PUB_USR_ALL_ALL;
grant create session to PUB_USR_ALL_ALL;


DECLARE 
    s VARCHAR2(4000);
    ir VARCHAR2(30);
BEGIN
    FOR q IN (SELECT * FROM collection) LOOP
        ir:=upper(q.institution_acronym) || '_' || upper(q.collection_cde);
        s:='grant ' || ir || ' to pub_usr_all_all';
        EXECUTE IMMEDIATE s;
    END LOOP;
END;
/



-- Users need limited create table privs.
BEGIN
    -- all the CF users
    --FOR q IN (select grantee from DBA_ROLE_PRIVS where GRANTED_ROLE='COLDFUSION_USER') LOOP
      --  EXECUTE IMMEDIATE 'grant create table to ' || q.grantee;
        --EXECUTE IMMEDIATE 'ALTER USER ' || q.grantee || ' default TABLESPACE users QUOTA 10M on users';
    --END LOOP;
    -- and the public collection users
    FOR q IN (select username from all_users where username like 'PUB_USR_%') LOOP
        EXECUTE IMMEDIATE 'grant connect to ' || q.username;
        EXECUTE IMMEDIATE 'grant create table to ' || q.username;
        EXECUTE IMMEDIATE 'ALTER USER ' || q.username || ' default TABLESPACE users QUOTA 10M on users';
    END LOOP;
END;



/*
	Da Spiel:
	
		"Us" users, those with Arctos and Oracle accounts, need access to 1 or more collections. Do this via the Manage Users widget.
		This privilege works in conjunction with existing roles to limit access. Public users access Arctos via "portals"
		(eg, http://arctos-test.arctos.database.museum/uam_mamm) and pick up usernames when they do so. The default portal gives
		access to all collections.
		
		So, by example:
		
		Current Situation: "us" user
			User: test
			Role: manage_specimens
			SQL: delete from cataloged_item
			Result: empty cataloged_item table
			
		VPD Scenario 1: "us" user
			User: test
			Role: manage_specimens
			Collection Access: uam_mamm
			SQL: delete from cataloged_item
			Result: no more UAM Mammals in the cataloged_item table
			
		VPD Scenario 2: public user via UAM Mamm "portal"
			User: pub_usr_uam_mamm
			Role: public
			Collection Access: uam_mamm
			SQL: select * from cataloged_item
			Result: all UAM Mammals in the cataloged_item table
			
		VPD Scenario 3: public user via open "portal"
			User: pub_usr_all_all
			Role: public
			Collection Access: [all collections]
			SQL: select * from cataloged_item
			Result: all rows
			
			
*/

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



/* *********************************************************************************************************************

FORM strategy:
* 
* Change all logins to user_login
* Assign guest users a login based on the URL they come into the app from and/or session.exclusive_collection_id

* While we're here, create a CF user that has access to the CF tables (and nothing else)
create user cf_dbuser identified by cfdbuser;
grant connect to cf_dbuser;
grant create session to cf_dbuser;
grant all on cf_users to cf_dbuser;
grant all on cf_user_data to cf_dbuser;
grant all on user_loan_request to cf_dbuser;
grant all on cf_user_loan to cf_dbuser;
grant all on cf_user_log to cf_dbuser
* 



* 
* 

*********************************************************************************************************************** / 
* 


/*********************************************************************************************************************
	Data Entry Stuff
	
	Role data_entry:
		INSERT into Bulkoader
		DELETE own records
		UPDATE own records
		SELECT own records
		
	manage_collection:
		UPDATE, DELETE, SELECT all records entered by members of own collection role
		
	Example:
		user A: uam_mamm, data_entry roles
			-- create UAM MAMM records
			-- update,delete,select anything with entered_by=A
			-- cannot change LOADED to NULL (trigger)
		user B: uam_mamm, mange_collection
			-- do anything to user A's records
			
			
	LKV will handle everything but the trigger w/ VPD
*/

CREATE ROLE data_entry;
GRANT ALL ON bulkloader TO data_entry;
-- USE existing ROLE manage_collection FOR ADMIN role.


CREATE OR REPLACE TRIGGER bulk_no_null_loaded 
    before UPDATE or INSERT ON uam.bulkloader
    for each row
declare
    hasrole NUMBER;
BEGIN
    IF :NEW.loaded IS NULL THEN
        select 
            COUNT(*) INTO hasrole
		from 
			sys.dba_role_privs
		where
		    upper(grantee) = SYS_CONTEXT ('USERENV','SESSION_USER') and 
		    upper(granted_role)='MANAGE_COLLECTION';
		IF hasrole=0 THEN
		    raise_application_error(-20001,'You do not have permission to set loaded to NULL.');
		END IF;
    END IF;
END;
/
sho err;





---------------------------------------------------------------------------------

CREATE OR REPLACE function concatGeologyAttribute(colobjid  in number )
    return varchar2
    as
        type rc is ref cursor;
        l_str    varchar2(4000);
       l_sep    varchar2(30);
       l_val    varchar2(4000);
/*
	returns a semicolon-separated list of geology attribute determinations
*/
   begin
    FOR r IN (
              select geology_attribute || '=' || geo_att_value oneAtt
	          from 
	              geology_attributes,
	              locality,
	              collecting_event,
	              cataloged_item
	          where
	           geology_attributes.locality_id=locality.locality_id AND
	           locality.locality_id=collecting_event.locality_id AND
	           collecting_event.collecting_event_id=cataloged_item.collecting_event_id AND
	           cataloged_item.collection_object_id=colobjid)
	 LOOP
	     l_str := l_str || l_sep || r.oneAtt;
           l_sep := '; ';
    END LOOP;
   
             
     

       return l_str;
  end;
/
CREATE PUBLIC SYNONYM concatGeologyAttribute FOR concatGeologyAttribute;
GRANT EXECUTE ON concatGeologyAttribute TO PUBLIC;


UPDATE cf_spec_res_cols SET
DISP_ORDER=DISP_ORDER+1 WHERE
DISP_ORDER>37;

INSERT INTO cf_spec_res_cols (
     COLUMN_NAME,
      SQL_ELEMENT,
      CATEGORY,
        CF_SPEC_RES_COLS_ID,
          DISP_ORDER)
          VALUES (
                 'geology_attributes',
                 'concatGeologyAttribute(flatTableName.collection_object_id)',
                 'locality',
                 somerandomsequence.nextval,
                 38);
                 
-- REBUILD spec_with_loc TO spec_with_loc__geol specs

alter table container_history modify PARENT_CONTAINER_ID null;

-- build FUNCTION in concatparts__vpd.sql AND RENAME file TO concatparts


-- handled properly by constraints
DROP TRIGGER TI_LAT_LONG;


-- fix annotations WHILE we're waiting on data....
ALTER TABLE specimen_annotations ADD reviewer_agent_id NUMBER;
ALTER TABLE specimen_annotations
    add CONSTRAINT fk_specimen_annotations_agent
      FOREIGN KEY (reviewer_agent_id)
      REFERENCES agent(agent_id);
ALTER TABLE specimen_annotations ADD reviewed_fg NUMBER(1) DEFAULT 0;
UPDATE specimen_annotations SET reviewed_fg=0 WHERE reviewed_fg IS NULL;
ALTER TABLE specimen_annotations MODIFY reviewed_fg NOT NULL;
ALTER TABLE specimen_annotations add CONSTRAINT ck_specimen_annotations_rev_fg CHECK (reviewed_fg IN (0,1));
ALTER TABLE specimen_annotations ADD reviewer_comment VARCHAR2(255);

GRANT UPDATE ON specimen_annotations TO MANAGE_COLLECTION;


