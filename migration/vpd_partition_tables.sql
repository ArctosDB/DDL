-- CATALOGED_ITEM
CREATE TABLE CATALOGED_ITEM_PART (
    COLLECTION_OBJECT_ID NUMBER NOT NULL,
	CAT_NUM NUMBER NOT NULL,
	ACCN_ID NUMBER NOT NULL,
	COLLECTING_EVENT_ID NUMBER NOT NULL,
	COLLECTION_CDE CHAR(4) NOT NULL,
	CATALOGED_ITEM_TYPE CHAR(2) NOT NULL,
	COLLECTION_ID NUMBER NOT NULL)
  TABLESPACE UAM_DAT_1
  PARTITION BY LIST (collection_id) ( 
    partition UAM_Mamm values (1),
	partition UAM_Bird values (2),
	partition UAM_Herp values (3),
	partition UAM_Ento values (4),
	partition UAM_Herb values (6),
	partition NBSB_Bird values (7),
	partition UAM_Bryo values (8),
	partition UAM_Crus values (9),
	partition UAM_Fish values (10),
	partition UAM_Moll values (11),
	partition KWP_Ento values (12),
	partition UAMObs_Mamm values (13),
	partition MSB_Mamm values (14),
	partition DGR_Ento values (15),
	partition DGR_Bird values (16),
	partition DGR_Mamm values (17),
	partition DGR_Herp values (18),
	partition DGR_Fish values (19),
	partition MSB_Bird values (20),
	partition UAM_ES values (21),
	partition WNMU_Bird values (22),
	partition WNMU_Fish values (23),
	partition WNMU_Mamm values (24),
	partition PSU_Mamm values (25),
	partition CRCM_Bird values (26),
	partition GOD_Herb values (27),
	partition MVZ_Mamm values (28),
	partition MVZ_Bird values (29),
	partition MVZ_Herp values (30),
	partition MVZ_Egg values (31),
	partition MVZ_Hild values (32),
	partition MVZ_Img values (33),
	partition MVZ_Page values (34),
	partition MVZObs_Bird values (35),
	partition MVZObs_Herp values (36),
	partition MVZObs_Mamm values (37));
	
