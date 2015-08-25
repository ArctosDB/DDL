/* Create application security function to implement RLS */

--CREATE AS uam; this is a mapping table for collection_id and locality_id.
CREATE TABLE vpd_collection_locality AS
    SELECT DISTINCT ci.collection_id, ce.locality_id
    FROM cataloged_item ci, collecting_event ce
    WHERE ci.collecting_event_id = ce.collecting_event_id
    GROUP BY  ci.collection_id, ce.locality_id;
    
ALTER TABLE vpd_collection_locality
ADD CONSTRAINT PK_VPD_COLLECTION_LOCALITY
PRIMARY KEY (collection_id, locality_id)
USING INDEX TABLESPACE uam_idx_1;

ALTER TABLE vpd_collection_locality ADD stale_fg NUMBER(1);
    
INSERT INTO vpd_collection_locality (locality_id, collection_id, stale_fg) (
    select uam.locality.locality_id , 0, 0
    from uam.locality, uam.vpd_collection_locality
    where uam.locality.locality_id = uam.vpd_collection_locality.locality_id (+)
    and uam.vpd_collection_locality.locality_id is null);
    
CREATE INDEX ix_vpd_collloc_collid 
ON vpd_collection_locality (collection_id)
TABLESPACE uam_idx_1;

CREATE INDEX ix_vpd_collloc_locid 
ON vpd_collection_locality (locality_id)
TABLESPACE uam_idx_1;
   
CREATE OR REPLACE TRIGGER tr_catitem_vpd_ad
AFTER DELETE ON cataloged_item
FOR EACH ROW
DECLARE lid collecting_event.locality_id%TYPE;
BEGIN
    SELECT locality_id INTO lid
    FROM collecting_event
    WHERE collecting_event_id = :OLD.collecting_event_id;
        
    UPDATE  vpd_collection_locality 
    SET stale_fg = 1
    WHERE locality_id=lid 
    AND collection_id=:OLD.collection_id;
END;
/

CREATE OR REPLACE TRIGGER tr_catitem_vpd_aiu
AFTER INSERT OR UPDATE ON cataloged_item
FOR EACH ROW
DECLARE lid collecting_event.locality_id%TYPE;
BEGIN
    SELECT locality_id INTO lid
    FROM collecting_event
    WHERE collecting_event_id = :NEW.collecting_event_id;
    
    INSERT INTO vpd_collection_locality (collection_id, locality_id)
    VALUES(:NEW.collection_id, lid);
EXCEPTION WHEN dup_val_on_index THEN
    NULL;
END;
/

CREATE OR REPLACE TRIGGER tr_locality_vpd_aid
AFTER INSERT OR DELETE ON locality
FOR EACH ROW
BEGIN
    IF inserting THEN
        INSERT INTO vpd_collection_locality (locality_id,collection_id,stale_fg)
        VALUES (:NEW.locality_id,0,0);
    ELSIF deleting THEN
        DELETE FROM vpd_collection_locality WHERE locality_id=:OLD.locality_id;
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE vpd_collection_locality_stale
IS n NUMBER;
BEGIN
    FOR r IN (
        SELECT locality_id, collection_id 
        FROM vpd_collection_locality WHERE stale_fg = 1
    ) LOOP
        SELECT COUNT(*) INTO n 
        FROM cataloged_item, collecting_event
        WHERE cataloged_item.collecting_event_id = collecting_event.collecting_event_id
        AND collecting_event.locality_id = r.locality_id 
        AND cataloged_item.collection_id = r.collection_id;
        IF n = 0 THEN
            DELETE FROM vpd_collection_locality
            WHERE locality_id = r.locality_id 
            AND collection_id=r.collection_id;
        ELSE
            UPDATE vpd_collection_locality 
            SET stale_fg = 0 
            WHERE locality_id = r.locality_id 
            AND collection_id=r.collection_id;
        END IF;
    END LOOP;
END;
/

--exec DBMS_SCHEDULER.DROP_JOB('VPD_COLL_LOC_STALE');
--exec DBMS_SCHEDULER.RUN_JOB('VPD_COLL_LOC_STALE', USE_CURRENT_SESSION=>TRUE);

BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'vpd_coll_loc_stale',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'vpd_collection_locality_stale',
		start_date		=> to_timestamp_tz(sysdate || ' 01:00:00', 'DD-MON-YYYY HH24:MI:SS'),
		repeat_interval	=> 'freq=hourly; byminute=10,40;',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'maintains stale records in vpd_collection_locality table');
END;
/ 

-- create as UAM
-- DROP PACKAGE app_security_context;

CREATE OR REPLACE PACKAGE app_security_context
-- Sets user info and predicates 
IS
    PROCEDURE set_user_info;
    
    FUNCTION set_cid_pred (
        object_schema   IN  VARCHAR2  DEFAULT NULL,
        object_name     IN  VARCHAR2  DEFAULT NULL
    )     
    RETURN VARCHAR2;

    FUNCTION set_lid_pred (
        object_schema   IN  VARCHAR2  DEFAULT NULL,
        object_name     IN  VARCHAR2  DEFAULT NULL
    )     
    RETURN VARCHAR2;
END;
/

CREATE OR REPLACE PACKAGE BODY app_security_context
IS
    PROCEDURE set_user_info
    -- Sets VPD_CONTEXT based on login
    IS
        username        VARCHAR2(30);
        clist           VARCHAR2(4000);
        rlist           VARCHAR2(4000);
        sep             CHAR(1);
    BEGIN
        -- get user information from the USERENV context
        SELECT SYS_CONTEXT ('USERENV','SESSION_USER') INTO username FROM dual;
        
        -- get the list of allowable collection_ids based on username/roles.
        FOR c IN (
            SELECT c.collection_id, d.granted_role
            FROM sys.dba_role_privs d, uam.cf_collection c
            WHERE d.granted_role = c.portal_name
            AND d.grantee = username
            ORDER BY c.collection_id
        ) LOOP
            clist := clist || sep || c.collection_id;
            rlist := rlist || sep || c.granted_role;
            sep := ',';
        END LOOP;
        
        -- set the vpd_context to be the list of allowable collection_ids
        DBMS_SESSION.SET_CONTEXT('VPD_CONTEXT', 'CID_LIST', clist);
        DBMS_SESSION.SET_CONTEXT('VPD_CONTEXT', 'ROLE_LIST', rlist);
    END set_user_info;
    -- generate predicate for collection_id
    
    FUNCTION set_cid_pred (
        object_schema   IN  VARCHAR2  DEFAULT NULL
       ,object_name     IN  VARCHAR2  DEFAULT NULL
    )     
    RETURN VARCHAR2
    IS
        username  VARCHAR2(30);
        predicate VARCHAR2(4000);
    BEGIN
        SELECT SYS_CONTEXT ('USERENV','SESSION_USER') INTO username FROM dual;
        
        IF SYS_CONTEXT('VPD_CONTEXT','CID_LIST') IS NOT NULL THEN
            predicate := 'collection_id in (' || SYS_CONTEXT('VPD_CONTEXT','CID_LIST',4000) || ')';
        ELSE
            predicate := '1 = 2';
        END IF;
            
        RETURN predicate;
    END set_cid_pred;
    
    -- generate predicate for locality_id
    FUNCTION set_lid_pred (
        object_schema   IN  VARCHAR2  DEFAULT NULL
       ,object_name     IN  VARCHAR2  DEFAULT NULL
    )     
    RETURN VARCHAR2
    IS
        username  VARCHAR2(30);
        predicate VARCHAR2(4000);
    BEGIN
        SELECT SYS_CONTEXT ('USERENV','SESSION_USER') INTO username FROM dual;
        IF SYS_CONTEXT('VPD_CONTEXT','CID_LIST') IS NOT NULL THEN 
            predicate := 'locality_id in (' || 
           		'select locality_id from uam.vpd_collection_locality ' ||
            	'where collection_id in (0,' || 
            	SYS_CONTEXT('VPD_CONTEXT','CID_LIST',4000) || '))';
        ELSE
            predicate := '1 = 2';
        END IF;
            
        RETURN predicate;
    END set_lid_pred;
END;
/

