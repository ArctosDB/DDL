/*
select dbms_metadata.get_ddl('INDEX', index_name)
from user_indexes
where table_name not like 'CT%'
and table_name not like 'CF%'
and table_name not like 'GREF%'
and table_name not like 'PLSQL%'
and table_name not in (
'ALERT_LOG', 'FAM_SUBFAM_ID_CLUSTER', 'PLAN_TABLE', 'TERM_ID_CLUSTER',
'ACCN', 'ADDR', 'AGENT', 'AGENT_NAME', 'AGENT_RANK', 'AGENT_RELATIONS',
'ANNOTATIONS', 'ATTRIBUTES', 'BINARY_OBJECT', 'BIOL_INDIV_RELATIONS', 'BOOK',
'BOOK_SECTION', 'BORROW', 'CATALOGED_ITEM', 'CITATION', 'COLLECTING_EVENT',
'COLLECTION', 'COLLECTION_CONTACTS', 'COLLECTOR', 'COLLECTOR_FORMATTED',
'COLL_OBJECT', 'COLL_OBJECT_ENCUMBRANCE', 'COLL_OBJECT_REMARK', 'COLL_OBJ_CONT_HIST',
'COLL_OBJ_OTHER_ID_NUM', 'COMMON_NAME', 'CONTAINER', 'CONTAINER_CHECK',
'CONTAINER_HISTORY', 'CORRESPONDENCE', 'ELECTRONIC_ADDRESS', 'ENCUMBRANCE',
'FIELD_NOTEBOOK_SECTION', 'FLUID_CONTAINER_HISTORY', 'FORMATTED_PUBLICATION',
'GEOG_AUTH_REC', 'GEOLOGY_ATTRIBUTES', 'GEOLOGY_ATTRIBUTE_HIERARCHY',
'GROUP_MEMBER', 'IDENTIFICATION', 'IDENTIFICATION_AGENT', 'IDENTIFICATION_TAXONOMY',
'JOURNAL', 'JOURNAL_ARTICLE', 'LAT_LONG', 'LOAN', 'LOAN_INSTALLMENT', 'LOAN_ITEM',
'LOAN_REQUEST', 'LOCALITY', 'MEDIA', 'MEDIA_LABELS', 'MEDIA_RELATIONS',
'OBJECT_CONDITION', 'PAGE', 'PERMIT', 'PERMIT_SHIPMENT', 'PERMIT_TRANS',
'PERSON', 'PROJECT', 'PROJECT_AGENT', 'PROJECT_PUBLICATION', 'PROJECT_SPONSOR',
'PROJECT_TRANS', 'PUBLICATION', 'PUBLICATION_ATTRIBUTES', 'PUBLICATION_AUTHOR_NAME', 
'PUBLICATION_URL', 'SHIPMENT', 'SPECIMEN_ANNOTATIONS', 'SPECIMEN_PART', 'TAG', 
'TAXONOMY', 'TAXON_RELATIONS', 'TRANS', 'TRANS_AGENT')
order by table_name, uniqueness, index_name;

BLACKLIST
BULKLOADER
CDATA
CGLOBAL
DGR_LOCATOR
FLAT
TACC_CHECK
TAB_MEDIA_REL_FKEY
TAXONOMY_ARCHIVE
VPD_COLLECTION_LOCALITY
*/

-- BLACKLIST
CREATE UNIQUE INDEX IU_BLACKLIST_IP
	ON BLACKLIST (IP)
	TABLESPACE UAM_IDX_1;

-- BULKLOADER
CREATE UNIQUE INDEX PK_BULKLOADER
	ON BULKLOADER (COLLECTION_OBJECT_ID)
	TABLESPACE UAM_IDX_1;

-- CDATA
CREATE UNIQUE INDEX PK_CDATA
	ON CDATA (CFID, APP)
	TABLESPACE UAM_IDX_1;

