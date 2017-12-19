https://github.com/ArctosDB/arctos/issues/1139

TODO:

minimize 
	ajax.js
	SpecimenResults.js

clean up now-unused table columns


create table permit_20171211 as select * from permit;




create table ctpermit_regulation (
	permit_regulation varchar2(255) not null,
	description varchar2(255) not null
);

create public synonym ctpermit_regulation for ctpermit_regulation;

grant all on ctpermit_regulation to manage_codetables;
grant select on ctpermit_regulation to public;

ALTER TABLE ctpermit_regulation add CONSTRAINT pk_ctpermit_regulation PRIMARY KEY (permit_regulation);


insert into ctpermit_regulation (permit_regulation,description) values ('CITES','Convention on International Trade in Endangered Species of Wild Fauna and Flora');
insert into ctpermit_regulation (permit_regulation,description) values ('BGEPA','Bald and Golden Eagle Protection Act');
insert into ctpermit_regulation (permit_regulation,description) values ('ESA','Endangered Species Act');
insert into ctpermit_regulation (permit_regulation,description) values ('MBTA','Migratory Bird Treaty Act');
insert into ctpermit_regulation (permit_regulation,description) values ('WBCA','Wild Bird Conservation Act');
insert into ctpermit_regulation (permit_regulation,description) values ('MMPA','Marine Mammal Protection Act');
insert into ctpermit_regulation (permit_regulation,description) values ('LA','Lacey Act');
insert into ctpermit_regulation (permit_regulation,description) values ('AECA','African Elephant Conservation Act');
insert into ctpermit_regulation (permit_regulation,description) values ('AA','Antiquities Act');
insert into ctpermit_regulation (permit_regulation,description) values ('AHPA','Archaeological and Historical Preservation Act');
insert into ctpermit_regulation (permit_regulation,description) values ('NHPA','National Historic Preservation Act');
insert into ctpermit_regulation (permit_regulation,description) values ('ARPA','Archaeological and Historical Preservation Act');
																									
																									
																									
																									
																								
																									

create table log_CTPERMIT_REGULATION (
username varchar2(60),
when date default sysdate,
n_DESCRIPTION VARCHAR2(255),
n_PERMIT_REGULATION VARCHAR2(255),
o_DESCRIPTION VARCHAR2(255),
o_PERMIT_REGULATION VARCHAR2(255)
);

create or replace public synonym log_CTPERMIT_REGULATION for log_CTPERMIT_REGULATION;

grant select on log_CTPERMIT_REGULATION to coldfusion_user;


CREATE OR REPLACE TRIGGER TR_log_CTPERMIT_REGULATION AFTER INSERT or update or delete ON CTPERMIT_REGULATION
FOR EACH ROW
BEGIN
insert into log_CTPERMIT_REGULATION (
username,
when,
n_DESCRIPTION,
n_PERMIT_REGULATION,
o_DESCRIPTION,
o_PERMIT_REGULATION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.PERMIT_REGULATION,
:OLD.DESCRIPTION,
:OLD.PERMIT_REGULATION
);
END;
/ 



		
		
create table ctpermit_agent_role (
	permit_agent_role varchar2(255) not null,
	description varchar2(255) not null
);

create public synonym ctpermit_agent_role for ctpermit_agent_role;

grant all on ctpermit_agent_role to manage_codetables;

grant select on ctpermit_agent_role to public;
ALTER TABLE ctpermit_agent_role add CONSTRAINT pk_ctpermit_agent_role PRIMARY KEY (permit_agent_role);

insert into ctpermit_agent_role (permit_agent_role,description)	values ('issued by','Agent issuing permit');	
insert into ctpermit_agent_role (permit_agent_role,description)	values ('issued to','Agent to whom permit is issued');	
insert into ctpermit_agent_role (permit_agent_role,description)	values ('contact','Agent who will receive permit notifications from Arctos');
																									
create table log_CTPERMIT_AGENT_ROLE (
	username varchar2(60),
	when date default sysdate,
	n_DESCRIPTION VARCHAR2(255),
	n_PERMIT_AGENT_ROLE VARCHAR2(255),
	o_DESCRIPTION VARCHAR2(255),
	o_PERMIT_AGENT_ROLE VARCHAR2(255)
);

create or replace public synonym log_CTPERMIT_AGENT_ROLE for log_CTPERMIT_AGENT_ROLE;

grant select on log_CTPERMIT_AGENT_ROLE to coldfusion_user;

