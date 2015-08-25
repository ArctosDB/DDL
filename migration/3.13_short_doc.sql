create sequence sq_short_doc_id;

CREATE PUBLIC SYNONYM sq_short_doc_id FOR sq_short_doc_id;
GRANT SELECT ON sq_short_doc_id TO PUBLIC;

CREATE OR REPLACE TRIGGER tr_short_doc_id before insert ON short_doc for each row
   begin    
       IF :new.short_doc_id IS NULL THEN
           select sq_short_doc_id.nextval into :new.short_doc_id from dual;
       END IF;
   end;                                                                                           
/
sho err

alter table short_doc add constraint PK_short_doc PRIMARY KEY (short_doc_id) using index TABLESPACE UAM_IDX_1;

create table short_doc (
    short_doc_id number not null,
    colname varchar2(76) not null,
    display_name varchar2(60),
    definition varchar2(4000) not null,
    search_hint varchar2(255),
    more_info varchar2(255)
);

CREATE PUBLIC SYNONYM short_doc FOR short_doc;

grant select on short_doc to public;

create role manage_documentation;

test-uam> insert into cf_ctuser_roles (role_name,description) values ('manage_documentation','manage popup documentation');

grant all on short_doc to manage_documentation;

grant manage_documentation to dlm;
grant manage_documentation to lam;
grant manage_documentation to gordon;
grant manage_documentation to ccicero;


create unique index iu_shortdoc_colname on short_doc(colname) tablespace uam_idx_1;