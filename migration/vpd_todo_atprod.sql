--  0) update uam code table data and update trans table.
see migrate_ctdata.sql
see vpd_tables UNDER trans.

--	1) export mvz data at Lily: 
run script /home/lam/mvzora/mvzlprod/dump/exp_data.sh or 
run exp uam@mvzlprod file=mvz_uam_schema.dmp owner=uam triggers=n constraints=n indexes=n grants=n
run exp uam@mvzlprod file=uam_uam_schema.dmp owner=uam triggers=n constraints=n indexes=n grants=n
5:35 PM CA TIME
--	2) ftp mvz data from Lily to Achlys.
	
--	3) ftp mvz data from Achlys to db.arctos.database.museum.
	
--	4) import mvz data into arctos db.
-- run as uam at db.arctos.database.museum:
imp uam file=mvz_uam_schema.dmp fromuser=uam touser=mvz constraints=n indexes=n grants=n

-- run as user vpd
BEGIN
    FOR tn IN (SELECT table_name FROM user_tables) LOOP
        EXECUTE IMMEDIATE 'grant select on mvz.' || tn.table_name || ' to uam';
        dbms_output.put_line('grant select on mvz.' || tn.table_name || ' to uam');
	END LOOP;
END;	

--	5) update mvz primary keys to value plus 10000000 (10 million)
-- make sure to check for max value in PK at uam.
-- run as user uam

DECLARE
    c NUMBER;
    maxid NUMBER;
BEGIN
    maxid := 0;
    FOR cn IN (
        SELECT ucc.constraint_name, ucc.table_name, ucc.column_name 
        FROM user_cons_columns ucc, user_constraints uc, user_tab_columns utc
        WHERE ucc.constraint_name = uc.constraint_name
        AND ucc.table_name = utc.table_name
        AND ucc.column_name = utc.column_name
        AND utc.data_type = 'NUMBER'
        AND uc.constraint_type = 'P'
        AND ucc.constraint_name NOT IN (
            SELECT constraint_name FROM user_cons_columns
            WHERE position = 2)
        AND ucc.table_name NOT LIKE 'PLSQL%'
        AND ucc.table_name NOT LIKE 'DR$%'
    ) LOOP
        EXECUTE IMMEDIATE 'select max(' || cn.column_name || ') from ' || cn.table_name INTO c;
        dbms_output.put_line(c || chr(9) || cn.constraint_name || chr(9) || cn.table_name || '.' || cn.column_name);
        IF c > maxid THEN
            maxid := c;
        END IF;
	END LOOP;
        dbms_output.put_line(chr(10) || 'MAXIMUM PRIMARY KEY ID: ' || maxid);
END;
/

--  5a) update main tables and drop foreign keys.
see vpd_tables.sql

--GREF TABLES

--GREF_PAGE_REFSET_NG
CREATE TABLE GREF_PAGE_REFSET_NG (
    PAGE_ID NUMBER,
    REFSET_NG_ID NUMBER )
TABLESPACE UAM_DAT_1;

-- GREF_REFSET_NG
CREATE TABLE GREF_REFSET_NG (
    ID NUMBER NOT NULL,
    TITLE VARCHAR2(4000 CHAR),
    PAGE_ID NUMBER )
TABLESPACE UAM_DAT_1;

-- GREF_REFSET_ROI_NG
CREATE TABLE GREF_REFSET_ROI_NG (
    REFSET_NG_ID NUMBER NOT NULL ,
    ROI_NG_ID NUMBER NOT NULL )
TABLESPACE UAM_DAT_1;

-- GREF_ROI_NG
CREATE TABLE GREF_ROI_NG (
    ID NUMBER NOT NULL ENABLE,
    X NUMBER,
	Y NUMBER,
	W NUMBER,
	H NUMBER,
	PAGE_ID NUMBER,
	ROI_VALUE_NG_ID NUMBER,
	PUBLICATION_ID NUMBER(22,0),
	SECTION_NUMBER NUMBER(22,0),
	PAGE_NUMBER NUMBER(22,0),
	GLOBAL NUMBER(1,0) DEFAULT (0) )
TABLESPACE UAM_DAT_1;

-- GREF_ROI_VALUE_NG
CREATE TABLE GREF_ROI_VALUE_NG (
    ID NUMBER NOT NULL,
	ROI_NG_ID NUMBER,
	ROI_VALUE_TYPE VARCHAR2(4000),
	VERBATIM_BEGIN VARCHAR2(4000),
	VERBATIM_END VARCHAR2(4000),
	RANGE_BEGIN DATE,
	RANGE_END DATE,
	AGENT_ID NUMBER,
	HIGHER_GEOGRAPHY_ID NUMBER,
	CAT_NUM NUMBER(22,0),
	COLLECTION_OBJECT_ID NUMBER(22,0),
	COLLECTION_DESC VARCHAR2(255),
	AGENT_NAME VARCHAR2(184),
	HIGHER_GEOG VARCHAR2(255),
	SPEC_LOCALITY VARCHAR2(255),
	COLLECTOR_NUMBER VARCHAR2(255),
	SCIENTIFIC_NAME VARCHAR2(255),
	VERBATIM_LOCALITY VARCHAR2(300),
	COLLECTING_EVENT_ID NUMBER(22,0) )
TABLESPACE UAM_DAT_1;

-- GREF_USER
CREATE TABLE GREF_USER (
    ID NUMBER(22,0) NOT NULL,
    FIRST_NAME VARCHAR2(127),
	LAST_NAME VARCHAR2(127),
	USER_NAME VARCHAR2(127),
	EMAIL VARCHAR2(127),
	PASSWORD_SHA1 VARCHAR2(127),
	TITLE VARCHAR2(127),
	INSTITUTION VARCHAR2(127),
	APPROVED NUMBER(1,0) )
TABLESPACE UAM_DAT_1;

insert into uam.GREF_PAGE_REFSET_NG 
select * from mvz.GREF_PAGE_REFSET_NG;

insert into uam.GREF_REFSET_NG 
select * from mvz.GREF_REFSET_NG;

insert into uam.GREF_REFSET_ROI_NG 
select * from mvz.GREF_REFSET_ROI_NG;

insert into uam.GREF_ROI_NG 
select * from mvz.GREF_ROI_NG;

insert into uam.GREF_ROI_VALUE_NG 
select * from mvz.GREF_ROI_VALUE_NG;

insert into uam.GREF_USER 
select * from mvz.GREF_USER;

UPDATE GREF_PAGE_REFSET_NG SET 
    page_id = page_id + 10000000;

UPDATE GREF_REFSET_NG SET 
    page_id = page_id + 10000000;

UPDATE GREF_ROI_NG SET 
    page_id = page_id + 10000000, 
    publication_id = publication_id + 10000000;

UPDATE GREF_ROI_VALUE_NG SET 
    agent_id = agent_id + 10000000, 
    collecting_event_id = collecting_event_id + 10000000,
    collection_object_id = collection_object_id + 10000000;

--GREF pkeys
ALTER TABLE GREF_REFSET_NG
    ADD CONSTRAINT PK_GREF_REFSET_NG
	PRIMARY KEY (ID)
	USING INDEX TABLESPACE UAM_IDX_1;
	
ALTER TABLE GREF_ROI_NG
    ADD CONSTRAINT PK_GREF_ROI_NG 
    PRIMARY KEY (ID)
    USING INDEX TABLESPACE UAM_IDX_1;
    
ALTER TABLE GREF_ROI_VALUE_NG
    ADD CONSTRAINT PK_GREF_ROI_VALUE_NG 
    PRIMARY KEY (ID)
    USING INDEX TABLESPACE UAM_IDX_1;
    
ALTER TABLE GREF_USER
    ADD CONSTRAINT PK_GREF_USER 
    PRIMARY KEY (ID)
    USING INDEX TABLESPACE UAM_IDX_1;

--GREF fkeys
ALTER TABLE GREF_PAGE_REFSET_NG
	ADD CONSTRAINT FK_PAGEREFSETNG_PAGE
	FOREIGN KEY (PAGE_ID)
	REFERENCES PAGE (PAGE_ID);

ALTER TABLE GREF_REFSET_NG
	ADD CONSTRAINT FK_REFSETNG_PAGE
	FOREIGN KEY (PAGE_ID)
	REFERENCES PAGE (PAGE_ID);
  
ALTER TABLE GREF_REFSET_ROI_NG
    ADD CONSTRAINT FK_REFSETROING_REFSETNG 
    FOREIGN KEY (REFSET_NG_ID)
    REFERENCES GREF_REFSET_NG (ID);
  