CREATE OR REPLACE TRIGGER TR_log_CTPERMIT_AGENT_ROLE AFTER INSERT or update or delete ON CTPERMIT_AGENT_ROLE
FOR EACH ROW
BEGIN
insert into log_CTPERMIT_AGENT_ROLE (
username,
when,
n_DESCRIPTION,
n_PERMIT_AGENT_ROLE,
o_DESCRIPTION,
o_PERMIT_AGENT_ROLE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.PERMIT_AGENT_ROLE,
:OLD.DESCRIPTION,
:OLD.PERMIT_AGENT_ROLE
);
END;
/ 



insert into ctpermit_type (permit_type,description) values ('collect','Authorization to collect and possess specimens or their parts (e.g., blood, feather samples).');

insert into ctpermit_type (permit_type,description) values ('export','Authorization to export specimens or their parts from one country to another.');

update ctpermit_type set 
description='Authorization to import specimens or their parts from one country to another.'
where
permit_type='import';

update ctpermit_type set 
description='Authorization to conduct research within a permitted jurisdiction. Usually also requires additional permits (e.g., collect, export). Examples: U.S. Forest Service research permit; Memorandum of Understanding; Convenio.'
where
permit_type='research';			

insert into ctpermit_type (permit_type,description) values ('salvage','Authorization to pick up and possess dead animals.');

insert into ctpermit_type (permit_type,description) values ('transfer','Authorization to transfer specimens from one institution to another within the same country. Example: USDA Transport Permit for restricted materials between US institutions; USFWS authorization to transfer confiscated materials.');
																							
insert into ctpermit_type (permit_type,description) values ('permit not required','Used for transactions under which a permit is explicitly not required. Clarify in permit_remarks.');

grant select on ctpermit_type to public;


create table permit_type (
	permit_type_id number not null,
	permit_id number not null,
	permit_type varchar2(255),
	permit_regulation varchar2(255)
);

create public synonym permit_type for permit_type;

grant all on permit_type to manage_transactions;


create sequence sq_permit_type_id;

create public synonym sq_permit_type_id for sq_permit_type_id;
GRANT SELECT ON sq_permit_type_id TO PUBLIC;

ALTER TABLE permit_type add CONSTRAINT pk_permit_type PRIMARY KEY (permit_type_id);

CREATE OR REPLACE TRIGGER permit_type_trg before insert  ON permit_type  
    for each row 
    begin     
	    if :NEW.permit_type_id is null then                                                                                      
	    	select sq_permit_type_id.nextval into :new.permit_type_id from dual;
	    end if;                       
    end;                                                                                            
/
sho err

ALTER TABLE permit_type ADD CONSTRAINT fk_permit_type_permit FOREIGN KEY (permit_id) REFERENCES permit (permit_id);

ALTER TABLE permit_type ADD CONSTRAINT fk_ct_permit_type FOREIGN KEY (permit_type) REFERENCES ctpermit_type (permit_type);

ALTER TABLE permit_type ADD CONSTRAINT fk_ctpermit_regulation FOREIGN KEY (permit_regulation) REFERENCES ctpermit_regulation (permit_regulation);






create table permit_agent (
	permit_agent_id number not null,
	permit_id number not null,
	agent_id number not null,
	agent_role varchar2(255) not null
);

create public synonym permit_agent for permit_agent;

grant all on permit_agent to manage_transactions;

create sequence sq_permit_agent_id;

create public synonym sq_permit_agent_id for sq_permit_agent_id;
GRANT SELECT ON sq_permit_agent_id TO PUBLIC;

ALTER TABLE permit_agent add CONSTRAINT pk_permit_agent PRIMARY KEY (permit_agent_id);


CREATE OR REPLACE TRIGGER permit_agent_trg before insert  ON permit_agent  
    for each row 
    begin     
	    if :NEW.permit_agent_id is null then                                                                                      
	    	select sq_permit_agent_id.nextval into :new.permit_agent_id from dual;
	    end if;                       
    end;                                                                                            
/
sho err

ALTER TABLE permit_agent ADD CONSTRAINT fk_permit_agent_permit FOREIGN KEY (permit_id) REFERENCES permit (permit_id);
ALTER TABLE permit_agent ADD CONSTRAINT fk_permit_agent_agent FOREIGN KEY (agent_id) REFERENCES agent (agent_id);
ALTER TABLE permit_agent ADD CONSTRAINT fk_ctpermit_agent_role FOREIGN KEY (agent_role) REFERENCES ctpermit_agent_role (permit_agent_role);


-- data migration
-- waiting on feedback from https://github.com/ArctosDB/arctos/issues/1139#issuecomment-349457758 before completion, can do easy stuff now though



--pull CSV from https://docs.google.com/spreadsheets/d/1XnZ4Jt3SViLYkvDGSrF8A45I7mbMTEfLnBWKpuiBTuY/edit#gid=2122230195
-- upload
create table temp_permit_type_mign as select * from dlm.my_temp_cf;