/*
select dbms_metadata.get_ddl('TABLE', 'CATALOGED_ITEM') from dual;

CREATE TABLE CATALOGED_ITEM (
	COLLECTION_OBJECT_ID NUMBER NOT NULL,
    CAT_NUM NUMBER NOT NULL,
	ACCN_ID NUMBER NOT NULL,
	COLLECTING_EVENT_ID NUMBER NOT NULL,
	COLLECTION_CDE CHAR(4) NOT NULL,
	CATALOGED_ITEM_TYPE CHAR(2) NOT NULL,
	COLLECTION_ID NUMBER NOT NULL,
	CONSTRAINT PK_CATALOGED_ITEM PRIMARY KEY (COLLECTION_OBJECT_ID)
		USING INDEX TABLESPACE UAM_IDX_1,
	CONSTRAINT POS_CAT_NUM CHECK (cat_num > 0),
	CONSTRAINT FK_CATITEM_COLLECTION FOREIGN KEY (COLLECTION_ID)
		REFERENCES COLLECTION (COLLECTION_ID),
	CONSTRAINT FK_CATITEM_COLLEVENT FOREIGN KEY (COLLECTING_EVENT_ID)
		REFERENCES COLLECTING_EVENT (COLLECTING_EVENT_ID),
 	CONSTRAINT FK_CATITEM_COLLOBJECT FOREIGN KEY (COLLECTION_OBJECT_ID)
		REFERENCES COLL_OBJECT (COLLECTION_OBJECT_ID),
	CONSTRAINT FK_CATITEM_TRANS FOREIGN KEY (ACCN_ID)
		REFERENCES ACCN (TRANSACTION_ID)
) TABLESPACE UAM_DAT_1;

select 
	'alter table ' || table_name || ' add constraint ' || constraint_name 
	|| chr(10) || chr(9) ||
	'foreign key (' || column_name || ')' 
	|| chr(10) || chr(9) ||
	'references CATALOGED_ITEM (COLLECTION_OBJECT_ID);'
from user_cons_columns
where constraint_name in (
	select constraint_name from user_constraints
	where r_constraint_name = 'PK_CATALOGED_ITEM')
order by table_name, column_name;

alter table ATTRIBUTES add constraint FK_ATTRIBUTES_CATITEM
        foreign key (COLLECTION_OBJECT_ID)
        references CATALOGED_ITEM (COLLECTION_OBJECT_ID);
alter table BIOL_INDIV_RELATIONS add constraint FK_BIOLINDIVRELN_CATITEM_COID
        foreign key (COLLECTION_OBJECT_ID)
        references CATALOGED_ITEM (COLLECTION_OBJECT_ID);
alter table BIOL_INDIV_RELATIONS add constraint FK_BIOLINDIVRELN_CATITEM_RCOID
        foreign key (RELATED_COLL_OBJECT_ID)
        references CATALOGED_ITEM (COLLECTION_OBJECT_ID);
alter table CITATION add constraint FK_CITATION_CATITEM
        foreign key (COLLECTION_OBJECT_ID)
        references CATALOGED_ITEM (COLLECTION_OBJECT_ID);
alter table COLLECTOR add constraint FK_COLLECTOR_CATITEM
        foreign key (COLLECTION_OBJECT_ID)
        references CATALOGED_ITEM (COLLECTION_OBJECT_ID);
alter table COLL_OBJ_OTHER_ID_NUM add constraint FK_COLLOBJOTHERIDNUM_CATITEM
        foreign key (COLLECTION_OBJECT_ID)
        references CATALOGED_ITEM (COLLECTION_OBJECT_ID);
alter table IDENTIFICATION add constraint FK_IDENTIFICATION_CATITEM
        foreign key (COLLECTION_OBJECT_ID)
        references CATALOGED_ITEM (COLLECTION_OBJECT_ID);
alter table SPECIMEN_ANNOTATIONS add constraint FK_SPECIMENANNO_CATITEM
        foreign key (COLLECTION_OBJECT_ID)
        references CATALOGED_ITEM (COLLECTION_OBJECT_ID);
alter table SPECIMEN_PART add constraint FK_SPECIMENPART_CATITEM
        foreign key (DERIVED_FROM_CAT_ITEM)
        references CATALOGED_ITEM (COLLECTION_OBJECT_ID);
alter table TAB_MEDIA_REL_FKEY add constraint FK_TABMEDIARELFKEY_CATITEM
        foreign key (CFK_CATALOGED_ITEM)
        references CATALOGED_ITEM (COLLECTION_OBJECT_ID);

select dbms_metadata.get_ddl('INDEX', index_name)
from user_indexes where table_name = 'CATALOGED_ITEM';

CREATE INDEX XIF12CATALOGED_ITEM ON CATALOGED_ITEM (COLLECTING_EVENT_ID)
	TABLESPACE UAM_IDX_1;
CREATE INDEX XIF13CATALOGED_ITEM ON CATALOGED_ITEM (COLLECTION_CDE)
	TABLESPACE UAM_IDX_1;
CREATE UNIQUE INDEX PKEY_CATALOGED_ITEM ON CATALOGED_ITEM (COLLECTION_OBJECT_ID)
	TABLESPACE UAM_IDX_1;
CREATE INDEX XIF6CATALOGED_ITEM ON CATALOGED_ITEM (ACCN_ID)
	TABLESPACE UAM_IDX_1;
CREATE UNIQUE INDEX XAK1CATALOGED_ITEM ON CATALOGED_ITEM (CAT_NUM, COLLECTION_ID)
	TABLESPACE UAM_IDX_1;

select dbms_metadata.get_ddl('TRIGGER', trigger_name)
from user_triggers where table_name = 'CATALOGED_ITEM';

CREATE OR REPLACE TRIGGER TU_FLAT_CATITEM
AFTER UPDATE ON cataloged_item
FOR EACH ROW
BEGIN
	UPDATE flat
	SET stale_flag = 1
	WHERE collection_object_id = :NEW.collection_object_id;
END;

CREATE OR REPLACE TRIGGER AD_FLAT_CATITEM
AFTER DELETE ON cataloged_item
FOR EACH ROW
BEGIN
	DELETE FROM flat
	WHERE collection_object_id = :OLD.collection_object_id;
END;

CREATE OR REPLACE TRIGGER TI_FLAT_CATITEM
AFTER INSERT ON cataloged_item
FOR EACH ROW
BEGIN
	INSERT INTO flat (
		collection_object_id,
		cat_num,
		accn_id,
		collecting_event_id,
		collection_cde,
		collection_id,
		catalognumbertext,
		stale_flag)
	VALUES (
		:new.collection_object_id,
		:new.cat_num,
		:new.accn_id,
		:new.collecting_event_id,
		:new.collection_cde,
		:new.collection_id,
		to_char(:NEW.cat_num),
		1);
END;

CREATE OR REPLACE TRIGGER A_FLAT_CATITEM
AFTER update ON cataloged_item
FOR EACH ROW
BEGIN
	UPDATE flat
	SET stale_flag = 1
	WHERE collection_object_id = :OLD.collection_object_id;
END;

*/

INSERT INTO cataloged_item_part SELECT * FROM cataloged_item;

ALTER TABLE cataloged_item RENAME TO cataloged_item_nopart;
ALTER TABLE cataloged_item_part RENAME TO cataloged_item;

-- rebuild constraints
ALTER TABLE cataloged_item_nopart DROP CONSTRAINT PK_CATALOGED_ITEM;
ALTER TABLE cataloged_item_nopart DROP CONSTRAINT FK_CATITEM_COLLEVENT;
ALTER TABLE cataloged_item_nopart DROP CONSTRAINT FK_CATITEM_COLLOBJECT;
ALTER TABLE cataloged_item_nopart DROP CONSTRAINT FK_CATITEM_COLLECTION;
ALTER TABLE cataloged_item_nopart DROP CONSTRAINT FK_CATITEM_TRANS;
ALTER TABLE cataloged_item_nopart DROP CONSTRAINT POS_CAT_NUM;

ALTER TABLE cataloged_item
    ADD CONSTRAINT PK_CATALOGED_ITEM PRIMARY KEY (COLLECTION_OBJECT_ID)
    USING INDEX TABLESPACE UAM_IDX_1;