ALTER TABLE GREF_REFSET_ROI_NG
    ADD CONSTRAINT FK_REFSETROING_ROING 
    FOREIGN KEY (ROI_NG_ID)
    REFERENCES GREF_ROI_NG (ID);

ALTER TABLE GREF_ROI_NG
    ADD CONSTRAINT FK_ROING_PAGE
    FOREIGN KEY (PAGE_ID)
    REFERENCES PAGE (PAGE_ID);
    
ALTER TABLE GREF_ROI_NG
    ADD CONSTRAINT FK_ROING_PUBLICATION 
    FOREIGN KEY (PUBLICATION_ID)
    REFERENCES PUBLICATION (PUBLICATION_ID);
    
ALTER TABLE GREF_ROI_NG
    ADD CONSTRAINT FK_ROING_ROIVALUENG 
    FOREIGN KEY (ROI_VALUE_NG_ID)
    REFERENCES GREF_ROI_VALUE_NG (ID);
    
ALTER TABLE GREF_ROI_VALUE_NG
    ADD CONSTRAINT FK_ROIVALUENG_AGENTNAME 
    FOREIGN KEY (AGENT_ID)
    REFERENCES AGENT_NAME (AGENT_NAME_ID);
    
ALTER TABLE GREF_ROI_VALUE_NG
    ADD CONSTRAINT FK_ROIVALUENG_COLLEVENT 
    FOREIGN KEY (COLLECTING_EVENT_ID)
    REFERENCES COLLECTING_EVENT (COLLECTING_EVENT_ID);
    
ALTER TABLE GREF_ROI_VALUE_NG
    ADD CONSTRAINT FK_ROIVALUENG_ROING 
    FOREIGN KEY (ROI_NG_ID)
    REFERENCES GREF_ROI_NG (ID);
    
ALTER TABLE GREF_ROI_VALUE_NG
    ADD CONSTRAINT FK_ROIVALUENG_COLLOBJECT 
    FOREIGN KEY (COLLECTION_OBJECT_ID)
    REFERENCES COLL_OBJECT (COLLECTION_OBJECT_ID);

CREATE PUBLIC SYNONYM GREF_PAGE_REFSET_NG FOR GREF_PAGE_REFSET_NG;
CREATE PUBLIC SYNONYM GREF_REFSET_NG FOR GREF_REFSET_NG;
CREATE PUBLIC SYNONYM GREF_REFSET_ROI_NG FOR GREF_REFSET_ROI_NG;
CREATE PUBLIC SYNONYM GREF_ROI_NG FOR GREF_ROI_NG;
CREATE PUBLIC SYNONYM GREF_ROI_VALUE_NG FOR GREF_ROI_VALUE_NG;
CREATE PUBLIC SYNONYM GREF_USER FOR GREF_USER;

-- CF tables
--cf tables

--grant select on CFFLAGS to uam;
--grant select on CF_ADDR to uam;
--grant select on CF_COLLECTION_APPEARANCE to uam;
--grant select on CF_FORM_PERMISSIONS to uam;
--grant select on CF_GENBANK_INFO to uam;
--grant select on CF_LABEL to uam;
--grant select on CF_LOAN to uam;
--grant select on CF_LOAN_ITEM to uam;
--grant select on CF_PROJECT to uam;
--grant select on CF_SEARCH_RESULTS to uam;
--grant select on CF_TEMP_ATTRIBUTES to uam;
--grant select on CF_TEMP_BARCODE_PARTS to uam;
--grant select on CF_TEMP_CITATION to uam;
--grant select on CF_TEMP_CONTAINER_LOCATION to uam;
--grant select on CF_TEMP_CONTAINER_LOCATION_TWO to uam;
--grant select on CF_TEMP_LOAN_ITEM to uam;
--grant select on CF_TEMP_OIDS to uam;
--grant select on CF_TEMP_PARTS to uam;
--grant select on CF_TEMP_RELATIONS to uam;
--grant select on CF_TEMP_SCANS to uam;
--grant select on CF_USER_LOAN to uam;
--grant select on CF_USER_ROLES to uam;
--grant select on CF_VERSION to uam;
--grant select on CF_VERSION_LOG to uam;

0       CFFLAGS
0       CF_ADDR
0       CF_ADDRESS
0       CF_COLLECTION_APPEARANCE
0       CF_GENBANK_INFO
0       CF_LABEL
0       CF_LOAN
0       CF_LOAN_ITEM
0       CF_PROJECT
0       CF_SEARCH_RESULTS
0       CF_TEMP_ATTRIBUTES
0       CF_TEMP_BARCODE_PARTS
0       CF_TEMP_CONTAINER_LOCATION
0       CF_TEMP_CONTAINER_LOCATION_TWO
0       CF_TEMP_LOAN_ITEM
0       CF_TEMP_PARTS
0       CF_TEMP_SCANS
0       CF_USER_LOAN
0       CF_VERSION
0       CF_VERSION_LOG

CF_BUGS
--CF_CANNED_SEARCH
CF_CTUSER_ROLES
CF_DATABASE_ACTIVITY
CF_DOWNLOAD
CF_LOG
CF_SPEC_RES_COLS
CF_USERS
CF_USER_DATA
CF_USER_LOG

UPDATE mvz.cf_bugs
SET bug_id = bug_id + 10000000, user_id = user_id + 10000000;

-- builds url based on id. don't bring over.
--UPDATE TABLE mvz.cf_canned_search
--SET canned_id = canned_id + 10000000, user_id = user_id + 10000000;

UPDATE mvz.cf_database_activity
SET activity_id = activity_id + 10000000, user_id = user_id + 10000000;

UPDATE mvz.cf_download
SET user_id = user_id + 10000000;

UPDATE mvz.cf_log
SET log_id = log_id + 10000000;

UPDATE mvz.cf_users
SET user_id = user_id + 10000000;

UPDATE mvz.cf_user_data
SET user_id = user_id + 10000000;

GRANT ALL ON cf_canned_search TO cf_dbuser;

--CF_BUGS
DESC mvz.CF_BUGS;
DESC uam.CF_BUGS;
SELECT COUNT(*) FROM mvz.CF_BUGS;
select count(*) from uam.CF_BUGS;

INSERT INTO uam.cf_bugs SELECT * FROM mvz.cf_bugs;

SELECT COUNT(*) FROM mvz.CF_BUGS;
select count(*) from uam.CF_BUGS;

--CF_CTUSER_ROLES
-- contains same roles. do not migrate.
DESC mvz.CF_CTUSER_ROLES;
DESC uam.CF_CTUSER_ROLES;
SELECT COUNT(*) FROM mvz.CF_CTUSER_ROLES;
select count(*) from uam.CF_CTUSER_ROLES;

select * from mvz.CF_CTUSER_ROLES order by role_name;
select * from uam.CF_CTUSER_ROLES order by role_name;

--CF_DATABASE_ACTIVITY
DESC mvz.CF_DATABASE_ACTIVITY;
DESC uam.CF_DATABASE_ACTIVITY;
SELECT COUNT(*) FROM mvz.CF_DATABASE_ACTIVITY;
select count(*) from uam.CF_DATABASE_ACTIVITY;

INSERT INTO uam.CF_DATABASE_ACTIVITY SELECT * FROM mvz.CF_DATABASE_ACTIVITY;

SELECT COUNT(*) FROM mvz.CF_DATABASE_ACTIVITY;
select count(*) from uam.CF_DATABASE_ACTIVITY;

--CF_DOWNLOAD
DESC mvz.CF_DOWNLOAD;
DESC uam.CF_DOWNLOAD;
SELECT COUNT(*) FROM mvz.CF_DOWNLOAD;
select count(*) from uam.CF_DOWNLOAD;

INSERT INTO uam.CF_DOWNLOAD SELECT * FROM mvz.CF_DOWNLOAD;

SELECT COUNT(*) FROM mvz.CF_DOWNLOAD;
select count(*) from uam.CF_DOWNLOAD;

--CF_LOG -- has trigger
DESC mvz.CF_LOG;
DESC uam.CF_LOG;
SELECT COUNT(*) FROM mvz.CF_LOG;
select count(*) from uam.CF_LOG;

ALTER TRIGGER CF_LOG_ID DISABLE;

INSERT INTO uam.CF_LOG SELECT * FROM mvz.CF_LOG;

SELECT COUNT(*) FROM mvz.CF_LOG;
select count(*) from uam.CF_LOG;