-- test at test
delete from permit_type where permit_id in (select permit_id from temp_permit_type_mign);


insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'export',
		REGULATION
	from
		temp_permit_type_mign
	where
		PERMIT_TYPE_SHOULD_BE='collect + export'
);

insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'collect',
		REGULATION
	from
		temp_permit_type_mign
	where
		PERMIT_TYPE_SHOULD_BE='collect + export'
);

insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'import',
		REGULATION
	from
		temp_permit_type_mign
	where
		PERMIT_TYPE_SHOULD_BE='export + import'
);


insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'export',
		REGULATION
	from
		temp_permit_type_mign
	where
		PERMIT_TYPE_SHOULD_BE='export + import'
);


insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'import',
		REGULATION
	from
		temp_permit_type_mign
	where
		PERMIT_TYPE_SHOULD_BE='collect + export + import'
);


insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'export',
		REGULATION
	from
		temp_permit_type_mign
	where
		PERMIT_TYPE_SHOULD_BE='collect + export + import'
);

insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'collect',
		REGULATION
	from
		temp_permit_type_mign
	where
		PERMIT_TYPE_SHOULD_BE='collect + export + import'
);

insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'research',
		REGULATION
	from
		temp_permit_type_mign
	where
		PERMIT_TYPE_SHOULD_BE='collect + research'
);

insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'collect',
		REGULATION
	from
		temp_permit_type_mign
	where
		PERMIT_TYPE_SHOULD_BE='collect + research'
);


insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'transfer',
		REGULATION
	from
		temp_permit_type_mign
	where
		PERMIT_TYPE_SHOULD_BE='transfer'
);

insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'collect',
		REGULATION
	from
		temp_permit_type_mign
	where
		PERMIT_TYPE_SHOULD_BE='collect'
);


insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'export',
		REGULATION
	from
		temp_permit_type_mign
	where
		PERMIT_TYPE_SHOULD_BE='export'
);

insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'import',
		REGULATION
	from
		temp_permit_type_mign
	where
		PERMIT_TYPE_SHOULD_BE='import'
);










insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'transfer',
		NULL
	from
		permit
	where
		permit_type='transport' and
		permit_id not in (select permit_id from temp_permit_type_mign)
);


insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'transfer',
		NULL
	from
		permit
	where
		permit_type='take/possess, transport' and
		permit_id not in (select permit_id from temp_permit_type_mign)
);


insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'collect',
		NULL
	from
		permit
	where
		permit_type='take/possess, transport' and
		permit_id not in (select permit_id from temp_permit_type_mign)
);


insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'collect',
		NULL
	from
		permit
	where
		permit_type='take/possess, research' and
		permit_id not in (select permit_id from temp_permit_type_mign)
);


insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'research',
		NULL
	from
		permit
	where
		permit_type='take/possess, research' and
		permit_id not in (select permit_id from temp_permit_type_mign)
);




insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'research',
		NULL
	from
		permit
	where
		permit_type='research' and
		permit_id not in (select permit_id from temp_permit_type_mign)
);



insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'import',
		NULL
	from
		permit
	where
		permit_type='import' and
		permit_id not in (select permit_id from temp_permit_type_mign)
);


insert into permit_type (
	permit_type_id,
	permit_id,
	permit_type,
	permit_regulation
) (
	select
		sq_permit_type_id.nextval,
		permit_id,
		'collect',
		NULL
	from
		permit
	where
		permit_type='take/possess' and
		permit_id not in (select permit_id from temp_permit_type_mign)
);



---- agents


insert into permit_agent (
	permit_agent_id,
	permit_id,
	agent_id,
	agent_role
) (
	select
		sq_permit_agent_id.nextval,
		permit_id,
		ISSUED_BY_AGENT_ID,
		'issued by'
	from
		permit
	where
		ISSUED_BY_AGENT_ID is not null
);


insert into permit_agent (
	permit_agent_id,
	permit_id,
	agent_id,
	agent_role
) (
	select
		sq_permit_agent_id.nextval,
		permit_id,
		ISSUED_TO_AGENT_ID,
		'issued to'
	from
		permit
	where
		ISSUED_TO_AGENT_ID is not null
);

insert into permit_agent (
	permit_agent_id,
	permit_id,
	agent_id,
	agent_role
) (
	select
		sq_permit_agent_id.nextval,
		permit_id,
		CONTACT_AGENT_ID,
		'contact'
	from
		permit
	where
		CONTACT_AGENT_ID is not null
);