-- CGLOBAL
CREATE INDEX IX_CGLOBAL_CFID
	ON CGLOBAL (CFID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_CGLOBAL_LVISIT
	ON CGLOBAL (LVISIT)
	TABLESPACE UAM_IDX_1;

-- DGR_LOCATOR
CREATE UNIQUE INDEX IU_DGRLOCATOR_FRZR_RCK_BX_PLC
	ON DGR_LOCATOR (FREEZER, RACK, BOX, PLACE)
	TABLESPACE UAM_IDX_1;

-- FLAT
CREATE INDEX IX_FLAT_BEGANDATE
	ON FLAT (BEGAN_DATE)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_BEGANDATE_YEAR
	ON FLAT (TO_NUMBER(TO_CHAR(BEGAN_DATE,'yyyy')))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_CATNUM
	ON FLAT (CAT_NUM)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_COLLECTIONID
	ON FLAT (COLLECTION_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_COLLECTORS
	ON FLAT (COLLECTORS)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_COLLEVENTID
	ON FLAT (COLLECTING_EVENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_CONTINENTOCEAN_UPR
	ON FLAT (UPPER(CONTINENT_OCEAN))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_COUNTRY_UP
	ON FLAT (UPPER(COUNTRY))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_COUNTY_UPR
	ON FLAT (UPPER(COUNTY))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_ENDEDDATE
	ON FLAT (ENDED_DATE)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_ENDEDDATE_YEAR
	ON FLAT (TO_NUMBER(TO_CHAR(ENDED_DATE,'yyyy')))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_FEATURE_UPR
	ON FLAT (UPPER(FEATURE))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_HIGHER_GEOG_UPR
	ON FLAT (UPPER(HIGHER_GEOG))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_IDENTIFICATIONID
	ON FLAT (IDENTIFICATION_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_ISLANDGROUP_UPR
	ON FLAT (UPPER(ISLAND_GROUP))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_ISLAND_UPR
	ON FLAT (UPPER(ISLAND))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_LOCALITYID
	ON FLAT (LOCALITY_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_PARTS_UPR
	ON FLAT (UPPER(PARTS))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_QUAD_UPR
	ON FLAT (UPPER(QUAD))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_SCIENTIFICNAME_UPR
	ON FLAT (UPPER(SCIENTIFIC_NAME))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_SEA_UPR
	ON FLAT (UPPER(SEA))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_SPECLOCALITY_UPR
	ON FLAT (UPPER(SPEC_LOCALITY))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_STALEFLAG
	ON FLAT (STALE_FLAG)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_STATEPROV_UPR
	ON FLAT (UPPER(STATE_PROV))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_TYPESTATUS_UPR
	ON FLAT (UPPER(TYPESTATUS))
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_FLAT_GUID_UPR
	ON FLAT (UPPER(GUID))
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_FLAT
	ON FLAT (COLLECTION_OBJECT_ID)
	TABLESPACE UAM_IDX_1;

-- REDIRECT
CREATE UNIQUE INDEX IU_REDIRECT_OLD
    ON REDIRECT (OLD_PATH)
    TABLESPACE UAM_IDX_1;

-- TAB_MEDIA_REL_FKEY 
CREATE UNIQUE INDEX PK_TAB_MEDIA_REL_FKEY
	ON TAB_MEDIA_REL_FKEY (MEDIA_RELATIONS_ID)
	TABLESPACE UAM_IDX_1;

-- TACC_CHECK
CREATE INDEX IX_TACCCHECK_BARCODE
	ON TACC_CHECK (BARCODE)
	TABLESPACE UAM_IDX_1;

-- TAXONOMY_ARCHIVE
CREATE INDEX IX_TAXONARCHIVE_TNID
	ON TAXONOMY_ARCHIVE (TAXON_NAME_ID)
	TABLESPACE UAM_IDX_1;
	
-- VPD_COLLECTION_LOCALITY
CREATE INDEX IX_VPD_COLLLOC_COLLID
	ON VPD_COLLECTION_LOCALITY(COLLECTION_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_VPD_COLLLOC_LOCID
	ON VPD_COLLECTION_LOCALITY (LOCALITY_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_VPD_COLLECTION_LOCALITY
	ON VPD_COLLECTION_LOCALITY (COLLECTION_ID, LOCALITY_ID)
	TABLESPACE UAM_IDX_1;
