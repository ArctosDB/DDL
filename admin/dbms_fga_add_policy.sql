/* add policies for UAM tables */

/* execute as user UAM */
CREATE USER uam_aud
    IDENTIFIED BY "secret_password"
    PROFILE arctos_user
    DEFAULT TABLESPACE USERS
    QUOTA 1G ON USERS;
    
GRANT CONNECT TO uam_aud;

CREATE OR REPLACE VIEW arctos_audit AS
    SELECT 
        TIMESTAMP, 
        DB_USER, 
        OBJECT_NAME, 
        regexp_replace(regexp_replace(SQL_TEXT,'[^[:print:]]',' '),'[    ]+',' ') AS SQL_TEXT,
        sql_bind
	FROM dba_fga_audit_trail;

/* execute as user SYS */
GRANT EXECUTE ON dbms_fga TO uam_aud;

GRANT SELECT ON uam.arctos_audit TO coldfusion_user;

/* execute as user uam_aud */

/* add policies to these tables
	ACCN
	ADDR
	AGENT
	AGENT_NAME
--AGENT_RANK (admin table	
	AGENT_RELATIONS
--ANNOTATIONS	
	ATTRIBUTES
--BINARY_OBJECT
	BIOL_INDIV_RELATIONS
--	BOOK -- replaced by publication_attributes
--	BOOK_SECTION -- replaced by publication_attributes
	BORROW
	CATALOGED_ITEM
	CITATION
	COLLECTING_EVENT
	COLLECTION
	COLLECTION_CONTACTS
	COLLECTOR
--COLLECTOR_FORMATTED
	COLL_OBJECT
	COLL_OBJECT_ENCUMBRANCE
	COLL_OBJECT_REMARK
	COLL_OBJ_CONT_HIST
	COLL_OBJ_OTHER_ID_NUM
	COMMON_NAME
	CONTAINER
	CONTAINER_CHECK
	CONTAINER_HISTORY
--DGR_LOCATOR
	ELECTRONIC_ADDRESS
	ENCUMBRANCE
--  FIELD_NOTEBOOK_SECTION -- replaced by publication_attributes
	FLUID_CONTAINER_HISTORY
--FORMATTED_PUBLICATION
	GEOG_AUTH_REC
	GEOLOGY_ATTRIBUTES
--GEOLOGY_ATTRIBUTE_HIERARCHY
--  GREF_PAGE_REFSET_NG
--  GREF_REFSET_NG
--  GREF_REFSET_ROI_NG
--  GREF_ROI_NG
--  GREF_ROI_VALUE_NG
--  GREF_USER
	GROUP_MEMBER
	IDENTIFICATION
	IDENTIFICATION_AGENT
	IDENTIFICATION_TAXONOMY
--  JOURNAL -- replaced by publication_attributes
--  JOURNAL_ARTICLE -- replaced by publication_attributes
	LAT_LONG
	LOAN
	LOAN_ITEM
--LOAN REQUEST
	LOCALITY
	MEDIA
	MEDIA_LABELS
	MEDIA_RELATIONS
	OBJECT_CONDITION
--  PAGE -- only used by gref tables
	PERMIT
--  PERMIT_SHIPMENT -- drop this table? not used; no data.
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
	SPECIMEN_ANNOTATIONS -- replaced by annotations.
	SPECIMEN_PART
--TAB_MEDIA_REL_FKEY
--TAG
	TAXONOMY
	TAXON_RELATIONS
	TRANS
	TRANS_AGENT
 */
    
/* execute as user UAM_AUD */

