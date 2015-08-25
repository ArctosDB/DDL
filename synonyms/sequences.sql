/*
select 'create public synonym ' || s.synonym_name || ' for ' || s.table_name || ';'
from all_synonyms s, dba_objects o
where s.table_owner = o.owner
and s.table_name = o.object_name
and s.table_owner = 'UAM'
and o.object_type = 'SEQUENCE'
*/

create public synonym BARCODE_VALUES for BARCODE_VALUES;
create public synonym BLONLINE_PKEY for BLONLINE_PKEY;
create public synonym BULKLOADER_PKEY for BULKLOADER_PKEY;
create public synonym CO for CO;
create public synonym COLL_OBJ_OTHER_ID_NUM_SEQ for COLL_OBJ_OTHER_ID_NUM_SEQ;
create public synonym CONTAINER_CHECK_SEQ for CONTAINER_CHECK_SEQ;
create public synonym DGR_LOCATOR_SEQ for DGR_LOCATOR_SEQ;
create public synonym ENCUMBRANCE_ID for ENCUMBRANCE_ID;
create public synonym IPNI_SEQ for IPNI_SEQ;
create public synonym IPNI_TAX for IPNI_TAX;
create public synonym JUSTNUMBERS for JUSTNUMBERS;
create public synonym LAT_LONG_ID_SEQ for LAT_LONG_ID_SEQ;
create public synonym LLIDSEQ for LLIDSEQ;
create public synonym LOCALITY_ID_SEQ for LOCALITY_ID_SEQ;
create public synonym PART_HIERARCHY_SEQ for PART_HIERARCHY_SEQ;
create public synonym PLSQL_PROFILER_RUNNUMBER for PLSQL_PROFILER_RUNNUMBER;
create public synonym QUERYSTATS_SEQ for QUERYSTATS_SEQ;
create public synonym SEQCONTAINER_ID for SEQCONTAINER_ID;
create public synonym SEQ_CF_USER_LOAN for SEQ_CF_USER_LOAN;
create public synonym SEQ_CONTAINER for SEQ_CONTAINER;
create public synonym SEQ_MEDIA_RELATIONS for SEQ_MEDIA_RELATIONS;
create public synonym SEQ_TAXON_NAME_ID for SEQ_TAXON_NAME_ID;
create public synonym SOMERANDOMSEQUENCE for SOMERANDOMSEQUENCE;
create public synonym SPARKY for SPARKY;
create public synonym SQ_ADDR_ID for SQ_ADDR_ID;
create public synonym SQ_AGENT_ID for SQ_AGENT_ID;
create public synonym SQ_AGENT_NAME_ID for SQ_AGENT_NAME_ID;
create public synonym SQ_ALA_IMAGE_ID for SQ_ALA_IMAGE_ID;
create public synonym SQ_ATTRIBUTE_ID for SQ_ATTRIBUTE_ID;
create public synonym SQ_COLLECTING_EVENT_ID for SQ_COLLECTING_EVENT_ID;
create public synonym SQ_COLLECTION_CONTACT_ID for SQ_COLLECTION_CONTACT_ID;
create public synonym SQ_COLLECTION_ID for SQ_COLLECTION_ID;
create public synonym SQ_COLLECTION_OBJECT_ID for SQ_COLLECTION_OBJECT_ID;
create public synonym SQ_COLL_OBJ_OTHER_ID_NUM_ID for SQ_COLL_OBJ_OTHER_ID_NUM_ID;
create public synonym SQ_CONTAINER_CHECK_ID for SQ_CONTAINER_CHECK_ID;
create public synonym SQ_CONTAINER_ID for SQ_CONTAINER_ID;
create public synonym SQ_ENCUMBRANCE_ID for SQ_ENCUMBRANCE_ID;
create public synonym SQ_GEOG_AUTH_REC_ID for SQ_GEOG_AUTH_REC_ID;
create public synonym SQ_GEOLOGY_ATTRIBUTE_HIER_ID for SQ_GEOLOGY_ATTRIBUTE_HIER_ID;
create public synonym SQ_IDENTIFICATION_ID for SQ_IDENTIFICATION_ID;
create public synonym SQ_JOURNAL_ID for SQ_JOURNAL_ID;
create public synonym SQ_LAT_LONG_ID for SQ_LAT_LONG_ID;
create public synonym SQ_LOCALITY_ID for SQ_LOCALITY_ID;
create public synonym SQ_MEDIA_ID for SQ_MEDIA_ID;
create public synonym SQ_PERMIT_ID for SQ_PERMIT_ID;
create public synonym SQ_PROJECT_ID for SQ_PROJECT_ID;
create public synonym SQ_PUBLICATION_ID for SQ_PUBLICATION_ID;
create public synonym SQ_PUBLICATION_URL_ID for SQ_PUBLICATION_URL_ID;
create public synonym SQ_TAG_ID for SQ_TAG_ID;
create public synonym SQ_TAXON_NAME_ID for SQ_TAXON_NAME_ID;
create public synonym SQ_TRANSACTION_ID for SQ_TRANSACTION_ID;
create public synonym TAXNUM for TAXNUM;
create public synonym TCS for TCS;
create public synonym TOAD_SEQ for TOAD_SEQ;
create public synonym T_S for T_S;
