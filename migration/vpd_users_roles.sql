/* Da Spiel:
	
		"Us" users, those with Arctos and Oracle accounts, need access to 1 or more collections. Do this via the Manage Users widget.
		This privilege works in conjunction with existing roles to limit access. Public users access Arctos via "portals"
		(eg, http://arctos-test.arctos.database.museum/uam_mamm) and pick up usernames when they do so. The default portal gives
		access to all collections.
		
		So, by example:
		
		Current Situation: "us" user
			User: test
			Role: manage_specimens
			SQL: delete from cataloged_item
			Result: empty cataloged_item table
			
		VPD Scenario 1: "us" user
			User: test
			Role: manage_specimens
			Collection Access: uam_mamm
			SQL: delete from cataloged_item
			Result: no more UAM Mammals in the cataloged_item table
			
		VPD Scenario 2: public user via UAM Mamm "portal"
			User: pub_usr_uam_mamm
			Role: public
			Collection Access: uam_mamm
			SQL: select * from cataloged_item
			Result: all UAM Mammals in the cataloged_item table
			
		VPD Scenario 3: public user via open "portal"
			User: pub_usr_all_all
			Role: public
			Collection Access: [all collections]
			SQL: select * from cataloged_item
			Result: all rows
*/

create profile arctos_user 
limit
    COMPOSITE_LIMIT                  UNLIMITED
	SESSIONS_PER_USER                UNLIMITED
	CPU_PER_SESSION                  UNLIMITED
	CPU_PER_CALL                     UNLIMITED
	LOGICAL_READS_PER_SESSION        UNLIMITED
	LOGICAL_READS_PER_CALL           UNLIMITED
	IDLE_TIME                        UNLIMITED
	CONNECT_TIME                     UNLIMITED
	PRIVATE_SGA                      UNLIMITED
	FAILED_LOGIN_ATTEMPTS            5
	PASSWORD_LIFE_TIME               UNLIMITED
	PASSWORD_REUSE_TIME              UNLIMITED
	PASSWORD_REUSE_MAX               UNLIMITED
	PASSWORD_VERIFY_FUNCTION         NULL
	PASSWORD_LOCK_TIME               UNLIMITED
	PASSWORD_GRACE_TIME              UNLIMITED;
	
/*  Data Entry Stuff
	
	Role data_entry:
		INSERT into Bulkoader
		DELETE own records
		UPDATE own records
		SELECT own records
		
	manage_collection:
		UPDATE, DELETE, SELECT all records entered by members of own collection role
		
	Example:
		user A: uam_mamm, data_entry roles
			-- create UAM MAMM records
			-- update,delete,select anything with entered_by=A
			-- cannot change LOADED to NULL (trigger)
		user B: uam_mamm, mange_collection
			-- do anything to user A's records
*/

CREATE ROLE data_entry;
GRANT ALL ON bulkloader TO data_entry;

CREATE ROLE manage_gref;
GRANT manage_gref TO uam;
--GRANT manage_gref TO eighty;

GRANT ALL ON GREF_PAGE_REFSET_NG TO MANAGE_GREF;
GRANT SELECT ON GREF_PAGE_REFSET_NG TO PUBLIC;

GRANT ALL ON GREF_REFSET_NG TO MANAGE_GREF;
GRANT SELECT ON GREF_REFSET_NG TO PUBLIC;

GRANT ALL ON GREF_REFSET_ROI_NG TO MANAGE_GREF;
GRANT SELECT ON GREF_REFSET_ROI_NG TO PUBLIC;

GRANT ALL ON GREF_ROI_NG TO MANAGE_GREF;
GRANT SELECT ON GREF_ROI_NG TO PUBLIC;

GRANT ALL ON GREF_ROI_VALUE_NG TO MANAGE_GREF;
GRANT SELECT ON GREF_ROI_VALUE_NG TO PUBLIC;

