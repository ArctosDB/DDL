/*
select dbms_metadata.get_ddl('INDEX', index_name) 
from user_indexes 
where table_name not like 'CT%'
and table_name not like 'CF%'
and table_name not like 'GREF%'
and table_name not like 'PLSQL%'
and table_name not in (
	'CDATA', 'CGLOBAL', 'ALERT_LOG', 'BLACKLIST', 
	'BULKLOADER', 'DGR_LOCATOR', 'FAM_SUBFAM_ID_CLUSTER',
	'FLAT', 'PLAN_TABLE', 'TAB_MEDIA_REL_FKEY', 'TACC_CHECK',
	'TAXONOMY_ARCHIVE', 'TERM_ID_CLUSTER','VPD_COLLECTION_LOCALITY')
order by table_name, uniqueness, index_name;

ACCN
ADDR
AGENT
AGENT_NAME
AGENT_RANK
AGENT_RELATIONS
ANNOTATIONS
ATTRIBUTES
BINARY_OBJECT
BIOL_INDIV_RELATIONS
BOOK
BOOK_SECTION
BORROW
CATALOGED_ITEM
CITATION
COLLECTING_EVENT
COLLECTION
COLLECTION_CONTACTS
COLLECTOR
COLLECTOR_FORMATTED
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
ELECTRONIC_ADDRESS
ENCUMBRANCE
FIELD_NOTEBOOK_SECTION
FLUID_CONTAINER_HISTORY
FORMATTED_PUBLICATION
GEOG_AUTH_REC
GEOLOGY_ATTRIBUTES
GEOLOGY_ATTRIBUTE_HIERARCHY
GROUP_MEMBER
IDENTIFICATION
IDENTIFICATION_AGENT
IDENTIFICATION_TAXONOMY
JOURNAL
JOURNAL_ARTICLE
LAT_LONG
LOAN
LOAN_INSTALLMENT
LOAN_ITEM
LOAN_REQUEST
LOCALITY
MEDIA
MEDIA_LABELS
MEDIA_RELATIONS
OBJECT_CONDITION
PAGE
PERMIT
PERMIT_SHIPMENT
PERMIT_TRANS
PERSON
PROJECT
PROJECT_AGENT
PROJECT_PUBLICATION
PROJECT_SPONSOR
PROJECT_TRANS
PUBLICATION
PUBLICATION_ATTRIBUTES
PUBLICATION_AUTHOR_NAME
PUBLICATION_URL
SHIPMENT
SPECIMEN_ANNOTATIONS
SPECIMEN_PART
TAG
TAXONOMY
TAXON_RELATIONS
TRANS
TRANS_AGENT
*/

-- ACCN
CREATE INDEX IX_ACCN_ACCNNUM_SUFFIX
	ON ACCN (ACCN_NUM, ACCN_NUM_SUFFIX)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_ACCN_PREFIX
	ON ACCN (ACCN_NUM_PREFIX)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_ACCN
	ON ACCN (TRANSACTION_ID)
	TABLESPACE UAM_IDX_1;

-- ADDR
CREATE UNIQUE INDEX PK_ADDR
	ON ADDR (ADDR_ID)
	TABLESPACE UAM_IDX_1;

