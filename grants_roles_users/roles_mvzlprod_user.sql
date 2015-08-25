/* update existing roles in user_roles table */
UPDATE user_roles 
SET
    role_name = 'MANAGE_CODETABLES', 
    description = 'INSERT, UPDATE, DELETE on all code tables (CT*)' 
WHERE role_name = 'manage_codetables';

UPDATE user_roles 
SET
    role_name = 'MANAGE_LOCALITY', 
    description = 'INSERT, UPDATE, DELETE on collecting_event, lat_long, locality, vessel' 
WHERE role_name = 'manage_locality';

UPDATE user_roles 
SET
    role_name = 'MANAGE_PUBLICATIONS',
    description = 'INSERT, UPDATE, DELETE on citation, field_notebook_section, journal, journal_article, page, project, project_agent, project_publication, project_trans, publication, publication_author_name, publication_url'
WHERE role_name = 'manage_publications'

UPDATE user_roles 
SET 
    role_name = 'MANAGE_SPECIMENS',
    description = 'INSERT, UPDATE, DELETE on attributes, binary_object, biol_indiv_relations, collector, coll_object, coll_object_encumbrance, coll_object_remark, coll_obj_cont_hist, coll_obj_other_id_num, identification_agent, specimen_part; INSERT, UPDATE on cataloged_item, identification; UPDATE on container, spec_with_loc; INSERT on citation, collecting_event'
WHERE role_name = 'manage_specimens'

UPDATE user_roles 
SET 
    role_name = 'MANAGE_TRANSACTIONS',
    description = 'INSERT, UPDATE, DELETE on addr, accn, borrow, electronic_address, encumbrance, loan, loan_item, permit, permit_shipment, permit_trans, project, project_agent, project_publication, project_remark, project_sponsor, shipment, trans'
WHERE role_name = 'manage_transactions'

UPDATE user_roles 
SET 
    role_name = 'PUBLIC', 
    description = 'SELECT on all tables' 
WHERE role_name = 'public';

/* insert new roles into user_roles table */
INSERT INTO user_roles (role_id, role_name, description) 
VALUES (
    somerandomsequence.nextval, 
    'COLDFUSION_USER', 
    'INSERT, UPDATE, DELETE on all cf tables (CF*)');
    
INSERT INTO user_roles (role_id, role_name, description) 
VALUES (
    somerandomsequence.nextval, 
    'DATA_ENTRY', 
    'INSERT, UPDATE, DELETE on bulkloader, bulkloader_stage');

INSERT INTO user_roles (role_id, role_name, description) 
VALUES (
    somerandomsequence.nextval, 
    'DGR_LOCATOR', 
    'INSERT, UPDATE, DELETE on dgr_locator');

INSERT INTO user_roles (role_id, role_name, description)
VALUES (
    somerandomsequence.nextval, 
    'GLOBAL_ADMIN',
    'INSERT, UPDATE, DELETE on temp_allow_cf_user, viewer');

INSERT INTO user_roles (role_id, role_name, description) 
VALUES (
    somerandomsequence.nextval, 
    'MANAGE_AGENTS', 
    'INSERT, UPDATE, DELETE on agent, agent_name, agent_relations, group_member, person');
    
INSERT INTO user_roles (role_id, role_name, description) 
VALUES (
    somerandomsequence.nextval, 
    'MANAGE_CONTAINER', 
    'INSERT, UPDATE, DELETE on container, fluid_container_history; INSERT on container_check');

INSERT INTO user_roles (role_id, role_name, description) 
VALUES (
    somerandomsequence.nextval, 
    'MANAGE_COLLECTION', 
    'INSERT, UPDATE, DELETE on collection, collection_contacts; DELETE on cataloged_item, identification, identification_taxonomy');

INSERT INTO user_roles (role_id, role_name, description) 
VALUES (
    somerandomsequence.nextval, 
    'MANAGE_GEOGRAPHY', 
    'INSERT, UPDATE, DELETE on geog_auth_rec');

INSERT INTO user_roles (role_id, role_name, description) 
VALUES (
    somerandomsequence.nextval, 
    'MANAGE_GREF', 
    'ALL on gref_user, gref_page_refset_ng, gref_refset_ng, gref_refset_roi_ng, gref_roi_value_ng, gref_roi_ng, hibernate_sequence; UPDATE on page; SELECT on flat');
    
INSERT INTO user_roles (role_id, role_name, description) 
VALUES (
    somerandomsequence.nextval, 
    'MANAGE_TAXONOMY', 
    'INSERT, UPDATE, DELETE on common_name, taxonomy, taxon_relations');

/* grant roles to users */
GRANT
    coldfusion_user,
    data_entry,
    global_admin,
    manage_agents,
    manage_codetables,
    manage_collection,
    manage_container,
    manage_geography,
    manage_gref,
    manage_locality,
    manage_publications,
    manage_specimens,
    manage_taxonomy,
    manage_transactions
TO ccicero;

GRANT
    coldfusion_user,
    data_entry,
    global_admin,
    manage_agents,
    manage_codetables,
    manage_collection,
    manage_container,
    manage_geography,
    manage_gref,
    manage_locality,
    manage_publications,
    manage_specimens,
    manage_taxonomy,
    manage_transactions
TO dusty;