/*
begin
for tn in (
        select table_name
        from user_tables
        where table_name in (
                'ACCN',
                'ADDR',
                'AGENT',
                'AGENT_NAME',
                'AGENT_RELATIONS',
                'ATTRIBUTES',
                'BIOL_INDIV_RELATIONS',
                'BORROW',
                'CATALOGED_ITEM',
                'CITATION',
                'COLLECTING_EVENT',
                'COLLECTION',
                'COLLECTION_CONTACTS',
                'COLLECTOR',
                'COLL_OBJECT',
                'COLL_OBJECT_ENCUMBRANCE',
                'COLL_OBJECT_REMARK',
                'COLL_OBJ_CONT_HIST',
                'COLL_OBJ_OTHER_ID_NUM',
                'COMMON_NAME',
                'CONTAINER',
                'CONTAINER_CHECK',
                'CONTAINER_HISTORY',
                'DGR_LOCATOR',
                'ELECTRONIC_ADDRESS',
                'ENCUMBRANCE',
                'FLUID_CONTAINER_HISTORY',
                'GEOG_AUTH_REC',
                'GEOLOGY_ATTRIBUTES',
                'GEOLOGY_ATTRIBUTE_HIERARCHY',
--                'GREF_PAGE_REFSET_NG',
--                'GREF_REFSET_NG',
--                'GREF_REFSET_ROI_NG',
--                'GREF_ROI_NG',
--                'GREF_ROI_VALUE_NG',
--                'GREF_USER',
                'GROUP_MEMBER',
                'IDENTIFICATION',
                'IDENTIFICATION_AGENT',
                'IDENTIFICATION_TAXONOMY',
                'LAT_LONG',
                'LOAN',
                'LOAN_ITEM',
                'LOCALITY',
                'MEDIA',
                'MEDIA_LABELS',
                'MEDIA_RELATIONS',
                'OBJECT_CONDITION',
--                'PAGE',
                'PERMIT',
                'PERMIT_TRANS',
                'PERSON',
                'PROJECT',
                'PROJECT_AGENT',
                'PROJECT_PUBLICATION',
                'PROJECT_SPONSOR',
                'PROJECT_TRANS',
                'PUBLICATION',
                'PUBLICATION_ATTRIBUTES',
                'PUBLICATION_AUTHOR_NAME',
                'PUBLICATION_URL',
                'SHIPMENT',
                'SPECIMEN_ANNOTATIONS',
                'SPECIMEN_PART',
                'TAB_MEDIA_REL_FKEY',
                'TAXONOMY',
                'TAXON_RELATIONS',
                'TRANS',
                'TRANS_AGENT')
        order by table_name
) loop
        dbms_output.put_line('BEGIN dbms_fga.drop_policy(''UAM'',''' || tn.table_name || ''',''' || tn.table_name || '''); END;');

        dbms_output.put_line('BEGIN dbms_fga.add_policy(object_schema =>''UAM'', object_name => ''' || tn.table_name || ''', policy_name => ''' || tn.table_name || ''', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => ''INSERT, UPDATE, DELETE'', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;');
end loop;
end;

*/

SELECT policy_name FROM dba_audit_policies ORDER BY policy_name;
select count(*) from DBA_FGA_AUDIT_TRAIL;

/* create policies as uam_aud */

BEGIN
dbms_fga.drop_policy('UAM','ACCN','ACCN');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'ACCN',
	policy_name => 'ACCN',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','ADDR','ADDR');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'ADDR',
	policy_name => 'ADDR',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','AGENT','AGENT');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'AGENT',
	policy_name => 'AGENT',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','AGENT_NAME','AGENT_NAME');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'AGENT_NAME',
	policy_name => 'AGENT_NAME',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','AGENT_RELATIONS','AGENT_RELATIONS');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'AGENT_RELATIONS',
	policy_name => 'AGENT_RELATIONS',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','ATTRIBUTES','ATTRIBUTES');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'ATTRIBUTES',
	policy_name => 'ATTRIBUTES',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','BIOL_INDIV_RELATIONS','BIOL_INDIV_RELATIONS');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'BIOL_INDIV_RELATIONS',
	policy_name => 'BIOL_INDIV_RELATIONS',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','BORROW','BORROW');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'BORROW',
	policy_name => 'BORROW',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

