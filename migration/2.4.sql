/*
	This file provides the code needed to move from v2.3.1 to v2.4
	
	Release info:
		Establishes session control
		Requires periodic password changes (currently 90 days)
		Provides means to customize by collection
			--/includes/css/{stylesheets} provided by user
			-- basic header stuff in manage collection
		establishes form-level access control
		Eliminates /tools/ and implements dropdown menus
		Adds multiple Add Parts functionality (SpecimenResults/Manage)
		Multiple searching - see documentation:
			Parts (add Big Searh Box under Preferences)
				-- finds specimens with ALL parts
			State (use |-separated list for OR)
		Add multiple generic agents to transactions
		Add lender_loan_type to borrow
		Improves other ID parsing
		Add institutional filter to loans
			-- to see loans, a logged-in user must have a role in a collection within the institution for
			which they wish to manage loans.
	To Test: Absolutely everything.
		The way in which variables are assigned, carried across
			sessions, and referenced has changed.
		The internal user login process has changed.
		The way in which pages are process has changed.
		
	Before going to Production:
		alter /CustomTags/rolecheck.cfm: turn off roles output
		alter /CustomTags/Security.cfm : turn off security output
		alter /includes/_header.cfm: turn on query caching
		alter /Application.cfc: turn off onError dump
		
	Requirements: 		
*/

ALTER TABLE cf_spec_res_cols
	ADD cf_spec_res_cols_id NUMBER;

ALTER TABLE cf_spec_res_cols
	ADD disp_order NUMBER;

UPDATE cf_spec_res_cols
	SET disp_order = 1;

ALTER TABLE cf_spec_res_cols
	MODIFY disp_order NOT NULL;
	
BEGIN
	FOR r IN (SELECT ROWID FROM cf_spec_res_cols) LOOP
		UPDATE cf_spec_res_cols
			SET cf_spec_res_cols_id = somerandomsequence.nextval
			WHERE ROWID = r.rowid;
	END LOOP;
END;
/

ALTER TABLE cf_spec_res_cols
	MODIFY cf_spec_res_cols_id NOT NULL;
	
ALTER TABLE cf_spec_res_cols
	ADD CONSTRAINT pk_cf_spec_res_cols
	PRIMARY KEY (cf_spec_res_cols_id);
	
CREATE OR REPLACE TRIGGER trg_cf_spec_res_cols_id
BEFORE INSERT ON cf_spec_res_cols
FOR EACH ROW
BEGIN
	SELECT somerandomsequence.nextval
		INTO :new.cf_spec_res_cols_id
		FROM dual;
END;																							
/
sho err	

UPDATE cf_spec_res_cols
	SET sql_element=replace(sql_element,'#','');
	
-- run code in /ddl/schema/cf_spec_res_cols to update table!!!

CREATE OR REPLACE FUNCTION get_str_el (
mystring IN VARCHAR,
separator IN VARCHAR,
pos IN NUMBER)
RETURN VARCHAR2
AS theThingy VARCHAR2(4000);
BEGIN
	SELECT bla INTO theThingy
	FROM (
		SELECT
			rownum r,
			SUBSTR(mystring || separator,
				NVL(LAG(token) OVER (ORDER BY token),0) + 1,
				token - (NVL(LAG(token) OVER (ORDER BY token), 0) + 1)) bla
		FROM (
			SELECT
				LEVEL,
				INSTR( mystring || separator, separator, 1, level ) token
			FROM DUAL
			CONNECT BY INSTR( mystring || separator, separator, 1, level ) != 0
			ORDER BY level
		)
	)
	WHERE r = pos;
	RETURN theThingy;
END;
/

CREATE OR REPLACE PROCEDURE parse_other_id (
	collection_object_id IN NUMBER,
	other_id_num IN VARCHAR2,
	other_id_type IN VARCHAR2)
IS
	part_one VARCHAR2(255);
	part_two VARCHAR2(255);
	part_three VARCHAR2(255);
	dlms VARCHAR2(255) := '|-.; ';
	td VARCHAR2(255);
