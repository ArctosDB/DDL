/*
select 'grant ' || privilege || ' on ' || TABLE_NAME || ' to ' || grantee || ';'
from dba_tab_privs tp, dba_objects o
where tp.TABLE_NAME = o.object_name
and tp.owner = 'UAM'
and o.owner = 'UAM'
and object_type = 'VIEW'
order by table_name, grantee, privilege
*/

grant SELECT on ACCEPTED_LAT_LONG to PUBLIC;
grant SELECT on ACCEPTED_LAT_LONG to UAM_QUERY;
grant SELECT on ARCTOS_AUDIT_VW to COLDFUSION_USER;
grant SELECT on COLL_NAMES to UAM_QUERY;
grant SELECT on CTGEOLOGY_ATTRIBUTE to PUBLIC;
grant SELECT on FILTERED_FLAT to DIGIR_QUERY;
grant SELECT on FILTERED_FLAT to PUBLIC;
grant SELECT on FILTERED_FLAT to UAM_QUERY;
grant SELECT on FORM_PUB_AUTH_YEAR to UAM_QUERY;
grant SELECT on FORM_PUB_FULL_CIT to UAM_QUERY;
grant SELECT on FP to UAM_QUERY;
grant SELECT on LOC_ACCEPTED_LAT_LONG to PUBLIC;
grant SELECT on LOC_ACC_LAT_LONG to PUBLIC;
grant SELECT on OLD_AGENTS to UAM_QUERY;
grant SELECT on ORPHANEDCATALOGED_ITEMS to UAM_QUERY;
grant SELECT on ORPHANEDCOLLECTORS to UAM_QUERY;
grant SELECT on ORPHANEDIDENTIFICATIONS to UAM_QUERY;
grant SELECT on PREFERRED_AGENT_NAME to PUBLIC;
grant SELECT on PREFERRED_AGENT_NAME to UAM_QUERY;
grant SELECT on PREP_NAMES to UAM_QUERY;
grant SELECT on PROJECT_MEDIA_RELATION_VIEW to PUBLIC;
grant SELECT on SEX to UAM_QUERY;
grant UPDATE on SPEC_WITH_LOC to MANAGE_SPECIMENS;
grant SELECT on SPEC_WITH_LOC to PUBLIC;
grant SELECT on TAXA_TERMS to PUBLIC;
