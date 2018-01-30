
create table ctexamined_for_parasite (
	examined_for_parasite varchar2(60) not null,
	description varchar2(4000) not null
);


create public synonym ctexamined_for_parasite for ctexamined_for_parasite;

grant all on ctexamined_for_parasite to manage_codetables;

grant select on ctexamined_for_parasite to public;

																							
drop table log_ctexamined_for_parasite;

create table log_ctexamined_for_parasite (
username varchar2(60),
when date default sysdate,
n_DESCRIPTION VARCHAR2(4000),
n_examined_for_parasite VARCHAR2(255),
o_DESCRIPTION VARCHAR2(4000),
o_examined_for_parasite VARCHAR2(255)
);


create or replace public synonym log_ctexamined_for_parasite for log_ctexamined_for_parasite;

grant select on log_ctexamined_for_parasite to coldfusion_user;


CREATE OR REPLACE TRIGGER TR_log_ctexamined_for_parasite AFTER INSERT or update or delete ON ctexamined_for_parasite
FOR EACH ROW
BEGIN
insert into log_ctexamined_for_parasite (
username,
when,
n_DESCRIPTION,
n_examined_for_parasite,
o_DESCRIPTION,
o_examined_for_parasite
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.examined_for_parasite,
:OLD.DESCRIPTION,
:OLD.examined_for_parasite
);
END;
/ 



insert into ctexamined_for_parasite (examined_for_parasite,description) values ('endoparasites','endos');
insert into ctexamined_for_parasite (examined_for_parasite,description) values ('ectoparasites','ectos');
insert into ctexamined_for_parasite (examined_for_parasite,description) values ('no','not examined');
insert into ctexamined_for_parasite (examined_for_parasite,description) values ('yes','low data');


insert into CTATTRIBUTE_TYPE (attribute_type,collection_cde,description) values ('parasites detected','Bird','this needs defined');
insert into CTATTRIBUTE_TYPE (attribute_type,collection_cde,description) values ('parasites detected','Mamm','this needs defined');
insert into CTATTRIBUTE_TYPE (attribute_type,collection_cde,description) values ('parasites detected','Host','this needs defined');
insert into CTATTRIBUTE_TYPE (attribute_type,collection_cde,description) values ('parasites detected','Herp','this needs defined');


delete from CTATTRIBUTE_TYPE where attribute_type='parasites detected';
delete from ctATTRIBUTE_CODE_TABLES where attribute_type='parasites detected';


insert into  ctATTRIBUTE_CODE_TABLES (ATTRIBUTE_TYPE,VALUE_CODE_TABLE) values ('parasites detected','CTEXAMINED_FOR_PARASITE');


update ctATTRIBUTE_CODE_TABLES set VALUE_CODE_TABLE='CTEXAMINED_FOR_PARASITE' WHERE ATTRIBUTE_TYPE='examined for parasites';

insert into CTATTRIBUTE_TYPE (attribute_type,collection_cde,description) values ('examined for parasites','Herp','this needs defined');

insert into CTATTRIBUTE_TYPE (attribute_type,collection_cde,description) values ('examined for parasites','Bird','this needs defined');
insert into CTATTRIBUTE_TYPE (attribute_type,collection_cde,description) values ('parasites detected','Bird','this needs defined');


-- MIGRATION

select distinct ATTRIBUTE_VALUE from attributes where ATTRIBUTE_TYPE='ectoparasite examination';

delete from attributes where ATTRIBUTE_TYPE='examined for parasites' and ATTRIBUTE_VALUE='ectoparasites';

insert into attributes (
	ATTRIBUTE_ID,
	COLLECTION_OBJECT_ID,
	DETERMINED_BY_AGENT_ID,
	ATTRIBUTE_TYPE,
	ATTRIBUTE_VALUE,
	ATTRIBUTE_REMARK,
	DETERMINATION_METHOD,
	DETERMINED_DATE
) (
	select
		sq_ATTRIBUTE_ID.nextval,
		COLLECTION_OBJECT_ID,
		DETERMINED_BY_AGENT_ID,
		'examined for parasites',
		'ectoparasites',
		'inserted from ectoparasite examination=yes; ' || ATTRIBUTE_REMARK,
		DETERMINATION_METHOD,
		DETERMINED_DATE
	from
		attributes
	where
		ATTRIBUTE_TYPE='ectoparasite examination' and
		ATTRIBUTE_VALUE='yes'
);