BEGIN
	IF IS_NUMBER(other_id_num) = 1 THEN -- just a number
		part_one := NULL;
		part_two := other_id_num;
		part_three := NULL;
	ELSIF -- check for the presence of [ and ], used to implicitly bracket NUMBER
		INSTR(other_id_num, '[') > 0 AND
		INSTR(other_id_num, ']') > 0 AND
		INSTR(other_id_num, ']', 1, 2) = 0 AND
		INSTR(other_id_num, '[', 1, 2) = 0 AND
		INSTR(other_id_num, '[') < INSTR(other_id_num, ']')
	THEN
		part_one := SUBSTR(other_id_num, 1, INSTR(other_id_num, '[') - 1);
		part_two := SUBSTR(other_id_num,
			INSTR(other_id_num, '[') + 1,
			INSTR(other_id_num, ']') - INSTR(other_id_num, '[') -1);
		part_three :=  SUBSTR(other_id_num, INSTR(other_id_num, ']') + 1);
	ELSIF -- number plus single char
		IS_NUMBER(SUBSTR(other_id_num, 1, LENGTH(other_id_num) - 1)) = 1
	THEN
		part_two := SUBSTR(other_id_num, 1, LENGTH(other_id_num) - 1);
		part_three := SUBSTR(other_id_num, LENGTH(other_id_num));				
	ELSIF -- single char + number
		 IS_NUMBER(SUBSTR(other_id_num, 2)) = 1
	THEN
		 part_one := SUBSTR(other_id_num, 1, 1);
		 part_two := SUBSTR(other_id_num, 2);
	ELSE -- loop through list of delimiter defined above and see what falls out
		FOR i IN 1..100 LOOP
			td := SUBSTR(dlms, i, 1);
			EXIT WHEN td IS NULL;
			IF INSTR(other_id_num,td) > 0 THEN  -- see if our number contains the current delimiter
				part_one := GET_STR_EL(other_id_num, td, 1);
				part_two := GET_STR_EL(other_id_num, td, 2);
				IF INSTR(other_id_num, td, 1, 2) > 0 THEN
					part_three := GET_STR_EL(other_id_num, td, 3);
				END IF;
				IF part_three IS NULL THEN -- got back two parts, see if we can make one of them numeric
					IF IS_NUMBER(part_two) = 0 AND IS_NUMBER(part_one) = 1 THEN
						part_three := part_two;
						part_two := part_one;
						part_one := NULL;
					END IF;
				END IF;
			END IF;
		END LOOP;
	END IF;
	--- last resort, or somehow missing number, or number isn't a number
	IF part_two IS NULL OR IS_NUMBER(part_two) != 1 THEN
		part_one := other_id_num;
		part_two := NULL;
		part_three := NULL;
	END IF;
	INSERT INTO coll_obj_other_id_num (
		collection_object_id,
		other_id_type,
		other_id_prefix,
		other_id_number,
		other_id_suffix)
	VALUES (
		collection_object_id,
		other_id_type,
		part_one,
		part_two,
		part_three);
END;
/
sho err

CREATE OR REPLACE PUBLIC SYNONYM parse_other_id FOR parse_other_id;
GRANT EXECUTE ON parse_other_id TO manage_specimens;

ALTER TRIGGER other_id_ct_check DISABLE;

UPDATE coll_obj_other_id_num
	SET other_id_prefix = other_id_prefix || concat_char
	WHERE other_id_prefix IS NOT NULL
	AND other_id_number IS NOT NULL;

UPDATE coll_obj_other_id_num
	SET other_id_suffix = concat_char || other_id_suffix
	WHERE other_id_suffix IS NOT NULL
	AND other_id_number IS NOT NULL;
	
ALTER TABLE coll_obj_other_id_num DROP COLUMN concat_char;

-- how bout a pkey while we're here
ALTER TABLE coll_obj_other_id_num ADD COLL_OBJ_OTHER_ID_NUM_ID NUMBER;

CREATE SEQUENCE coll_obj_other_id_num_seq;

BEGIN
	FOR r IN (SELECT rowid FROM coll_obj_other_id_num) LOOP
		UPDATE coll_obj_other_id_num
			SET coll_obj_other_id_num_id = coll_obj_other_id_num_seq.nextval
			WHERE rowid = r.rowid;
	END LOOP;
END;
/

ALTER TRIGGER other_id_ct_check ENABLE;

