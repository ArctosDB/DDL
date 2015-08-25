-- new procedure to create a new address from existing address
-- if existing address is used in shipment or correspondence.
CREATE OR REPLACE PROCEDURE add_new_addr (
	st1 in VARCHAR2,
	st2 in VARCHAR2,
	ci in VARCHAR2,
	st in VARCHAR2,
	zp in VARCHAR2,
	cc in VARCHAR2,
	ms in VARCHAR2,
	aid in NUMBER,
	atype in VARCHAR2,
	title in VARCHAR2,
	rmk in VARCHAR2,
	inst in VARCHAR2,
	dept in VARCHAR2
)
AS
	pragma autonomous_transaction;
BEGIN
	INSERT INTO addr (
		street_addr1,
		street_addr2,
		city,
		state,
		zip,
		country_cde,
		mail_stop,
		agent_id,
		addr_type,
		job_title,
		valid_addr_fg,
		addr_remarks,
		institution,
		department)
	VALUES (
		st1,
		st2,
		ci,
		st,
		zp,
		cc,
		ms,
		aid,
		atype,
		title,
		1,
		rmk,
		inst,
		dept);
		
	COMMIT;
END;
/

-- new trigger that checks for changes and calls the procedure
-- that creates a new address if the old address is used.
CREATE OR REPLACE TRIGGER tr_addr_au
BEFORE UPDATE ON addr
FOR EACH ROW
DECLARE
    ship INTEGER;
    corr INTEGER;
	new_data VARCHAR2(4000);
	old_data VARCHAR2(4000);
BEGIN
	SELECT :OLD.addr_id || :OLD.street_addr1 || :OLD.street_addr2 || 
		:OLD.city ||:OLD.state || :OLD.zip || :OLD.country_cde || 
		:OLD.mail_stop || :OLD.agent_id || :OLD.addr_type || 
		:OLD.job_title || :OLD.institution || :OLD.department
    INTO old_data FROM dual;
    
	SELECT :NEW.addr_id || :NEW.street_addr1 || :NEW.street_addr2 || 
		:NEW.city || :NEW.state || :NEW.zip || :NEW.country_cde || 
		:NEW.mail_stop || :NEW.agent_id || :NEW.addr_type || 
		:NEW.job_title || :NEW.institution || :NEW.department
    INTO new_data FROM dual;
    
    dbms_output.put_line('OLD: ' || old_data);
    dbms_output.put_line('NEW: ' || new_data);
    
    IF old_data != new_data THEN
		SELECT COUNT(*) INTO ship
		FROM shipment
		WHERE shipped_to_addr_id = :OLD.addr_id;

		SELECT COUNT(*) INTO corr
		FROM correspondence
		WHERE to_agent_addr_id = :OLD.addr_id;
		
	    dbms_output.put_line('SHIP: ' || ship);
	    dbms_output.put_line('CORR: ' || corr);

		IF (ship > 0 OR corr > 0) THEN
			-- if we made it here we want to create a new record
	
			-- call procedure for autonomous transaction
			add_new_addr(
				:NEW.street_addr1,
				:NEW.street_addr2,
				:NEW.city,
				:NEW.state,
				:NEW.zip,
				:NEW.country_cde,
				:NEW.mail_stop,
				:NEW.agent_id,
				:NEW.addr_type,
				:NEW.job_title,
				:NEW.addr_remarks,
				:NEW.institution,
				:NEW.department);
				
			-- now that we've used the changes to create a new record,
			--   1) set valid_addr_fg = 0 and
			--   2) replace :NEW values with :OLD ones
			-- so that we don't update anything for the existing used record.
			-- formatted_addr gets updated by trigger BUILD_FORMATTED_ADDR
			
			:NEW.valid_addr_fg := 0;
			:NEW.street_addr1 := :OLD.street_addr1;
			:NEW.street_addr2 := :OLD.street_addr2;
			:NEW.city := :OLD.city;
			:NEW.state := :OLD.state;
			:NEW.zip := :OLD.zip;
			:NEW.country_cde := :OLD.country_cde;
			:NEW.mail_stop := :OLD.mail_stop;
			:NEW.agent_id := :OLD.agent_id;
			:NEW.addr_type := :OLD.addr_type;
			:NEW.job_title := :OLD.job_title;
			:NEW.addr_remarks := :OLD.addr_remarks;
			:NEW.institution := :OLD.institution;
			:NEW.department := :OLD.department;
			
		END IF;
	END IF;