-- BULKLOADER FGA POLICY added 10/19/2010
BEGIN
dbms_fga.drop_policy('UAM','BULKLOADER','BULKLOADER');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'BULKLOADER',
	policy_name => 'BULKLOADER',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;
-- BULKLOADER FGA POLICY added 10/19/2010

BEGIN
dbms_fga.drop_policy('UAM','CATALOGED_ITEM','CATALOGED_ITEM');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'CATALOGED_ITEM',
	policy_name => 'CATALOGED_ITEM',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','CITATION','CITATION');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'CITATION',
	policy_name => 'CITATION',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','COLLECTING_EVENT','COLLECTING_EVENT');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'COLLECTING_EVENT',
	policy_name => 'COLLECTING_EVENT',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','COLLECTION','COLLECTION');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'COLLECTION',
	policy_name => 'COLLECTION',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','COLLECTION_CONTACTS','COLLECTION_CONTACTS');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'COLLECTION_CONTACTS',
	policy_name => 'COLLECTION_CONTACTS',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','COLLECTOR','COLLECTOR');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'COLLECTOR',
	policy_name => 'COLLECTOR',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','COLL_OBJECT','COLL_OBJECT');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'COLL_OBJECT',
	policy_name => 'COLL_OBJECT',
	audit_condition => NULL,
	audit_column => 'COLL_OBJECT_TYPE,ENTERED_PERSON_ID,COLL_OBJECT_ENTERED_DATE,COLL_OBJ_DISPOSITION,LOT_COUNT,CONDITION,FLAGS',
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','COLL_OBJECT_ENCUMBRANCE','COLL_OBJECT_ENCUMBRANCE');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'COLL_OBJECT_ENCUMBRANCE',
	policy_name => 'COLL_OBJECT_ENCUMBRANCE',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','COLL_OBJECT_REMARK','COLL_OBJECT_REMARK');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'COLL_OBJECT_REMARK',
	policy_name => 'COLL_OBJECT_REMARK',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','COLL_OBJ_CONT_HIST','COLL_OBJ_CONT_HIST');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'COLL_OBJ_CONT_HIST',
	policy_name => 'COLL_OBJ_CONT_HIST',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','COLL_OBJ_OTHER_ID_NUM','COLL_OBJ_OTHER_ID_NUM');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'COLL_OBJ_OTHER_ID_NUM',
	policy_name => 'COLL_OBJ_OTHER_ID_NUM',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','COMMON_NAME','COMMON_NAME');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'COMMON_NAME',
	policy_name => 'COMMON_NAME',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','CONTAINER','CONTAINER');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'CONTAINER',
	policy_name => 'CONTAINER',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','CONTAINER_CHECK','CONTAINER_CHECK');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'CONTAINER_CHECK',
	policy_name => 'CONTAINER_CHECK',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','CONTAINER_HISTORY','CONTAINER_HISTORY');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'CONTAINER_HISTORY',
	policy_name => 'CONTAINER_HISTORY',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','DGR_LOCATOR','DGR_LOCATOR');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'DGR_LOCATOR',
	policy_name => 'DGR_LOCATOR',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','ELECTRONIC_ADDRESS','ELECTRONIC_ADDRESS');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'ELECTRONIC_ADDRESS',
	policy_name => 'ELECTRONIC_ADDRESS',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','ENCUMBRANCE','ENCUMBRANCE');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'ENCUMBRANCE',
	policy_name => 'ENCUMBRANCE',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','FLUID_CONTAINER_HISTORY','FLUID_CONTAINER_HISTORY');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'FLUID_CONTAINER_HISTORY',
	policy_name => 'FLUID_CONTAINER_HISTORY',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','GEOG_AUTH_REC','GEOG_AUTH_REC');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'GEOG_AUTH_REC',
	policy_name => 'GEOG_AUTH_REC',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','GEOLOGY_ATTRIBUTES','GEOLOGY_ATTRIBUTES');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'GEOLOGY_ATTRIBUTES',
	policy_name => 'GEOLOGY_ATTRIBUTES',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','GEOLOGY_ATTRIBUTE_HIERARCHY','GEOLOGY_ATTRIBUTE_HIERARCHY');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'GEOLOGY_ATTRIBUTE_HIERARCHY',
	policy_name => 'GEOLOGY_ATTRIBUTE_HIERARCHY',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