/* above for loop ran too slow with other_id_ct_check trigger enabled
and alternative to disabling the trigger is to use below AND re-create everything

CREATE SEQUENCE sparky;

CREATE TABLE oid2 AS
	SELECT
		collection_object_id,
		other_id_num,
		other_id_type,
		other_id_prefix,
		other_id_number,
		other_id_suffix,
		display_value,
		sparky.nextval AS coll_obj_other_id_num_id
		FROM coll_obj_other_id_num;

SELECT MAX(COLL_OBJ_OTHER_ID_NUM_ID) + 1 FROM oid2;

ALTER TABLE coll_obj_other_id_num RENAME TO coll_obj_other_id_num_old;

ALTER TABLE oid2 RENAME TO coll_obj_other_id_num;

DROP SEQUENCE coll_obj_other_id_num_seq;

CREATE SEQUENCE coll_obj_other_id_num_seq START WITH 854567;

ALTER TABLE coll_obj_other_id_num MODIFY coll_obj_other_id_num_id NOT NULL;

ALTER TABLE coll_obj_other_id_num
	ADD CONSTRAINT pk_coll_obj_other_id_num_id
	PRIMARY KEY (coll_obj_other_id_num_id);

ALTER TABLE coll_obj_other_id_num_old
	DROP CONSTRAINT pk_coll_obj_other_id_num;

CREATE UNIQUE INDEX pk_coll_obj_other_id_num
	ON coll_obj_other_id_num (collection_object_id, other_id_type, display_value);

DROP INDEX XIF18COLL_OBJ_OTHER_ID_NUM;
	
CREATE INDEX XIF18COLL_OBJ_OTHER_ID_NUM
	ON COLL_OBJ_OTHER_ID_NUM (COLLECTION_OBJECT_ID);								

DROP INDEX COLLOBJOTHERIDNUM_COLLOBJID;

CREATE INDEX COLLOBJOTHERIDNUM_COLLOBJID
	ON COLL_OBJ_OTHER_ID_NUM (DISPLAY_VALUE);

DROP INDEX XIE2COLL_OBJ_OTHER_ID_NUM;

CREATE INDEX XIE2COLL_OBJ_OTHER_ID_NUM
	ON COLL_OBJ_OTHER_ID_NUM (OTHER_ID_TYPE);

REVOKE ALL ON coll_obj_other_id_num_old FROM manage_specimens;

GRANT INSERT, UPDATE, DELETE ON coll_obj_other_id_num TO manage_specimens;

CREATE OR REPLACE TRIGGER coll_obj_disp_val
BEFORE INSERT or UPDATE ON coll_obj_other_id_num
FOR EACH ROW
BEGIN
 	:NEW.display_value := :NEW.other_id_prefix || :NEW.other_id_number || :NEW.other_id_suffix;
 	SELECT coll_obj_other_id_num_seq.nextval into :NEW.coll_obj_other_id_num_id FROM dual;
END;
/
sho err

DROP TRIGGER UP_FLAT_OTHERIDS;

CREATE OR REPLACE TRIGGER up_flat_otherids
AFTER INSERT OR UPDATE OR DELETE ON coll_obj_other_id_num
BEGIN
	FOR i IN 1 .. state_pkg.newRows.count LOOP
		UPDATE flat
		SET
			genbankNum = concatGenbank(collection_object_id),
			otherCatalogNumbers = concatOtherId(collection_object_id),
			field_num = concatSingleOtherId(collection_object_id,'Field Num'),
			CollectorNumber = concatSingleOtherId(collection_object_id, 'collector number')
		WHERE collection_object_id = state_pkg.newRows(i);
	END LOOP;
END;
/
sho err

DROP TRIGGER AD_FLAT_OTHERIDS;

CREATE OR REPLACE TRIGGER AD_FLAT_OTHERIDS
AFTER DELETE ON coll_obj_other_id_num
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.collection_object_id;
END;
/
show err

DROP TRIGGER A_FLAT_OTHERIDS;

CREATE OR REPLACE TRIGGER A_FLAT_OTHERIDS
AFTER INSERT OR UPDATE ON coll_obj_other_id_num
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.collection_object_id;
END;
/
show err

DROP TRIGGER B_FLAT_OTHERIDS;

CREATE OR REPLACE TRIGGER B_FLAT_OTHERIDS
BEFORE insert or update or delete ON coll_obj_other_id_num
FOR EACH ROW
BEGIN
	state_pkg.newRows := state_pkg.empty;
end;
/
show err

DROP TRIGGER OTHER_ID_CT_CHECK;

CREATE OR REPLACE TRIGGER OTHER_ID_CT_CHECK
before UPDATE or INSERT ON coll_obj_other_id_num
for each row
declare
	numrows number;
	collectionCode varchar2(20);
BEGIN
	select collection.collection_cde into collectionCode
	from collection,cataloged_item
	where collection.collection_id = cataloged_item.collection_id
	and cataloged_item.collection_object_id = :NEW.collection_object_id;
	execute immediate 'SELECT COUNT(*)
		FROM ctcoll_other_id_type
		WHERE other_id_type = ''' || :NEW.other_id_type || '''
		AND collection_cde = ''' || collectionCode || '''' INTO numrows ;
	IF (numrows = 0) THEN
		raise_application_error(
			-20001,
			'Invalid other ID type (' || :NEW.other_id_type || ') for collection_cde ' || collectionCode || '.');
	END IF;
END;
/
show err

DROP TRIGGER TU_COLL_OBJ_OTHER_ID_NUM;
CREATE OR REPLACE TRIGGER TU_COLL_OBJ_OTHER_ID_NUM
after UPDATE on Coll_Obj_Other_ID_Num for each row
declare numrows INTEGER;
begin
	select count(*) into numrows
	from Coll_Object
	where :new.Collection_Object_id = Coll_Object.Collection_Object_id;
	if (numrows = 0) then
		raise_application_error(
			-20007,
			'Cannot UPDATE "Coll_Obj_Other_ID_Num" because "Coll_Object" does not exist.');
	end if;
end;
/
show err

DROP TRIGGER COLL_OBJ_DATA_CHECK;

CREATE OR REPLACE TRIGGER COLL_OBJ_DATA_CHECK
before UPDATE or INSERT ON coll_obj_other_id_num
for each row
declare
	numrows number;
	isNumber number;
BEGIN
	if :new.other_id_type = 'AF' then
		select is_number(:new.other_id_num) into isNumber from dual;
		if isNumber = 0 then
			raise_application_error(
				-20000,
				'AF must be numeric!');
		end if;
	end if;
	if :new.other_id_type = 'NK Number' then
		select is_number(:new.other_id_num) into isNumber from dual;
		if isNumber = 0 then
			raise_application_error(
				-20000,
				'NK Number must be numeric!');
		end if;
	end if;
	if :new.other_id_type = 'NK' then
		select is_number(:new.other_id_num) into isNumber from dual;
		if isNumber = 0 then
			raise_application_error(
				-20000,
				'NK must be numeric!');
		end if;
	end if;
END;
/
show err

CREATE OR REPLACE TRIGGER TI_COLL_OBJ_OTHER_ID_NUM
after INSERT on Coll_Obj_Other_ID_Num for each row
declare numrows INTEGER;
begin
	select count(*) into numrows
	from Coll_Object
	where :new.Collection_Object_id = Coll_Object.Collection_Object_id;
	if (numrows = 0) then
		raise_application_error(
			-20002,
			'Cannot INSERT "Coll_Obj_Other_ID_Num" because "Coll_Object" does not exist.');
	end if;
end;
/
show err

-- end of recreation of coll_object_other_id_num
*/

