/*
select 'grant ' || privilege || ' on ' || TABLE_NAME || ' to ' || grantee || ';'
from dba_tab_privs tp, dba_objects o
where tp.TABLE_NAME = o.object_name
and tp.owner = 'UAM'
and o.owner = 'UAM'
and object_type = 'PROCEDURE'
order by table_name, grantee, privilege
*/

grant EXECUTE on BUILD_COLL_CODE_TABLES to PUBLIC;
grant EXECUTE on BULKLOADER_STAGE_CHECK to PUBLIC;
grant EXECUTE on MAKEDGRFREEZERPOSITIONS to DGR_LOCATOR;
grant EXECUTE on PARSE_OTHER_ID to COLDFUSION_USER;
grant EXECUTE on PARSE_OTHER_ID to MANAGE_SPECIMENS;
grant EXECUTE on PARSE_OTHER_ID to PUBLIC;
