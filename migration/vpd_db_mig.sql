DECLARE n NUMBER;
BEGIN
    SELECT MAX(collection_id) + 1 INTO n FROM collection;
    EXECUTE IMMEDIATE 'CREATE SEQUENCE sq_collection START WITH ' || n;
    EXECUTE IMMEDIATE 'create public synonym sq_collection for sq_collection';
    EXECUTE IMMEDIATE 'grant select on sq_collection to public';
END;
/
sho err;

CREATE INDEX u_flat_locid ON flat(locality_id) TABLESPACE uam_idx_1;
CREATE INDEX u_flat_colevntid ON flat(collecting_event_id) TABLESPACE uam_idx_1;



DROP PROCEDURE UPDATE_FLAT_GEOGLOCID;
DROP PROCEDURE UPDATE_FLAT_TEST;
DROP TRIGGER TD_COLLECTING_EVENT;
DROP TRIGGER TD_LOCALITY;
DROP TRIGGER TI_CATALOGED_ITEM;
DROP TRIGGER TI_COLLECTING_EVENT;
DROP TRIGGER TI_NOTES_OF_COLL_EVENT;
DROP TRIGGER TI_PROJECT_COLL_EVENT;
DROP TRIGGER TU_COLLECTING_EVENT;
DROP TRIGGER TU_LOCALITY;
DROP TRIGGER TD_CATALOGED_ITEM;
DROP PUBLIC SYNONYM SPC;
DROP VIEW SPC;
DROP TRIGGER COLL_OBJ_DISP_VAL_TEST;
DROP TRIGGER TD_ACCN;
DROP TRIGGER TD_ADDR;
DROP TRIGGER TD_FIELD_NOTEBOOK_SECTION;
DROP TRIGGER TD_LOAN;



ALTER TABLE cataloged_item
add CONSTRAINT fk_accn
  FOREIGN KEY (accn_id)
  REFERENCES accn(transaction_id);
ALTER TABLE accn ADD constraint pk_accn PRIMARY KEY (transaction_id); 

DELETE FROM coll_object_remark WHERE collection_object_id NOT IN (SELECT collection_object_id FROM coll_object);

ALTER TABLE coll_object_remark
add CONSTRAINT fk_coll_object_remark
  FOREIGN KEY (collection_object_id)
  REFERENCES coll_object(collection_object_id);
  
ALTER TABLE identification
add CONSTRAINT fk_id_cat_item
  FOREIGN KEY (collection_object_id)
  REFERENCES cataloged_item(collection_object_id);


CREATE INDEX ix_ctdepth_units ON ctdepth_units(depth_units)  TABLESPACE uam_idx_1;


-- replace flat.triggers_setFlag.sql with flat.triggers_setFlag.vpd.sql (changes Accn)
UPDATE flat SET accession=(SELECT DISTINCT accn_number FROM accn WHERE  accn.transaction_id=flat.ACCN_ID);

------------------------------------------------------------------------------------------------------------------------
--   Need to clean up other IDs to no longer be collection-specific
-- clean up the unused stuff while we're here
ALTER TABLE COLL_OBJ_OTHER_ID_NUM DROP COLUMN OTHER_ID_NUM;
-- rebuild CONCATSINGLEOTHERIDINT
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

drop trigger COLL_OBJ_DISP_VAL_TEST;

--- rebuild the check trigger
CREATE OR REPLACE TRIGGER "UAM".OTHER_ID_CT_CHECK BEFORE
INSERT
OR UPDATE ON "UAM"."COLL_OBJ_OTHER_ID_NUM" REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW declare
numrows number;
collectionCode varchar2(20);
BEGIN
execute immediate 'SELECT COUNT(*)
        FROM ctcoll_other_id_type
        WHERE other_id_type = ''' || :NEW.other_id_type || '''' INTO numrows ;
IF (numrows = 0) THEN
raise_application_error(
-20001,
'Invalid other ID type');
END IF;
END;
/

DROP TRIGGER TI_COLL_OBJ_OTHER_ID_NUM;
DROP TRIGGER TU_COLL_OBJ_OTHER_ID_NUM;
DROP VIEW af;
drop view af_num;
DROP VIEW COLLECTORNUMBER;
--- continue cleaning up the stuff made unnecessary by key relationships

DROP TRIGGER TI_PERMIT_TRANS;
DROP TRIGGER TI_PROJECT_TRANS;
DROP TRIGGER TI_SHIPMENT;
DROP TRIGGER TI_TRANS_AGENT_ADDR;
DROP TRIGGER TU_AGENT;
DROP TRIGGER TU_BORROW;
DROP TRIGGER TU_COLL_OBJ_CONT_HIST;
DROP TRIGGER TU_CONTAINER_HISTORY;
DROP TRIGGER TU_CORRESPONDENCE;
DROP TRIGGER TU_DEACCN;
DROP TRIGGER TU_FLUID_CONTAINER_HISTORY;
DROP TRIGGER TU_LOAN_INSTALLMENT;
DROP TRIGGER TU_GROUP_MEMBER;
DROP TRIGGER TU_GROUP_MASTER;
DROP TRIGGER TU_LOAN_REQUEST;
DROP TRIGGER TU_PERMIT_TRANS;
DROP TRIGGER TU_PERSON;
DROP TRIGGER TU_PROJECT_TRANS;