ALTER TABLE borrow ADD lender_loan_type VARCHAR2(60);

CREATE TABLE trans_agent (
	trans_agent_id NUMBER NOT NULL,
	transaction_id NUMBER NOT NULL,
	agent_id NUMBER NOT NULL,
	trans_agent_role VARCHAR2(60) NOT NULL);

CREATE PUBLIC SYNONYM trans_agent FOR trans_agent;
GRANT SELECT ON trans_agent TO PUBLIC;
GRANT INSERT, UPDATE, DELETE ON trans_agent TO manage_transactions;

CREATE SEQUENCE trans_agent_seq;
CREATE PUBLIC SYNONYM trans_agent_seq FOR trans_agent_seq;
GRANT SELECT ON trans_agent_seq TO PUBLIC;

ALTER TABLE trans_agent
	ADD CONSTRAINT trans_agent_pkey
	PRIMARY  KEY (trans_agent_id);

ALTER TABLE trans_agent
	ADD CONSTRAINT fk_trans_agnt_trans
	FOREIGN KEY (transaction_id)
	REFERENCES trans(transaction_id);
	
ALTER TABLE trans_agent
	add CONSTRAINT fk_trans_agnt_agnt
	FOREIGN KEY (agent_id)
	REFERENCES agent(agent_id);