ALTER TABLE cataloged_item
    ADD CONSTRAINT CK_CATITEM_CATNUM CHECK (cat_num > 0);
ALTER TABLE cataloged_item
    ADD CONSTRAINT FK_CATITEM_COLLECTION FOREIGN KEY (COLLECTION_ID)
    REFERENCES COLLECTION (COLLECTION_ID);
ALTER TABLE cataloged_item
    ADD CONSTRAINT FK_CATITEM_COLLEVENT FOREIGN KEY (COLLECTING_EVENT_ID)
    REFERENCES COLLECTING_EVENT (COLLECTING_EVENT_ID);
ALTER TABLE cataloged_item
    ADD CONSTRAINT FK_CATITEM_COLLOBJECT FOREIGN KEY (COLLECTION_OBJECT_ID)
    REFERENCES COLL_OBJECT (COLLECTION_OBJECT_ID);
ALTER TABLE cataloged_item
    ADD CONSTRAINT FK_CATITEM_TRANS FOREIGN KEY (ACCN_ID)
    REFERENCES ACCN (TRANSACTION_ID);

-- rebuild indexes
DROP INDEX XIF12CATALOGED_ITEM;
DROP INDEX XIF13CATALOGED_ITEM;
DROP INDEX PKEY_CATALOGED_ITEM;
DROP INDEX XIF6CATALOGED_ITEM;
DROP INDEX XAK1CATALOGED_ITEM;
	
CREATE INDEX IX_CATITEM_COLL_EVENT_ID ON CATALOGED_ITEM (COLLECTING_EVENT_ID)
	TABLESPACE UAM_IDX_1;
CREATE INDEX IX_CATITEM_COLL_ID ON CATALOGED_ITEM (COLLECTION_ID)
	TABLESPACE UAM_IDX_1;
CREATE INDEX IX_CATITEM_ACCN_ID ON CATALOGED_ITEM (ACCN_ID)
	TABLESPACE UAM_IDX_1;
CREATE UNIQUE INDEX IX_CATITEM_CATNUM_COLL_ID ON CATALOGED_ITEM (CAT_NUM, COLLECTION_ID)
	TABLESPACE UAM_IDX_1;

-- drop foreign keys
ALTER TABLE ATTRIBUTES DROP CONSTRAINT FK_ATTRIBUTES_CATITEM;
ALTER TABLE BIOL_INDIV_RELATIONS DROP CONSTRAINT FK_BIOLINDIVRELN_CATITEM_COID;
ALTER TABLE BIOL_INDIV_RELATIONS DROP CONSTRAINT FK_BIOLINDIVRELN_CATITEM_RCOID;
ALTER TABLE CITATION DROP CONSTRAINT FK_CITATION_CATITEM;
ALTER TABLE COLLECTOR DROP CONSTRAINT FK_COLLECTOR_CATITEM;
ALTER TABLE COLL_OBJ_OTHER_ID_NUM DROP CONSTRAINT FK_COLLOBJOTHERIDNUM_CATITEM;
ALTER TABLE IDENTIFICATION DROP CONSTRAINT FK_IDENTIFICATION_CATITEM;
ALTER TABLE SPECIMEN_ANNOTATIONS DROP CONSTRAINT FK_SPECIMENANNO_CATITEM;
ALTER TABLE SPECIMEN_PART DROP CONSTRAINT FK_SPECIMENPART_CATITEM;
ALTER TABLE TAB_MEDIA_REL_FKEY DROP CONSTRAINT FK_TABMEDIARELFKEY_CATITEM;

-- rebuild foreign keys
ALTER TABLE ATTRIBUTES ADD CONSTRAINT FK_ATTRIBUTES_CATITEM
        FOREIGN KEY (COLLECTION_OBJECT_ID)
        REFERENCES CATALOGED_ITEM (COLLECTION_OBJECT_ID);
ALTER TABLE BIOL_INDIV_RELATIONS ADD CONSTRAINT FK_BIOLINDIVRELN_CATITEM_COID
        FOREIGN KEY (COLLECTION_OBJECT_ID)
        REFERENCES CATALOGED_ITEM (COLLECTION_OBJECT_ID);
ALTER TABLE BIOL_INDIV_RELATIONS ADD CONSTRAINT FK_BIOLINDIVRELN_CATITEM_RCOID
        FOREIGN KEY (RELATED_COLL_OBJECT_ID)
        REFERENCES CATALOGED_ITEM (COLLECTION_OBJECT_ID);
ALTER TABLE CITATION ADD CONSTRAINT FK_CITATION_CATITEM
        FOREIGN KEY (COLLECTION_OBJECT_ID)
        REFERENCES CATALOGED_ITEM (COLLECTION_OBJECT_ID);
ALTER TABLE COLLECTOR ADD CONSTRAINT FK_COLLECTOR_CATITEM
        FOREIGN KEY (COLLECTION_OBJECT_ID)
        REFERENCES CATALOGED_ITEM (COLLECTION_OBJECT_ID);
