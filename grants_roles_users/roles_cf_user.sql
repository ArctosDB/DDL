/* hack to allow public users to update their perfs */
cf_users

/* drop roles that have been phased out or roles that have changed privs (to avoid having to revoke) */
DROP ROLE add_accn; -- do not recreate
DROP ROLE add_identification; -- do not recreate
--        coldfusion_user;
DROP ROLE manage_authority;  -- not recreate
--        manage_codetables;
--        manage_gref;
DROP ROLE manage_identification; -- not recreate
DROP ROLE manage_locality;
DROP ROLE manage_publications;
DROP ROLE manage_random; -- not recreated
DROP ROLE manage_specimens;
DROP ROLE manage_transactions;

/* create/recreate new roles */
--          coldfusion_user;
CREATE ROLE data_entry; -- new in qa/prod
CREATE ROLE dgr_locator; -- new in qa/prod
CREATE ROLE global_admin; -- new in qa/prod
CREATE ROLE manage_agents; -- new in qa/prod
--          manage_codetables;
CREATE ROLE manage_collection; -- new in qa/prod
CREATE ROLE manage_container; -- new in qa/prod
CREATE ROLE manage_geography; -- new in qa/prod
--          manage_gref;
CREATE ROLE manage_locality;
CREATE ROLE manage_publications;
CREATE ROLE manage_specimens;
CREATE ROLE manage_taxonomy; 
-- new in qa/prod
CREATE ROLE manage_transactions;

/**************************** coldfusion_user ********************************/
/* all privileges on cf* tables, mostly used for bulkloading various things. */
/* build with
    SELECT 'GRANT INSERT, UPDATE, DELETE ON ' ||
        table_name || ' TO coldfusion_user;'
    FROM user_tables
    WHERE table_name like 'cf%';
*/
GRANT INSERT, UPDATE, DELETE ON cfflags TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_addr TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_address TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_bugs TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_canned_search TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_database_activity TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_download TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_genbank_info TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_label TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_loan TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_loan_item TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_log TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_project TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_search_results TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_spec_res_cols TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_temp_attributes TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_temp_barcode_parts TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_temp_citation TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_temp_container_location TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_temp_georef TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_temp_loan TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_temp_loan_item TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_temp_oids TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_temp_parts TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_temp_relations TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_temp_scans TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_users TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_user_data TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_user_loan TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_user_log TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_user_roles TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_version TO coldfusion_user;
GRANT INSERT, UPDATE, DELETE ON cf_version_log TO coldfusion_user;

/**************************** data_entry *************************************/
GRANT INSERT, UPDATE, DELETE ON bulkloader TO data_entry;
GRANT INSERT, UPDATE, DELETE ON bulkloader_stage TO data_entry;

/**************************** dgr_locator ************************************/
GRANT INSERT, UPDATE, DELETE ON dgr_locator TO dgr_locator;

/**************************** global_admin ***********************************/
GRANT INSERT, UPDATE, DELETE ON temp_allow_cf_user TO global_admin;
GRANT INSERT, UPDATE, DELETE ON viewer TO global_admin;

DECLARE wtf varchar2(3000);
BEGIN
    FOR t IN (SELECT table_name FROM user_tables) LOOP
        wtf := 'GRANT SELECT ON ' || t.table_name || ' TO public';
        execute immediate (wtf);
    END LOOP;
END;

/**************************** manage_agents **********************************/
GRANT INSERT, UPDATE, DELETE ON agent TO manage_agents;
GRANT INSERT, UPDATE, DELETE ON agent_name TO manage_agents;
GRANT INSERT, UPDATE, DELETE ON agent_relations TO manage_agents;
GRANT INSERT, UPDATE, DELETE ON group_member TO manage_agents;
GRANT INSERT, UPDATE, DELETE ON person TO manage_agents;