/*
BEGIN
dbms_fga.drop_policy('UAM','GREF_PAGE_REFSET_NG','GREF_PAGE_REFSET_NG');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'GREF_PAGE_REFSET_NG',
	policy_name => 'GREF_PAGE_REFSET_NG',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','GREF_REFSET_NG','GREF_REFSET_NG');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'GREF_REFSET_NG',
	policy_name => 'GREF_REFSET_NG',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','GREF_REFSET_ROI_NG','GREF_REFSET_ROI_NG');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'GREF_REFSET_ROI_NG',
	policy_name => 'GREF_REFSET_ROI_NG',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','GREF_ROI_NG','GREF_ROI_NG');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'GREF_ROI_NG',
	policy_name => 'GREF_ROI_NG',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','GREF_ROI_VALUE_NG','GREF_ROI_VALUE_NG');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'GREF_ROI_VALUE_NG',
	policy_name => 'GREF_ROI_VALUE_NG',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','GREF_USER','GREF_USER');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'GREF_USER',
	policy_name => 'GREF_USER',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

*/

BEGIN
dbms_fga.drop_policy('UAM','GROUP_MEMBER','GROUP_MEMBER');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'GROUP_MEMBER',
	policy_name => 'GROUP_MEMBER',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','IDENTIFICATION','IDENTIFICATION');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'IDENTIFICATION',
	policy_name => 'IDENTIFICATION',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','IDENTIFICATION_AGENT','IDENTIFICATION_AGENT');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'IDENTIFICATION_AGENT',
	policy_name => 'IDENTIFICATION_AGENT',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','IDENTIFICATION_TAXONOMY','IDENTIFICATION_TAXONOMY');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'IDENTIFICATION_TAXONOMY',
	policy_name => 'IDENTIFICATION_TAXONOMY',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','LAT_LONG','LAT_LONG');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'LAT_LONG',
	policy_name => 'LAT_LONG',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','LOAN','LOAN');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'LOAN',
	policy_name => 'LOAN',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','LOAN_ITEM','LOAN_ITEM');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'LOAN_ITEM',
	policy_name => 'LOAN_ITEM',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','LOCALITY','LOCALITY');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'LOCALITY',
	policy_name => 'LOCALITY',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','MEDIA','MEDIA');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'MEDIA',
	policy_name => 'MEDIA',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','MEDIA_LABELS','MEDIA_LABELS');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'MEDIA_LABELS',
	policy_name => 'MEDIA_LABELS',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','MEDIA_RELATIONS','MEDIA_RELATIONS');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'MEDIA_RELATIONS',
	policy_name => 'MEDIA_RELATIONS',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','OBJECT_CONDITION','OBJECT_CONDITION');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'OBJECT_CONDITION',
	policy_name => 'OBJECT_CONDITION',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

/*
BEGIN
dbms_fga.drop_policy('UAM','PAGE','PAGE');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'PAGE',
	policy_name => 'PAGE',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

*/