ALTER TRIGGER CF_LOG_ID ENABLE;

--CF_SPEC_RES_COLS --  has trigger and pkey
-- do not need to bring over. same data as uam.

--CF_USERS -- has trigger
--CF_PW_CHANGE is disabled here.
DESC mvz.CF_USERS;
DESC uam.CF_USERS;
SELECT COUNT(*) FROM mvz.CF_USERS;
select count(*) from uam.CF_USERS;
       
SELECT username FROM mvz.CF_USERS
WHERE username IN (SELECT username FROM uam.cf_users)
AND username NOT IN (SELECT USErname FROM dba_users)
ORDER BY username;

Chris
Duke Rogers
Julia Lenz
Melissa Reed-Eckert
Username
adamah
adhornsby
ahope
arush
b_young
bhaley
brandy
burtonl
ccicero
dcrawford
demboski
dusty
egutierrez
gerson
gordon
gshugart
jcpatton
jessewayne34@hotmail.com
jfrey
jmalaney
jrdemboski
kabendz
lam
lolson
ltlbear
lumberjack1982
marcosmollerach
markstoeckle
mc202
mncady
namark
nhatch
orrteri
pvelazco
rfaucett
robgur
rook137
ruedas
sadiel
skkrause
smaher02
somacdonald
sueguers
tperry
tsjung
tuco
vlmathis
voleguy
wchun
werainey

DELETE FROM cf_user_data
WHERE user_id IN (
    SELECT user_id FROM cf_users
    WHERE upper(username) IN (
'AIPPOLITO',
'TRAPAGA',
'TROX',
'CCICERO',
'IOMEDEA1',
'DKT',
'DMFISHER197',
'DUSTY',
'EWOMMACK',
'HPARK',
'JACASTILLO',
'JHAVENS',
'JSANTOS',
'KDODD',
'KLOVETT',
'KROWE',
'LYDSMITH',
'MJALBE',
'MJOSE',
'MKOO',
'MTAKAHASHI',
'MTIEE',
'PATTON',
'PTITLE',
'SDIAZ',
'SHANNA',
'SHARONL',
'STOMIYA',
'SWERNING',
'TFEO',
'TUCO',
'VOLEGUY',
'WOODJACE')
);

DELETE FROM cf_users
    WHERE upper(username) IN (
'AIPPOLITO',
'TRAPAGA',
'TROX',
'CICERO',
'IOMEDEA1',
'DKT',
'DMFISHER197',
'DUSTY',
'EWOMMACK',
'HPARK',
'JACASTILLO',
'JHAVENS',
'JSANTOS',
'KDODD',
'KLOVETT',
'KROWE',
'LYDSMITH',
'MJALBE',
'MJOSE',
'MKOO',
'MTAKAHASHI',
'MTIEE',
'PATTON',
'PTITLE',
'SDIAZ',
'SHANNA',
'SHARONL',
'STOMIYA',
'SWERNING',
'TFEO',
'TUCO',
'VOLEGUY',
'WOODJACE');

DROP USER tuco;
DROP USER voleguy;
DROP USER dusty;
DROP USER ccicero;

INSERT INTO uam.CF_USERS (
 USERNAME,
 PASSWORD,
 TARGET,
 DISPLAYROWS,
 MAPSIZE,
 PARTS,
 ACCN_NUM,
 HIGHER_TAXA,
 AF_NUM,
 RIGHTS,
 USER_ID,
 ACTIVE_LOAN_ID,
 COLLECTION,
 IMAGES,
 PERMIT,
 CITATION,
 PROJECT,
 PRESMETH,
 ATTRIBUTES,
 COLLS,
 PHYLCLASS,
 SCINAMEOPERATOR,
 DATES,
 DETAIL_LEVEL,
 COLL_ROLE,
 CURATORIAL_STUFF,
 IDENTIFIER,
 BOUNDINGBOX,
 KILLROW,
 APPROVED_TO_REQUEST_LOANS,
 BIGSEARCHBOX,
 COLLECTING_SOURCE,
 SCIENTIFIC_NAME,
 CUSTOMOTHERIDENTIFIER,
 CHRONOLOGICAL_EXTENT,
 MAX_ERROR_IN_METERS,
 SHOWOBSERVATIONS,
 COLLECTION_IDS,
 EXCLUSIVE_COLLECTION_ID,
 LOAN_REQUEST_COLL_ID,
 MISCELLANEOUS,
 LOCALITY,
 RESULTCOLUMNLIST,
 PW_CHANGE_DATE,
 LAST_LOGIN,
 SPECSRCHPREFS,
 FANCYCOID,
 RESULT_SORT)
SELECT 
 USERNAME,
 PASSWORD,
 TARGET,
 DISPLAYROWS,
 MAPSIZE,
 PARTS,
 ACCN_NUM,
 HIGHER_TAXA,
 AF_NUM,
 RIGHTS,
 USER_ID,
 ACTIVE_LOAN_ID,
 COLLECTION,
 IMAGES,
 PERMIT,
 CITATION,
 PROJECT,
 PRESMETH,
 ATTRIBUTES,
 COLLS,
 PHYLCLASS,
 SCINAMEOPERATOR,
 DATES,
 DETAIL_LEVEL,
 COLL_ROLE,
 CURATORIAL_STUFF,
 IDENTIFIER,
 BOUNDINGBOX,
 KILLROW,
 APPROVED_TO_REQUEST_LOANS,
 BIGSEARCHBOX,
 COLLECTING_SOURCE,
 SCIENTIFIC_NAME,
 CUSTOMOTHERIDENTIFIER,
 CHRONOLOGICAL_EXTENT,
 MAX_ERROR_IN_METERS,
 SHOWOBSERVATIONS,
 COLLECTION_IDS,
 EXCLUSIVE_COLLECTION_ID,
 LOAN_REQUEST_COLL_ID,
 MISCELLANEOUS,
 LOCALITY,
 RESULTCOLUMNLIST,
 PW_CHANGE_DATE,
 LAST_LOGIN,
 SPECSRCHPREFS,
 FANCYCOID,
 RESULT_SORT
FROM mvz.CF_USERS
WHERE username NOT IN (SELECT username FROM uam.cf_users);

SELECT COUNT(*) FROM mvz.CF_USERS;
select count(*) from uam.CF_USERS;

--CF_USER_DATA
DESC mvz.CF_USER_DATA;
DESC uam.CF_USER_DATA;
SELECT COUNT(*) FROM mvz.CF_USER_DATA;
select count(*) from uam.CF_USER_DATA;

INSERT INTO uam.CF_USER_DATA 
SELECT * FROM mvz.CF_USER_DATA
WHERE user_id NOT IN (
    SELECT user_id FROM mvz.cf_users
    WHERE username NOT IN (SELECT username FROM uam.cf_users)
);

SELECT COUNT(*) FROM mvz.CF_USER_DATA;
select count(*) from uam.CF_USER_DATA;

--CF_USER_LOG
DESC mvz.CF_USER_LOG;
DESC uam.CF_USER_LOG;
SELECT COUNT(*) FROM mvz.CF_USER_LOG;
select count(*) from uam.CF_USER_LOG;

INSERT INTO uam.CF_USER_LOG SELECT * FROM mvz.CF_USER_LOG;

SELECT COUNT(*) FROM mvz.CF_USER_LOG;
select count(*) from uam.CF_USER_LOG;

-- CF_COLLECTION
---- update MVZ's collection appearance
CREATE TABLE cf_collection AS SELECT 
    collection.collection_id cf_collection_id,
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
    ' ' HEADER_CREDIT
FROM
    cf_collection_appearance,
    collection
WHERE collection.collection_id=cf_collection_appearance.collection_id(+);

ALTER TABLE cf_collection MODIFY CF_COLLECTION_ID NUMBER;
ALTER TABLE cf_collection MODIFY COLLECTION_ID NULL;

CREATE SEQUENCE sq_cf_collection_id NOCACHE;

CREATE OR REPLACE TRIGGER TR_CFCOLLECTION_SQ
BEFORE INSERT ON cf_collection
FOR EACH ROW
BEGIN
    IF :NEW.cf_collection_id IS NULL THEN
        SELECT SQ_CF_COLLECTION_ID.nextval into :NEW.cf_collection_id from dual;
    END IF;
END;

ALTER TABLE cf_collection ADD portal_name VARCHAR2(30);
ALTER TABLE cf_collection ADD collection VARCHAR2(30);