/**************************** manage_codetables ******************************/
/* build with:
    SELECT 'GRANT INSERT, UPDATE, DELETE ON ' ||
        table_name || ' TO manage_codetables;'
    FROM user_tables
    WHERE table_name like 'CT%';
*/
GRANT INSERT, UPDATE, DELETE ON ctaccn_status TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctaccn_type TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctaddr_type TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctagent_name_type TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctagent_relationship TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctagent_type TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctage_class TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctattribute_code_tables TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctattribute_type TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctbin_obj_aspect TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctbin_obj_subject TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctbiol_relations TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctborrow_status TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctcf_loan_use_type TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctcitation_type_status TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctclass TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctcollecting_source TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctcollection_cde TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctcollector_role TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctcoll_contact_role TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctcoll_obj_disp TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctcoll_obj_flags TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctcoll_other_id_type TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctcontainer_type TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctcontinent TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctdatum TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctdepth_units TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctdownload_purpose TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctelectronic_addr_type TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctencumbrance_action TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctew TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctfeature TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctflags TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctfluid_concentration TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctfluid_type TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctgeog_source_authority TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctgeorefmethod TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctinfraspecific_rank TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctisland_group TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctlat_long_error_units TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctlat_long_ref_source TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctlat_long_units TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctlength_units TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctloan_status TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctloan_type TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctnature_of_id TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctns TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctnumeric_age_units TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctorig_elev_units TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctpermit_type TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctprefix TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctproject_agent_role TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctpublication_type TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctsex_cde TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctshipped_carrier_method TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctspecimen_part_list_order TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctspecimen_part_modifier TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctspecimen_part_name TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctspecimen_preserv_method TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctsuffix TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON cttaxa_formula TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON cttaxonomic_authority TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON cttaxon_relation TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctverificationstatus TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctweight_units TO manage_codetables;
GRANT INSERT, UPDATE, DELETE ON ctyes_no TO manage_codetables;

/**************************** manage_collection ******************************/
GRANT INSERT, UPDATE, DELETE ON collection TO manage_collection;
GRANT INSERT, UPDATE, DELETE ON collection_contacts TO manage_collection;
GRANT DELETE ON cataloged_item TO manage_collection;
GRANT DELETE ON identification TO manage_collection;
GRANT DELETE ON identification_taxonomy TO manage_collection;

/**************************** manage_container *******************************/
GRANT INSERT, UPDATE, DELETE ON container TO manage_container;
GRANT INSERT, UPDATE, DELETE ON fluid_container_history TO manage_container;
GRANT INSERT ON container_check TO manage_container;

/**************************** manage_geography *******************************/
GRANT INSERT, UPDATE, DELETE ON geog_auth_rec TO manage_geography;

/**************************** manage_locality ********************************/
GRANT INSERT, UPDATE, DELETE ON collecting_event TO manage_locality;
GRANT INSERT, UPDATE, DELETE ON lat_long TO manage_locality;
GRANT INSERT, UPDATE, DELETE ON locality TO manage_locality;
GRANT INSERT, UPDATE, DELETE ON vessel TO manage_locality;

/**************************** manage_publications ****************************/
GRANT INSERT, UPDATE, DELETE ON book TO manage_publications;
GRANT INSERT, UPDATE, DELETE ON book_section TO manage_publications;
GRANT INSERT, UPDATE, DELETE ON citation TO manage_publications;
GRANT INSERT, UPDATE, DELETE ON field_notebook_section TO manage_publications;
GRANT INSERT, UPDATE, DELETE ON journal TO manage_publications;
GRANT INSERT, UPDATE, DELETE ON journal_article TO manage_publications;
GRANT INSERT, UPDATE, DELETE ON page TO manage_publications;
GRANT INSERT, UPDATE, DELETE ON project TO manage_publications;
GRANT INSERT, UPDATE, DELETE ON project_agent TO manage_publications;
GRANT INSERT, UPDATE, DELETE ON project_publication TO manage_publications;
GRANT INSERT, UPDATE, DELETE ON project_trans TO manage_publications;
GRANT INSERT, UPDATE, DELETE ON publication TO manage_publications;
GRANT INSERT, UPDATE, DELETE ON publication_author_name TO manage_publications;
GRANT INSERT, UPDATE, DELETE ON publication_url TO manage_publications;