CREATE UNIQUE INDEX u_trans_agent 
    ON trans_agent(transaction_id, agent_id, trans_agent_role);

CREATE TABLE cttrans_agent_role (
	trans_agent_role VARCHAR2(60) NOT NULL);

CREATE PUBLIC SYNONYM cttrans_agent_role FOR cttrans_agent_role;
GRANT SELECT ON cttrans_agent_role TO PUBLIC;
GRANT INSERT, UPDATE, DELETE ON cttrans_agent_role TO manage_codetables;

CREATE OR REPLACE TRIGGER trans_agent_pre
BEFORE UPDATE OR INSERT ON trans_agent
FOR EACH ROW
DECLARE numrows NUMBER;
BEGIN
	IF :NEW.trans_agent_id IS NULL THEN
		SELECT trans_agent_seq.nextval INTO :NEW.trans_agent_id FROM dual;
	END IF;
	SELECT COUNT(*) INTO numrows 
	    FROM cttrans_agent_role 
	    WHERE trans_agent_role = :NEW.trans_agent_role;
    IF (numrows = 0) THEN
        raise_application_error(
            -20001,
            'Invalid trans_agent_role');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trans_agent_entered
AFTER INSERT ON trans
FOR EACH ROW
BEGIN
	INSERT INTO trans_agent (
    		transaction_id,
			agent_id,
			trans_agent_role) (
        SELECT
            :NEW.transaction_id,
	        agent_name.agent_id,
	        'entered by'
		FROM agent_name
		WHERE agent_name_type='login'
		AND upper(agent_name) = upper(USER));
END;
/

CREATE OR REPLACE FUNCTION concattransagent (
    trans_id IN NUMBER, trans_agent_role IN VARCHAR )
RETURN VARCHAR2
AS
    TYPE RC IS REF CURSOR;
	l_str	VARCHAR2(4000);
	l_sep	VARCHAR2(3);
	l_val	VARCHAR2(4000);
	l_cur	RC;
BEGIN
    OPEN l_cur FOR 'SELECT agent_name
		FROM preferred_agent_name, trans_agent
		WHERE trans_agent.agent_id=preferred_agent_name.agent_id
		AND trans_agent.transaction_id = :x
		AND trans_agent.trans_agent_role = :y
		ORDER BY agent_name'
        USING trans_id, trans_agent_role;
    LOOP
        FETCH l_cur INTO l_val;
        EXIT WHEN l_cur%notfound;
        l_str := l_str || l_sep || l_val;
        l_sep := ', ';
		END LOOP;
	CLOSE l_cur;
    RETURN l_str;
END;
/

CREATE OR REPLACE PUBLIC SYNONYM concattransagent FOR concattransagent;
GRANT EXECUTE ON concattransagent TO PUBLIC;

INSERT INTO cttrans_agent_role VALUES ('authorized by');
INSERT INTO cttrans_agent_role VALUES ('entered by');
INSERT INTO cttrans_agent_role VALUES ('received by');
INSERT INTO cttrans_agent_role VALUES ('associated with agency');
INSERT INTO cttrans_agent_role VALUES ('received from');

INSERT INTO trans_agent (
    	transaction_id,
		agent_id,
		trans_agent_role) (
    SELECT
	    transaction_id,
		auth_agent_id,
		'authorized by'
	FROM trans
	WHERE auth_agent_id IS NOT NULL);

INSERT INTO trans_agent (
    	transaction_id,
		agent_id,
		trans_agent_role) (
    SELECT
	    transaction_id,
		trans_entered_agent_id,
		'entered by'
	FROM trans);
	
INSERT INTO trans_agent (
    	transaction_id,
		agent_id,
		trans_agent_role) (
	SELECT
		trans.transaction_id,
		trans.received_agent_id,
		'received from'
	FROM trans, accn
	WHERE trans.transaction_id = accn.transaction_id);
	
INSERT INTO trans_agent (
    	transaction_id,
		agent_id,
		trans_agent_role) (
    SELECT
		trans.transaction_id,
		trans.received_agent_id,
		'received by'
	FROM trans, loan
	WHERE trans.transaction_id = loan.transaction_id);