ALTER TABLE COLL_OBJ_OTHER_ID_NUM ADD CONSTRAINT FK_COLLOBJOTHERIDNUM_CATITEM
        FOREIGN KEY (COLLECTION_OBJECT_ID)
        REFERENCES CATALOGED_ITEM (COLLECTION_OBJECT_ID);
ALTER TABLE IDENTIFICATION ADD CONSTRAINT FK_IDENTIFICATION_CATITEM
        FOREIGN KEY (COLLECTION_OBJECT_ID)
        REFERENCES CATALOGED_ITEM (COLLECTION_OBJECT_ID);
--!!! mvz has no data in specimen_annotations
ALTER TABLE SPECIMEN_ANNOTATIONS ADD CONSTRAINT FK_SPECIMENANNO_CATITEM
        FOREIGN KEY (COLLECTION_OBJECT_ID)
        REFERENCES CATALOGED_ITEM (COLLECTION_OBJECT_ID);
ALTER TABLE SPECIMEN_PART ADD CONSTRAINT FK_SPECIMENPART_CATITEM
        FOREIGN KEY (DERIVED_FROM_CAT_ITEM)
        REFERENCES CATALOGED_ITEM (COLLECTION_OBJECT_ID);
ALTER TABLE TAB_MEDIA_REL_FKEY ADD CONSTRAINT FK_TABMEDIARELFKEY_CATITEM
        FOREIGN KEY (CFK_CATALOGED_ITEM)
        REFERENCES CATALOGED_ITEM (COLLECTION_OBJECT_ID);
        
-- rebuild triggers
DROP TRIGGER TU_FLAT_CATITEM;
DROP TRIGGER AD_FLAT_CATITEM;
DROP TRIGGER TI_FLAT_CATITEM;
DROP TRIGGER A_FLAT_CATITEM;

CREATE OR REPLACE TRIGGER tr_catitem_flat_ad
AFTER DELETE ON cataloged_item
FOR EACH ROW
BEGIN
	DELETE FROM flat
	WHERE collection_object_id = :OLD.collection_object_id;
END;

CREATE OR REPLACE TRIGGER tr_catitem_flat_au
AFTER UPDATE ON cataloged_item
FOR EACH ROW
BEGIN
	UPDATE flat
	SET stale_flag = 1
    WHERE collection_object_id = :OLD.collection_object_id
	OR collection_object_id = :NEW.collection_object_id;
END;

CREATE OR REPLACE TRIGGER tr_catitem_flat_ai
AFTER INSERT ON cataloged_item
FOR EACH ROW
BEGIN
	INSERT INTO flat (
		collection_object_id,
		cat_num,
		accn_id,
		collecting_event_id,
		collection_cde,
		collection_id,
		catalognumbertext,
		stale_flag)
	VALUES (
		:NEW.collection_object_id,
		:NEW.cat_num,
		:NEW.accn_id,
		:NEW.collecting_event_id,
		:NEW.collection_cde,
		:NEW.collection_id,
		to_char(:NEW.cat_num),
		1);
END;

--rebuild synonyms and grants

CREATE OR REPLACE PUBLIC SYNONYM cataloged_item FOR cataloged_item;
GRANT SELECT ON cataloged_item TO PUBLIC;
GRANT INSERT, UPDATE ON cataloged_item TO MANAGE_SPECIMENS;
GRANT DELETE ON cataloged_item TO MANAGE_COLLECTION;
			
ANALYZE TABLE cataloged_item COMPUTE STATISTICS;

--FLAT
-- check public synonyms, table privileges.

