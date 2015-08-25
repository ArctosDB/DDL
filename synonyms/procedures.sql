/*
select 'create public synonym ' || s.synonym_name || ' for ' || s.table_name || ';'
from all_synonyms s, dba_objects o
where s.table_owner = o.owner
and s.table_name = o.object_name
and s.table_owner = 'UAM'
and o.object_type = 'PROCEDURE'
*/        

create public synonym BULKLOADER_STAGE_CHECK for BULKLOADER_STAGE_CHECK;
create public synonym MAKEDGRFREEZERPOSITIONS for MAKEDGRFREEZERPOSITIONS;
create public synonym PARSE_OTHER_ID for PARSE_OTHER_ID;
        