GRANT ALL ON GREF_USER TO MANAGE_GREF;
GRANT SELECT ON GREF_USER TO PUBLIC;

-- create mvz users

-- MVZ public users
BOWIE --(make public user only)
CMORITZ --(make public user only)
RPDAMA --(make public user only)
KKLITZ --(make public user only)
MCGUIREJ --(make public account only)

-- MVZ oracle users
EIGHTY
JDECK

-- MVZ users already at uam prod.
--create user DUSTY identified by "c-cret99" profile arctos_user;
--create user LAM identified by "c-cret99" profile arctos_user;

-- Create privileged MVZ users
create user AIPPOLITO identified by "c-cret01" profile arctos_user;
create user ATRAPAGA identified by "c-cret02" profile arctos_user;
create user ATROX identified by "c-cret03" profile arctos_user;
create user CCICERO identified by "c-cret04" profile arctos_user;
create user DIOMEDEA1 identified by "c-cret05" profile arctos_user;
create user DKT identified by "c-cret06" profile arctos_user;
create user DMFISHER197 identified by "c-cret07" profile arctos_user;
create user EWOMMACK identified by "c-cret08" profile arctos_user;
create user GREF_USER identified by "c-cret09" profile arctos_user;
create user HPARK identified by "c-cret10" profile arctos_user;
create user JACASTILLO identified by "c-cret11" profile arctos_user;
create user JHAVENS identified by "c-cret12" profile arctos_user;
create user JSANTOS identified by "c-cret13" profile arctos_user;
create user KDODD identified by "c-cret14" profile arctos_user;
create user KLOVETT identified by "c-cret15" profile arctos_user;
create user KROWE identified by "c-cret16" profile arctos_user;
create user LYDSMITH identified by "c-cret17" profile arctos_user;
create user MJALBE identified by "c-cret18" profile arctos_user;
create user MJOSE identified by "c-cret19" profile arctos_user;
create user MKOO identified by "c-cret20" profile arctos_user;
create user MTAKAHASHI identified by "c-cret21" profile arctos_user;
create user MTIEE identified by "c-cret22" profile arctos_user;
create user PATTON identified by "c-cret23" profile arctos_user;
create user PTITLE identified by "c-cret24" profile arctos_user;
create user SDIAZ identified by "c-cret25" profile arctos_user;
create user SHANNA identified by "c-cret26" profile arctos_user;
create user SHARONL identified by "c-cret27" profile arctos_user;
create user STOMIYA identified by "c-cret28" profile arctos_user;
create user SWERNING identified by "c-cret29" profile arctos_user;
create user TFEO identified by "c-cret30" profile arctos_user;
create user TUCO identified by "c-cret31" profile arctos_user;
create user VOLEGUY identified by "c-cret32" profile arctos_user;
create user WOODJACE identified by "c-cret33" profile arctos_user;
    
-- grant manage roles to MVZ users.	  
GRANT
    COLDFUSION_USER,
    MANAGE_TRANSACTIONS
TO AIPPOLITO;

GRANT
    COLDFUSION_USER,
    MANAGE_TRANSACTIONS
TO ATRAPAGA;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    MANAGE_AGENTS,
    MANAGE_COLLECTION,
    MANAGE_CONTAINER,
    MANAGE_GEOGRAPHY,
    MANAGE_LOCALITY,
    MANAGE_PUBLICATIONS,
    MANAGE_SPECIMENS,
    MANAGE_TAXONOMY,
    MANAGE_TRANSACTIONS
TO ATROX;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    GLOBAL_ADMIN,
    MANAGE_AGENTS,
    MANAGE_CODETABLES,
    MANAGE_COLLECTION,
    MANAGE_CONTAINER,
    MANAGE_GEOGRAPHY,
    MANAGE_GREF,
    MANAGE_LOCALITY,
    MANAGE_MEDIA,
    MANAGE_PUBLICATIONS,
    MANAGE_SPECIMENS,
    MANAGE_TAXONOMY,
    MANAGE_TRANSACTIONS