-- create partitioned flat table
CREATE TABLE FLAT_PART (
    COLLECTION_OBJECT_ID NUMBER, 
    CAT_NUM NUMBER NOT NULL , 
    ACCN_ID NUMBER NOT NULL , 
    COLLECTION_ID NUMBER NOT NULL , 
    INSTITUTION_ACRONYM VARCHAR2(20), 
    COLLECTION_CDE VARCHAR2(5), 
    COLLECTION VARCHAR2(30), 
    COLLECTING_EVENT_ID NUMBER, 
    BEGAN_DATE DATE, 
    ENDED_DATE DATE, 
    VERBATIM_DATE VARCHAR2(60), 
    LAST_EDIT_DATE DATE, 
    INDIVIDUALCOUNT NUMBER, 
    COLL_OBJ_DISPOSITION VARCHAR2(20), 
    COLLECTORS VARCHAR2(4000), 
    FIELD_NUM VARCHAR2(4000), 
    OTHERCATALOGNUMBERS VARCHAR2(4000), 
    GENBANKNUM VARCHAR2(4000), 
    RELATEDCATALOGEDITEMS VARCHAR2(4000), 
    TYPESTATUS VARCHAR2(4000), 
    SEX VARCHAR2(4000), 
    PARTS VARCHAR2(4000), 
    ENCUMBRANCES VARCHAR2(4000), 
    ACCESSION VARCHAR2(81), 
    GEOG_AUTH_REC_ID NUMBER, 
    HIGHER_GEOG VARCHAR2(255), 
    CONTINENT_OCEAN VARCHAR2(50), 
    COUNTRY VARCHAR2(50), 
    STATE_PROV VARCHAR2(75), 
    COUNTY VARCHAR2(50), 
    FEATURE VARCHAR2(50), 
    ISLAND VARCHAR2(50), 
    ISLAND_GROUP VARCHAR2(50), 
    QUAD VARCHAR2(30), 
    SEA VARCHAR2(50), 
    LOCALITY_ID NUMBER, 
    SPEC_LOCALITY VARCHAR2(255), 
    MINIMUM_ELEVATION NUMBER, 
    MAXIMUM_ELEVATION NUMBER, 
    ORIG_ELEV_UNITS VARCHAR2(2), 
    MIN_ELEV_IN_M NUMBER, 
    MAX_ELEV_IN_M NUMBER, 
    DEC_LAT NUMBER(12, 10), 
    DEC_LONG NUMBER(13, 10), 
    DATUM VARCHAR2(55), 
    ORIG_LAT_LONG_UNITS VARCHAR2(20), 
    VERBATIMLATITUDE VARCHAR2(127), 
    VERBATIMLONGITUDE VARCHAR2(127), 
    LAT_LONG_REF_SOURCE VARCHAR2(255), 
    COORDINATEUNCERTAINTYINMETERS NUMBER, 
    GEOREFMETHOD VARCHAR2(255), 
    LAT_LONG_REMARKS VARCHAR2(4000), 
    LAT_LONG_DETERMINER VARCHAR2(184), 
    IDENTIFICATION_ID NUMBER, 
    SCIENTIFIC_NAME VARCHAR2(255), 
    IDENTIFIEDBY VARCHAR2(4000), 
    MADE_DATE DATE, REMARKS VARCHAR2(4000), 
    HABITAT VARCHAR2(4000), 
    ASSOCIATED_SPECIES VARCHAR2(4000), 
    TAXA_FORMULA VARCHAR2(25), 
    FULL_TAXON_NAME VARCHAR2(4000), 
    PHYLCLASS VARCHAR2(4000), 
    KINGDOM VARCHAR2(4000), 
    PHYLUM VARCHAR2(4000), 
    PHYLORDER VARCHAR2(4000), 
    FAMILY VARCHAR2(4000), 
    GENUS VARCHAR2(4000), 
    SPECIES VARCHAR2(4000), 
    SUBSPECIES VARCHAR2(4000), 
    AUTHOR_TEXT VARCHAR2(4000), 
    NOMENCLATURAL_CODE VARCHAR2(4000), 
    INFRASPECIFIC_RANK VARCHAR2(4000), 
    IDENTIFICATIONMODIFIER CHAR(1), 
    GUID VARCHAR2(67), 
    BASISOFRECORD VARCHAR2(17), 
    DEPTH_UNITS VARCHAR2(20), 
    MIN_DEPTH NUMBER, 
    MAX_DEPTH NUMBER, 
    MIN_DEPTH_IN_M NUMBER, 
    MAX_DEPTH_IN_M NUMBER, 
    COLLECTING_METHOD VARCHAR2(255), 
    COLLECTING_SOURCE VARCHAR2(15), 
    DAYOFYEAR NUMBER, 
    AGE_CLASS VARCHAR2(4000), 
    ATTRIBUTES VARCHAR2(4000), 
    VERIFICATIONSTATUS VARCHAR2(40), 
    SPECIMENDETAILURL VARCHAR2(255), 
    IMAGEURL VARCHAR2(121), 
    FIELDNOTESURL VARCHAR2(121), 
    CATALOGNUMBERTEXT VARCHAR2(40), 
    COLLECTORNUMBER VARCHAR2(4000), 
    VERBATIMELEVATION VARCHAR2(84), 
    YEAR NUMBER, 
    MONTH NUMBER, 
    DAY NUMBER, 
    STALE_FLAG NUMBER DEFAULT 0 NOT NULL)
TABLESPACE UAM_DAT_1 
PARTITION BY LIST (collection_id) ( 
    partition UAM_Mamm values (1),
	partition UAM_Bird values (2),
	partition UAM_Herp values (3),
	partition UAM_Ento values (4),
	partition UAM_Herb values (6),
	partition NBSB_Bird values (7),
	partition UAM_Bryo values (8),
	partition UAM_Crus values (9),
	partition UAM_Fish values (10),
	partition UAM_Moll values (11),
	partition KWP_Ento values (12),
	partition UAMObs_Mamm values (13),
	partition MSB_Mamm values (14),
	partition DGR_Ento values (15),
	partition DGR_Bird values (16),
	partition DGR_Mamm values (17),
	partition DGR_Herp values (18),
	partition DGR_Fish values (19),
	partition MSB_Bird values (20),
	partition UAM_ES values (21),
	partition WNMU_Bird values (22),
	partition WNMU_Fish values (23),
	partition WNMU_Mamm values (24),
	partition PSU_Mamm values (25),
	partition CRCM_Bird values (26),
	partition GOD_Herb values (27),
	partition MVZ_Mamm values (28),
	partition MVZ_Bird values (29),
	partition MVZ_Herp values (30),
	partition MVZ_Egg values (31),
	partition MVZ_Hild values (32),
	partition MVZ_Img values (33),
	partition MVZ_Page values (34),
	partition MVZObs_Bird values (35),
	partition MVZObs_Herp values (36),
	partition MVZObs_Mamm values (37));
	