END;
/

-- renames trigger.
ALTER TRIGGER tr_addr_au RENAME TO tr_addr_bu

-- new trigger to use next value in sequence if addr_id is null on insert.
CREATE OR REPLACE TRIGGER tr_addr_sq
BEFORE INSERT ON addr
FOR EACH ROW
BEGIN
    IF :new.addr_id IS NULL THEN
        SELECT sq_addr_id.nextval
        INTO :new.addr_id
        FROM dual;
    END IF;
END;
/

-- new trigger to raise error if trying to update agent name that is used
-- in publication_author_name, project_agent, project_sponsor.
CREATE OR REPLACE TRIGGER TR_AGENT_NAME_BU
BEFORE UPDATE ON AGENT_NAME
FOR EACH ROW
DECLARE numrows INTEGER;
BEGIN
    SELECT COUNT(*) INTO numrows
	FROM PUBLICATION_AUTHOR_NAME
	WHERE AGENT_NAME_ID = :OLD.AGENT_NAME_ID;
	
    IF (numrows > 0) THEN
        RAISE_APPLICATION_ERROR(
    	-20001,
		'Cannot UPDATE an agent name used as a publication author.');
    end if;
    
    SELECT COUNT(*) INTO numrows
	FROM PROJECT_AGENT
	WHERE AGENT_NAME_ID = :OLD.AGENT_NAME_ID;
	
    IF (numrows > 0) THEN
        RAISE_APPLICATION_ERROR(
    	-20001,
		'Cannot UPDATE an agent name used as a project agent.');
    end if;
	
    SELECT COUNT(*) INTO numrows
	FROM PROJECT_SPONSOR
	WHERE AGENT_NAME_ID = :OLD.AGENT_NAME_ID;
	
    IF (numrows > 0) THEN
        RAISE_APPLICATION_ERROR(
    	-20001,
		'Cannot UPDATE an agent name used as a project sponsor.');
    end if;
END;
/

-- check for agents that have more than one preferred name.
-- needs to be fixed before continuing.
select count(*), agent_id 
from agent_name 
where agent_name_type = 'preferred'
group by agent_id
having count(*) > 1;

-- update agent.preferred_agent_name_id with good data.
update agent a set a.preferred_agent_name_id = (
    select an.agent_name_id
	from agent_name an
	where an.agent_name_type = 'preferred'
	and a.agent_id = an.agent_id
);

-- code to generate drop constraint sql for foreign keys
-- that reference agent.agent_id (PK_AGENT).
select 'alter table ' || table_name || ' drop constraint ' || constraint_name || ';'
from user_constraints where r_constraint_name = 'PK_AGENT';

-- code to generate drop constraint sql for foreign keys
-- that reference agent_name.agent_name_id (PK_AGENT_NAME).
select 'alter table ' || table_name || ' drop constraint ' || constraint_name || ';'
from user_constraints where r_constraint_name = 'PK_AGENT_NAME';

-- code to generate sql to rebuild foreign key constraints
-- that reference agent.agent_id (PK_AGENT)
-- exclude foreign key on agent_name.agent_id since it will
-- be built separately as deferrable initially deferred.
select 'alter table ' || table_name || chr(10) || chr(9) ||
'add constraint ' || constraint_name || chr(10) || chr(9) ||
'foreign key (' || column_name  || ')' || chr(10) || chr(9) ||
'referencing agent (agent_id);'
from user_cons_columns where constraint_name in (
    select constraint_name 
    from user_constraints
    where r_constraint_name = 'PK_AGENT'
    AND table_name != 'AGENT_NAME');