/* code below is corrected by code above to insert 
"received by" and "received from" records

INSERT INTO trans_agent (
	transaction_id,
	agent_id,
	trans_agent_role) (
	SELECT
		transaction_id,
		received_agent_id,
		'received by'
	FROM trans);
	
-- update code below is to correct erroneous code above
	
UPDATE trans_agent
	SET trans_agent_role = 'received from'
	WHERE transaction_id in (SELECT transaction_id FROM accn)
	AND trans_agent_role = 'received by';
*/

INSERT INTO trans_agent (
    	transaction_id,
		agent_id,
		trans_agent_role) (
    SELECT
	    transaction_id,
		trans_agency_id,
	    'associated with agency'
	FROM trans
	WHERE trans_agency_id IS NOT NULL);
	
ALTER TABLE trans MODIFY trans_entered_agent_id NULL;
ALTER TABLE trans MODIFY received_agent_id NULL;

CREATE TABLE cf_collection_appearance (
	collection_id NUMBER NOT NULL,
	header_color VARCHAR2(20) NOT NULL,
	header_image VARCHAR2(255) NOT NULL,
	collection_url VARCHAR2(255) NOT NULL,
	collection_link_text VARCHAR2(60) NOT NULL,
	institution_url VARCHAR2(255) NOT NULL,
	institution_link_text VARCHAR2(60) NOT NULL,
	meta_description VARCHAR2(255) NOT NULL,
	meta_keywords VARCHAR2(255) NOT NULL,
	stylesheet VARCHAR2(60) NOT NULL);
	
CREATE OR REPLACE PUBLIC SYNONYM cf_collection_appearance 
    FOR cf_collection_appearance;
GRANT ALL ON cf_collection_appearance TO manage_collection;
GRANT SELECT ON cf_collection_appearance TO PUBLIC;

ALTER TABLE cf_collection_appearance
	ADD CONSTRAINT fk_cfcollappear_collection
	FOREIGN KEY (collection_id)
	REFERENCES collection(collection_id);

ALTER TABLE cf_users ADD pw_change_date DATE;

ALTER TABLE cf_users ADD last_login DATE;

UPDATE cf_users SET pw_change_date = SYSDATE;

ALTER TABLE cf_users MODIFY pw_change_date NOT NULL;
	
CREATE OR REPLACE TRIGGER cf_pw_change
BEFORE UPDATE OR INSERT ON cf_users
FOR EACH ROW
BEGIN
    IF :NEW.password != :OLD.password THEN
		:NEW.pw_change_date := SYSDATE;
	END IF;
END;
/
sho err;

CREATE TABLE cf_form_permissions (
	key NUMBER NOT NULL,
	form_path VARCHAR2(255) NOT NULL,
	role_name VARCHAR2(255) NOT NULL);
	
CREATE PUBLIC SYNONYM cf_form_permissions FOR cf_form_permissions;
GRANT ALL ON cf_form_permissions TO coldfusion_user;
GRANT SELECT ON cf_form_permissions TO PUBLIC;
   
CREATE OR REPLACE TRIGGER cf_form_permissions_key
BEFORE UPDATE OR INSERT ON cf_form_permissions
FOR EACH ROW
BEGIN
    IF :NEW.key IS NULL THEN
    	SELECT somerandomsequence.nextval INTO :NEW.key FROM dual;
    END IF;
END;
/
sho err;

-- use the following to get the SQL to populate cf_form_permissions
SELECT 'insert into cf_form_permissions (form_path,role_name) values (''' || form_path || ''',''' || role_name || '''' || ');'
	FROM cf_form_permissions;

ALTER TABLE cf_ctuser_roles
    ADD CONSTRAINT user_role_key
    PRIMARY KEY (role_name);
    
ALTER TABLE cf_form_permissions
    ADD CONSTRAINT fk_role
    FOREIGN KEY (role_name)
    REFERENCES cf_ctuser_roles (role_name);

ALTER TABLE identification_agent
    ADD CONSTRAINT fk_identification_id 
    FOREIGN KEY (identification_id)
    REFERENCES identification (identification_id);
        
ALTER TABLE identification_agent
    ADD CONSTRAINT fk_id_agent_id 
    FOREIGN KEY (agent_id)
    REFERENCES agent (agent_id);