CREATE OR REPLACE TRIGGER tr_cf_collection_sync                                       
BEFORE UPDATE OR INSERT OR DELETE ON collection  
FOR EACH ROW
DECLARE  c NUMBER;
begin
    IF inserting THEN
        INSERT INTO cf_collection (
            collection_id,
            dbusername,
            dbpwd)
        VALUES (
            :NEW.collection_id,
            'PUB_USR_' || upper(:NEW.institution_acronym) || '_' || upper(:NEW.collection_cde),
            'userpw.' || :NEW.collection_id);            
    ELSIF deleting THEN
        DELETE FROM cf_collection WHERE collection_id = :OLD.collection_id;
    ELSIF updating THEN
        IF (:NEW.collection_id != :OLD.collection_id) THEN
            UPDATE cf_collection SET 
                collection_id = :NEW.collection_id,
                cf_collection_id = :NEW.collection_id 
            WHERE collection_id=:OLD.collection_id;
        END IF;
        IF (:NEW.institution_acronym != :OLD.institution_acronym) OR 
            (:NEW.collection_cde != :OLD.collection_cde) OR 
            (:NEW.collection != :OLD.collection
        ) THEN
            UPDATE cf_collection SET 
                dbusername='PUB_USR_' || upper(:NEW.institution_acronym) || '_' || upper(:NEW.collection_cde),
                dbpwd='userpw.' || :NEW.collection_id,
                collection = :NEW.collection,
                portal_name=upper(:NEW.institution_acronym) || '_' || upper(:NEW.collection_cde)
            WHERE collection_id = :NEW.collection_id;
        END IF;
    END IF;
END;                                                                                            
/

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
    HEADER_CREDIT)