-- code to generate sql to rebuild foreign key constraints
-- that reference agent_name.agent_name_id (PK_AGENT_NAME)
select 'alter table ' || table_name || chr(10) || chr(9) ||
'add constraint ' || constraint_name || chr(10) || chr(9) ||
'foreign key (' || column_name  || ')' || chr(10) || chr(9) ||
'referencing agent_name (agent_name_id);'
from user_cons_columns where constraint_name in (
    select constraint_name 
    from user_constraints
    where r_constraint_name = 'PK_AGENT_NAME');

-- drop foreign keys to agent.agent_id. necessary in order
-- to drop and re-create primary key on agent.agent_id as
-- deferrable initially deferred.
-- generated from code above.
alter table ADDR drop constraint FK_ADDR_AGENT;
alter table AGENT_NAME drop constraint FK_AGENTNAME_AGENT;
alter table AGENT_RANK drop constraint FK_AR_AGENT_ID;
alter table AGENT_RANK drop constraint FK_AR_RANKER_AGENT_ID;
alter table AGENT_RELATIONS drop constraint FK_AGENTRELATIONS_AGENT_ANID;
alter table AGENT_RELATIONS drop constraint FK_AGENTRELATIONS_AGENT_RANID;
alter table ATTRIBUTES drop constraint FK_ATTRIBUTES_AGENT;
alter table COLLECTION_CONTACTS drop constraint FK_COLLCONTACTS_AGENT;
alter table COLLECTOR drop constraint FK_COLLECTOR_AGENT;
alter table COLL_OBJECT drop constraint FK_COLLOBJECT_AGENT_EDITED;
alter table COLL_OBJECT drop constraint FK_COLLOBJECT_AGENT_ENTERED;
alter table CONTAINER_CHECK drop constraint FK_CONTAINERCHECK_AGENT;
alter table ELECTRONIC_ADDRESS drop constraint FK_ELECTRONICADDR_AGENT;
alter table ENCUMBRANCE drop constraint FK_ENCUMBRANCE_AGENT;
alter table GROUP_MEMBER drop constraint FK_GROUPMEMBER_AGENT_GROUP;
alter table GROUP_MEMBER drop constraint FK_GROUPMEMBER_AGENT_MEMBER;
alter table IDENTIFICATION_AGENT drop constraint FK_IDAGENT_AGENT;
alter table LAT_LONG drop constraint FK_LATLONG_AGENT;
alter table MEDIA_LABELS drop constraint FK_MEDIALABELS_AGENT;
alter table MEDIA_RELATIONS drop constraint FK_MEDIARELNS_AGENT;
alter table OBJECT_CONDITION drop constraint FK_OBJECTCONDITION_AGENT;
alter table PERMIT drop constraint FK_PERMIT_AGENT_CONTACT;
alter table PERMIT drop constraint FK_PERMIT_AGENT_ISSUEDBY;
alter table PERMIT drop constraint FK_PERMIT_AGENT_ISSUEDTO;
alter table PERSON drop constraint FK_PERSON_AGENT;
alter table SHIPMENT drop constraint FK_SHIPMENT_AGENT;
alter table TAB_MEDIA_REL_FKEY drop constraint FK_TABMEDIARELFKEY_AGENT;
alter table TRANS_AGENT drop constraint FK_TRANSAGENT_AGENT;


-- drop foreign keys to agent_name.agent_name_id. necessary in order
-- to drop and re-create primary key on agent_name.agent_name_id as
-- deferrable initially deferred.
-- generated from code above.
alter table GREF_ROI_VALUE_NG drop constraint FK_ROIVALUENG_AGENTNAME;
alter table PROJECT_AGENT drop constraint FK_PROJECTAGENT_AGENTNAME;
alter table PROJECT_SPONSOR drop constraint FK_PROJECTSPONSOR_AGENTNAME;
alter table PUBLICATION_AUTHOR_NAME drop constraint FK_PUBAUTHNAME_AGENTNAME;

-- drop primary keys on agent and agent_name.
ALTER TABLE agent DROP CONSTRAINT pk_agent; 
ALTER TABLE agent_name DROP CONSTRAINT pk_agent_name; 

