


  
create sequence sq_agent_relations_id start with 1 increment by 1 nocache;

  create public synonym sq_agent_relations_id for sq_agent_relations_id;
  grant select on sq_agent_relations_id to public;
  
  
alter table agent_relations add agent_relations_id number;
  
  
    lock table agent_relations in exclusive mode nowait;



update agent_relations set agent_relations_id = sq_agent_relations_id.nextval;



CREATE OR REPLACE TRIGGER tr_agent_relations_id_sq
BEFORE INSERT ON agent_relations
FOR EACH ROW
BEGIN
    IF :new.agent_relations_id IS NULL THEN
        SELECT sq_agent_relations_id.nextval
        INTO :new.agent_relations_id
        FROM dual;
    END IF;
END;
/


alter table agent_relations drop constraint PK_agent_relations keep index;

alter index PK_agent_relations rename to IX_u_agent_relations;

alter table agent_relations add constraint PK_agent_relations primary key (agent_relations_id) using index tablespace uam_idx_1;

-- electronic_address
create sequence sq_electronic_address_id start with 1 increment by 1 nocache;
 create public synonym sq_electronic_address_id for sq_electronic_address_id;
  grant select on sq_electronic_address_id to public;
alter table electronic_address add electronic_address_id number;
    lock table electronic_address in exclusive mode nowait;
update electronic_address set electronic_address_id = sq_electronic_address_id.nextval;


CREATE OR REPLACE TRIGGER tr_electronic_address_id_sq
BEFORE INSERT ON electronic_address
FOR EACH ROW
BEGIN
    IF :new.electronic_address_id IS NULL THEN
        SELECT sq_electronic_address_id.nextval
        INTO :new.electronic_address_id
        FROM dual;
    END IF;
END;
/

alter table electronic_address drop constraint PK_electronic_address keep index;
alter index PK_electronic_address rename to IX_u_electronic_address;

alter table electronic_address add constraint PK_electronic_address primary key (electronic_address_id) using index tablespace uam_idx_1;



-- group_member
create sequence sq_group_member_id start with 1 increment by 1 nocache;
 create public synonym sq_group_member_id for sq_group_member_id;
  grant select on sq_group_member_id to public;
alter table group_member add group_member_id number;
    lock table group_member in exclusive mode nowait;
update group_member set group_member_id = sq_group_member_id.nextval;


CREATE OR REPLACE TRIGGER tr_group_member_id_sq
BEFORE INSERT ON group_member
FOR EACH ROW
BEGIN
    IF :new.group_member_id IS NULL THEN
        SELECT sq_group_member_id.nextval
        INTO :new.group_member_id
        FROM dual;
    END IF;
END;
/

alter table group_member drop constraint PK_group_member keep index;
alter index PK_group_member rename to IX_u_group_member;
alter table group_member add constraint PK_group_member primary key (group_member_id) using index tablespace uam_idx_1;

-- see if we can get by with a lack of order
alter table group_member modify MEMBER_ORDER null;



---- this is already done do nothing!!


--update coll_obj_other_id_num set ID_REFERENCES='collected with' where ID_REFERENCES in ('collected from','collected on');


--- deal with agents being randomly assigned roles

alter table cf_ctuser_roles add required_reading varchar2(255);

update cf_ctuser_roles set required_reading='http://arctosdb.org/documentation/publications/' where ROLE_NAME='manage_publications';
update cf_ctuser_roles set required_reading='http://arctosdb.org/documentation/agent/' where ROLE_NAME='manage_agents';
update cf_ctuser_roles set required_reading='http://arctosdb.org/documentation/container/' where ROLE_NAME='manage_container';
update cf_ctuser_roles set required_reading='http://arctosdb.org/documentation/places/higher-geography/' where ROLE_NAME='manage_geography';
update cf_ctuser_roles set required_reading='http://arctosdb.org/documentation/places/locality/' where ROLE_NAME='manage_locality';
update cf_ctuser_roles set required_reading='http://arctosdb.org/documentation/transaction/' where ROLE_NAME='manage_transactions';
update cf_ctuser_roles set required_reading='http://arctosdb.org/documentation/authorities/' where ROLE_NAME='manage_codetables';
update cf_ctuser_roles set required_reading='http://arctosdb.org/documentation/identification/taxonomy/' where ROLE_NAME='manage_taxonomy';
update cf_ctuser_roles set required_reading='http://arctosdb.org/how-to/create/data-entry/' where ROLE_NAME='data_entry';
update cf_ctuser_roles set required_reading='http://arctosdb.org/documentation/media/' where ROLE_NAME='manage_media';