VALUES (
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

UPDATE cf_collection SET cf_collection_id = collection_id WHERE collection_id IS NOT NULL;



UPDATE cf_collection 
SET (portal_name, collection) = (
SELECT lower(institution_acronym) || '_' || lower(collection_cde), collection 
FROM collection
WHERE collection.collection_id = cf_collection.collection_id);

UPDATE cf_collection 
SET portal_name = 'all_all', collection = 'All Collections' 
WHERE cf_collection_id = 0;

ALTER TABLE cf_collection MODIFY portal_name NOT NULL;
ALTER TABLE cf_collection MODIFY collection NOT NULL;
    
--CF_COLLECTION
update cf_collection set
	HEADER_COLOR='white',
	HEADER_IMAGE='/images/MVZ_fancy_logo.jpg',
	COLLECTION_URL='http://mvz.berkeley.edu/',
	COLLECTION_LINK_TEXT='<br>Collections Database',
	INSTITUTION_URL='http://mvz.berkeley.edu/',
	INSTITUTION_LINK_TEXT='MUSEUM OF VERTEBRATE ZOOLOGY',
	META_DESCRIPTION='MVZ',
	META_KEYWORDS='MVZ',
	STYLESHEET='',
	header_credit=''
where upper(portal_name) LIKE 'MVZ%';

/* still need this?

INSERT INTO cf_collection (
        collection_id,
    	collection,
    	dbusername,
    	dbpwd,
    	portal_name ) (
    select
    	collection_id,
    	collection,
    	'PUB_USR_' || upper(institution_acronym) || '_' || upper(collection_cde),
    	'userpw.' || collection_id,
    	upper(institution_acronym) || '_' || upper(collection_cde)
    from collection
    where collection_id > 300000
    );
*/
    
--- and new VPD users for MVZ
INSERT INTO cf_collection (
    CF_COLLECTION_ID,
	COLLECTION_ID,
	DBUSERNAME,
	DBPWD,
	HEADER_COLOR,
	HEADER_IMAGE,
	COLLECTION_URL,
	COLLECTION_LINK_TEXT,
	INSTITUTION_URL,
	INSTITUTION_LINK_TEXT,
	META_DESCRIPTION,
	META_KEYWORDS,
	STYLESHEET,
	HEADER_CREDIT,
	PORTAL_NAME,
	COLLECTION)
VALUES (
    NULL,
    NULL,
    'PUB_USR_MVZ_ALL',
    'userpw.38',
    'white',
    '/images/MVZ_fancy_logo.jpg',
    'http://mvz.berkeley.edu/',
    '<br>Collections Database',
    'http://mvz.berkeley.edu/',
    'MUSEUM OF VERTEBRATE ZOOLOGY',
    'MVZ',
    'MVZ',
    NULL,
    NULL,
    'MVZ_ALL',
    'MVZ Collections');

--BULKLOADER

CREATE OR REPLACE TRIGGER bulk_no_null_loaded 
BEFORE UPDATE OR INSERT ON bulkloader
FOR EACH ROW
DECLARE
    hasrole NUMBER;
BEGIN
    IF :NEW.loaded IS NULL THEN
        select COUNT(*) INTO hasrole
		from sys.dba_role_privs
		where
		    upper(grantee) = SYS_CONTEXT ('USERENV','SESSION_USER') and 
		    upper(granted_role)='MANAGE_COLLECTION';
		IF hasrole=0 THEN
		    raise_application_error(-20001,'You do not have permission to set loaded to NULL.');
		END IF;
    END IF;
END;
/

alter table bulkloader modify RELATED_TO_NUM_TYPE varchar2(255);
alter table bulkloader_deletes modify RELATED_TO_NUM_TYPE varchar2(255);
alter table BULKLOADER_CLONE modify RELATED_TO_NUM_TYPE varchar2(255);
alter table BULKLOADER_STAGE modify RELATED_TO_NUM_TYPE varchar2(255);
alter table CF_TEMP_RELATIONS modify RELATED_TO_NUM_TYPE varchar2(255);
    
--make sure ctattribute_code_tables has no duplicates accross attribute_type.
-- DROP duplicate TABLE WITH bad name:
drop table ct_attribute_code_tables purge;
drop public synonym ct_attribute_code_tables;
--ADD PRIMARY KEY TO ctattribute_code_tables see line 178



-- BULKLOADER: fix ct values in bulkloader.
--select distinct ATTRIBUTE_1 from mvz.bulkloader where ATTRIBUTE_1 not in (select attribute_type from ctattribute_type);
--select distinct ATTRIBUTE_2 from mvz.bulkloader where ATTRIBUTE_2 not in (select attribute_type from ctattribute_type);
--select distinct ATTRIBUTE_3 from mvz.bulkloader where ATTRIBUTE_3 not in (select attribute_type from ctattribute_type);
--select distinct ATTRIBUTE_4 from mvz.bulkloader where ATTRIBUTE_4 not in (select attribute_type from ctattribute_type);
--select distinct ATTRIBUTE_5 from mvz.bulkloader where ATTRIBUTE_5 not in (select attribute_type from ctattribute_type);
--select distinct ATTRIBUTE_6 from mvz.bulkloader where ATTRIBUTE_6 not in (select attribute_type from ctattribute_type);
--select distinct ATTRIBUTE_7 from mvz.bulkloader where ATTRIBUTE_7 not in (select attribute_type from ctattribute_type);
--select distinct ATTRIBUTE_8 from mvz.bulkloader where ATTRIBUTE_8 not in (select attribute_type from ctattribute_type);
--select distinct ATTRIBUTE_9 from mvz.bulkloader where ATTRIBUTE_9 not in (select attribute_type from ctattribute_type);
--select distinct ATTRIBUTE_10 from mvz.bulkloader where ATTRIBUTE_10 not in (select attribute_type from ctattribute_type);
--select distinct COLL_OBJ_DISPOSITION from mvz.bulkloader where COLL_OBJ_DISPOSITION not in (select COLL_OBJ_DISPOSITION from ctCOLL_OBJ_DISP);
select distinct DATUM from mvz.bulkloader where DATUM not in (select DATUM from ctDATUM);
update mvz.bulkloader set datum = 'North American Datum 1927' where datum = 'NAD27';                  
update mvz.bulkloader set datum = 'North American Datum 1983' where datum = 'NAD83';
update mvz.bulkloader set datum = 'World Geodetic System 1984' where datum = 'WGS84';
update mvz.bulkloader set datum = 'unknown' where datum = 'not recorded';

select distinct GEOREFMETHOD from mvz.bulkloader where GEOREFMETHOD not in (select GEOREFMETHOD from CTGEOREFMETHOD);
update mvz.bulkloader set georefmethod = 'MaNIS georeferencing guidelines' where georefmethod = 'MaNIS Georeferencing Guidelines';

select distinct NATURE_OF_ID from mvz.bulkloader where NATURE_OF_ID not in (select nature_of_id from ctnature_of_id);
update mvz.bulkloader set nature_of_id = 'field' where nature_of_id = 'field ID';
update mvz.bulkloader set nature_of_id = 'geographic distribution'  where nature_of_id = 'ssp. based on geog.';

--select distinct ORIG_ELEV_UNITS from mvz.bulkloader where ORIG_ELEV_UNITS not in (select ORIG_ELEV_UNITS from CTORIG_ELEV_UNITS);
--select distinct ORIG_LAT_LONG_UNITS from mvz.bulkloader where ORIG_LAT_LONG_UNITS not in (select ORIG_LAT_LONG_UNITS from CTLAT_LONG_UNITS);
select distinct OTHER_ID_NUM_TYPE_1 from mvz.bulkloader where OTHER_ID_NUM_TYPE_1 not in (select OTHER_ID_TYPE from CTCOLL_OTHER_ID_TYPE);
update mvz.bulkloader set OTHER_ID_NUM_TYPE_1 = 'CAS: California Academy of Sciences, San Francisco' where OTHER_ID_NUM_TYPE_1 = 'California Academy of Sciences, San Francisco';

select distinct OTHER_ID_NUM_TYPE_2 from mvz.bulkloader where OTHER_ID_NUM_TYPE_2 not in (select OTHER_ID_TYPE from CTCOLL_OTHER_ID_TYPE);
update mvz.bulkloader set OTHER_ID_NUM_TYPE_2 = 'CAS: California Academy of Sciences, San Francisco' where OTHER_ID_NUM_TYPE_2 = 'California Academy of Sciences, San Francisco';

--select distinct OTHER_ID_NUM_TYPE_3 from mvz.bulkloader where OTHER_ID_NUM_TYPE_3 not in (select OTHER_ID_TYPE from CTCOLL_OTHER_ID_TYPE);
--select distinct OTHER_ID_NUM_TYPE_4 from mvz.bulkloader where OTHER_ID_NUM_TYPE_4 not in (select OTHER_ID_TYPE from CTCOLL_OTHER_ID_TYPE);
--select distinct OTHER_ID_NUM_TYPE_5 from mvz.bulkloader where OTHER_ID_NUM_TYPE_5 not in (select OTHER_ID_TYPE from CTCOLL_OTHER_ID_TYPE);

select distinct PART_DISPOSITION_1 from mvz.bulkloader where PART_DISPOSITION_1 not in (select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP);
UPDATE mvz.bulkloader SET PART_DISPOSITION_1 = 'transfer of custody' where PART_DISPOSITION_1 = 'elsewhere';
UPDATE mvz.bulkloader SET PART_DISPOSITION_1 = 'in collection' where PART_DISPOSITION_1 = 'archived';

select distinct PART_DISPOSITION_2 from mvz.bulkloader where PART_DISPOSITION_2 not in (select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP);
UPDATE mvz.bulkloader SET PART_DISPOSITION_2 = 'in collection' where PART_DISPOSITION_2 IN ('archived', 'partly in collection');
                                                                                           
select distinct PART_DISPOSITION_3 from mvz.bulkloader where PART_DISPOSITION_3 not in (select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP);
UPDATE mvz.bulkloader SET PART_DISPOSITION_3 = 'transfer of custody' where PART_DISPOSITION_3 = 'elsewhere';
UPDATE mvz.bulkloader SET PART_DISPOSITION_3 = 'in collection' where PART_DISPOSITION_3 IN ('archived', 'partly in collection');

select distinct PART_DISPOSITION_4 from mvz.bulkloader where PART_DISPOSITION_4 not in (select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP);
UPDATE mvz.bulkloader SET PART_DISPOSITION_4 = 'transfer of custody' where PART_DISPOSITION_4 = 'elsewhere';
UPDATE mvz.bulkloader SET PART_DISPOSITION_4 = 'in collection' where PART_DISPOSITION_4 IN ('archived', 'partly in collection');

select distinct PART_DISPOSITION_5 from mvz.bulkloader where PART_DISPOSITION_5 not in (select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP);
UPDATE mvz.bulkloader SET PART_DISPOSITION_5 = 'in collection' where PART_DISPOSITION_5 IN ('archived', 'partly in collection');

select distinct PART_DISPOSITION_6 from mvz.bulkloader where PART_DISPOSITION_6 not in (select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP);
UPDATE mvz.bulkloader SET PART_DISPOSITION_6 = 'in collection' where PART_DISPOSITION_6 IN ('archived', 'partly in collection');

select distinct PART_DISPOSITION_7 from mvz.bulkloader where PART_DISPOSITION_7 not in (select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP);
UPDATE mvz.bulkloader SET PART_DISPOSITION_7 = 'in collection' where PART_DISPOSITION_7 IN ('archived', 'partly in collection');

select distinct PART_DISPOSITION_8 from mvz.bulkloader where PART_DISPOSITION_8 not in (select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP);
UPDATE mvz.bulkloader SET PART_DISPOSITION_8 = 'in collection' where PART_DISPOSITION_8 IN ('archived', 'partly in collection');

select distinct PART_DISPOSITION_9 from mvz.bulkloader where PART_DISPOSITION_9 not in (select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP);
UPDATE mvz.bulkloader SET PART_DISPOSITION_9 = 'in collection' where PART_DISPOSITION_9 IN ('archived', 'partly in collection');

select distinct PART_DISPOSITION_10 from mvz.bulkloader where PART_DISPOSITION_10 not in (select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP);
UPDATE mvz.bulkloader SET PART_DISPOSITION_10 = 'in collection' where PART_DISPOSITION_10 IN ('archived', 'partly in collection');

select distinct PART_DISPOSITION_11 from mvz.bulkloader where PART_DISPOSITION_11 not in (select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP);
UPDATE mvz.bulkloader SET PART_DISPOSITION_11 = 'in collection' where PART_DISPOSITION_11 IN ('archived', 'partly in collection');

select distinct PART_DISPOSITION_12 from mvz.bulkloader where PART_DISPOSITION_12 not in (select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP);
UPDATE mvz.bulkloader SET PART_DISPOSITION_12 = 'in collection' where PART_DISPOSITION_12 in ('archived', 'partly in collection');

--select distinct PART_MODIFIER_1 from mvz.bulkloader where PART_MODIFIER_1 not in (select PART_MODIFIER from CTSPECIMEN_PART_MODIFIER);
--select distinct PART_MODIFIER_2 from mvz.bulkloader where PART_MODIFIER_2 not in (select PART_MODIFIER from CTSPECIMEN_PART_MODIFIER);
--select distinct PART_MODIFIER_3 from mvz.bulkloader where PART_MODIFIER_3 not in (select PART_MODIFIER from CTSPECIMEN_PART_MODIFIER);
--select distinct PART_MODIFIER_4 from mvz.bulkloader where PART_MODIFIER_4 not in (select PART_MODIFIER from CTSPECIMEN_PART_MODIFIER);

select distinct collection_cde || PART_NAME_1 from mvz.bulkloader where collection_cde || PART_NAME_1 not in (select collection_cde || PART_NAME from CTSPECIMEN_PART_NAME) and PART_NAME_1 is not null;
update uam.bulkloader set PART_NAME_1 = 'photographe' where PART_NAME_1 = 'photo';

--select distinct collection_cde || PART_NAME_2 from mvz.bulkloader where collection_cde || PART_NAME_2 not in (select collection_cde || PART_NAME from CTSPECIMEN_PART_NAME) and PART_NAME_2 is not null;
--select distinct collection_cde || PART_NAME_3 from mvz.bulkloader where collection_cde || PART_NAME_3 not in (select collection_cde || PART_NAME from CTSPECIMEN_PART_NAME) and PART_NAME_2 is not null;
--select distinct collection_cde || PART_NAME_4 from mvz.bulkloader where collection_cde || PART_NAME_4 not in (select collection_cde || PART_NAME from CTSPECIMEN_PART_NAME) and PART_NAME_4 is not null;
--select distinct collection_cde || PART_NAME_5 from mvz.bulkloader where collection_cde || PART_NAME_5 not in (select collection_cde || PART_NAME from CTSPECIMEN_PART_NAME) and PART_NAME_5 is not null;

--select distinct collection_cde || PART_NAME_6 from mvz.bulkloader where collection_cde || PART_NAME_6 not in (select collection_cde || PART_NAME from CTSPECIMEN_PART_NAME) and PART_NAME_6 is not null;
--select distinct collection_cde || PART_NAME_7 from mvz.bulkloader where collection_cde || PART_NAME_7 not in (select collection_cde || PART_NAME from CTSPECIMEN_PART_NAME) and PART_NAME_7 is not null;
--select distinct collection_cde || PART_NAME_8 from mvz.bulkloader where collection_cde || PART_NAME_8 not in (select collection_cde || PART_NAME from CTSPECIMEN_PART_NAME) and PART_NAME_8 is not null;
--select distinct collection_cde || PART_NAME_9 from mvz.bulkloader where collection_cde || PART_NAME_9 not in (select collection_cde || PART_NAME from CTSPECIMEN_PART_NAME) and PART_NAME_9 is not null;
--select distinct collection_cde || PART_NAME_10 from mvz.bulkloader where collection_cde || PART_NAME_10 not in (select collection_cde || PART_NAME from CTSPECIMEN_PART_NAME) and PART_NAME_10 is not null;

--select distinct collection_cde || PRESERV_METHOD_1 from mvz.bulkloader where collection_cde || PRESERV_METHOD_1 not in (select collection_cde || PRESERVE_METHOD from CTSPECIMEN_PRESERV_METHOD) and PRESERV_METHOD_1 is not null;
--select distinct collection_cde || PRESERV_METHOD_2 from mvz.bulkloader where collection_cde || PRESERV_METHOD_2 not in (select collection_cde || PRESERVE_METHOD from CTSPECIMEN_PRESERV_METHOD) and PRESERV_METHOD_2 is not null;
--select distinct collection_cde || PRESERV_METHOD_3 from mvz.bulkloader where collection_cde || PRESERV_METHOD_3 not in (select collection_cde || PRESERVE_METHOD from CTSPECIMEN_PRESERV_METHOD) and PRESERV_METHOD_3 is not null;
--select distinct collection_cde || PRESERV_METHOD_4 from mvz.bulkloader where collection_cde || PRESERV_METHOD_4 not in (select collection_cde || PRESERVE_METHOD from CTSPECIMEN_PRESERV_METHOD) and PRESERV_METHOD_4 is not null;
--select distinct collection_cde || PRESERV_METHOD_5 from mvz.bulkloader where collection_cde || PRESERV_METHOD_5 not in (select collection_cde || PRESERVE_METHOD from CTSPECIMEN_PRESERV_METHOD) and PRESERV_METHOD_5 is not null;
--select distinct collection_cde || PRESERV_METHOD_6 from mvz.bulkloader where collection_cde || PRESERV_METHOD_6 not in (select collection_cde || PRESERVE_METHOD from CTSPECIMEN_PRESERV_METHOD) and PRESERV_METHOD_6 is not null;
--select distinct collection_cde || PRESERV_METHOD_7 from mvz.bulkloader where collection_cde || PRESERV_METHOD_7 not in (select collection_cde || PRESERVE_METHOD from CTSPECIMEN_PRESERV_METHOD) and PRESERV_METHOD_7 is not null;
--select distinct collection_cde || PRESERV_METHOD_8 from mvz.bulkloader where collection_cde || PRESERV_METHOD_8 not in (select collection_cde || PRESERVE_METHOD from CTSPECIMEN_PRESERV_METHOD) and PRESERV_METHOD_8 is not null;
--select distinct collection_cde || PRESERV_METHOD_9 from mvz.bulkloader where collection_cde || PRESERV_METHOD_9 not in (select collection_cde || PRESERVE_METHOD from CTSPECIMEN_PRESERV_METHOD) and PRESERV_METHOD_9 is not null;
--select distinct collection_cde || PRESERV_METHOD_10 from mvz.bulkloader where collection_cde || PRESERV_METHOD_10 not in (select collection_cde || PRESERVE_METHOD from CTSPECIMEN_PRESERV_METHOD) and PRESERV_METHOD_10 is not null;

--select distinct RELATED_TO_NUM_TYPE from mvz.bulkloader where RELATED_TO_NUM_TYPE not in (select OTHER_ID_TYPE from CTCOLL_OTHER_ID_TYPE);
--select distinct RELATIONSHIP from mvz.bulkloader where RELATIONSHIP not in (select BIOL_INDIV_RELATIONSHIP from CTBIOL_RELATIONS);
--select distinct VERIFICATIONSTATUS from mvz.bulkloader where VERIFICATIONSTATUS not in (select VERIFICATIONSTATUS from CTVERIFICATIONSTATUS);
 
update mvz.bulkloader set 
    collection_object_id = collection_object_id + 10000000, 
    locality_id = locality_id + 10000000;
    
ALTER TABLE mvz.bulkloader DROP COLUMN vessel;
ALTER TABLE mvz.bulkloader DROP COLUMN station_name;
ALTER TABLE mvz.bulkloader DROP COLUMN station_number;

insert into uam.bulkloader select * from mvz.bulkloader;

update mvz.bulkloader_attempts set 
    B_COLLECTION_OBJECT_ID = B_COLLECTION_OBJECT_ID + 10000000, 
    COLLECTION_OBJECT_ID = COLLECTION_OBJECT_ID + 10000000;
    
insert into uam.bulkloader_attempts select * from mvz.bulkloader_attempts;

update mvz.bulkloader_deletes set 
    collection_object_id = collection_object_id + 10000000, 
    locality_id = locality_id + 10000000;

ALTER TABLE mvz.bulkloader_deletes DROP COLUMN vessel;
ALTER TABLE mvz.bulkloader_deletes DROP COLUMN station_name;
ALTER TABLE mvz.bulkloader_deletes DROP COLUMN station_number;

insert into uam.bulkloader_deletes select * from mvz.bulkloader_deletes;
    
--!!! make sure TO REBUILD bulk_pkg AND sequences.

DROP SEQUENCE SQ_ADDR_ID;
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
			'ADDR',
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

SELECT MAX(ADDR_ID) FROM ATTRIBUTES;
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


-- This code below is to fix issue with bulkoader unable to delete coll_object.

--alter table COLL_OBJECT_REMARK
--   add constraint FK_COLLOBJREM_COLLOBJ_COID foreign key (COLLECTION_OBJECT_ID)
--      references COLL_OBJECT (COLLECTION_OBJECT_ID);

alter table COLL_OBJECT_REMARK
   DROP constraint FK_COLLOBJREM_COLLOBJ_COID;

alter table COLL_OBJECT_REMARK
   add constraint FK_COLLOBJREM_COLLOBJECT foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID)
      ON DELETE CASCADE;
      