insert into attributes (
	ATTRIBUTE_ID,
	COLLECTION_OBJECT_ID,
	DETERMINED_BY_AGENT_ID,
	ATTRIBUTE_TYPE,
	ATTRIBUTE_VALUE,
	ATTRIBUTE_REMARK,
	DETERMINATION_METHOD,
	DETERMINED_DATE
) (
	select
		sq_ATTRIBUTE_ID.nextval,
		COLLECTION_OBJECT_ID,
		DETERMINED_BY_AGENT_ID,
		'examined for parasites',
		'no',
		'inserted from ectoparasite examination=no; ' || ATTRIBUTE_REMARK,
		DETERMINATION_METHOD,
		DETERMINED_DATE
	from
		attributes
	where
		ATTRIBUTE_TYPE='ectoparasite examination' and
		ATTRIBUTE_VALUE='no'
);



insert into attributes (
	ATTRIBUTE_ID,
	COLLECTION_OBJECT_ID,
	DETERMINED_BY_AGENT_ID,
	ATTRIBUTE_TYPE,
	ATTRIBUTE_VALUE,
	ATTRIBUTE_REMARK,
	DETERMINATION_METHOD,
	DETERMINED_DATE
) (
	select
		sq_ATTRIBUTE_ID.nextval,
		COLLECTION_OBJECT_ID,
		DETERMINED_BY_AGENT_ID,
		'parasites detected',
		'no',
		'inserted from ectoparasites detected=no; ' || ATTRIBUTE_REMARK,
		DETERMINATION_METHOD,
		DETERMINED_DATE
	from
		attributes
	where
		ATTRIBUTE_TYPE='ectoparasites detected' and
		ATTRIBUTE_VALUE='no'
);



insert into attributes (
	ATTRIBUTE_ID,
	COLLECTION_OBJECT_ID,
	DETERMINED_BY_AGENT_ID,
	ATTRIBUTE_TYPE,
	ATTRIBUTE_VALUE,
	ATTRIBUTE_REMARK,
	DETERMINATION_METHOD,
	DETERMINED_DATE
) (
	select
		sq_ATTRIBUTE_ID.nextval,
		COLLECTION_OBJECT_ID,
		DETERMINED_BY_AGENT_ID,
		'parasites detected',
		'ectoparasites',
		'inserted from ectoparasites detected=yes; ' || ATTRIBUTE_REMARK,
		DETERMINATION_METHOD,
		DETERMINED_DATE
	from
		attributes
	where
		ATTRIBUTE_TYPE='ectoparasites detected' and
		ATTRIBUTE_VALUE='yes'
);

  
insert into attributes (
	ATTRIBUTE_ID,
	COLLECTION_OBJECT_ID,
	DETERMINED_BY_AGENT_ID,
	ATTRIBUTE_TYPE,
	ATTRIBUTE_VALUE,
	ATTRIBUTE_REMARK,
	DETERMINATION_METHOD,
	DETERMINED_DATE
) (
	select
		sq_ATTRIBUTE_ID.nextval,
		COLLECTION_OBJECT_ID,
		DETERMINED_BY_AGENT_ID,
		'parasites detected',
		'endoparasites',
		'inserted from endoparasites detected=yes; ' || ATTRIBUTE_REMARK,
		DETERMINATION_METHOD,
		DETERMINED_DATE
	from
		attributes
	where
		ATTRIBUTE_TYPE='endoparasites detected' and
		ATTRIBUTE_VALUE='yes'
);




insert into attributes (
	ATTRIBUTE_ID,
	COLLECTION_OBJECT_ID,
	DETERMINED_BY_AGENT_ID,
	ATTRIBUTE_TYPE,
	ATTRIBUTE_VALUE,
	ATTRIBUTE_REMARK,
	DETERMINATION_METHOD,
	DETERMINED_DATE
) (
	select
		sq_ATTRIBUTE_ID.nextval,
		COLLECTION_OBJECT_ID,
		DETERMINED_BY_AGENT_ID,
		'parasites detected',
		'no',
		'inserted from endoparasites detected=no; ' || ATTRIBUTE_REMARK,
		DETERMINATION_METHOD,
		DETERMINED_DATE
	from
		attributes
	where
		ATTRIBUTE_TYPE='endoparasites detected' and
		ATTRIBUTE_VALUE='no'
);


insert into attributes (
	ATTRIBUTE_ID,
	COLLECTION_OBJECT_ID,
	DETERMINED_BY_AGENT_ID,
	ATTRIBUTE_TYPE,
	ATTRIBUTE_VALUE,
	ATTRIBUTE_REMARK,
	DETERMINATION_METHOD,
	DETERMINED_DATE
) (
	select
		sq_ATTRIBUTE_ID.nextval,
		COLLECTION_OBJECT_ID,
		DETERMINED_BY_AGENT_ID,
		'examined for parasites',
		'no',
		'inserted from endoparasite examination=no; ' || ATTRIBUTE_REMARK,
		DETERMINATION_METHOD,
		DETERMINED_DATE
	from
		attributes
	where
		ATTRIBUTE_TYPE='endoparasite examination' and
		ATTRIBUTE_VALUE='no'
);