/**************************** manage_specimens *******************************/
GRANT INSERT, UPDATE, DELETE ON attributes TO manage_specimens;
GRANT INSERT, UPDATE, DELETE ON binary_object TO manage_specimens;
GRANT INSERT, UPDATE, DELETE ON biol_indiv_relations TO manage_specimens;
GRANT INSERT, UPDATE, DELETE ON collector TO manage_specimens;
GRANT INSERT, UPDATE, DELETE ON coll_object TO manage_specimens;
GRANT INSERT, UPDATE, DELETE ON coll_object_encumbrance TO manage_specimens;
GRANT INSERT, UPDATE, DELETE ON coll_object_remark TO manage_specimens;
GRANT INSERT, UPDATE, DELETE ON coll_obj_cont_hist TO manage_specimens;
GRANT INSERT, UPDATE, DELETE ON coll_obj_other_id_num TO manage_specimens;
GRANT INSERT, UPDATE, DELETE ON identification_agent TO manage_specimens;
GRANT INSERT, UPDATE, DELETE ON specimen_part TO manage_specimens;
GRANT INSERT, UPDATE ON cataloged_item TO manage_specimens;
GRANT INSERT, UPDATE ON identification TO manage_specimens;
GRANT INSERT, UPDATE ON identification_taxonomy TO manage_specimens;
GRANT UPDATE ON container TO manage_specimens;
GRANT UPDATE ON spec_with_loc TO manage_specimens;
GRANT INSERT ON citation TO manage_specimens;
GRANT INSERT ON collecting_event TO manage_specimens;

/**************************** manage_taxonomy ********************************/
GRANT INSERT, UPDATE, DELETE ON common_name TO manage_taxonomy;
GRANT INSERT, UPDATE, DELETE ON taxonomy TO manage_taxonomy;
GRANT INSERT, UPDATE, DELETE ON taxon_relations TO manage_taxonomy;

/***************************** manage_transactions ***************************/
GRANT INSERT, UPDATE, DELETE ON addr TO manage_transactions;
GRANT INSERT, UPDATE, DELETE ON accn TO manage_transactions;
GRANT INSERT, UPDATE, DELETE ON borrow TO manage_transactions;
GRANT INSERT, UPDATE, DELETE ON electronic_address TO manage_transactions;
GRANT INSERT, UPDATE, DELETE ON encumbrance TO manage_transactions;
GRANT INSERT, UPDATE, DELETE ON loan TO manage_transactions;
GRANT INSERT, UPDATE, DELETE ON loan_item TO    manage_transactions;
GRANT INSERT, UPDATE, DELETE ON permit TO manage_transactions;
GRANT INSERT, UPDATE, DELETE ON permit_shipment TO manage_transactions;
GRANT INSERT, UPDATE, DELETE ON permit_trans TO manage_transactions;
GRANT INSERT, UPDATE, DELETE ON project TO manage_transactions;
GRANT INSERT, UPDATE, DELETE ON project_agent TO manage_transactions;
GRANT INSERT, UPDATE, DELETE ON project_publication TO manage_transactions;
GRANT INSERT, UPDATE, DELETE ON project_remark TO manage_transactions;
GRANT INSERT, UPDATE, DELETE ON project_sponsor TO manage_transactions;
GRANT INSERT, UPDATE, DELETE ON shipment TO manage_transactions;
GRANT INSERT, UPDATE, DELETE ON trans TO manage_transactions;

/* --manage_users: assign roles TO users - how to do? */
    
/********************** set us up, as we'll have no access - ughhhh **********/
GRANT manage_codetables, manage_agents, coldfusion_user, global_admin
    TO dlm;
/* grant new/recreated roles to uam with admin option */
--    coldfusion_user TO uam WITH ADMIN OPTION;
GRANT data_entry TO uam WITH ADMIN OPTION;
GRANT dgr_locator TO uam WITH ADMIN OPTION;
GRANT global_admin TO uam WITH ADMIN OPTION;
GRANT manage_agents TO uam WITH ADMIN OPTION;
--    manage_codetables TO uam WITH ADMIN OPTION;
GRANT manage_container TO uam WITH ADMIN OPTION;
GRANT manage_collection TO uam WITH ADMIN OPTION;
GRANT manage_geography TO uam WITH ADMIN OPTION;
--    manage_gref TO uam WITH ADMIN OPTION;
GRANT manage_locality TO uam WITH ADMIN OPTION;
GRANT manage_publications TO uam WITH ADMIN OPTION;
GRANT manage_specimens TO uam WITH ADMIN OPTION;
GRANT manage_taxonomy TO uam WITH ADMIN OPTION;
GRANT manage_transactions TO uam WITH ADMIN OPTION;