--alter table OBJECT_CONDITION
--   add constraint FK_OBJECTCONDITION_COLLOBJECT foreign key (COLLECTION_OBJECT_ID)
--      references COLL_OBJECT (COLLECTION_OBJECT_ID);

alter table OBJECT_CONDITION
   DROP constraint FK_OBJECTCONDITION_COLLOBJECT;
      
alter table OBJECT_CONDITION
   add constraint FK_OBJECTCONDITION_COLLOBJECT foreign key (COLLECTION_OBJECT_ID)
      references COLL_OBJECT (COLLECTION_OBJECT_ID)
      ON DELETE CASCADE;

--alter table COLL_OBJ_CONT_HIST
--   add constraint FK_COLLOBJCONTHIST_COLLOBJ foreign key (COLLECTION_OBJECT_ID)
--      references COLL_OBJECT (COLLECTION_OBJECT_ID);
ALTER TABLE coll_obj_cont_hist
    DROP CONSTRAINT FK_COLLOBJCONTHIST_COLLOBJ
      
alter table COLL_OBJ_CONT_HIST
   add constraint FK_COLLOBJCONTHIST_SPECPART foreign key (COLLECTION_OBJECT_ID)
      references SPECIMEN_PART (COLLECTION_OBJECT_ID)
      ON DELETE CASCADE;
      
/* this trigger is no longer needed because of foreign keys.
CREATE OR REPLACE TRIGGER "UAM"."TI_COLL_OBJ_CONT_HIST" after INSERT on Coll_Obj_Cont_Hist for each row
-- ERwin Builtin Wed May 05 11:26:47 2004
-- INSERT trigger on Coll_Obj_Cont_Hist
declare numrows INTEGER;
begin
    select count(*) into numrows
      from Coll_Object
      where
        :new.Collection_Object_id = Coll_Object.Collection_Object_id;
    if ( numrows = 0 )
    then
      raise_application_error(
        -20002,
        'Cannot INSERT "Coll_Obj_Cont_Hist" because "Coll_Object" does not exist.'
      );
    end if;
    select count(*) into numrows
      from Container
      where :new.Container_id = Container.Container_id;
    if ( numrows = 0 )
    then
      raise_application_error(
        -20002,
        'Cannot INSERT "Coll_Obj_Cont_Hist" because "Container" does not exist.'
      );
    end if;
-- ERwin Builtin Wed May 05 11:26:47 2004
end;
*/