-- recreate flat
INSERT INTO flat_part (
	collection_object_id,
	cat_num,
	accn_id,
	collecting_event_id,
	collection_cde,
	collection_id,
	catalognumbertext,
	stale_flag
	) (
select
	collection_object_id,
	cat_num,
	accn_id,
	collecting_event_id,
	collection_cde,
	collection_id,
	to_char(cat_num),
	1
FROM cataloged_item);

-- drop old flat triggers, keys, indexes.

ALTER TABLE flat RENAME TO flat_nopart;
ALTER TABLE flat_part RENAME TO flat;

- !!! recreate flat triggers and procedures.  
run flat.triggers_setFlag.vpd.sql



ALTER TABLE flat DROP CONSTRAINT PK_FLAT;

ALTER TABLE flat
ADD CONSTRAINT PK_FLAT
PRIMARY KEY (COLLECTION_OBJECT_ID)
USING INDEX TABLESPACE UAM_IDX_1;


DROP INDEX FLAT_BEGAN_DATE;
DROP INDEX "UAM"."PFLAT_BEGAN_DATE";
CREATE INDEX IX_FLAT_BEGAN_DATE ON FLAT (BEGAN_DATE)
  TABLESPACE UAM_IDX_1;

--191 -- 0.0152%
DROP INDEX FLAT_BEG_YEAR;
CREATE INDEX IX_FLAT_BEG_YEAR ON FLAT (TO_NUMBER(TO_CHAR(BEGAN_DATE,'yyyy')))
  TABLESPACE UAM_IDX_1;

-- probably too many distinct values.
DROP INDEX FLAT_CAT_NUM;
DROP INDEX "UAM"."PFLAT_CAT_NUM";
CREATE INDEX IX_FLAT_CAT_NUM ON FLAT (CAT_NUM)
  TABLESPACE UAM_IDX_1;

--32 -- 0.0025%
DROP INDEX FLAT_COLLECTION_ID;
CREATE INDEX IX_FLAT_COLLECTION_ID ON FLAT (COLLECTION_ID)
  TABLESPACE UAM_IDX_1;

-- concatenated column; probably too many distinct values.
DROP INDEX FLAT_COLLECTORS;
DROP INDEX "UAM"."PFLAT_COLLECTORS";
CREATE INDEX IX_FLAT_COLLECTORS ON FLAT (COLLECTORS)
  TABLESPACE UAM_IDX_1;

--42817 -- 3.4272%
DROP INDEX FLAT_ENDED_DATE;
DROP INDEX "UAM"."PFLAT_ENDED_DATE";
CREATE INDEX IX_FLAT_ENDED_DATE ON FLAT (ENDED_DATE)
  TABLESPACE UAM_IDX_1;

--189 -- 0.0151%
DROP INDEX FLAT_END_YEAR;
CREATE INDEX IX_FLAT_ENDED_YEAR ON FLAT (TO_NUMBER(TO_CHAR(ENDED_DATE,'yyyy')))
  TABLESPACE UAM_IDX_1;

-- probably too may distinct values.
DROP INDEX FLAT_IDENT_ID;
CREATE INDEX IX_FLAT_IDENT_ID ON FLAT (IDENTIFICATION_ID)
  TABLESPACE UAM_IDX_1;

--1 -- 0.00008%
DROP INDEX FLAT_STALE_FLAG;
DROP INDEX "UAM"."PFLAT_STALE_FLAG";
CREATE INDEX IX_FLAT_STALE_FLAG ON FLAT (STALE_FLAG)
  TABLESPACE UAM_IDX_1;

-- too many distinct values.
DROP INDEX IDX$$_19D50001;
/* old stuff; do not rebuild
CREATE INDEX IX_FLAT_COMPOSITE ON FLAT (
	COLLECTION_OBJECT_ID, 
	COLLECTION, 
	CAT_NUM, 
	SCIENTIFIC_NAME, 
	ACCESSION, 
	SPEC_LOCALITY, 
	VERBATIM_DATE, 
	DEC_LAT, 
	DEC_LONG, 
	COLLECTION_ID, 
	INSTITUTION_ACRONYM,
	COLLECTION_CDE)
  TABLESPACE UAM_IDX_1;
*/

DROP INDEX TEST_IDX;
--CREATE INDEX TEST_IDX ON FLAT (NLSSORT(SCIENTIFIC_NAME,'nls_sort=''GENERIC_M_AI'''))
--  TABLESPACE UAM_IDX_1;

-- 419461 -- 33.5756%
DROP INDEX U_FLAT_COLEVNTID;
CREATE INDEX IX_FLAT_COLL_EVENT_ID ON FLAT (COLLECTING_EVENT_ID)
  TABLESPACE UAM_IDX_1;

--22  -- 0.0017%
DROP INDEX U_FLAT_CONTINENT_OCEAN;
DROP INDEX "UAM"."PU_FLAT_CONTINENT_OCEAN";
CREATE INDEX IX_FLAT_CONTINENT_OCEAN_UP ON FLAT (UPPER(CONTINENT_OCEAN))
  TABLESPACE UAM_IDX_1;