-- drop indexes on agent.agent_id and agent_name.agent_name_id.
-- will be rebuilt as part of primary key.
DROP INDEX XPKAGENT_NAME;
DROP INDEX PKEY_AGENT;
    
-- add primary key for agent.agent_id as deferrable initially deferred.
ALTER TABLE agent 
    ADD CONSTRAINT pk_agent 
    PRIMARY KEY (agent_id) 
    DEFERRABLE INITIALLY DEFERRED;
    
-- add primary keys for agent_name.agent_name_id as deferrable initially deferred.
ALTER TABLE agent_name
    ADD CONSTRAINT pk_agent_name
    PRIMARY KEY (agent_name_id)
    DEFERRABLE INITIALLY DEFERRED;
    
-- NEW: add foreign key for agent.preferred_agent_name_id
-- referencing agent_name.agent_name_id as deferrable initially deferred.
ALTER TABLE agent
    ADD CONSTRAINT fk_agent_agentname
    FOREIGN KEY (preferred_agent_name_id)
    REFERENCES agent_name (agent_name_id)
    DEFERRABLE INITIALLY DEFERRED;
    
-- add foreign key for agent_name.agent_id
-- referencing agent.agent_id as deferrable initially deferred.
ALTER TABLE agent_name
    ADD CONSTRAINT fk_agentname_agent
    FOREIGN KEY (agent_id) REFERENCES agent (agent_id)
    DEFERRABLE INITIALLY DEFERRED;

-- add foreign keys on tables that reference agent.agent_id.
alter table ADDR
        add constraint FK_ADDR_AGENT
        foreign key (AGENT_ID)
        referencing agent (agent_id);

alter table PERMIT
        add constraint FK_PERMIT_AGENT_ISSUEDBY
        foreign key (ISSUED_BY_AGENT_ID)
        referencing agent (agent_id);

alter table TAB_MEDIA_REL_FKEY
        add constraint FK_TABMEDIARELFKEY_AGENT
        foreign key (CFK_AGENT)
        referencing agent (agent_id);

alter table TRANS_AGENT
        add constraint FK_TRANSAGENT_AGENT
        foreign key (AGENT_ID)
        referencing agent (agent_id);

alter table AGENT_RELATIONS
        add constraint FK_AGENTRELATIONS_AGENT_RANID
        foreign key (RELATED_AGENT_ID)
        referencing agent (agent_id);

alter table COLLECTION_CONTACTS
        add constraint FK_COLLCONTACTS_AGENT
        foreign key (CONTACT_AGENT_ID)
        referencing agent (agent_id);

alter table ELECTRONIC_ADDRESS
        add constraint FK_ELECTRONICADDR_AGENT
        foreign key (AGENT_ID)
        referencing agent (agent_id);

alter table LAT_LONG
        add constraint FK_LATLONG_AGENT
        foreign key (DETERMINED_BY_AGENT_ID)
        referencing agent (agent_id);

alter table AGENT_RANK
        add constraint FK_AR_AGENT_ID
        foreign key (AGENT_ID)
        referencing agent (agent_id);

alter table ENCUMBRANCE
        add constraint FK_ENCUMBRANCE_AGENT
        foreign key (ENCUMBERING_AGENT_ID)
        referencing agent (agent_id);

alter table SHIPMENT
        add constraint FK_SHIPMENT_AGENT
        foreign key (PACKED_BY_AGENT_ID)
        referencing agent (agent_id);

alter table AGENT_RELATIONS
        add constraint FK_AGENTRELATIONS_AGENT_ANID
        foreign key (AGENT_ID)
        referencing agent (agent_id);

alter table COLLECTOR
        add constraint FK_COLLECTOR_AGENT
        foreign key (AGENT_ID)
        referencing agent (agent_id);

alter table PERMIT
        add constraint FK_PERMIT_AGENT_CONTACT
        foreign key (CONTACT_AGENT_ID)
        referencing agent (agent_id);

