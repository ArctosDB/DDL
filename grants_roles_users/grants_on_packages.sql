/*
select 'grant ' || privilege || ' on ' || TABLE_NAME || ' to ' || grantee || ';'
from dba_tab_privs tp, dba_objects o
where tp.TABLE_NAME = o.object_name
and tp.owner = 'UAM'
and o.owner = 'UAM'
and object_type = 'PACKAGE'
order by table_name, grantee, privilege
*/

grant EXECUTE on APP_SECURITY_CONTEXT to BRADTRUETT;
grant EXECUTE on APP_SECURITY_CONTEXT to HBASSETT;
grant EXECUTE on APP_SECURITY_CONTEXT to KAGOBROSKI;
grant EXECUTE on APP_SECURITY_CONTEXT to LLAWSON;
grant EXECUTE on APP_SECURITY_CONTEXT to MPICCHIONE;
grant EXECUTE on APP_SECURITY_CONTEXT to PUBLIC;
grant EXECUTE on APP_SECURITY_CONTEXT to SWRIGHT;