TO CCICERO;

GRANT
    COLDFUSION_USER,
    MANAGE_TRANSACTIONS
TO DIOMEDEA1;

GRANT
    COLDFUSION_USER,
    MANAGE_TRANSACTIONS
TO DKT;

GRANT
    COLDFUSION_USER
TO DMFISHER197;

/*
GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    GLOBAL_ADMIN,
    MANAGE_AGENTS,
    MANAGE_CODETABLES,
    MANAGE_COLLECTION,
    MANAGE_CONTAINER,
    MANAGE_GEOGRAPHY,
    MANAGE_GREF,
    MANAGE_LOCALITY,
    MANAGE_MEDIA,
    MANAGE_PUBLICATIONS,
    MANAGE_SPECIMENS,
    MANAGE_TAXONOMY,
    MANAGE_TRANSACTIONS
TO DUSTY;
*/

GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    MANAGE_LOCALITY,
    MANAGE_SPECIMENS,
    MANAGE_TRANSACTIONS
TO EWOMMACK;

GRANT
    MANAGE_GREF
TO GREF_USER;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    MANAGE_SPECIMENS
TO HPARK;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    MANAGE_LOCALITY,
    MANAGE_SPECIMENS,
    MANAGE_TRANSACTIONS
TO JACASTILLO;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    MANAGE_LOCALITY,
    MANAGE_SPECIMENS,
    MANAGE_TRANSACTIONS
TO JHAVENS;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY
TO JSANTOS;

GRANT
    COLDFUSION_USER,
    MANAGE_SPECIMENS
TO KDODD;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    MANAGE_LOCALITY,
    MANAGE_SPECIMENS,
    MANAGE_TRANSACTIONS
TO KLOVETT;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    MANAGE_LOCALITY,
    MANAGE_SPECIMENS,
    MANAGE_TRANSACTIONS
TO KROWE;

/*
GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    GLOBAL_ADMIN,
    MANAGE_AGENTS,
    MANAGE_CODETABLES,
    MANAGE_COLLECTION,
    MANAGE_CONTAINER,
    MANAGE_GEOGRAPHY,
    MANAGE_LOCALITY,
    MANAGE_MEDIA,
    MANAGE_PUBLICATIONS,
    MANAGE_SPECIMENS,
    MANAGE_TAXONOMY,
    MANAGE_TRANSACTIONS
TO LAM;
*/

GRANT
    COLDFUSION_USER,
    MANAGE_TRANSACTIONS
TO LYDSMITH;

GRANT
    COLDFUSION_USER,
    MANAGE_AGENTS,
    MANAGE_SPECIMENS,
    MANAGE_TRANSACTIONS
TO MJALBE;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY
TO MJOSE;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    GLOBAL_ADMIN,
    MANAGE_AGENTS,
    MANAGE_CODETABLES,
    MANAGE_COLLECTION,
    MANAGE_CONTAINER,
    MANAGE_GEOGRAPHY,
    MANAGE_LOCALITY,
    MANAGE_MEDIA,
    MANAGE_PUBLICATIONS,
    MANAGE_SPECIMENS,
    MANAGE_TAXONOMY,
    MANAGE_TRANSACTIONS
TO MKOO;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    MANAGE_LOCALITY,
    MANAGE_SPECIMENS,
    MANAGE_TRANSACTIONS
TO MTAKAHASHI;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    MANAGE_LOCALITY,
    MANAGE_SPECIMENS,
    MANAGE_TRANSACTIONS
TO MTIEE;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    MANAGE_AGENTS,
    MANAGE_COLLECTION,
    MANAGE_CONTAINER,
    MANAGE_GEOGRAPHY,
    MANAGE_LOCALITY,
    MANAGE_PUBLICATIONS,
    MANAGE_SPECIMENS,
    MANAGE_TAXONOMY,
    MANAGE_TRANSACTIONS