-- Grant all privs on security context package to uam so uam can grant execute to new users.
--GRANT ALL PRIVILEGES ON sys.app_security_context TO uam WITH GRANT OPTION;

-- grant as UAM
grant execute on app_security_context to PUBLIC

/*
-- Grant execute on security context package to users.
-- need to do this after migrating collection table data and users.
DECLARE 
    s VARCHAR2(4000);
    u VARCHAR2(30);
BEGIN
    dbms_output.put_line('PUB_USRs:');
    FOR p IN (SELECT * FROM uam.collection) LOOP
        u:='PUB_USR_' || upper(p.institution_acronym) || '_' || upper(p.collection_cde);
        s:='grant execute on sys.app_security_context to ' || u;
        EXECUTE IMMEDIATE s;
        dbms_output.put_line(chr(9) ||s);
    END LOOP;
    
    dbms_output.put_line('COLDFUSION_USERs:');
    
    FOR g IN (
        SELECT grantee FROM dba_role_privs 
        where granted_role = 'COLDFUSION_USER'
        order by grantee
    ) LOOP
        s:='grant execute on sys.app_security_context to ' || g.grantee;
        EXECUTE IMMEDIATE s;
        dbms_output.put_line(chr(9) ||s);
    END LOOP;
END;
/
*/

-- Create CONTEXT workspace as SYS to retain user session info in memory 
--DROP CONTEXT vpd_context;
CREATE CONTEXT vpd_context USING uam.app_security_context;

-- Create trigger as SYS to set VPD_CONTEXT whenever a user connects.
CREATE OR REPLACE TRIGGER tr_on_logon
AFTER LOGON ON DATABASE
BEGIN
    -- set date format
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYY-MM-DD''';
    
    -- Set appropriate security based on username.
    UAM.APP_SECURITY_CONTEXT.SET_USER_INFO();
END;
/

/
--exec dbms_rls.drop_policy('UAM','CATALOGED_ITEM','CATITEM_SIUD_POL');
--exec dbms_rls.drop_policy('UAM','COLLECTION','COLLECTION_SIUD_POL');
--exec dbms_rls.drop_policy('UAM','FLAT','FLAT_SIUD_POL');
--exec dbms_rls.drop_policy('UAM','LOCALITY','LOCALITY_SIUD_POL');
--exec dbms_rls.drop_policy('UAM','TRANS','TRANS_SIUD_POL');

--exec dbms_rls.enable_policy('UAM','CATALOGED_ITEM','CATITEM_SIUD_POL', FALSE);
--exec dbms_rls.enable_policy('UAM','COLLECTION','COLLECTION_SIUD_POL', FALSE);
--exec dbms_rls.enable_policy('UAM','FLAT','FLAT_SIUD_POL', FALSE);
--exec dbms_rls.enable_policy('UAM','LOCALITY','LOCALITY_SIUD_POL', FALSE);
--exec dbms_rls.enable_policy('UAM','TRANS','TRANS_SIUD_POL', FALSE);

-- CATALOGED_ITEM  where collection_id in VPD_CONTEXT
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'CATALOGED_ITEM'
        ,policy_name => 'CATITEM_SIUD_POL'
        ,function_schema => 'UAM'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_CID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- COLLECTION where collection_id in VPD_CONTEXT
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'COLLECTION'
        ,policy_name => 'COLLECTION_SIUD_POL'
        ,function_schema => 'UAM'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_CID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- FLAT collection_id in VPD_CONTEXT
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'FLAT'
        ,policy_name => 'FLAT_SIUD_POL'
        ,function_schema => 'UAM'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_CID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/
-- LOCALITY --> collecting_event --> cataloged_item --> collection
-- where l.locality_id = ce.locality_id
-- and ce.collecting_event_id = ci.collecting_event_id
-- and ci.collection_id in VPD_CONTEXT
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'LOCALITY'
        ,policy_name => 'LOCALITY_SIUD_POL'
        ,function_schema => 'UAM'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_LID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- TRANS where collection_id in VPD_CONTEXT
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'TRANS'
        ,policy_name => 'TRANS_SIUD_POL'
        ,function_schema => 'UAM'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_CID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/
