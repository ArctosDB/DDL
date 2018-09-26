alter table project_agent add award_number varchar2(255);

CREATE OR REPLACE TRIGGER trg_project_agent_biu  ...

drop table cache_publication_sdata;

create table cache_publication_sdata (
	doi varchar2(255) not null,
	json_data clob not null,
	jmamm_citation varchar2(4000),
	last_date date not null,
	source varchar2(255) not null
);
	

insert into cf_form_permissions (FORM_PATH,ROLE_NAME) values ('/info/publicationDetails.cfm','public');