BEGIN
dbms_fga.drop_policy('UAM','PERMIT','PERMIT');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'PERMIT',
	policy_name => 'PERMIT',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','PERMIT_TRANS','PERMIT_TRANS');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'PERMIT_TRANS',
	policy_name => 'PERMIT_TRANS',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','PERSON','PERSON');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'PERSON',
	policy_name => 'PERSON',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','PROJECT','PROJECT');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'PROJECT',
	policy_name => 'PROJECT',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','PROJECT_AGENT','PROJECT_AGENT');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'PROJECT_AGENT',
	policy_name => 'PROJECT_AGENT',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','PROJECT_PUBLICATION','PROJECT_PUBLICATION');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'PROJECT_PUBLICATION',
	policy_name => 'PROJECT_PUBLICATION',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','PROJECT_SPONSOR','PROJECT_SPONSOR');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'PROJECT_SPONSOR',
	policy_name => 'PROJECT_SPONSOR',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','PROJECT_TRANS','PROJECT_TRANS');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'PROJECT_TRANS',
	policy_name => 'PROJECT_TRANS',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','PUBLICATION','PUBLICATION');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'PUBLICATION',
	policy_name => 'PUBLICATION',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','PUBLICATION_ATTRIBUTES','PUBLICATION_ATTRIBUTES');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'PUBLICATION_ATTRIBUTES',
	policy_name => 'PUBLICATION_ATTRIBUTES',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','PUBLICATION_AUTHOR_NAME','PUBLICATION_AUTHOR_NAME');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'PUBLICATION_AUTHOR_NAME',
	policy_name => 'PUBLICATION_AUTHOR_NAME',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','PUBLICATION_URL','PUBLICATION_URL');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'PUBLICATION_URL',
	policy_name => 'PUBLICATION_URL',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','SHIPMENT','SHIPMENT');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'SHIPMENT',
	policy_name => 'SHIPMENT',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','SPECIMEN_ANNOTATIONS','SPECIMEN_ANNOTATIONS');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'SPECIMEN_ANNOTATIONS',
	policy_name => 'SPECIMEN_ANNOTATIONS',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','SPECIMEN_PART','SPECIMEN_PART');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'SPECIMEN_PART',
	policy_name => 'SPECIMEN_PART',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','TAB_MEDIA_REL_FKEY','TAB_MEDIA_REL_FKEY');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'TAB_MEDIA_REL_FKEY',
	policy_name => 'TAB_MEDIA_REL_FKEY',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','TAXONOMY','TAXONOMY');
END;

/*
-- fga policies follow renamed tables.  when renaming tables, make sure
-- to drop old policy and recreate on new table.
BEGIN
    dbms_fga.drop_policy('UAM','TAXONOMY_OLD','TAXONOMY');
END;
*/

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'TAXONOMY',
	policy_name => 'TAXONOMY',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','TAXON_NAME','TAXON_NAME');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'TAXON_NAME',
	policy_name => 'TAXON_NAME',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','TAXON_RELATIONS','TAXON_RELATIONS');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'TAXON_RELATIONS',
	policy_name => 'TAXON_RELATIONS',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','TRANS','TRANS');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'TRANS',
	policy_name => 'TRANS',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

BEGIN
dbms_fga.drop_policy('UAM','TRANS_AGENT','TRANS_AGENT');
END;

BEGIN
dbms_fga.add_policy(object_schema =>'UAM',
	object_name => 'TRANS_AGENT',
	policy_name => 'TRANS_AGENT',
	audit_condition => NULL,
	audit_column => NULL,
	handler_schema => NULL,
	handler_module => NULL,
	enable => TRUE,
	statement_types => 'INSERT, UPDATE, DELETE',
	audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
	audit_column_opts => dbms_fga.any_columns);
END;

-- LKV: 2010 Feb 08: ADD policies TO CT% TABLES
/*
begin
for tn in (
	select table_name
	from user_tables
	where table_name like 'CT%'
	order by table_name
) loop
	--dbms_output.put_line('BEGIN dbms_fga.drop_policy(''UAM'',''' || tn.table_name || ''',''' || tn.table_name || '''); END;');
	dbms_output.put_line('BEGIN dbms_fga.add_policy(object_schema =>''UAM'', object_name => ''' || tn.table_name || ''', policy_name => ''' || tn.table_name || ''', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => ''INSERT, UPDATE, DELETE'', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;');
 end loop;
 end;
 */
 