--202 --0.0161%
DROP INDEX U_FLAT_COUNTRY;
DROP INDEX "UAM"."PU_FLAT_COUNTRY";
CREATE INDEX IX_FLAT_COUNTRY_UP ON FLAT (UPPER(COUNTRY))
  TABLESPACE UAM_IDX_1;

--2831 --0.2266%
DROP INDEX U_FLAT_COUNTY;
DROP INDEX "UAM"."PU_FLAT_COUNTY";
CREATE INDEX IX_FLAT_COUNTY_UP ON FLAT (UPPER(COUNTY))
  TABLESPACE UAM_IDX_1;

--176 -- 0 .0140%
DROP INDEX U_FLAT_FEATURE;
DROP INDEX "UAM"."PU_FLAT_FEATURE";
CREATE INDEX IX_FLAT_FEATURE_UP ON FLAT (UPPER(FEATURE))
  TABLESPACE UAM_IDX_1;

-- probably too many distinct values.
DROP INDEX U_FLAT_HIGHER_GEOG;
DROP INDEX "UAM"."PU_FLAT_HIGHER_GEOG";
CREATE INDEX IX_FLAT_HIGHER_GEOG_UP ON FLAT (UPPER(HIGHER_GEOG))
  TABLESPACE UAM_IDX_1;

--1165 -- 0.0932%
DROP INDEX U_FLAT_ISLAND;
DROP INDEX "UAM"."PU_FLAT_ISLAND";
CREATE INDEX IX_FLAT_ISLAND_UP ON FLAT (UPPER(ISLAND))
  TABLESPACE UAM_IDX_1;

--137 -- 0.0109%
DROP INDEX U_FLAT_ISLAND_GROUP;
DROP INDEX "UAM"."PU_FLAT_ISLAND_GROUP";
CREATE INDEX IX_FLAT_ISLAND_GROUP_UP ON FLAT (UPPER(ISLAND_GROUP))
  TABLESPACE UAM_IDX_1;

-- probably too many distinct values.
DROP INDEX U_FLAT_LOCID;
CREATE INDEX IX_FLAT_LOCALITY_ID ON FLAT (LOCALITY_ID)
  TABLESPACE UAM_IDX_1;

-- concatenated column. probably too many disintct values.
DROP INDEX U_FLAT_PART;
CREATE INDEX IX_FLAT_PARTS_UP ON FLAT (UPPER(PARTS))
  TABLESPACE UAM_IDX_1;

--212 -- 0.0169%
DROP INDEX U_FLAT_QUAD;
DROP INDEX "UAM"."PU_FLAT_QUAD";
CREATE INDEX IX_FLAT_QUAD_UP ON FLAT (UPPER(QUAD))
  TABLESPACE UAM_IDX_1;

--30081 -- 2.4078%
DROP INDEX U_FLAT_SCIENTIFIC_NAME;
DROP INDEX "UAM"."PU_FLAT_SCIENTIFIC_NAME";
CREATE INDEX IX_FLAT_SCIENTIFIC_NAME_UP ON FLAT (UPPER(SCIENTIFIC_NAME))
  TABLESPACE UAM_IDX_1;

--31 -- 0.0024%
DROP INDEX U_FLAT_SEA;
DROP INDEX "UAM"."PU_FLAT_SEA";
CREATE INDEX IX_FLAT_SEA_UP ON FLAT (UPPER(SEA))
  TABLESPACE UAM_IDX_1;

-- probably too many distinct values.
DROP INDEX U_FLAT_SPEC_LOCALITY;
DROP INDEX "UAM"."PU_FLAT_SPEC_LOCALITY";
CREATE INDEX IX_FLAT_SPEC_LOCALITY_UP ON FLAT (UPPER(SPEC_LOCALITY))
  TABLESPACE UAM_IDX_1;

--1395 -- 0.1116%
DROP INDEX U_FLAT_STATE_PROV;
DROP INDEX "UAM"."PU_FLAT_STATE_PROV";
CREATE INDEX IX_FLAT_STATE_PROV_U ON FLAT (UPPER(STATE_PROV))
  TABLESPACE UAM_IDX_1;

--833 -- 0.0666%
DROP INDEX U_FLAT_TYPESTATUS;
DROP INDEX "UAM"."PFLAT_TYPESTATUS";
CREATE INDEX IX_FLAT_TYPESTATUS_UP ON FLAT (UPPER(TYPESTATUS))
    TABLESPACE UAM_IDX_1;

/* eg bitmap index.
--833 -- 0.0666%
DROP INDEX U_FLAT_TYPESTATUS;
CREATE BITMAP INDEX IB_FLAT_TYPESTATUS
    ON FLAT (UPPER(TYPESTATUS))
    TABLESPACE UAM_IDX_1;
exec dbms_stats.gather_index_stats(OWNNAME=>'UAM', INDNAME=>'IB_FLAT_TYPESTATUS');
*/

