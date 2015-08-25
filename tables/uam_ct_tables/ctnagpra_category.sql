

drop table ctnagpra_category;

create table ctnagpra_category as select lower(NAGPRA_category) NAGPRA_category,'EH' collection_cde, documentation DESCRIPTION from dlm.my_temp_cf ;

alter table ctnagpra_category modify collection_cde varchar2(10) not null;
alter table ctnagpra_category modify DESCRIPTION varchar2(4000);
alter table ctnagpra_category modify NAGPRA_CATEGORY varchar2(60) not null;

insert into ctnagpra_category (NAGPRA_category,collection_cde,DESCRIPTION) (select lower(NAGPRA_category),'Arc',documentation from dlm.my_temp_cf);

create public synonym ctnagpra_category for ctnagpra_category;

grant select on ctnagpra_category to public;

grant all on ctnagpra_category to manage_codetables;

create unique index ix_u_ctnagrpa_category on ctnagpra_category (NAGPRA_category,collection_cde) tablespace uam_idx_1;

create table log_ctnagpra_category ( 
	username varchar2(60),	
	when date default sysdate,
	n_NAGPRA_CATEGORY varchar2(60),
	n_collection_cde varchar2(10),
	n_DESCRIPTION varchar2(4000),
	o_NAGPRA_CATEGORY varchar2(60),
	o_collection_cde varchar2(10),
	o_DESCRIPTION varchar2(4000)
);


create or replace public synonym log_ctnagpra_category for log_ctnagpra_category;


grant select on log_ctnagpra_category to coldfusion_user;


CREATE OR REPLACE TRIGGER TR_log_nagpra_category 
	AFTER INSERT or update or delete ON ctnagpra_category
	FOR EACH ROW 
BEGIN 
	insert into log_ctnagpra_category ( 
		username, 
		when,
		n_NAGPRA_CATEGORY,
		n_collection_cde,
		n_DESCRIPTION,
		o_NAGPRA_CATEGORY,
		o_collection_cde,
		o_DESCRIPTION
	) values (
		SYS_CONTEXT('USERENV','SESSION_USER'),
		sysdate,
		:NEW.NAGPRA_CATEGORY,
		:NEW.collection_cde,
		:NEW.DESCRIPTION,
		:OLD.NAGPRA_CATEGORY,
		:OLD.collection_cde,
		:OLD.DESCRIPTION
	);
END;
/
	

insert into CTATTRIBUTE_TYPE (ATTRIBUTE_TYPE,COLLECTION_CDE,DESCRIPTION) values ('NAGPRA category','EH','see http://www.nps.gov/nagpra/MANDATES/INDEX.HTM and http://www.nps.gov/nagpra/TRAINING/GLOSSARY.HTM');
insert into CTATTRIBUTE_TYPE (ATTRIBUTE_TYPE,COLLECTION_CDE,DESCRIPTION) values ('NAGPRA category','Arc','see http://www.nps.gov/nagpra/MANDATES/INDEX.HTM and http://www.nps.gov/nagpra/TRAINING/GLOSSARY.HTM');

insert into CTATTRIBUTE_CODE_TABLES (ATTRIBUTE_TYPE,VALUE_CODE_TABLE) values ('NAGPRA category',upper('ctnagpra_category'));