TO PATTON;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    MANAGE_LOCALITY,
    MANAGE_SPECIMENS,
    MANAGE_TRANSACTIONS
TO PTITLE;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    MANAGE_LOCALITY,
    MANAGE_SPECIMENS,
    MANAGE_TRANSACTIONS
TO SDIAZ;

GRANT
    COLDFUSION_USER,
    MANAGE_SPECIMENS,
    MANAGE_TRANSACTIONS
TO SHANNA;

GRANT
    COLDFUSION_USER,
    MANAGE_TRANSACTIONS
TO SHARONL;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    MANAGE_SPECIMENS,
    MANAGE_TRANSACTIONS
TO STOMIYA;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    MANAGE_AGENTS,
    MANAGE_LOCALITY,
    MANAGE_SPECIMENS,
    MANAGE_TRANSACTIONS
TO SWERNING;

GRANT
    COLDFUSION_USER,
    MANAGE_LOCALITY,
    MANAGE_SPECIMENS
TO TFEO;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    GLOBAL_ADMIN,
    MANAGE_AGENTS,
    MANAGE_CODETABLES,
    MANAGE_COLLECTION,
    MANAGE_CONTAINER,
    MANAGE_GEOGRAPHY,
    MANAGE_GREF,
    MANAGE_LOCALITY,
    MANAGE_PUBLICATIONS,
    MANAGE_SPECIMENS,
    MANAGE_TAXONOMY,
    MANAGE_TRANSACTIONS
TO TUCO;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY,
    MANAGE_AGENTS,
    MANAGE_COLLECTION,
    MANAGE_CONTAINER,
    MANAGE_GEOGRAPHY,
    MANAGE_LOCALITY,
    MANAGE_MEDIA,
    MANAGE_PUBLICATIONS,
    MANAGE_SPECIMENS,
    MANAGE_TAXONOMY,
    MANAGE_TRANSACTIONS
TO VOLEGUY;

GRANT
    COLDFUSION_USER,
    DATA_ENTRY
TO WOODJACE;
                

-----------------------------------------------------------------------
-- need a ROLE FOR every collection. EACH "us" USER will be given one OR more OF these ROLES
-- create SQL for them with:
-- also need a PUBLIC USER FOR every one OF these ROLES TO deal WITH NOT-us people looking
-- FOR a specific ENTRY point. So, go TO ..../uam_mamm AS a REAL USER, AND you (now) get a USErname {you}.
-- same point AS nobody, AND you run queries AS uam_query. Need TO CHANGE CF TO assign a (generic access-point specific) 
-- username to every user. This role will have SELECT ONLY on collection-specific parts of the VPD.
-- make very sure to have good Oracle security policies - it WILL get hacked.
-- and the revised plan:
-- each collection has a role: UAM_MAMM
-- each collection has a user: PUB_USR_UAM_MAMM
-- each of those public users need a role: grant UAM_MAMM to PUB_USR_UAM_MAMM;
-- each "us" user gets 1 or more roles: grant UAM_MAMM to dlm;
-- may create multi-role public users:
-- 	grant uam_mamm to pub_usr_all_all;
--	grant uam_bird to pub_usr_all_all;
-- etc.

/*  Create new user, roles to control VPD functions 
--	create public users per institution, per collection: pub_user_inst_coll
--	create collection roles per institution, per collection: inst_coll
--	grant collection roles to public users: inst_coll to pub_user_inst_coll
--	grant connect to public user: pub_user_inst_coll
*/