DROP TRIGGER TI_COLL_OBJ_CONT_HIST;

CREATE OR REPLACE TRIGGER tr_collobjconthist_ad
AFTER DELETE ON coll_obj_cont_hist
FOR EACH ROW
BEGIN
    DELETE FROM container WHERE container_id = :OLD.container_id;
END;
/

ALTER TABLE container_history
DROP CONSTRAINT FK_CONTAINERHIST_CONTAINER;

ALTER TABLE container_history
ADD CONSTRAINT FK_CONTAINERHIST_CONTAINER
FOREIGN KEY (container_id)
REFERENCES container (container_id)
ON DELETE CASCADE;

CREATE OR REPLACE TRIGGER tr_specimenpart_ad
AFTER DELETE ON specimen_part
FOR EACH ROW
DECLARE 
BEGIN
    DELETE FROM coll_object WHERE collection_object_id = :OLD.collection_object_id;
END;
/

--END bulkloader fix FOR deleting coll_object.

--SEQUENCES
--SQ_COLLECTION_ID
DECLARE n NUMBER;
BEGIN
    SELECT MAX(collection_id) + 1 INTO n FROM collection;
    EXECUTE IMMEDIATE 'CREATE SEQUENCE sq_collection_id nocache START WITH ' || n;
    EXECUTE IMMEDIATE 'create public synonym sq_collection_id for sq_collection_id';
    EXECUTE IMMEDIATE 'grant select on sq_collection_id to public';
END;
/
-- CHECK FOR sequences IN TRIGGERs.
somerandomsequence
    CF_TEMP_PART_SAMPLE            CF_TEMP_PART_SAMPLE_KEY        ENABLED
select max(I$KEY) from CF_TEMP_PART_SAMPLE;
    CF_REPORT_SQL                  CF_REPORT_SQL_KEY              ENABLED
select max(report_id) from CF_REPORT_SQL;
    CF_TEMP_ID                     CF_TEMP_ID_KEY                 ENABLED
select max(key) from CF_TEMP_ID;
    CF_TEMP_PARTS                  CF_TEMP_PARTS_KEY              ENABLED
select max(key) from CF_TEMP_PARTS;
    CF_COLLECTION                  CF_CF_COLLECTION_KEY           ENABLED
select max(cf_collection_id) from CF_COLLECTION;
    CF_LOG                         CF_LOG_ID                      ENABLED
select max(log_id) from CF_LOG;
    CF_CANNED_SEARCH               CF_CANNED_SEARCH_TRG           ENABLED
select max(canned_id) from CF_CANNED_SEARCH;
    CFRELEASE_NOTES                CFRELEASE_NOTES_ID             ENABLED
select max(release_note_id) from CFRELEASE_NOTES;
--    CONTAINER_CHECK                CONTAINER_CHECK_ID             ENABLED
select max(container_check_id) from CONTAINER_CHECK;
create sequence sq_container_check_id start with 1371645 increment by 1 nocache;
CREATE OR REPLACE TRIGGER CONTAINER_CHECK_ID
before insert ON container_check
for each row
begin
    if :NEW.container_check_id is null then
        select sq_container_check_id.nextval
        into :new.container_check_id from dual;
    end if;
    if :NEW.check_date is null then
        :NEW.check_date:= sysdate;
    end if;
end;
/
    CF_TEMP_TAXONOMY               CF_TEMP_TAXONOMY_KEY           ENABLED
select max(key) from CF_TEMP_TAXONOMY;
    CF_TEMP_OIDS                   CF_TEMP_OIDS_KEY               ENABLED
select max(key) from CF_TEMP_OIDS;
    CF_TEMP_LOAN_ITEM              CF_TEMP_LOAN_ITEM_KEY          ENABLED
select max(key) from CF_TEMP_LOAN_ITEM;
    CF_TEMP_CITATION               CF_TEMP_CITATION_KEY           ENABLED
select max(key) from CF_TEMP_CITATION;
    CF_TEMP_AGENTS                 CF_TEMP_AGENTS_KEY             ENABLED
select max(key) from CF_TEMP_AGENTS;
    CF_TEMP_ATTRIBUTES             CF_TEMP_ATTRIBUTES_KEY         ENABLED
select max(key) from CF_TEMP_ATTRIBUTES;

    GEOLOGY_ATTRIBUTE_HIERARCHY    GEOL_ATT_HIERARCHY_SEQ         ENABLED
select max(geology_attribute_hierarchy_id) from GEOLOGY_ATTRIBUTE_HIERARCHY;
create sequence sq_geology_attribute_hier_id nocache START WITH 5339828;

CREATE OR REPLACE TRIGGER GEOL_ATT_HIERARCHY_SEQ
before insert ON geology_attribute_hierarchy 
for each row
begin
    IF :new.geology_attribute_hierarchy_id IS NULL THEN
        select sq_geology_attribute_hier_id.nextval 
        into :new.geology_attribute_hierarchy_id
        from dual;
    END IF; 
end;
/

    CF_SPEC_RES_COLS               TRG_CF_SPEC_RES_COLS_ID        ENABLED
select max(cf_spec_res_cols_id) from CF_SPEC_RES_COLS;
-- end of somerandomsequence.    
    
--ala_plant_imaging_seq
    ALA_PLANT_IMAGING              ALA_PLANT_IMAGING_KEY          ENABLED
select max(image_id) from ALA_PLANT_IMAGING;

drop sequence ala_plant_imaging_seq;

create sequence sq_ala_image_id nocache start with 140821;

DROP TRIGGER ALA_PLANT_IMAGING_KEY

CREATE OR REPLACE TRIGGER TR_ALA_PLANT_IMAGING_SQ
before insert ON ala_plant_imaging
for each row
begin
    if :new.image_id is null then
        select sq_ala_image_id.nextval
        into :new.image_id from dual;
    end if;
end;    
/

--sq_coll_obj_other_id_num_id
    COLL_OBJ_OTHER_ID_NUM          TR_COLL_OBJ_OTHER_ID_NUM_SQ    ENABLED
select max(coll_obj_other_id_num_id) from COLL_OBJ_OTHER_ID_NUM;
select SQ_coll_obj_other_id_num_id.nextval from dual;

CREATE OR REPLACE TRIGGER COLL_OBJ_DISP_VAL
BEFORE INSERT or UPDATE ON coll_obj_other_id_num
FOR EACH ROW
BEGIN
    :NEW.display_value := :NEW.OTHER_ID_PREFIX || :NEW.OTHER_ID_NUMBER || :NEW.OTHER_ID_SUFFIX;
END;
/

CREATE OR REPLACE TRIGGER TR_coll_obj_other_id_num_SQ
BEFORE INSERT ON coll_obj_other_id_num
FOR EACH ROW
BEGIN
    IF :NEW.COLL_OBJ_OTHER_ID_NUM_ID IS NULL THEN 
        select SQ_coll_obj_other_id_num_id.nextval 
        into :NEW.COLL_OBJ_OTHER_ID_NUM_ID
        FROM dual;
    END IF;
END;

    
--seq_media_relations
-- need to create a separate trigger.
    MEDIA_RELATIONS                MEDIA_RELATIONS_SEQ            ENABLED
select max(media_relations_id) from MEDIA_RELATIONS;

--specimen_annotations_seq
    SPECIMEN_ANNOTATIONS           SPECIMEN_ANNOTATIONS_KEY       ENABLED
select max(annotation_id) from SPECIMEN_ANNOTATIONS;
    
--seq_media_labels
-- need to create a separate trigger.
    MEDIA_LABELS                   MEDIA_LABELS_SEQ               ENABLED
select max(media_label_id) from MEDIA_LABELS;
    
--project_sponsor_seq
    PROJECT_SPONSOR                TRIG_PROJECT_SPONSOR_ID        ENABLED
select max(project_sponsor_id) from PROJECT_SPONSOR;
    
--objcondid
-- need to create a separate trigger for this.
    COLL_OBJECT                    TRG_OBJECT_CONDITION           ENABLED
select max(OBJECT_CONDITION_ID) from OBJECT_CONDITION;
    
--junk
--cf_version_seq
    CF_VERSION                     CF_VERSION_PKEY_TRG            ENABLED
select max(version_id) from CF_VERSION;
DROP TABLE CF_VERSION;
DROP TRIGGER CF_VERSION_PKEY_TRG;
DROP SEQUENCE cf_version_seq;