BEGIN
    BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTABUNDANCE', policy	_name => 'CTABUNDANCE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTACCN_STATUS', policy_name => 'CTACCN_STATUS', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTACCN_TYPE', policy_name => 'CTACCN_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTADDR_TYPE', policy_name => 'CTADDR_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTAGENT_NAME_TYPE', policy_name => 'CTAGENT_NAME_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTAGENT_RANK', policy_name => 'CTAGENT_RANK', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTAGENT_RELATIONSHIP', policy_name => 'CTAGENT_RELATIONSHIP', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTAGENT_TYPE', policy_name => 'CTAGENT_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTAGE_CLASS', policy_name => 'CTAGE_CLASS', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTATTRIBUTE_CODE_TABLES', policy_name => 'CTATTRIBUTE_CODE_TABLES', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTATTRIBUTE_TYPE', policy_name => 'CTATTRIBUTE_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTAUTHOR_ROLE', policy_name => 'CTAUTHOR_ROLE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTBIOL_RELATIONS', policy_name => 'CTBIOL_RELATIONS', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTBORROW_STATUS', policy_name => 'CTBORROW_STATUS', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTCASTE', policy_name => 'CTCASTE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTCATALOGED_ITEM_TYPE', policy_name => 'CTCATALOGED_ITEM_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTCF_LOAN_USE_TYPE', policy_name => 'CTCF_LOAN_USE_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTCITATION_TYPE_STATUS', policy_name => 'CTCITATION_TYPE_STATUS', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTCLASS', policy_name => 'CTCLASS', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTCOLLECTING_SOURCE', policy_name => 'CTCOLLECTING_SOURCE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTCOLLECTION_CDE', policy_name => 'CTCOLLECTION_CDE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTCOLLECTOR_ROLE', policy_name => 'CTCOLLECTOR_ROLE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTCOLL_CONTACT_ROLE', policy_name => 'CTCOLL_CONTACT_ROLE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTCOLL_OBJECT_TYPE', policy_name => 'CTCOLL_OBJECT_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTCOLL_OBJ_DISP', policy_name => 'CTCOLL_OBJ_DISP', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTCOLL_OTHER_ID_TYPE', policy_name => 'CTCOLL_OTHER_ID_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTCONTAINER_TYPE', policy_name => 'CTCONTAINER_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTCONTAINER_TYPE_SIZE', policy_name => 'CTCONTAINER_TYPE_SIZE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTCONTINENT', policy_name => 'CTCONTINENT', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTDATUM', policy_name => 'CTDATUM', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTDEPTH_UNITS', policy_name => 'CTDEPTH_UNITS', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTDOWNLOAD_PURPOSE', policy_name => 'CTDOWNLOAD_PURPOSE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTELECTRONIC_ADDR_TYPE', policy_name => 'CTELECTRONIC_ADDR_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTENCUMBRANCE_ACTION', policy_name => 'CTENCUMBRANCE_ACTION', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTEW', policy_name => 'CTEW', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTFEATURE', policy_name => 'CTFEATURE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTFLAGS', policy_name => 'CTFLAGS', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTFLUID_CONCENTRATION', policy_name => 'CTFLUID_CONCENTRATION', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTFLUID_TYPE', policy_name => 'CTFLUID_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTGEOG_SOURCE_AUTHORITY', policy_name => 'CTGEOG_SOURCE_AUTHORITY', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTGEOREFMETHOD', policy_name => 'CTGEOREFMETHOD', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTIMAGE_OBJECT_TYPE', policy_name => 'CTIMAGE_OBJECT_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTINFRASPECIFIC_RANK', policy_name => 'CTINFRASPECIFIC_RANK', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTISLAND_GROUP', policy_name => 'CTISLAND_GROUP', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTJOURNAL_NAME', policy_name => 'CTJOURNAL_NAME', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTKILL_METHOD', policy_name => 'CTKILL_METHOD', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTLAT_LONG_ERROR_UNITS', policy_name => 'CTLAT_LONG_ERROR_UNITS', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTLAT_LONG_REF_SOURCE', policy_name => 'CTLAT_LONG_REF_SOURCE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTLAT_LONG_UNITS', policy_name => 'CTLAT_LONG_UNITS', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTLENGTH_UNITS', policy_name => 'CTLENGTH_UNITS', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTLOAN_STATUS', policy_name => 'CTLOAN_STATUS', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTLOAN_TYPE', policy_name => 'CTLOAN_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTMEDIA_LABEL', policy_name => 'CTMEDIA_LABEL', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTMEDIA_RELATIONSHIP', policy_name => 'CTMEDIA_RELATIONSHIP', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTMEDIA_TYPE', policy_name => 'CTMEDIA_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTMIME_TYPE', policy_name => 'CTMIME_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTMONETARY_UNITS', policy_name => 'CTMONETARY_UNITS', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTNATURE_OF_ID', policy_name => 'CTNATURE_OF_ID', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTNOMENCLATURAL_CODE', policy_name => 'CTNOMENCLATURAL_CODE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTNS', policy_name => 'CTNS', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTNUMERIC_AGE_UNITS', policy_name => 'CTNUMERIC_AGE_UNITS', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTORIG_ELEV_UNITS', policy_name => 'CTORIG_ELEV_UNITS', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTPERMIT_TYPE', policy_name => 'CTPERMIT_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTPREFIX', policy_name => 'CTPREFIX', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTPROJECT_AGENT_ROLE', policy_name => 'CTPROJECT_AGENT_ROLE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTPUBLICATION_ATTRIBUTE', policy_name => 'CTPUBLICATION_ATTRIBUTE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTPUBLICATION_TYPE', policy_name => 'CTPUBLICATION_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTSECTION_TYPE', policy_name => 'CTSECTION_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTSEX_CDE', policy_name => 'CTSEX_CDE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTSHIPPED_CARRIER_METHOD', policy_name => 'CTSHIPPED_CARRIER_METHOD', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTSPECIMEN_PART_LIST_ORDER', policy_name => 'CTSPECIMEN_PART_LIST_ORDER', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTSPECIMEN_PART_MODIFIER', policy_name => 'CTSPECIMEN_PART_MODIFIER', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTSPECIMEN_PART_NAME', policy_name => 'CTSPECIMEN_PART_NAME', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTSPECIMEN_PRESERV_METHOD', policy_name => 'CTSPECIMEN_PRESERV_METHOD', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTSUFFIX', policy_name => 'CTSUFFIX', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTTAXA_FORMULA', policy_name => 'CTTAXA_FORMULA', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTTAXONOMIC_AUTHORITY', policy_name => 'CTTAXONOMIC_AUTHORITY', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTTAXON_RELATION', policy_name => 'CTTAXON_RELATION', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTTAXON_VARIABLE', policy_name => 'CTTAXON_VARIABLE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTTRANSACTION_TYPE', policy_name => 'CTTRANSACTION_TYPE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTTRANS_AGENT_ROLE', policy_name => 'CTTRANS_AGENT_ROLE', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTVERIFICATIONSTATUS', policy_name => 'CTVERIFICATIONSTATUS', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTWEIGHT_UNITS', policy_name => 'CTWEIGHT_UNITS', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
	BEGIN dbms_fga.add_policy(object_schema =>'UAM', object_name => 'CTYES_NO', policy_name => 'CTYES_NO', audit_condition => NULL, audit_column => NULL, handler_schema => NULL, handler_module => NULL, enable => TRUE, statement_types => 'INSERT, UPDATE, DELETE', audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED, audit_column_opts => dbms_fga.any_columns); END;
END;
/