DECLARE s VARCHAR2(4000);
BEGIN
    FOR uname IN (SELECT username FROM dba_users WHERE username IN (
	    'AIPPOLITO',
		'ATRAPAGA',
        'ATROX',
		'CCICERO',
		'DIOMEDEA1',
		'DKT',
		'DMFISHER197',
		'EWOMMACK',
		'GREF_USER',
		'HPARK',
		'JACASTILLO',
		'JHAVENS',
		'JSANTOS',
		'KDODD',
		'KLOVETT',
		'KROWE',
		'LYDSMITH',
		'MJALBE',
		'MJOSE',
		'MKOO',
		'MTAKAHASHI',
		'MTIEE',
		'PATTON',
		'PTITLE',
		'SDIAZ',
		'SHANNA',
		'SHARONL',
		'STOMIYA',
		'SWERNING',
		'TFEO',
		'TUCO',
		'VOLEGUY',
		'WOODJACE'
    )) LOOP
        s:='grant ' || 
            'MVZOBS_BIRD, ' ||
			'MVZOBS_HERP, ' ||
			'MVZOBS_MAMM, ' ||
			'MVZ_BIRD, ' ||
			'MVZ_EGG, ' ||
			'MVZ_HERP, ' ||
			'MVZ_HILD, ' ||
			'MVZ_IMG, ' ||
			'MVZ_MAMM, ' ||
			'MVZ_PAGE ' ||
			'to ' || uname.username;
		EXECUTE IMMEDIATE s;
		dbms_output.put_line (s);
    END LOOP;
END;	


DECLARE 
    s VARCHAR2(4000);
    u VARCHAR2(30);
    ir VARCHAR2(30);
BEGIN
    FOR q IN (SELECT * FROM collection) LOOP
        u:='PUB_USR_' || upper(q.institution_acronym) || '_' || upper(q.collection_cde);
        ir:=upper(q.institution_acronym) || '_' || upper(q.collection_cde);
        s:='create user ' || u || ' identified by "userpw.' || q.collection_id || '" PROFILE ARCTOS_USER';
        EXECUTE IMMEDIATE s;
        s:='create role ' || ir;
        EXECUTE IMMEDIATE s;
        s:='grant ' || ir || ' to ' || u;
        EXECUTE IMMEDIATE s;
        s:='grant connect to ' || u;
        EXECUTE IMMEDIATE s;
    END LOOP;
END;
/

--	and an all-collection VPD-bypassing super-public-role-thingee
--	stick with the institution_collection syntax.
--	might later want roles like public_uam_all and/or public_all_mamm

CREATE USER PUB_USR_ALL_ALL IDENTIFIED BY "userpw.00" PROFILE ARCTOS_USER;
ALTER USER PUB_USR_ALL_ALL IDENTIFIED BY "userpw.00" PROFILE ARCTOS_USER;
--grant all collection roles to PUB_USR_ALL_ALL
-- and digir_query
DECLARE 
    s VARCHAR2(4000);
    ir VARCHAR2(30);
BEGIN
    FOR q IN (SELECT * FROM collection) LOOP
        ir:=upper(q.institution_acronym) || '_' || upper(q.collection_cde);
        s:='grant ' || ir || ' to pub_usr_all_all';
        EXECUTE IMMEDIATE s;
         s:='grant ' || ir || ' to digir_query';
         dbms_output.put_line(s);
        EXECUTE IMMEDIATE s;
    END LOOP;
END;
/

CREATE USER PUB_USR_MVZ_ALL IDENTIFIED BY "userpw.38" PROFILE ARCTOS_USER;
    
-- grant mvz collection roles to pub_usr_mvz_all
DECLARE 
    s VARCHAR2(4000);
    ir VARCHAR2(30);
BEGIN
    FOR q IN (SELECT * FROM collection WHERE institution_acronym LIKE 'MVZ%') LOOP
        ir:=upper(q.institution_acronym) || '_' || upper(q.collection_cde);
        s:='grant ' || ir || ' to pub_usr_mvz_all';
        EXECUTE IMMEDIATE s;
    END LOOP;
END;
/

-- grant mvz collection roles to mvz users.