insert into attributes (
	ATTRIBUTE_ID,
	COLLECTION_OBJECT_ID,
	DETERMINED_BY_AGENT_ID,
	ATTRIBUTE_TYPE,
	ATTRIBUTE_VALUE,
	ATTRIBUTE_REMARK,
	DETERMINATION_METHOD,
	DETERMINED_DATE
) (
	select
		sq_ATTRIBUTE_ID.nextval,
		COLLECTION_OBJECT_ID,
		DETERMINED_BY_AGENT_ID,
		'examined for parasites',
		'endoparasites',
		'inserted from endoparasite examination=yes; ' || ATTRIBUTE_REMARK,
		DETERMINATION_METHOD,
		DETERMINED_DATE
	from
		attributes
	where
		ATTRIBUTE_TYPE='endoparasite examination' and
		ATTRIBUTE_VALUE='yes'
);
















insert into attributes (
	ATTRIBUTE_ID,
	COLLECTION_OBJECT_ID,
	DETERMINED_BY_AGENT_ID,
	ATTRIBUTE_TYPE,
	ATTRIBUTE_VALUE,
	ATTRIBUTE_REMARK,
	DETERMINATION_METHOD,
	DETERMINED_DATE
) (
	select
		sq_ATTRIBUTE_ID.nextval,
		COLLECTION_OBJECT_ID,
		DETERMINED_BY_AGENT_ID,
		'examined for parasites',
		'yes',
		'inserted from examined for parasites=yes; ' || ATTRIBUTE_REMARK,
		DETERMINATION_METHOD,
		DETERMINED_DATE
	from
		attributes
	where
		ATTRIBUTE_TYPE='examined for parasites' and
		ATTRIBUTE_VALUE='yes'
);




insert into attributes (
	ATTRIBUTE_ID,
	COLLECTION_OBJECT_ID,
	DETERMINED_BY_AGENT_ID,
	ATTRIBUTE_TYPE,
	ATTRIBUTE_VALUE,
	ATTRIBUTE_REMARK,
	DETERMINATION_METHOD,
	DETERMINED_DATE
) (
	select
		sq_ATTRIBUTE_ID.nextval,
		COLLECTION_OBJECT_ID,
		DETERMINED_BY_AGENT_ID,
		'examined for parasites',
		'no',
		'inserted from examined for parasites=no; ' || ATTRIBUTE_REMARK,
		DETERMINATION_METHOD,
		DETERMINED_DATE
	from
		attributes
	where
		ATTRIBUTE_TYPE='examined for parasites' and
		ATTRIBUTE_VALUE='no'
);


insert into attributes (
	ATTRIBUTE_ID,
	COLLECTION_OBJECT_ID,
	DETERMINED_BY_AGENT_ID,
	ATTRIBUTE_TYPE,
	ATTRIBUTE_VALUE,
	ATTRIBUTE_REMARK,
	DETERMINATION_METHOD,
	DETERMINED_DATE
) (
	select
		sq_ATTRIBUTE_ID.nextval,
		COLLECTION_OBJECT_ID,
		DETERMINED_BY_AGENT_ID,
		'parasites detected',
		'no',
		'inserted from parasites found=no; ' || ATTRIBUTE_REMARK,
		DETERMINATION_METHOD,
		DETERMINED_DATE
	from
		attributes
	where
		ATTRIBUTE_TYPE='parasites found' and
		ATTRIBUTE_VALUE='no'
);


insert into attributes (
	ATTRIBUTE_ID,
	COLLECTION_OBJECT_ID,
	DETERMINED_BY_AGENT_ID,
	ATTRIBUTE_TYPE,
	ATTRIBUTE_VALUE,
	ATTRIBUTE_REMARK,
	DETERMINATION_METHOD,
	DETERMINED_DATE
) (
	select
		sq_ATTRIBUTE_ID.nextval,
		COLLECTION_OBJECT_ID,
		DETERMINED_BY_AGENT_ID,
		'parasites detected',
		'yes',
		'inserted from parasites found=yes; ' || ATTRIBUTE_REMARK,
		DETERMINATION_METHOD,
		DETERMINED_DATE
	from
		attributes
	where
		ATTRIBUTE_TYPE='parasites found' and
		ATTRIBUTE_VALUE='yes'
);



    
    
    

eal Application Testing options

UAM@ARCTOSTE> desc ctATTRIBUTE_CODE_TABLES
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 ATTRIBUTE_TYPE 						   NOT NULL VARCHAR2(60)
 VALUE_CODE_TABLE							    VARCHAR2(60)
 UNITS_CODE_TABLE							    VARCHAR2(60)


 
 