-- add a remark so I can explain why there are three congos
alter table geog_auth_rec add geog_remark varchar2(4000);

-- and a new table so I can follow wiki, do something useful, use accents/strange characters, etc., all at the same time


create table geog_search_term (
	geog_search_term_id number not null,
	geog_auth_rec_id number not null,
	search_term varchar2(4000) not null
);

create sequence sq_geog_search_term_id;

CREATE PUBLIC SYNONYM sq_geog_search_term_id FOR sq_geog_search_term_id;
GRANT SELECT ON sq_geog_search_term_id TO PUBLIC;


alter table geog_search_term add constraint PK_geog_search_term PRIMARY KEY (geog_search_term_id) using index TABLESPACE UAM_IDX_1;

ALTER TABLE geog_search_term add CONSTRAINT fk_geog FOREIGN KEY (geog_auth_rec_id) REFERENCES geog_auth_rec(geog_auth_rec_id);   


CREATE OR REPLACE TRIGGER tr_geog_search_term_id before insert ON geog_search_term for each row
   begin    
       IF :new.geog_search_term_id IS NULL THEN
           select sq_geog_search_term_id.nextval into :new.geog_search_term_id from dual;
       END IF;
   end;                                                                                           
/
sho err

CREATE PUBLIC SYNONYM geog_search_term FOR geog_search_term;

grant select on geog_search_term to public;
grant all on geog_search_term to manage_geography;

create unique index iu_geog_srchterm on geog_search_term(geog_auth_rec_id,search_term) tablespace uam_idx_1;

create index ix_u_geog_srchterm on geog_search_term(upper(search_term)) tablespace uam_idx_1;