-- grant uam collection roles to uam users.
GRANT uam_herb TO AlanBatten;
GRANT uam_mamm TO lolson;
GRANT wnmu_herb TO rj3nn1ngs;
GRANT wnmu_fish TO rj3nn1ngs;
GRANT wnmu_mamm TO rj3nn1ngs;
GRANT msb_mamm TO jdragoo;
GRANT msb_mamm TO esong;
GRANT msb_mamm TO jmalaney;
GRANT dgr_mamm TO jmalaney;
GRANT msb_mamm TO gordon;
GRANT uam_mamm TO gordon;
GRANT uam_mammobs TO gordon;
GRANT uam_mamm TO hayley;
GRANT msb_mamm TO cindy;
GRANT msb_bird TO andy;
GRANT msb_mamm TO ahope;
GRANT uam_ento TO ffdss;
GRANT uam_mamm TO Sumy;
GRANT msb_mamm TO AdrienneR;
GRANT dgr_mamm TO cheryl;
GRANT uam_herb TO steffi;
GRANT msb_mamm TO jldunnum;
GRANT dgr_mamm TO jldunnum;
GRANT uam_herb TO carolyn;
GRANT uam_herb TO sayuri;
GRANT uam_mamm TO aren;
GRANT uam_bird TO aren;
GRANT uam_mamm TO brandy;
GRANT uam_herb TO ZJMEYERS;
GRANT uam_es TO fnamh6;
GRANT msb_mamm TO ADRIENNER;
GRANT dgr_mamm TO AHOPE;
GRANT uam_herb TO ALANBATTEN;
GRANT uam_herb TO ALBREEN;
GRANT uam_fish TO ANDRES_LOPEZ;
GRANT msb_bird TO ANDY;
GRANT uam_mamm TO AREN;
GRANT uam_bird TO AREN;
GRANT uam_mamm TO BRANDY;
GRANT UAMOBS_MAMM TO BRANDY;
GRANT uam_herb TO CAROLYN;
GRANT uam_herb TO CELIA;
GRANT dgr_mamm TO CHERYL;
GRANT dgr_bird TO CHERYL;
GRANT DGR_ENTO TO CHERYL;
GRANT DGR_FISH TO CHERYL;
GRANT DGR_HERP TO CHERYL;
GRANT dgr_mamm TO CINDY;
GRANT UAM_ES TO CLYARDLEY;
GRANT MSB_BIRD TO CWITT;
DROP USER DCRAWFORD;
DROP USER EDIJAM5;
DROP USER ESONG;
GRANT uam_ento TO FFDSS;
GRANT uam_es TO FNAMH6;
DROP USER FSCMF;
DROP USER FSELM10;
GRANT uam_mamm FSIAH2;
DROP USER FSJLF;
GRANT uam_mamm TO FSKBH1;
DROP USER FSKHS4;
GRANT uam_mamm TO  FSKMW19;
GRANT uam_mamm TO FSSLP18;
GRANT uam_mamm TO FTRJC;
GRANT msb_mamm TO GORDON;
GRANT uam_mamm TO HAYLEY;
GRANT uam_mamm HEATHER;
GRANT msb_mamm TO JDRAGOO;
--JHESTER
GRANT msb_mamm TO JHRAINES;
GRANT msb_mamm TO JLDUNNUM;
GRANT dgr_mamm TO JLDUNNUM;
GRANT msb_mamm TO JMALANEY;
GRANT dgr_mamm TO JMALANEY;
GRANT msb_mamm TO JOSECOOK;
GRANT dgr_mamm TO JOSECOOK;
GRANT msb_mamm TO JPKAVANAUGH;
GRANT msb_mamm TO JREARICK;
--JSMITH19
--KENDRA
--KMCDONALD
GRANT msb_mamm TO KSPEER;
GRANT uam_mamm TO LOLSON;
GRANT UAMOBS_MAMM TO LOLSON;
DROP USER LOUIE;
GRANT msb_mamm TO MBOGAN;
--MLELEVIE
GRANT uam_herb TO MONTEG;
DROP USER MREAD;
DROP USER MWEKSLER;
GRANT uam_es TO PDRUCKEN;
GRANT msb_mamm TO RANDLEM;
--REDSUN
DROP USER RHIANNON;
GRANT WNMU_BIRD TO RJ3NN1NGS;
GRANT WNMU_FISH TO RJ3NN1NGS;
GRANT WNMU_MAMM TO RJ3NN1NGS;
--ROSE
GRANT uam_herb TO SAYURI;
--SCOTT
GRANT uam_fish TO SCOTT_AYERS;
GRANT msb_mamm TO SOMACDONALD;
DROP USER SSWANSON;
GRANT uam_herb TO STEFFI;
--STELLA297
GRANT uam_mamm TO SUMY;
DROP USER SYLVIA;
--SYURISTA
DROP USER TADAMSON;
GRANT msb_mamm TO VMCORVINO;
GRANT uam_herb TO ZJMEYERS;