DROP PROCEDURE B_BUILD_KEYS_TABLE;
DROP VIEW AFNUMBER;
DROP VIEW DETAIL_TWO;
DROP VIEW DETAIL_VIEW;
DROP VIEW FLAT_VIEW;
DROP TRIGGER TD_GROUP_MASTER;
DROP TRIGGER TD_PERSON;
DROP TRIGGER TI_BORROW;
DROP TRIGGER TI_CORRESPONDENCE;
DROP TRIGGER TI_DEACCN;
DROP TRIGGER TI_FLUID_CONTAINER_HISTORY;
DROP TRIGGER TI_LOAN;
DROP TRIGGER TI_LOAN_INSTALLMENT;
DROP TRIGGER TI_LOAN_REQUEST;
DROP TRIGGER TU_SHIPMENT;
DROP TRIGGER TU_TRANS_AGENT_ADDR;
DROP TRIGGER TD_AGENT;

-- cataloged_item.accn_id should point to accn ONLY, not accn and trans
ALTER TABLE cataloged_item DROP CONSTRAINT FK_CATALOGE_FK_CATITE_TRANS;

DROP TRIGGER 
DROP TRIGGER 
DROP TRIGGER 



























-- rebuild bulkloader_stage_check
-- rebuild bulk_pkg.{all}
-- clean up the code table
ALTER TABLE ctcoll_other_id_type DROP CONSTRAINT SYS_C0019312;
alter table ctcoll_other_id_type drop column COLLECTION_CDE;

DECLARE 
    c NUMBER;
BEGIN
    FOR r IN (SELECT OTHER_ID_TYPE,DESCRIPTION,ROWID FROM ctcoll_other_id_type) LOOP
        SELECT COUNT(*) INTO c FROM ctcoll_other_id_type WHERE OTHER_ID_TYPE=r.OTHER_ID_TYPE AND
            DESCRIPTION != r.DESCRIPTION AND ROWID != r.rowid;
        IF c > 0 THEN
            dbms_output.put_line (r.OTHER_ID_TYPE || ';' || r.DESCRIPTION);-- || '|' || OTHER_ID_TYPE || ';' || DESCRIPTION);
        END IF;
    END LOOP;
END;
/
-- clean up manually
SELECT ':' || description || ':' FROM ctcoll_other_id_type WHERE OTHER_ID_TYPE='UAM';
-- damned linebreak thingee
DELETE FROM ctcoll_other_id_type WHERE OTHER_ID_TYPE='UAM' AND DESCRIPTION LIKE 'Legacy catalog numbering system%';
-- left with identical type/desc dups

BEGIN
    FOR r IN (SELECT OTHER_ID_TYPE,ROWID FROM ctcoll_other_id_type) LOOP
       DELETE FROM ctcoll_other_id_type WHERE ROWID != r.rowid AND other_id_type=r.other_id_type;
    END LOOP;
END;
/


CREATE UNIQUE INDEX ix_ctother_id_type ON ctcoll_other_id_type(other_id_type) TABLESPACE uam_idx_1;
-----------------------
ALTER TABLE cf_collection_appearance ADD header_credit VARCHAR2(255);

-- Set up a table that controls possible CF usernames and their associated customizations....
-- At the interface, this table will be used to get metadata for "not us" users
-- "Is us" users will need to have these settings ever-ridden by their assigned collection
-- affiliations (via roles)
-- The interfaces (and relationships) also need to allow entries that are not real collections into
-- cf_collection_appearance. This will be useful for creating "portals" - ie, MVZ or All Mammal Collections
-- or whatever.
-- This table will be a replacement for cf_collection_appearance

CREATE TABLE cf_collection AS SELECT 
    somerandomsequence.nextval cf_collection_id,
    collection.collection_id,
    'PUB_USR_' || upper(institution_acronym) || '_' || upper(collection_cde) dbusername,
    'userpw.' || collection.collection_id dbpwd,
    HEADER_COLOR,
    HEADER_IMAGE,
    COLLECTION_URL,
    COLLECTION_LINK_TEXT,
    INSTITUTION_URL,
    INSTITUTION_LINK_TEXT,
    META_DESCRIPTION,
    META_KEYWORDS,
    STYLESHEET,
    HEADER_CREDIT
FROM
    cf_collection_appearance,
    collection
WHERE
    collection.collection_id=cf_collection_appearance.collection_id(+)
    ;