/* not sure if we should implement these 
CREATE BITMAP INDEX IB_PFLAT_STALE_FLAG 
ON FLAT (STALE_FLAG)
TABLESPACE "UAM_IDX_1"  LOCAL (
 PARTITION "UAM_MAMM" TABLESPACE "UAM_IDX_1",
 PARTITION "UAM_BIRD" TABLESPACE "UAM_IDX_1",
 PARTITION "UAM_HERP" TABLESPACE "UAM_IDX_1",
 PARTITION "UAM_ENTO" TABLESPACE "UAM_IDX_1",
 PARTITION "UAM_HERB" TABLESPACE "UAM_IDX_1",
 PARTITION "NBSB_BIRD" TABLESPACE "UAM_IDX_1",
 PARTITION "UAM_BRYO" TABLESPACE "UAM_IDX_1",
 PARTITION "UAM_CRUS" TABLESPACE "UAM_IDX_1",
 PARTITION "UAM_FISH" TABLESPACE "UAM_IDX_1",
 PARTITION "UAM_MOLL" TABLESPACE "UAM_IDX_1",
 PARTITION "KWP_ENTO" TABLESPACE "UAM_IDX_1",
 PARTITION "UAMOBS_MAMM" TABLESPACE "UAM_IDX_1",
 PARTITION "MSB_MAMM" TABLESPACE "UAM_IDX_1",
 PARTITION "DGR_ENTO" TABLESPACE "UAM_IDX_1",
 PARTITION "DGR_BIRD" TABLESPACE "UAM_IDX_1",
 PARTITION "DGR_MAMM" TABLESPACE "UAM_IDX_1",
 PARTITION "DGR_HERP" TABLESPACE "UAM_IDX_1",
 PARTITION "DGR_FISH" TABLESPACE "UAM_IDX_1",
 PARTITION "MSB_BIRD" TABLESPACE "UAM_IDX_1",
 PARTITION "UAM_ES" TABLESPACE "UAM_IDX_1",
 PARTITION "WNMU_BIRD" TABLESPACE "UAM_IDX_1",
 PARTITION "WNMU_FISH" TABLESPACE "UAM_IDX_1",
 PARTITION "WNMU_MAMM" TABLESPACE "UAM_IDX_1",
 PARTITION "PSU_MAMM" TABLESPACE "UAM_IDX_1",
 PARTITION "CRCM_BIRD" TABLESPACE "UAM_IDX_1",
 PARTITION "GOD_HERB" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZ_MAMM" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZ_BIRD" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZ_HERP" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZ_EGG" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZ_HILD" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZ_IMG" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZ_PAGE" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZOBS_BIRD" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZOBS_HERP" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZOBS_MAMM" TABLESPACE "UAM_IDX_1" )

CREATE BITMAP INDEX IB_FLAT_COLLECTION_ID" 
ON FLAT (COLLECTION_ID)
TABLESPACE "UAM_IDX_1"  LOCAL (
 PARTITION "UAM_MAMM" TABLESPACE "UAM_IDX_1",
 PARTITION "UAM_BIRD" TABLESPACE "UAM_IDX_1",
 PARTITION "UAM_HERP" TABLESPACE "UAM_IDX_1",
 PARTITION "UAM_ENTO" TABLESPACE "UAM_IDX_1",
 PARTITION "UAM_HERB" TABLESPACE "UAM_IDX_1",
 PARTITION "NBSB_BIRD" TABLESPACE "UAM_IDX_1",
 PARTITION "UAM_BRYO" TABLESPACE "UAM_IDX_1",
 PARTITION "UAM_CRUS" TABLESPACE "UAM_IDX_1",
 PARTITION "UAM_FISH" TABLESPACE "UAM_IDX_1",
 PARTITION "UAM_MOLL" TABLESPACE "UAM_IDX_1",
 PARTITION "KWP_ENTO" TABLESPACE "UAM_IDX_1",
 PARTITION "UAMOBS_MAMM" TABLESPACE "UAM_IDX_1",
 PARTITION "MSB_MAMM" TABLESPACE "UAM_IDX_1",
 PARTITION "DGR_ENTO" TABLESPACE "UAM_IDX_1",
 PARTITION "DGR_BIRD" TABLESPACE "UAM_IDX_1",
 PARTITION "DGR_MAMM" TABLESPACE "UAM_IDX_1",
 PARTITION "DGR_HERP" TABLESPACE "UAM_IDX_1",
 PARTITION "DGR_FISH" TABLESPACE "UAM_IDX_1",
 PARTITION "MSB_BIRD" TABLESPACE "UAM_IDX_1",
 PARTITION "UAM_ES" TABLESPACE "UAM_IDX_1",
 PARTITION "WNMU_BIRD" TABLESPACE "UAM_IDX_1",
 PARTITION "WNMU_FISH" TABLESPACE "UAM_IDX_1",
 PARTITION "WNMU_MAMM" TABLESPACE "UAM_IDX_1",
 PARTITION "PSU_MAMM" TABLESPACE "UAM_IDX_1",
 PARTITION "CRCM_BIRD" TABLESPACE "UAM_IDX_1",
 PARTITION "GOD_HERB" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZ_MAMM" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZ_BIRD" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZ_HERP" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZ_EGG" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZ_HILD" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZ_IMG" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZ_PAGE" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZOBS_BIRD" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZOBS_HERP" TABLESPACE "UAM_IDX_1",
 PARTITION "MVZOBS_MAMM" TABLESPACE "UAM_IDX_1" );
*/

ANALYZE TABLE flat COMPUTE STATISTICS;