GRANT
    data_entry,
    manage_locality,
    manage_specimens,
    manage_transactions
TO jhavens;

GRANT
    data_entry,
    manage_locality,
    manage_specimens,
    manage_transactions
TO jsantos;

GRANT
    coldfusion_user,
    data_entry,
    global_admin,
    manage_agents,
    manage_codetables,
    manage_collection,
    manage_container,
    manage_geography,
    manage_locality,
    manage_publications,
    manage_specimens,
    manage_taxonomy,
    manage_transactions
TO lam;

GRANT
    manage_specimens,
    manage_transactions
TO mjalbe;

GRANT
    data_entry,
    global_admin,
    manage_agents,
    manage_collection,
    manage_container,
    manage_geography,
    manage_locality,
    manage_publications,
    manage_specimens,
    manage_taxonomy,
    manage_transactions
TO mkoo;

GRANT
    manage_transactions
TO mvzoffice;

GRANT
    manage_codetables
TO pdevore;

GRANT
    manage_locality,
    manage_specimens,
    manage_transactions
TO ptam;

GRANT
    data_entry,
    manage_locality,
    manage_specimens,
    manage_transactions
TO rsetsuda;

GRANT
    manage_locality,
    manage_specimens
TO tieem;

GRANT
    coldfusion_user,
    data_entry,
    global_admin,
    manage_agents,
    manage_collection,
    manage_container,
    manage_geography,
    manage_gref,
    manage_locality,
    manage_publications,
    manage_specimens,
    manage_taxonomy,
    manage_transactions
TO tuco;

GRANT
    data_entry,
    global_admin,
    manage_agents,
    manage_collection,
    manage_container,
    manage_geography,
    manage_locality,
    manage_publications,
    manage_specimens,
    manage_taxonomy,
    manage_transactions
TO voleguy;

GRANT
    data_entry,
    manage_agents,
    manage_collection,
    manage_container,
    manage_geography,
    manage_locality,
    manage_publications,
    manage_specimens,
    manage_taxonomy,
    manage_transactions
TO patton;

GRANT 
    manage_transactions
TO diomedea1;

GRANT
    manage_specimens,
    manage_transactions,
    manage_locality,
    data_entry
TO drkayn;

GRANT
    manage_specimens,
    data_entry
TO jacastillo

GRANT
    manage_specimens
TO kklitz;

GRANT
    manage_specimens,
    manage_transactions,
    manage_locality,
    data_entry
TO mjose;

GRANT
    manage_specimens,
    manage_transactions,
    manage_locality,
    data_entry
TO rpdama;

GRANT
    data_entry,
    global_admin,
    manage_agents,
    manage_collection,
    manage_container,
    manage_geography,
    manage_locality,
    manage_publications,
    manage_specimens,
    manage_transactions
TO atrox;

GRANT
    manage_specimens,
    manage_taxonomy,
    manage_transactions
TO bowie;

GRANT
    manage_specimens,
    manage_taxonomy,
    manage_transactions
TO mcguirej;

GRANT
    manage_locality,
    manage_specimens
TO ptitle;

/*
add to qa list for prod (per ccicero):
patton (same roles as voleguy, minus global_admin)
diomedea1 (manage_transactions)
drkayn (manage_specimens, manage_transactions, manage_locality, data_entry)
jacastillo (manage_specimens, data_entry)
JohnDPerrine (public only)
kklitz (manage_specimens)
mjose (manage_specimens, manage_transactions, manage_locality, data_entry)
rpdama (manage_specimens, manage_transactions, manage_locality, data_entry)
zhanna (public only)
atrox (same as voleguy)
bowie (manage_specimens, manage_taxonomy, manage_transactions)
mcguirej (manage_specimens, manage_taxonomy, manage_transactions)
ptitle (manage_locality, manage_specimens)
*/

/* update cf_user_roles table with newly granted roles */
declare ui number;
declare pr number;
begin
    FOR un IN (
        'CCICERO',
		'DUSTY',
		'JHAVENS',
		'JSANTOS',
		'LAM',
		'MJALBE',
		'MKOO',
		'MVZOFFICE',
		'PDEVORE',
		'PTAM',
		'RSETSUDA',
		'TIEEM',
		'TUCO',
		'VOLEGUY',
		'PATTON',
		'DIOMEDEA1',
		'DRKAYN',
		'JACASTILLO',
        'JOHNDPERRINE',
		'KKLITZ',
		'MJOSE',
		'RPDAMA',
        'ZHANNA',
		'ATROX',
		'BOWIE',
		'MCGUIREJ',
		'PTITLE'
	) LOOP
        SELECT user_id INTO ui FROM cf_users WHERE upper(username) = un;
        SELECT role_id INTO pr FROM user_roles WHERE upper(role_name) = 'PUBLIC';
        dbms_output.putline(ui || ', ' || pr);
        INSERT INTO cf_user_roles (user_id, role_id) VALUES (ui, pr);
        FOR ur IN (SELECT role_id FROM user_roles WHERE role_name IN (
            SELECT granted_role FROM dba_role_privs WHERE grantee = un)
        ) LOOP
            dbms_output.putline(ui || ', ' || ur.role_id);
            INSERT INTO cf_user_roles (user_id, role_id) VALUES (ui, ur.role_id);
        END LOOP;
    END LOOP;
END;