/*
select 'create public synonym ' || s.synonym_name || ' for ' || s.table_name || ';'
from all_synonyms s, dba_objects o
where s.table_owner = o.owner
and s.table_name = o.object_name
and s.table_owner = 'UAM'
and o.object_type = 'VIEW'
*/

create public synonym ACCEPTED_LAT_LONG for ACCEPTED_LAT_LONG;
create public synonym COLL_NAMES for COLL_NAMES;
create public synonym CTGEOLOGY_ATTRIBUTE for CTGEOLOGY_ATTRIBUTE;
create public synonym FILTERED_FLAT for FILTERED_FLAT;
create public synonym LAM_FILTERED_FLAT for LAM_FILTERED_FLAT;
create public synonym LOC_ACCEPTED_LAT_LONG for LOC_ACCEPTED_LAT_LONG;
create public synonym OLD_AGENTS for OLD_AGENTS;
create public synonym ORPHANEDCATALOGED_ITEMS for ORPHANEDCATALOGED_ITEMS;
create public synonym ORPHANEDCOLLECTORS for ORPHANEDCOLLECTORS;
create public synonym ORPHANEDIDENTIFICATIONS for ORPHANEDIDENTIFICATIONS;
create public synonym PREFERRED_AGENT_NAME for PREFERRED_AGENT_NAME;
create public synonym PREP_NAMES for PREP_NAMES;
create public synonym PROJECT_MEDIA_RELATION_VIEW for PROJECT_MEDIA_RELATION_VIEW;
create public synonym SCIENTIFIC_NAME_WITH_AUTHOR for SCIENTIFIC_NAME_WITH_AUTHOR;
create public synonym SPC2 for SPC2;
create public synonym SPEC_WITH_LOC for SPEC_WITH_LOC;
create public synonym TAXA_TERMS for TAXA_TERMS;