-- AGENT
CREATE INDEX IX_AGENT_PREFERRED
	ON AGENT (PREFERRED_AGENT_NAME_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX PK_AGENT
	ON AGENT (AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_AGENT_AID_PREFERRED
	ON AGENT (AGENT_ID, PREFERRED_AGENT_NAME_ID)
	TABLESPACE UAM_IDX_1;

-- AGENT_NAME
CREATE BITMAP INDEX IB_AGENTNAME_TYPE
	ON AGENT_NAME (AGENT_NAME_TYPE)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_AGENTNAME_AGENTNAME_UPR
	ON AGENT_NAME (UPPER(AGENT_NAME))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_AGENTNAME_AID
	ON AGENT_NAME (AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX PK_AGENT_NAME
	ON AGENT_NAME (AGENT_NAME_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_AGENTNAME_AGENTNAME_AID
	ON AGENT_NAME (AGENT_NAME, AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_AGENTNAME_AGENTNAME_ANID
	ON AGENT_NAME (AGENT_NAME, AGENT_NAME_ID)
	TABLESPACE UAM_IDX_1;
	
-- AGENT_RANK 
CREATE UNIQUE INDEX PK_AGENT_RANK
	ON AGENT_RANK (AGENT_RANK_ID)
	TABLESPACE UAM_IDX_1;

-- AGENT_RELATIONS
CREATE INDEX IX_AGENTRELNS_AID
	ON AGENT_RELATIONS (AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_AGENTRELNS_RELATED
	ON AGENT_RELATIONS (RELATED_AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_AGENT_RELATIONS
	ON AGENT_RELATIONS (AGENT_ID, RELATED_AGENT_ID, AGENT_RELATIONSHIP)
	TABLESPACE UAM_IDX_1;
	
-- ANNOTATIONS 
CREATE UNIQUE INDEX PK_ANNOTATIONS
	ON ANNOTATIONS (ANNOTATION_ID)
	TABLESPACE UAM_IDX_1;
	
-- ATTRIBUTES 
CREATE INDEX IX_ATTRIBUTES_COID
	ON ATTRIBUTES (COLLECTION_OBJECT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_ATTRIBUTES_DETERMINEDBY
	ON ATTRIBUTES (DETERMINED_BY_AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_ATTRIBUTES
	ON ATTRIBUTES (ATTRIBUTE_ID)
	TABLESPACE UAM_IDX_1;
	
-- BINARY_OBJECT 
CREATE UNIQUE INDEX PK_BINARY_OBJECT
    ON BINARY_OBJECT (COLLECTION_OBJECT_ID)
    TABLESPACE UAM_IDX_1;

CREATE INDEX IX_BINARYOBJECT_VIEWERID
    ON BINARY_OBJECT (VIEWER_ID)
    TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_BINARYOBJECT_FULLURL
    ON BINARY_OBJECT (FULL_URL)
    TABLESPACE UAM_IDX_1;
	
-- BIOL_INDIV_RELATIONS 
CREATE INDEX IX_BIOLINDIVRELNS_RCOID
	ON BIOL_INDIV_RELATIONS (RELATED_COLL_OBJECT_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_BIOL_INDIV_RELATIONS
	ON BIOL_INDIV_RELATIONS (COLLECTION_OBJECT_ID, RELATED_COLL_OBJECT_ID, BIOL_INDIV_RELATIONSHIP)
	TABLESPACE UAM_IDX_1;
	
-- BOOK 
CREATE UNIQUE INDEX PK_BOOK
	ON BOOK (PUBLICATION_ID)
	TABLESPACE UAM_IDX_1;

-- BOOK_SECTION 
CREATE INDEX IX_BOOKSECTION_BOOKID
	ON BOOK_SECTION (BOOK_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_BOOK_SECTION
	ON BOOK_SECTION (PUBLICATION_ID)
	TABLESPACE UAM_IDX_1;

-- BORROW 
CREATE UNIQUE INDEX PK_BORROW
	ON BORROW (TRANSACTION_ID)
	TABLESPACE UAM_IDX_1;

-- CATALOGED_ITEM 
CREATE INDEX IX_CATITEM_ACCN_ID
	ON CATALOGED_ITEM (ACCN_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_CATITEM_COLL_EVENT_ID
	ON CATALOGED_ITEM (COLLECTING_EVENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_CATITEM_COLL_ID
	ON CATALOGED_ITEM (COLLECTION_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_CATITEM_CATNUM_COLLID
	ON CATALOGED_ITEM (CAT_NUM, COLLECTION_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_CATALOGED_ITEM
	ON CATALOGED_ITEM (COLLECTION_OBJECT_ID)
	TABLESPACE UAM_IDX_1;

-- CITATION 
CREATE INDEX IX_CITATION_CITED
	ON CITATION (CITED_TAXON_NAME_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_CITATION_COID
	ON CITATION (COLLECTION_OBJECT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_CITATION_PUBID
	ON CITATION (PUBLICATION_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX ix_u_CITATION_ID
	ON CITATION (PUBLICATION_ID, IDENTIFICATION_ID)
	TABLESPACE UAM_IDX_1;

-- COLLECTING_EVENT 
CREATE INDEX IX_COLLEVENT_LOCID
	ON COLLECTING_EVENT (LOCALITY_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_COLLEVENT_LOCID_CEID
	ON COLLECTING_EVENT (LOCALITY_ID, COLLECTING_EVENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_COLLECTING_EVENT
	ON COLLECTING_EVENT (COLLECTING_EVENT_ID)
	TABLESPACE UAM_IDX_1;

-- COLLECTION 
CREATE UNIQUE INDEX PK_COLLECTION
	ON COLLECTION (COLLECTION_ID)
	TABLESPACE UAM_IDX_1;

-- COLLECTION_CONTACTS 
CREATE UNIQUE INDEX PK_COLLECTION_CONTACTS
	ON COLLECTION_CONTACTS (COLLECTION_CONTACT_ID)
	TABLESPACE UAM_IDX_1;

-- COLLECTOR 
CREATE INDEX IX_COLLECTOR_AGENTID
	ON COLLECTOR (AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_COLLECTOR_COID
	ON COLLECTOR (COLLECTION_OBJECT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_COLLECTOR_COLLNUM
	ON COLLECTOR (COLL_NUM)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_COLLECTOR_ROLE
	ON COLLECTOR (COLLECTOR_ROLE)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_COLLECTOR_COID_ORDER_ROLE
	ON COLLECTOR (COLLECTION_OBJECT_ID, COLL_ORDER, COLLECTOR_ROLE)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_COLLECTOR
	ON COLLECTOR (COLLECTION_OBJECT_ID, AGENT_ID, COLLECTOR_ROLE)
	TABLESPACE UAM_IDX_1;
	
-- COLLECTOR_FORMATTED 
CREATE UNIQUE INDEX PK_COLLECTOR_FORMATTED
	ON COLLECTOR_FORMATTED (COLLECTION_OBJECT_ID)
	TABLESPACE UAM_IDX_1;

-- COLL_OBJECT 
CREATE INDEX IX_COLLOBJECT_CONDITION
	ON COLL_OBJECT (CONDITION)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_COLLOBJECT_DISPOSITION
	ON COLL_OBJECT (COLL_OBJ_DISPOSITION)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_COLLOBJECT_ENTEREDPID
	ON COLL_OBJECT (ENTERED_PERSON_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_COLLOBJECT_LASTEDITEDPID
	ON COLL_OBJECT (LAST_EDITED_PERSON_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_COLL_OBJECT
	ON COLL_OBJECT (COLLECTION_OBJECT_ID)
	TABLESPACE UAM_IDX_1;

-- COLL_OBJECT_ENCUMBRANCE 
CREATE INDEX IX_COLLOBJECTENCUMBRANCE_COID
	ON COLL_OBJECT_ENCUMBRANCE (COLLECTION_OBJECT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_COLLOBJECTENCUMBRANCE_EID
	ON COLL_OBJECT_ENCUMBRANCE (ENCUMBRANCE_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_COLL_OBJECT_ENCUMBRANCE
	ON COLL_OBJECT_ENCUMBRANCE (ENCUMBRANCE_ID, COLLECTION_OBJECT_ID)
	TABLESPACE UAM_IDX_1;

-- COLL_OBJECT_REMARK 
CREATE UNIQUE INDEX PK_COLL_OBJECT_REMARK
	ON COLL_OBJECT_REMARK (COLLECTION_OBJECT_ID)
	TABLESPACE UAM_IDX_1;

-- COLL_OBJ_CONT_HIST 
CREATE INDEX IX_COLLOBJCONTHIST_CID
	ON COLL_OBJ_CONT_HIST (CONTAINER_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_COLLOBJCONTHIST_COID
	ON COLL_OBJ_CONT_HIST (COLLECTION_OBJECT_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_COLL_OBJ_CONT_HIST
	ON COLL_OBJ_CONT_HIST (COLLECTION_OBJECT_ID, CONTAINER_ID)
	TABLESPACE UAM_IDX_1;
	
-- COLL_OBJ_OTHER_ID_NUM 
CREATE INDEX IX_COLLOBJOIDN_COID
	ON COLL_OBJ_OTHER_ID_NUM (COLLECTION_OBJECT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_COLLOBJOIDN_DISPLAY
	ON COLL_OBJ_OTHER_ID_NUM (DISPLAY_VALUE)
	TABLESPACE UAM_IDX_1;
	
CREATE INDEX IX_UP_COLLOBJOIDN_DISPLAY ON COLL_OBJ_OTHER_ID_NUM (UPPER(DISPLAY_VALUE)) TABLESPACE UAM_IDX_1;


CREATE INDEX IX_COLLOBJOIDN_TYPE
	ON COLL_OBJ_OTHER_ID_NUM (OTHER_ID_TYPE)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_COLLOBJOIDN_COID_TYPE_DISP
	ON COLL_OBJ_OTHER_ID_NUM (COLLECTION_OBJECT_ID, OTHER_ID_TYPE, DISPLAY_VALUE)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_COLL_OBJ_OTHER_ID_NUM
	ON COLL_OBJ_OTHER_ID_NUM (COLL_OBJ_OTHER_ID_NUM_ID)
	TABLESPACE UAM_IDX_1;
	
-- COMMON_NAME 
CREATE INDEX IX_COMMONNAME_COMMONNAME
	ON COMMON_NAME (COMMON_NAME)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_COMMONNAME_COMMONNAME_UPR
	ON COMMON_NAME (UPPER(COMMON_NAME))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_COMMONNAME_TNID
	ON COMMON_NAME (TAXON_NAME_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_COMMON_NAME
	ON COMMON_NAME (TAXON_NAME_ID, COMMON_NAME)
	TABLESPACE UAM_IDX_1;

-- CONTAINER 
CREATE INDEX IX_CONTAINER_PCID
	ON CONTAINER (PARENT_CONTAINER_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_CONTAINER_PRINTFG
	ON CONTAINER (PRINT_FG)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_CONTAINER_BARCODE
	ON CONTAINER (BARCODE)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_CONTAINER
	ON CONTAINER (CONTAINER_ID)
	TABLESPACE UAM_IDX_1;
	
-- CONTAINER_CHECK 
CREATE UNIQUE INDEX PK_CONTAINER_CHECK
	ON CONTAINER_CHECK (CONTAINER_CHECK_ID)
	TABLESPACE UAM_IDX_1;

-- CONTAINER_HISTORY 
CREATE INDEX IX_CONTAINERHISTORY_CID
	ON CONTAINER_HISTORY (CONTAINER_ID)
	TABLESPACE UAM_IDX_1;

-- CORRESPONDENCE 
CREATE UNIQUE INDEX PK_CORRESPONDENCE
	ON CORRESPONDENCE (CORRESPONDENCE_ID)
	TABLESPACE UAM_IDX_1;

-- ELECTRONIC_ADDRESS 
CREATE INDEX IX_ELECTRONICADDRESS_AID
	ON ELECTRONIC_ADDRESS (AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_ELECTRONIC_ADDRESS
	ON ELECTRONIC_ADDRESS (AGENT_ID, ADDRESS_TYPE, ADDRESS)
	TABLESPACE UAM_IDX_1;

-- ENCUMBRANCE 
CREATE INDEX IX_ENCUMBRANCE_ENCACTION
	ON ENCUMBRANCE (ENCUMBRANCE_ACTION)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_ENCUMBRANCE_ENCAID
	ON ENCUMBRANCE (ENCUMBERING_AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_ENCUMBRANCE
	ON ENCUMBRANCE (ENCUMBRANCE_ID)
	TABLESPACE UAM_IDX_1;

-- FIELD_NOTEBOOK_SECTION 
CREATE UNIQUE INDEX PK_FIELD_NOTEBOOK_SECTION
	ON FIELD_NOTEBOOK_SECTION (PUBLICATION_ID)
	TABLESPACE UAM_IDX_1;

-- FLUID_CONTAINER_HISTORY 
CREATE INDEX IX_FLUICONTHIST_CID
	ON FLUID_CONTAINER_HISTORY (CONTAINER_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_FLUID_CONTAINER_HISTORY
	ON FLUID_CONTAINER_HISTORY (CONTAINER_ID, CHECKED_DATE)
	TABLESPACE UAM_IDX_1;

-- FORMATTED_PUBLICATION 
CREATE INDEX IX_FORMATTEDPUB_FORMATSTYLE
	ON FORMATTED_PUBLICATION (FORMAT_STYLE)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FORMATTEDPUB_FORMATTEDPUB
	ON FORMATTED_PUBLICATION (FORMATTED_PUBLICATION)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FORMATTEDPUB_PUBID
	ON FORMATTED_PUBLICATION (PUBLICATION_ID)
	TABLESPACE UAM_IDX_1;

-- GEOG_AUTH_REC 
CREATE INDEX IX_GEOGAUTHREC_CONTOCEAN
	ON GEOG_AUTH_REC (CONTINENT_OCEAN)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_GEOGAUTHREC_CONTOCEAN_UPR
	ON GEOG_AUTH_REC (UPPER(CONTINENT_OCEAN))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_GEOGAUTHREC_COUNTRY
	ON GEOG_AUTH_REC (COUNTRY)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_GEOGAUTHREC_COUNTRY_UPR
	ON GEOG_AUTH_REC (UPPER(COUNTRY))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_GEOGAUTHREC_COUNTY
	ON GEOG_AUTH_REC (COUNTY)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_GEOGAUTHREC_COUNTY_UPR
	ON GEOG_AUTH_REC (UPPER(COUNTY))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_GEOGAUTHREC_FEATURE
	ON GEOG_AUTH_REC (FEATURE)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_GEOGAUTHREC_ISLAND
	ON GEOG_AUTH_REC (ISLAND)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_GEOGAUTHREC_ISLANDGROUP
	ON GEOG_AUTH_REC (ISLAND_GROUP)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_GEOGAUTHREC_ISLANDGROUP_UPR
	ON GEOG_AUTH_REC (UPPER(ISLAND_GROUP))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_GEOGAUTHREC_ISLAND_UPR
	ON GEOG_AUTH_REC (UPPER(ISLAND))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_GEOGAUTHREC_QUAD
	ON GEOG_AUTH_REC (QUAD)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_GEOGAUTHREC_QUAD_UPR
	ON GEOG_AUTH_REC (UPPER(QUAD))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_GEOGAUTHREC_SEA
	ON GEOG_AUTH_REC (SEA)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_GEOGAUTHREC_SOURCEAUTHORITY
	ON GEOG_AUTH_REC (SOURCE_AUTHORITY)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_GEOGAUTHREC_STATEPROV
	ON GEOG_AUTH_REC (STATE_PROV)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_GEOGAUTHREC_STATEPROV_UPR
	ON GEOG_AUTH_REC (UPPER(STATE_PROV))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_GEOGAUTHREC_VALIDCATTERMFG
	ON GEOG_AUTH_REC (VALID_CATALOG_TERM_FG)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_GEOGAUTHREC_HIGHERGEOG
	ON GEOG_AUTH_REC (HIGHER_GEOG)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_GEOG_AUTH_REC
	ON GEOG_AUTH_REC (GEOG_AUTH_REC_ID)
	TABLESPACE UAM_IDX_1;
	
-- function stripGeogRanks is used by the data services geog-looker-upper and needs these to be less-slow	
create index ix_sr_geo_country on geog_auth_rec ( stripGeogRanks(country) ) tablespace uam_idx_1;
create index ix_sr_geo_state_prov on geog_auth_rec ( stripGeogRanks(state_prov) ) tablespace uam_idx_1;
create index ix_sr_geo_county on geog_auth_rec ( stripGeogRanks(county) ) tablespace uam_idx_1;
create index ix_sr_geo_island on geog_auth_rec ( stripGeogRanks(island) ) tablespace uam_idx_1;
create index ix_sr_geo_island_group on geog_auth_rec ( stripGeogRanks(island_group) ) tablespace uam_idx_1;


-- GEOLOGY_ATTRIBUTES 
CREATE UNIQUE INDEX PK_GEOLOGY_ATTRIBUTES
	ON GEOLOGY_ATTRIBUTES (GEOLOGY_ATTRIBUTE_ID)
	TABLESPACE UAM_IDX_1;

-- GEOLOGY_ATTRIBUTE_HIERARCHY 
CREATE UNIQUE INDEX IU_GEOLATTRHIER_VALUE
	ON GEOLOGY_ATTRIBUTE_HIERARCHY (ATTRIBUTE_VALUE)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_GEOLOGY_ATTRIBUTE_HIERARCHY
	ON GEOLOGY_ATTRIBUTE_HIERARCHY (GEOLOGY_ATTRIBUTE_HIERARCHY_ID)
	TABLESPACE UAM_IDX_1;

-- GROUP_MEMBER 
CREATE INDEX IX_GROUPMEMBER_GROUP
	ON GROUP_MEMBER (GROUP_AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_GROUPMEMBER_MEMBER
	ON GROUP_MEMBER (MEMBER_AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_GROUP_MEMBER
	ON GROUP_MEMBER (GROUP_AGENT_ID, MEMBER_AGENT_ID)
	TABLESPACE UAM_IDX_1;

-- IDENTIFICATION 
CREATE INDEX IX_IDENTIFICATION_COLLOBJID
	ON IDENTIFICATION (COLLECTION_OBJECT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_IDENTIFICATION_SCINAME_U
	ON IDENTIFICATION (UPPER(SCIENTIFIC_NAME))
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_IDENTIFICATION
	ON IDENTIFICATION (IDENTIFICATION_ID)
	TABLESPACE UAM_IDX_1;

-- IDENTIFICATION_AGENT 
CREATE INDEX IX_IDENTIFICATIONAGENT_AID
	ON IDENTIFICATION_AGENT (AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_IDENTIFICATIONAGENT_IID
	ON IDENTIFICATION_AGENT (IDENTIFICATION_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_IDENTIFICATIONAGENT_IID_AID
	ON IDENTIFICATION_AGENT (IDENTIFICATION_ID, AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_IDENTIFICATION_AGENT
	ON IDENTIFICATION_AGENT (IDENTIFICATION_AGENT_ID)
	TABLESPACE UAM_IDX_1;

-- IDENTIFICATION_TAXONOMY 
CREATE INDEX IX_IDENTIFICATIONTAXONOMY_IID
	ON IDENTIFICATION_TAXONOMY (IDENTIFICATION_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_IDENTIFICATIONTAXONOMY_TNID
	ON IDENTIFICATION_TAXONOMY (TAXON_NAME_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_IDENTIFICATION_TAXONOMY
	ON IDENTIFICATION_TAXONOMY (IDENTIFICATION_ID, TAXON_NAME_ID, VARIABLE)
	TABLESPACE UAM_IDX_1;

-- JOURNAL 
CREATE UNIQUE INDEX PK_JOURNAL
	ON JOURNAL (JOURNAL_ID)
	TABLESPACE UAM_IDX_1;

-- JOURNAL_ARTICLE 
CREATE INDEX IX_JOURNALARTICLE_JOURNALID
	ON JOURNAL_ARTICLE (JOURNAL_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_JOURNAL_ARTICLE
	ON JOURNAL_ARTICLE (PUBLICATION_ID)
	TABLESPACE UAM_IDX_1;

-- LAT_LONG 
CREATE INDEX IX_LATLONG_DECLAT
	ON LAT_LONG (DEC_LAT)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_LATLONG_DECLAT_DECLONG
	ON LAT_LONG (DEC_LAT, DEC_LONG)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_LATLONG_DECLONG
	ON LAT_LONG (DEC_LONG)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_LATLONG_DETERMINEDBY
	ON LAT_LONG (DETERMINED_BY_AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_LATLONG_LOCID
	ON LAT_LONG (LOCALITY_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_LAT_LONG
	ON LAT_LONG (LAT_LONG_ID)
	TABLESPACE UAM_IDX_1;

-- LOAN 
CREATE UNIQUE INDEX IU_LOAN_LOANNUM_PREFIX_SUFFIX
	ON LOAN (LOAN_NUM, LOAN_NUM_PREFIX, LOAN_NUM_SUFFIX)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_LOAN
	ON LOAN (TRANSACTION_ID)
	TABLESPACE UAM_IDX_1;

-- LOAN_INSTALLMENT 
CREATE UNIQUE INDEX PK_LOAN_INSTALLMENT
	ON LOAN_INSTALLMENT (TRANSACTION_ID)
	TABLESPACE UAM_IDX_1;

-- LOAN_ITEM 
CREATE INDEX IX_LOANITEM_COID
	ON LOAN_ITEM (COLLECTION_OBJECT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_LOANITEM_RECONCILEDBY
	ON LOAN_ITEM (RECONCILED_BY_PERSON_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_LOANITEM_TRANSID
	ON LOAN_ITEM (TRANSACTION_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_LOAN_ITEM
	ON LOAN_ITEM (TRANSACTION_ID, COLLECTION_OBJECT_ID)
	TABLESPACE UAM_IDX_1;

-- LOAN_REQUEST 
CREATE UNIQUE INDEX PK_LOAN_REQUEST
	ON LOAN_REQUEST (CORRESPONDENCE_ID)
	TABLESPACE UAM_IDX_1;

-- LOCALITY 
CREATE INDEX IX_LOCALITY_GEOGAUTHRECID
	ON LOCALITY (GEOG_AUTH_REC_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_LOCALITY_LOCID_GEOGAUTHREC
	ON LOCALITY (LOCALITY_ID, GEOG_AUTH_REC_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_LOCALITY
	ON LOCALITY (LOCALITY_ID)
	TABLESPACE UAM_IDX_1;

-- MEDIA 
CREATE INDEX IX_MEDIA_MEDIATYPE
	ON MEDIA (MEDIA_TYPE)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_MEDIA_MIMETYPE
	ON MEDIA (MIME_TYPE)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_MEDIA_MEDIAURI
	ON MEDIA (MEDIA_URI)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_MEDIA
	ON MEDIA (MEDIA_ID)
	TABLESPACE UAM_IDX_1;

-- MEDIA_LABELS 
CREATE INDEX IX_MEDIALABELS_ASSIGNEDYBYAID
	ON MEDIA_LABELS (ASSIGNED_BY_AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_MEDIALABELS_MID_LABEL_VALUE
	ON MEDIA_LABELS (MEDIA_ID, MEDIA_LABEL, LABEL_VALUE)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_MEDIA_LABELS
	ON MEDIA_LABELS (MEDIA_LABEL_ID)
	TABLESPACE UAM_IDX_1;

-- MEDIA_RELATIONS 
CREATE INDEX IX_MEDIARELATIONS_CREATEDBYAID
	ON MEDIA_RELATIONS (CREATED_BY_AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_MEDIARELATIONS_MEDIAID
	ON MEDIA_RELATIONS (MEDIA_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_MEDIARELATIONS_RELATEDPKEY
	ON MEDIA_RELATIONS (RELATED_PRIMARY_KEY)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_MEDIARELATIONS_RELATIONSHIP
	ON MEDIA_RELATIONS (MEDIA_RELATIONSHIP)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_MEDIA_RELATIONS
	ON MEDIA_RELATIONS (MEDIA_RELATIONS_ID)
	TABLESPACE UAM_IDX_1;

-- OBJECT_CONDITION 
CREATE UNIQUE INDEX IU_OBJCOND_COID_COND_AID_DATE
	ON OBJECT_CONDITION (COLLECTION_OBJECT_ID, CONDITION, DETERMINED_AGENT_ID, DETERMINED_DATE)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_OBJECT_CONDITION
	ON OBJECT_CONDITION (OBJECT_CONDITION_ID)
	TABLESPACE UAM_IDX_1;

-- PAGE 
CREATE INDEX IX_PAGE_PUBID
	ON PAGE (PUBLICATION_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_PAGE_SECTPAGEORDER_PAGENUM
	ON PAGE (SECTION_PAGE_ORDER, PAGE_NUM)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_PAGE
	ON PAGE (PAGE_ID)
	TABLESPACE UAM_IDX_1;

-- PERMIT 
CREATE INDEX IX_PERMIT_ISSUEDBY
	ON PERMIT (ISSUED_BY_AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_PERMIT_ISSUEDTO
	ON PERMIT (ISSUED_TO_AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_PERMIT
	ON PERMIT (PERMIT_ID)
	TABLESPACE UAM_IDX_1;

-- PERMIT_SHIPMENT 
CREATE UNIQUE INDEX PK_PERMIT_SHIPMENT
	ON PERMIT_SHIPMENT (PERMIT_ID)
	TABLESPACE UAM_IDX_1;

-- PERMIT_TRANS 
CREATE INDEX IX_PERMITTRANS_PERMITID
	ON PERMIT_TRANS (PERMIT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_PERMITTRANS_TRANSID
	ON PERMIT_TRANS (TRANSACTION_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_PERMIT_TRANS
	ON PERMIT_TRANS (PERMIT_ID, TRANSACTION_ID)
	TABLESPACE UAM_IDX_1;

-- PERSON 
CREATE UNIQUE INDEX PK_PERSON
	ON PERSON (PERSON_ID)
	TABLESPACE UAM_IDX_1;

-- PROJECT 
CREATE INDEX IX_PROJECT_PROJECTNAME_UPR
	ON PROJECT (UPPER(PROJECT_NAME))
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_PROJECT
	ON PROJECT (PROJECT_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_PROJECT_PROJECTNAME
	ON PROJECT (PROJECT_NAME)
	TABLESPACE UAM_IDX_1;

-- protect URLs which are formed from project name
create unique index iu_proj_niceurl_pname on project (niceURL(PROJECT_NAME)) tablespace uam_idx_1;


-- PROJECT_AGENT 
CREATE INDEX IX_PROJECTAGENT_ANID
	ON PROJECT_AGENT (AGENT_NAME_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_PROJECTAGENT_PROJID
	ON PROJECT_AGENT (PROJECT_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_PROJECT_AGENT
	ON PROJECT_AGENT (PROJECT_ID, AGENT_NAME_ID, PROJECT_AGENT_ROLE)
	TABLESPACE UAM_IDX_1;

-- PROJECT_PUBLICATION 
CREATE INDEX IX_PROJECTPUBLICATION_PROJID
	ON PROJECT_PUBLICATION (PROJECT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_PROJECTPUBLICATION_PUBID
	ON PROJECT_PUBLICATION (PUBLICATION_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_PROJECT_PUBLICATION
	ON PROJECT_PUBLICATION (PROJECT_ID, PUBLICATION_ID)
	TABLESPACE UAM_IDX_1;

-- PROJECT_SPONSOR 
CREATE UNIQUE INDEX PK_PROJECT_SPONSOR
	ON PROJECT_SPONSOR (PROJECT_SPONSOR_ID)
	TABLESPACE UAM_IDX_1;

-- PROJECT_TRANS 
CREATE INDEX IX_PROJECTTRANS_PROJID
	ON PROJECT_TRANS (PROJECT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_PROJECTTRANS_TRANSID
	ON PROJECT_TRANS (TRANSACTION_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_PROJECT_TRANS
	ON PROJECT_TRANS (PROJECT_ID, TRANSACTION_ID)
	TABLESPACE UAM_IDX_1;

-- PUBLICATION 
CREATE UNIQUE INDEX PK_PUBLICATION
	ON PUBLICATION (PUBLICATION_ID)
	TABLESPACE UAM_IDX_1;

-- PUBLICATION_ATTRIBUTES 
CREATE UNIQUE INDEX IU_PUBATTR_PUBID_ATTRIBUTE
	ON PUBLICATION_ATTRIBUTES (PUBLICATION_ID, PUBLICATION_ATTRIBUTE)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_PUBLICATION_ATTRIBUTES
	ON PUBLICATION_ATTRIBUTES (PUBLICATION_ATTRIBUTE_ID)
	TABLESPACE UAM_IDX_1;

-- PUBLICATION_AUTHOR_NAME 
CREATE INDEX IX_PUBAUTHNAME_ANID
	ON PUBLICATION_AUTHOR_NAME (AGENT_NAME_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_PUBAUTHNAME_PUBID
	ON PUBLICATION_AUTHOR_NAME (PUBLICATION_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_PUBAUTHNAME_PUBID_ANID
	ON PUBLICATION_AUTHOR_NAME (PUBLICATION_ID, AGENT_NAME_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_PUBAUTHNAME_PUBID_POSITION
	ON PUBLICATION_AUTHOR_NAME (PUBLICATION_ID, AUTHOR_POSITION)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_PUBLICATION_AUTHOR_NAME
	ON PUBLICATION_AUTHOR_NAME (PUBLICATION_AUTHOR_NAME_ID)
	TABLESPACE UAM_IDX_1;

--PUBLICATION_URL 
CREATE UNIQUE INDEX PK_PUBLICATION_URL
	ON PUBLICATION_URL (PUBLICATION_URL_ID)
	TABLESPACE UAM_IDX_1;

-- SHIPMENT 
CREATE INDEX IX_SHIPMENT_TRANSID
	ON SHIPMENT (TRANSACTION_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_SHIPMENT_CONTID
	ON SHIPMENT (CONTAINER_ID)
	TABLESPACE UAM_IDX_1;

-- SPECIMEN_ANNOTATIONS 
CREATE UNIQUE INDEX PK_SPECIMEN_ANNOTATIONS
	ON SPECIMEN_ANNOTATIONS (ANNOTATION_ID)
	TABLESPACE UAM_IDX_1;

-- SPECIMEN_PART 
CREATE INDEX IX_SPECIMENPART_DERIVEDFROM
	ON SPECIMEN_PART (DERIVED_FROM_CAT_ITEM)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_SPECIMENPART_PARTNAME
	ON SPECIMEN_PART (PART_NAME)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_SPECIMENPART_SAMPLEDFROM
	ON SPECIMEN_PART (SAMPLED_FROM_OBJ_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_SPECIMEN_PART
	ON SPECIMEN_PART (COLLECTION_OBJECT_ID)
	TABLESPACE UAM_IDX_1;

-- TAG 
CREATE UNIQUE INDEX PK_TAG
	ON TAG (TAG_ID)
	TABLESPACE UAM_IDX_1;

-- TAXONOMY 
CREATE INDEX IX_TAXONOMY_FULLTAXONNAME
	ON TAXONOMY (FULL_TAXON_NAME)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_TAXONOMY_NOMENCLATURALCODE
	ON TAXONOMY (NOMENCLATURAL_CODE)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_TAXONOMY_PHYLCLASS
	ON TAXONOMY (PHYLCLASS)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_TAXONOMY_PHYLORDER
	ON TAXONOMY (PHYLORDER)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_TAXONOMY_SCINAME_UPR
	ON TAXONOMY (UPPER(SCIENTIFIC_NAME))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_TAXONOMY_SOURCEAUTHORITY
	ON TAXONOMY (SOURCE_AUTHORITY)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_TAXONOMY_TNID_SCINAME_FULL
	ON TAXONOMY (TAXON_NAME_ID, SCIENTIFIC_NAME, FULL_TAXON_NAME)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_TAXONOMY_VALIDCATALOGTERM
	ON TAXONOMY (VALID_CATALOG_TERM_FG)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_TAXONOMY_SCINAME
	ON TAXONOMY (SCIENTIFIC_NAME)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_TAXONOMY
	ON TAXONOMY (TAXON_NAME_ID)
	TABLESPACE UAM_IDX_1;

-- TAXON_RELATIONS 
CREATE INDEX IX_TAXONRELNS_RELATED
	ON TAXON_RELATIONS (RELATED_TAXON_NAME_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_TAXONRELNS_TNID
	ON TAXON_RELATIONS (TAXON_NAME_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_TAXONRELNS_TNID_RELATED
	ON TAXON_RELATIONS (TAXON_NAME_ID, RELATED_TAXON_NAME_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_TAXON_RELATIONS
	ON TAXON_RELATIONS (TAXON_NAME_ID, RELATED_TAXON_NAME_ID, TAXON_RELATIONSHIP)
	TABLESPACE UAM_IDX_1;

-- TRANS 
CREATE INDEX IX_TRANS_AUTH
	ON TRANS (AUTH_AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_TRANS_ENTERED
	ON TRANS (TRANS_ENTERED_AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_TRANS_RECEIVED
	ON TRANS (RECEIVED_AGENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_TRANS
	ON TRANS (TRANSACTION_ID)
	TABLESPACE UAM_IDX_1;

-- TRANS_AGENT
CREATE UNIQUE INDEX IU_TRANSAGENT_TID_AID_ROLE
	ON TRANS_AGENT(TRANSACTION_ID, AGENT_ID, TRANS_AGENT_ROLE)
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX PK_TRANS_AGENT
	ON TRANS_AGENT (TRANS_AGENT_ID)
	TABLESPACE UAM_IDX_1;