ALTER TABLE cf_collection MODIFY CF_COLLECTION_ID NUMBER;
ALTER TABLE cf_collection MODIFY COLLECTION_ID NULL;

 CREATE OR REPLACE TRIGGER cf_cf_collection_key                                         
 before insert  ON cf_collection  
 for each row
    begin     
    	if :NEW.cf_collection_id is null then                                                                                      
    		select somerandomsequence.nextval into :new.cf_collection_id from dual;
    	end if;                                
    end;                                                                                            
/
sho err
    
 CREATE OR REPLACE TRIGGER cf_collection_sync                                       
 before UPDATE OR insert OR DELETE ON collection  
 for each row
  DECLARE 
     c NUMBER;
    begin
        IF inserting THEN
            INSERT INTO cf_collection (
                collection_id,
                dbusername,
                dbpwd
            ) VALUES (
                :NEW.collection_id,
                'PUB_USR_' || upper(:NEW.institution_acronym) || '_' || upper(:NEW.collection_cde),
                'userpw.' || :NEW.collection_id
            );            
    	ELSIF deleting THEN
    	    DELETE FROM cf_collection WHERE collection_id=:OLD.collection_id;
    	ELSIF updating THEN
    	    IF (:NEW.collection_id != :OLD.collection_id) THEN
    	        UPDATE cf_collection SET collection_id=:NEW.collection_id,
    	         cf_collection_id=:NEW.collection_id WHERE collection_id=:OLD.collection_id;
    	    END IF;
    	    IF (:NEW.institution_acronym != :OLD.institution_acronym) OR 
    	        (:NEW.collection_cde != :OLD.collection_cde) OR 
    	        (:NEW.collection != :OLD.collection) THEN
    	        UPDATE cf_collection SET 
    	            dbusername='PUB_USR_' || upper(:NEW.institution_acronym) || '_' || upper(:NEW.collection_cde),
    	            dbpwd='userpw.' || :NEW.collection_id,
    	            collection=:NEW.collection,
    	            portal_name=upper(:NEW.institution_acronym) || '_' || upper(:NEW.collection_cde)
    	        WHERE collection_id = :NEW.collection_id;
    	    END IF;
    	END IF;
    end;                                                                                            
/
sho err
-- seed some other values in
-- id=0 is a sacred value used for the default everything "portal"
INSERT INTO cf_collection (
    cf_collection_id,
    dbusername,
    dbpwd,
    HEADER_COLOR,
    HEADER_IMAGE,
    COLLECTION_URL,
    COLLECTION_LINK_TEXT,
    INSTITUTION_URL,
    INSTITUTION_LINK_TEXT,
    META_DESCRIPTION,
    META_KEYWORDS,
    STYLESHEET,
    HEADER_CREDIT
) VALUES (
    0,
    'PUB_USR_ALL_ALL',
    'userpw.00',
    '#E7E7E7',
    '/images/genericHeaderIcon.gif',
    '/',
    'Arctos',
    '/',
    'Multi-Institution, Multi-Collection Museum Database',
    'Arctos is a biological specimen database.',
    'museum, collection, management, system',
    '',
    '');
CREATE PUBLIC SYNONYM cf_collection FOR cf_collection;
GRANT ALL ON cf_collection TO cf_dbuser;
GRANT ALL ON cf_collection TO manage_collection;

UPDATE cf_collection SET cf_collection_id=collection_id WHERE collection_id IS NOT NULL;

ALTER TABLE cf_collection ADD portal_name VARCHAR2(30);
ALTER TABLE cf_collection ADD collection VARCHAR2(30);
UPDATE cf_collection SET (portal_name,collection)=(SELECT
lower(institution_acronym) || '_' || lower(collection_cde),
collection FROM collection
WHERE collection.collection_id=cf_collection.collection_id)
;
UPDATE cf_collection SET portal_name='all_all',collection='All Collections' WHERE cf_collection_id=0;
ALTER TABLE cf_collection MODIFY portal_name NOT NULL;
ALTER TABLE cf_collection MODIFY collection NOT NULL;

-- REPLACE make_part_coll_obj_cont WITH make_part_coll_obj_cont.vpd.sql


-- these indices seem to have a pretty substantial impact
create index u_id_sci_name on identification (upper(scientific_name)) tablespace uam_idx_1;
ANALYZE TABLE identification COMPUTE STATISTICS;
create index u_tax_sci_name on taxonomy (upper(scientific_name)) tablespace uam_idx_1;
ANALYZE TABLE taxonomy COMPUTE STATISTICS;
create index u_common_name on common_name (upper(common_name)) tablespace uam_idx_1;
ANALYZE TABLE common_name COMPUTE STATISTICS;


DROP INDEX tti;
DROP INDEX ttt;
DROP INDEX ttc;

create index tti on identification (upper(scientific_name)) tablespace uam_idx_1;
ANALYZE TABLE identification COMPUTE STATISTICS;
create index  on taxonomy (upper(scientific_name)) tablespace uam_idx_1;
ANALYZE TABLE taxonomy COMPUTE STATISTICS;
create index  on common_name (upper(common_name)) tablespace uam_idx_1;
ANALYZE TABLE common_name COMPUTE STATISTICS;

 

    