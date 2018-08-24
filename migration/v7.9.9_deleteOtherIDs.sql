-- TODO

-- rebuild ajax, switch includes


drop table cf_temp_delete_oids;
drop public synonym cf_temp_delete_oids;

create table cf_temp_delete_oids (
	key number,
	collection_object_id number,
	guid varchar2(60) not null,
	other_id_type varchar2(255) not null,
	other_id_number varchar2(255) not null,
	other_id_references varchar2(255) not null,
	status varchar2(4000),
	username varchar2(60) not null
);

create public synonym cf_temp_delete_oids for cf_temp_delete_oids;

grant select,insert,update,delete on cf_temp_delete_oids to manage_collection;

CREATE OR REPLACE TRIGGER cf_temp_d_oids_key
	before insert ON cf_temp_delete_oids
	for each row
    begin
    	if :NEW.key is null then
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;
		:NEW.username:=SYS_CONTEXT('USERENV', 'SESSION_USER');
    end;
/
sho err

insert into cf_form_permissions (FORM_PATH,ROLE_NAME) values ('/tools/BulkDeleteOtherId.cfm','manage_collection');