alter table AGENT_RANK
        add constraint FK_AR_RANKER_AGENT_ID
        foreign key (RANKED_BY_AGENT_ID)
        referencing agent (agent_id);

alter table ATTRIBUTES
        add constraint FK_ATTRIBUTES_AGENT
        foreign key (DETERMINED_BY_AGENT_ID)
        referencing agent (agent_id);

alter table IDENTIFICATION_AGENT
        add constraint FK_IDAGENT_AGENT
        foreign key (AGENT_ID)
        referencing agent (agent_id);

alter table MEDIA_RELATIONS
        add constraint FK_MEDIARELNS_AGENT
        foreign key (CREATED_BY_AGENT_ID)
        referencing agent (agent_id);

alter table OBJECT_CONDITION
        add constraint FK_OBJECTCONDITION_AGENT
        foreign key (DETERMINED_AGENT_ID)
        referencing agent (agent_id);

alter table CONTAINER_CHECK
        add constraint FK_CONTAINERCHECK_AGENT
        foreign key (CHECKED_AGENT_ID)
        referencing agent (agent_id);

alter table GROUP_MEMBER
        add constraint FK_GROUPMEMBER_AGENT_GROUP
        foreign key (GROUP_AGENT_ID)
        referencing agent (agent_id);

alter table MEDIA_LABELS
        add constraint FK_MEDIALABELS_AGENT
        foreign key (ASSIGNED_BY_AGENT_ID)
        referencing agent (agent_id);

alter table COLL_OBJECT
        add constraint FK_COLLOBJECT_AGENT_EDITED
        foreign key (LAST_EDITED_PERSON_ID)
        referencing agent (agent_id);

alter table COLL_OBJECT
        add constraint FK_COLLOBJECT_AGENT_ENTERED
        foreign key (ENTERED_PERSON_ID)
        referencing agent (agent_id);

alter table GROUP_MEMBER
        add constraint FK_GROUPMEMBER_AGENT_MEMBER
        foreign key (MEMBER_AGENT_ID)
        referencing agent (agent_id);

alter table PERMIT
        add constraint FK_PERMIT_AGENT_ISSUEDTO
        foreign key (ISSUED_TO_AGENT_ID)
        referencing agent (agent_id);

alter table PERSON
        add constraint FK_PERSON_AGENT
        foreign key (PERSON_ID)
        referencing agent (agent_id);

-- add foreign keys on tables that reference agent.agent_id.
alter table PUBLICATION_AUTHOR_NAME
        add constraint FK_PUBAUTHNAME_AGENTNAME
        foreign key (AGENT_NAME_ID)
        referencing agent_name (agent_name_id);

alter table GREF_ROI_VALUE_NG
        add constraint FK_ROIVALUENG_AGENTNAME
        foreign key (AGENT_ID)
        referencing agent_name (agent_name_id);

alter table PROJECT_AGENT
        add constraint FK_PROJECTAGENT_AGENTNAME
        foreign key (AGENT_NAME_ID)
        referencing agent_name (agent_name_id);

alter table PROJECT_SPONSOR
        add constraint FK_PROJECTSPONSOR_AGENTNAME
        foreign key (AGENT_NAME_ID)
        referencing agent_name (agent_name_id);

-- new trigger to check for only one preferred name,
-- and preventing a preferred name from being deleted.
CREATE OR REPLACE TRIGGER tr_agent_name_biud
BEFORE INSERT OR UPDATE OR DELETE ON agent_name
FOR EACH ROW 
DECLARE 
	pragma autonomous_transaction;
	c number;
