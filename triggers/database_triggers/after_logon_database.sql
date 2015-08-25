-- create as sys

CREATE TRIGGER set_session_nls_params
AFTER LOGON
ON DATABASE
BEGIN
   DBMS_SESSION.SET_NLS('NLS_SORT', 'GENERIC_M_AI');
   DBMS_SESSION.SET_NLS('NLS_COMP', 'LINGUISTIC');
   DBMS_SESSION.SET_NLS('NLS_LENGTH_SEMANTICS', 'CHAR');
END;
/






CREATE OR REPLACE TRIGGER "SYS".TR_ON_LOGON AFTER
LOGON ON DATABASE BEGIN
-- Set appropriate security based on username.
    UAM.APP_SECURITY_CONTEXT.SET_USER_INFO();
    --DBMS_SESSION.SET_NLS('NLS_DATE_FORMAT', 'yyyy-mm-dd');
     execute immediate 'alter session set nls_date_format = ''yyyy-mm-dd'' ';
    
END;