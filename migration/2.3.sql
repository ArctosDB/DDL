/*
	This file provides the code needed to move from v2.2.2 to v2.3
	
	Release info:
		Adds user login to all forms
		Improves admin users

	move user management widget to using actual DB values
	New table cf_ctuser_roles lists roles available to users via Arctos
*/

CREATE TABLE cf_ctuser_roles (
    role_name varchar2(38),
    description varchar2(4000));
CREATE PUBLIC SYNONYM cf_ctuser_roles 
    FOR cf_ctuser_roles;
GRANT SELECT ON cf_ctuser_roles 
    TO PUBLIC;
INSERT INTO cf_ctuser_roles (role_name, description) 
	VALUES (
        'coldfusion_user',
        'Access to bulkoaders (except specimen loader; lots of internal widgets). Anyone who does anything, more or less.');
INSERT INTO cf_ctuser_roles (role_name, description) 
	VALUES (
        'data_entry',
        'Data entry and specimen bulkloader');
INSERT INTO cf_ctuser_roles (role_name, description) 
	VALUES (
        'dgr_locator',
        'DGR personnel ONLY');
INSERT INTO cf_ctuser_roles (role_name, description) 
	VALUES (
        'global_admin',
        'Invite users to become operators; grant and revoke rights from users. Also "trashcan" for things that students probably shouldn''t mess with but don''t fit well elsewhere.');
INSERT INTO cf_ctuser_roles (role_name, description) 
    VALUES (
        'manage_agents',
        'Just what you''d guess. Manage_agents can update');
INSERT INTO cf_ctuser_roles (role_name, description) 
	VALUES (
        'manage_codetables',
        'Just what it says. VERY limited access.');
INSERT INTO cf_ctuser_roles (role_name, description) 
	VALUES (
        'manage_collection',
        'Collection metadata tables, DELETE on cataloged item and identification (manage_collection can create identifications)');
INSERT INTO cf_ctuser_roles (role_name, description) 
	VALUES (
        'manage_container',
        'Just what you''d guess. manage_container can update container (ie, to associate a specimen with a container)');
INSERT INTO cf_ctuser_roles (role_name, description) 
	VALUES (
        'manage_geography',
        'Geog_auth_rec. Should be very limited access.');
INSERT INTO cf_ctuser_roles (role_name, description) 
	VALUES (
        'manage_locality',
        'Locality and coordinates.');
INSERT INTO cf_ctuser_roles (role_name, description) 
	VALUES (
        'manage_publications',
        'Publications and projects');
INSERT INTO cf_ctuser_roles (role_name, description) 
	VALUES (
        'manage_specimens',
        '"good student" basics. Manipulate most things at SpecimenDetail; add citations.');
INSERT INTO cf_ctuser_roles (role_name, description) 
	VALUES (
        'manage_taxonomy',
        'Taxonomy and taxonomy relationships. Should be limited access (note: this is NOT identification)');
INSERT INTO cf_ctuser_roles (role_name, description) 
	VALUES (
        'manage_transactions',
        'Accns, loans, borrows, permits');