BEGIN
	IF INSERTING THEN
		SELECT COUNT(*) INTO c
		FROM agent_name
		WHERE agent_id = :NEW.agent_id
		and agent_name_type = 'preferred';
		
		IF :NEW.agent_name_type = 'preferred' THEN
			c := c + 1; -- pre-transaction value plus the new value we're trying to insert
		END IF;
			
		IF c != 1 THEN
		    RAISE_APPLICATION_ERROR(
			    -20001,
			    'FAIL: You are trying to make ' || c || ' preferred names!');
		END IF;
	ELSIF UPDATING ('AGENT_NAME_TYPE') THEN
		IF (:NEW.agent_name_type = 'preferred' AND :OLD.agent_name_type != 'preferred')
		    OR (:NEW.agent_name_type != 'preferred' AND :OLD.agent_name_type = 'preferred')
		THEN -- only care if they're trying to update preferred to another name type, or another type to preferred
			RAISE_APPLICATION_ERROR(
			    -20001,
			    'FAIL: no switching!');
		END IF;
	ELSIF DELETING THEN -- since we never let them create >1 preferred, don't ever let them delete the preferred
		IF :OLD.agent_name_type = 'preferred' THEN
			RAISE_APPLICATION_ERROR(
			    -20001,
			    'FAIL: no deleting preferred names!');
		END IF;
    END IF;
END;
/
sho err;

uam@arctost1> desc test_agent;
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 AGENT_ID                                  NOT NULL NUMBER
 AGENT_TYPE                                NOT NULL VARCHAR2(30)
 AGENT_REMARKS                                      VARCHAR2(4000)
 PREFERRED_AGENT_NAME_ID                   NOT NULL NUMBER

uam@arctost1> desc test_agent_name;
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 AGENT_NAME_ID                             NOT NULL NUMBER
 AGENT_ID                                  NOT NULL NUMBER
 AGENT_NAME_TYPE                           NOT NULL VARCHAR2(18)
 DONOR_CARD_PRESENT_FG                              NUMBER
 AGENT_NAME                                NOT NULL VARCHAR2(184)

-- fail
insert into t1 (a,b) values (1,2);
insert into t2 (a,b,tp) values (1,2,'b');
commit;

SELECT sq_agent_id.nextval, sq_agent_name_id.nextval FROM dual;

insert into test_agent (agent_id, preferred_agent_name_id, agent_type)
values (15248037, 4730335, 'person');
insert into test_agent_name (agent_id, agent_name_id, agent_name_type, agent_name)
values (15248037, 4730335, 'initials', 'T. E. S. T.');
commit;

-- pass
insert into t1 (a,b) values (1,2);
insert into t2 (a,b,tp) values (1,2,'a');

insert into test_agent (agent_id, preferred_agent_name_id, agent_type)
values (15248036, 4730334, 'person');
insert into test_agent_name (agent_id, agent_name_id, agent_name_type, agent_name)
values (15248036, 4730334, 'preferred', 'Test A. Agent');
commit;

-- fail
update t2 set tp='b';

UPDATE test_agent_name SET agent_name_type = 'initials'
WHERE agent_id = 15248036;
commit;

--pass
insert into t2 (a,b,tp) values (1,3,'b');

insert into test_agent_name (agent_id, agent_name_id, agent_name_type, agent_name)
values (15248036, 4730336, 'initials', 'T. A. A.');

insert into test_agent_name (agent_id, agent_name_id, agent_name_type, agent_name)
values (15248036, 4730335, 'aka', 'Testie Agent');
COMMIT;

-- fail
update t2 set tp='a' where b=3;

UPDATE test_agent_name SET agent_name_type = 'preferred'
WHERE agent_name_id = 4730336;
COMMIT;

UPDATE test_agent_name SET agent_name_type = 'aka'
WHERE agent_name_id = 4730334;
COMMIT;

-- fail
delete from t1;

DELETE FROM test_agent WHERE agent_id = 15248036;
COMMIT;

DELETE FROM test_agent_name WHERE agent_name_id = 4730334;
COMMIT;

DELETE FROM test_agent_name WHERE agent_name_id = 4730335;
COMMIT;

-- pass
alter trigger t_t2 disable;
delete from t1;
alter trigger t_t2 enable;

alter trigger tr_test_agent_name disable;
delete from test_agent WHERE agent_id = 15248036;
alter trigger tr_test_agent_name enable;

select t1.agent_id, t2.agent_name_id, t2.agent_name_type
from test_agent t1,test_agent_name t2
where t1.agent_id = t2.agent_id
AND t1.agent_id = 15248036;