-- make SQL easier

CREATE OR REPLACE FUNCTION getPermitAgents (pid in number, prole in varchar2)
return varchar2
as
	rstr varchar2(4000);
	s varchar2(20);
begin
	for r in (select getPreferredAgentName(permit_agent.agent_id) name from permit_agent where permit_id=pid and agent_role=prole) loop
		rstr:=rstr || s || r.name;
		s:='; ';
	end loop;
	return rstr;
  end;
/
show err

create public synonym getPermitAgents for getPermitAgents;
grant execute on getPermitAgents to public; 


CREATE OR REPLACE FUNCTION getPermitTypeReg (pid in number)
return varchar2
as
	rstr varchar2(4000);
	s varchar2(20);
begin
	for r in (select permit_type, permit_regulation from permit_type where permit_id=pid) loop
		rstr:=rstr || s || r.permit_type || ' - ' || r.permit_regulation;
		s:='; ';
	end loop;
	return rstr;
  end;
/
show err

create public synonym getPermitTypeReg for getPermitTypeReg;
grant execute on getPermitTypeReg to public; 

-- type only, for GGBN
CREATE OR REPLACE FUNCTION getPermitType (pid in number)
return varchar2
as
	rstr varchar2(4000);
	s varchar2(20);
begin
	for r in (select permit_type from permit_type where permit_id=pid) loop
		rstr:=rstr || s || r.permit_type ;
		s:='; ';
	end loop;
	return rstr;
  end;
/
show err

create or replace public synonym getPermitType for getPermitType;
grant execute on getPermitType to public; 


select getPermitType(collection_object_id) from flat where guid='MVZ:Bird:182074';




-- require number
update permit set permit_num='not assigned' where permit_num is null;

alter table permit modify permit_num not null;

-- deal with renewals
 alter table permit modify permit_remarks varchar2(4000);
 
 
 
begin
	for r in (select * from permit where RENEWED_DATE is not null) loop
		dbms_output.put_line(r.permit_id);
		insert into permit (
			PERMIT_ID,
			ISSUED_DATE,
			EXP_DATE,
			PERMIT_NUM,
			PERMIT_REMARKS
		) values (
			sq_permit_id.nextval,
			r.RENEWED_DATE,
			r.EXP_DATE,
			r.PERMIT_NUM,
			'Renewal of <a href="/Permit.cfm?Action=editPermit&permit_id=' || r.permit_id || '">' || r.permit_id || '</a>, original exp_date=' || r.EXP_DATE || ', original renewed_date=' || r.renewed_date || '. ' || r.PERMIT_REMARKS
		);
		
		
		for a in (select * from permit_agent where permit_id=r.permit_id) loop
			insert into permit_agent (
				permit_id,
				agent_id,
				agent_role
			) values (
				sq_permit_id.currval,
				a.agent_id,
				a.agent_role
			);
		end loop;
		for t in (select * from permit_type where permit_id=r.permit_id) loop
			insert into permit_type (
				permit_id,
				permit_type,
				permit_regulation
			) values (
				sq_permit_id.currval,
				t.permit_type,
				t.permit_regulation
			);
		end loop;		
	end loop;
end;
/






 
 
-- delete later

alter table permit modify ISSUED_BY_AGENT_ID null;
alter table permit modify ISSUED_TO_AGENT_ID null;
alter table permit modify PERMIT_TYPE null;

select count(*) from permit;
select count(*) from permit_20171211;

alter table permit drop column ISSUED_BY_AGENT_ID;
alter table permit drop column ISSUED_TO_AGENT_ID;
alter table permit drop column RENEWED_DATE;
alter table permit drop column CONTACT_AGENT_ID;
alter table permit drop column PERMIT_TYPE;


select permit_type from ctpermit_type where permit_type not in (select permit_type from permit_type);

delete from ctpermit_type where permit_type='transport';
delete from ctpermit_type where permit_type='take/possess, transport';
delete from ctpermit_type where permit_type='take/possess';
delete from ctpermit_type where permit_type='transfer of property';
delete from ctpermit_type where permit_type='other';
delete from ctpermit_type where permit_type='take/possess, research';
delete from ctpermit_type where permit_type='xxxx';


select permit_type from permit_20171211 where permit_id not in (select permit_id from permit_type );


select permit_type, permit_id from permit_20171211 where permit_id not in (select permit_id from permit_type );

-- add a remark for permits with no type
begin
	for r in (select  permit_type, permit_id from permit_20171211 where permit_id not in (select permit_id from permit_type )) loop
	
	update permit set permit_remarks='original permit type=other; ' || permit_remarks where permit_id=r.permit_id;
end loop;
end;
/