-- junk
--cf_version_log_seq
    CF_VERSION_LOG                 CF_VERSION_LOG_PKEY_TRG        ENABLED
DROP TABLE CF_VERSION_log;
DROP TRIGGER CF_VERSION_LOG_PKEY_TRG;
DROP SEQUENCE cf_version_log_seq;
    
--identification_agent_seq
    IDENTIFICATION_AGENT           IDENTIFICATION_AGENT_TRG       ENABLED
select max(identification_agent_id) from IDENTIFICATION_AGENT;
    
--seq_geology_attributes
    GEOLOGY_ATTRIBUTES             GEOLOGY_ATTRIBUTES_SEQ         ENABLED
select max(geology_attribute_id) from GEOLOGY_ATTRIBUTES;
    
--seq_media
    MEDIA                          MEDIA_SEQ                      ENABLED
select max(media_id) from MEDIA;
    

-- 7) create pub roles and users.
run vpd_users_roles.sql

-- 8) CREATE PACKAGE app_security_context AS sys
run vpd_security_fnc.sql

-- 9) CHECK PUBLIC synonyms:
select table_name from user_tables where table_name not in (
select table_name from dba_synonyms where owner = 'PUBLIC' and table_owner = 'UAM')
order by table_name

uam@arctos> create public synonym TAB_MEDIA_REL_FKEY for TAB_MEDIA_REL_FKEY;
uam@arctos> create public synonym VPD_COLLECTION_LOCALITY for VPD_COLLECTION_LOCALITY;

select count(*), object_type from user_objects where object_name not in (
select table_name from dba_synonyms where owner = 'PUBLIC' and table_owner = 'UAM')
group by object_type
order by object_type

select object_type || chr(9) || object_name from user_objects where object_name not in (
select table_name from dba_synonyms where owner = 'PUBLIC' and table_owner = 'UAM')
AND object_type IN ('FUNCTION', 'PACKAGE', 'PACKAGE BODY', 'PROCEDURE', 'SEQUENCE', 'TABLE', 'VIEW')
order by object_type, object_name

create public synonym GET_MEDIA_RELATIONS_STRING for GET_MEDIA_RELATIONS_STRING;
grant EXECUTE ON GET_MEDIA_RELATIONS_STRING TO PUBLIC;

create public synonym SQ_ALA_IMAGE_ID for SQ_ALA_IMAGE_ID;
GRANT SELECT ON SQ_ALA_IMAGE_ID TO PUBLIC;

create public synonym SQ_CF_COLLECTION_ID for SQ_CF_COLLECTION_ID;
GRANT SELECT ON SQ_CF_COLLECTION_ID TO PUBLIC;

create public synonym SQ_COLL_OBJ_OTHER_ID_NUM_ID for SQ_COLL_OBJ_OTHER_ID_NUM_ID;
GRANT SELECT ON SQ_COLL_OBJ_OTHER_ID_NUM_ID TO PUBLIC;

create public synonym SQ_CONTAINER_CHECK_ID for SQ_CONTAINER_CHECK_ID;
GRANT SELECT ON SQ_CONTAINER_CHECK_ID TO PUBLIC;

create public synonym SQ_GEOLOGY_ATTRIBUTE_HIER_ID for SQ_GEOLOGY_ATTRIBUTE_HIER_ID;
GRANT SELECT ON SQ_GEOLOGY_ATTRIBUTE_HIER_ID TO PUBLIC;


--10) BUILD COLLECTION CODE TABLES.

--11) MISCELLANEOUS CHANGES
--DLM done: alter table ctcoll_other_id_type add base_url varchar2(4000);

CREATE OR REPLACE TRIGGER CF_REPORT_SQL_KEY
before insert ON cf_report_sql
for each row
begin
    if :NEW.report_id is null then
        select SQ_REPORT_ID.nextval into :new.report_id from dual;
    end if;
end;

alter trigger CF_REPORT_SQL_KEY rename to TR_CF_REPORT_SQL_BI;

alter table cf_users add locsrchprefs varchar2(4000);

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

-- not needed; primary key index created on table.
--CREATE UNIQUE INDEX ix_ctother_id_type ON ctcoll_other_id_type(other_id_type) TABLESPACE uam_idx_1;
ALTER TABLE cf_collection_appearance ADD header_credit VARCHAR2(255);

ALTER TABLE cataloged_item
ADD CONSTRAINT fk_catitem_accn
FOREIGN KEY (accn_id)
REFERENCES accn(transaction_id);
  
ALTER TABLE accn 
ADD constraint pk_accn 
PRIMARY KEY (transaction_id)
USING INDEX TABLESPACE uam_idx_1; 

ALTER TABLE coll_object_remark
ADD CONSTRAINT fk_collobjectrem_collobj
FOREIGN KEY (collection_object_id)
REFERENCES coll_object(collection_object_id);
  
ALTER TABLE identification
ADD CONSTRAINT fk_identification_catitem
FOREIGN KEY (collection_object_id)
REFERENCES cataloged_item(collection_object_id);
      
drop trigger COLL_OBJ_DISP_VAL_TEST;

--- rebuild the check trigger
CREATE OR REPLACE TRIGGER OTHER_ID_CT_CHECK BEFORE
INSERT
OR UPDATE ON COLL_OBJ_OTHER_ID_NUM
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
declare
    numrows number;
    collectionCode varchar2(20);
BEGIN
    execute immediate 'SELECT COUNT(*)
        FROM ctcoll_other_id_type
        WHERE other_id_type = ''' || :NEW.other_id_type || '''' 
        INTO numrows ;
        
    IF (numrows = 0) THEN
        raise_application_error(
            -20001, 'Invalid other ID type');
    END IF;
END;
/

DROP TRIGGER TI_COLL_OBJ_OTHER_ID_NUM;
DROP TRIGGER TU_COLL_OBJ_OTHER_ID_NUM;

-- REPLACE make_part_coll_obj_cont WITH make_part_coll_obj_cont.vpd.sql

-- these indices seem to have a pretty substantial impact
create index ix_identification_sciname_u 
    on identification (upper(scientific_name)) 
    tablespace uam_idx_1;
    
ANALYZE TABLE identification COMPUTE STATISTICS;
    
create index ix_taxonomy_sciname_u on 
    taxonomy (upper(scientific_name)) 
    tablespace uam_idx_1;
    
ANALYZE TABLE taxonomy COMPUTE STATISTICS;

create index ix_comname_comname_u 
    on common_name (upper(common_name)) 
    tablespace uam_idx_1;
    
ANALYZE TABLE common_name COMPUTE STATISTICS;

-- !!! make sure TO CHECK ON version OF verify_function function. 
-- OLD version ON test did NOT have period IN LIST OF allowable characers.


CREATE OR REPLACE function concatGeologyAttribute(colobjid in number )
return varchar2
as
    type rc is ref cursor;
    l_str    varchar2(4000);
    l_sep    varchar2(30);
    l_val    varchar2(4000);
/*
	returns a semicolon-separated list of geology attribute determinations
*/
BEGIN
    FOR r IN (
        SELECT geology_attribute || '=' || geo_att_value oneAtt
        FROM 
            geology_attributes,
            locality,
            collecting_event,
            cataloged_item
        WHERE geology_attributes.locality_id=locality.locality_id 
        AND locality.locality_id=collecting_event.locality_id 
        AND collecting_event.collecting_event_id=cataloged_item.collecting_event_id 
        AND cataloged_item.collection_object_id=colobjid
    ) LOOP
        l_str := l_str || l_sep || r.oneAtt;
        l_sep := '; ';
    END LOOP;
    RETURN l_str;
END;
/

CREATE PUBLIC SYNONYM concatGeologyAttribute FOR concatGeologyAttribute;
GRANT EXECUTE ON concatGeologyAttribute TO PUBLIC;

UPDATE cf_spec_res_cols 
SET DISP_ORDER = DISP_ORDER + 1 
WHERE DISP_ORDER > 37;

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

-- 2/6/09 UPDATE FUNCTION CONCATSINGLEOTHERIDINT; old version used display val instead of other_id_number
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
        SELECT other_id_number INTO oidnum
        FROM coll_obj_other_id_num
        WHERE other_id_type = p_other_col_name
        AND collection_object_id = p_key_val;
ELSE
oidnum := NULL;
END IF;
    RETURN oidnum;
END;

create public synonym ConcatSingleOtherIdInt for ConcatSingleOtherIdInt;
grant execute on ConcatSingleOtherIdInt to public;