-- grant connect, create table to users; set default tablespace and quota.
BEGIN
    -- all the CF users
    FOR q IN (SELECT GRANTEE FROM DBA_ROLE_PRIVS WHERE GRANTED_ROLE = 'COLDFUSION_USER') LOOP
        EXECUTE IMMEDIATE 'GRANT CONNECT TO ' || q.grantee;
        EXECUTE IMMEDIATE 'GRANT CREATE TABLE TO ' || q.grantee;
        EXECUTE IMMEDIATE 'ALTER USER ' || q.grantee || ' pROFILE arctos_user DEFAULT TABLESPACE users QUOTA 1G ON users';
    END LOOP;
    -- and the public collection users
    FOR q IN (select username from all_users where username like 'PUB_USR_%') LOOP
        EXECUTE IMMEDIATE 'GRANT CONNECT TO ' || q.username;
        EXECUTE IMMEDIATE 'GRANT CREATE TABLE TO ' || q.username;
        EXECUTE IMMEDIATE 'ALTER USER ' || q.username || ' pROFILE arctos_user DEFAULT TABLESPACE users QUOTA 1G ON users';
    END LOOP;
END;
/

--- damn - vpal/ipal-->es
drop user pub_usr_uam_vpal;
drop user pub_usr_uam_ipal;
CREATE USER pub_usr_uam_es IDENTIFIED BY "userpw.21" PROFILE arctos_user;
grant connect to pub_usr_uam_es;
grant create table to pub_usr_uam_es;
ALTER USER pub_usr_uam_es default TABLESPACE users QUOTA 1G on users;
UPDATE flat SET collection='UAM Earth Science' WHERE collection_id=21;

-- check for arctos users who are not cold fusion users and set profile, default tablespace, and quota.
BEGIN
    FOR u IN (
        SELECT username FROM dba_users
        WHERE PROFILE != 'ARCTOS_USER'
        ORDER BY username
    ) LOOP
        dbms_output.put_line (u.username);
    END LOOP;
END;

-- scott is oracle system user
alter user scott profile default;
alter user DIGIR_QUERY PROFILE arctos_user DEFAULT TABLESPACE users QUOTA 1G ON users;
alter user UAM profile arctos_user DEFAULT TABLESPACE users QUOTA 1G ON users;
----alter user UAM_QUERY PROFILE arctos_user DEFAULT TABLESPACE users QUOTA 1G ON users;
--alter user UAM_UPDATE PROFILE arctos_user DEFAULT TABLESPACE users QUOTA 1G ON users;
--alter user VPD_TEST PROFILE arctos_user DEFAULT TABLESPACE users QUOTA 1G ON users;
/* only at test
alter user EIGHTY profile arctos_user PROFILE arctos_user DEFAULT TABLESPACE users QUOTA 1G ON users';;
*/
BEGIN
    -- all the CF users
    FOR q IN (SELECT table_name FROM USEr_tables WHERE table_name LIKE 'CF%') LOOP
        EXECUTE IMMEDIATE 'GRANT all privileges on ' ||  q.table_name || ' TO cf_dbuser';
    END LOOP;
END;
/
