
--------------- https://github.com/ArctosDB/arctos/issues/2267 ---------------------------------------
-- code table needs logging
-- everything needs translated to PG

drop table taxon_concept;
create or replace sequence sq_taxon_concept_id;
create public synonym sq_taxon_concept_id for sq_taxon_concept_id;
grant select on sq_taxon_concept_id to public;

create table taxon_concept (
	taxon_concept_id number  not null,
	taxon_name_id number not null,
	publication_id number not null
);

create or replace public synonym taxon_concept for taxon_concept;
grant all on taxon_concept to manage_taxonomy;
grant select on taxon_concept to public;


alter table taxon_concept add constraint pktaxon_concept primary key (taxon_concept_id);
ALTER TABLE taxon_concept ADD CONSTRAINT fk_concept_name  FOREIGN KEY (taxon_name_id)  REFERENCES taxon_name(taxon_name_id);
ALTER TABLE taxon_concept ADD CONSTRAINT fk_concept_pub  FOREIGN KEY (publication_id)  REFERENCES publication(publication_id);

drop table taxon_concept_rel;
create sequence sq_taxon_concept_rel_id;
create public synonym sq_taxon_concept_rel_id for sq_taxon_concept_rel_id;
grant select on sq_taxon_concept_rel_id to public;


create table taxon_concept_rel (
	taxon_concept_rel_id number not null,
	from_taxon_concept_id number not null,
	to_taxon_concept_id number not null,
	relationship varchar2(255)  not null,
	according_to_publication_id number  not null
);

create table cttaxon_concept_relationship (
	relationship varchar2(30) not null,
	description varchar2(4000) not null
);

create or replace public synonym cttaxon_concept_relationship for cttaxon_concept_relationship;
grant all on cttaxon_concept_relationship to manage_codetables;
grant select on cttaxon_concept_relationship to public;

alter table cttaxon_concept_relationship add constraint pkcttaxon_concept_relationship primary key (relationship);



create or replace public synonym taxon_concept_rel for taxon_concept_rel;
grant all on taxon_concept_rel to manage_taxonomy;

alter table taxon_concept_rel add constraint pktaxon_concept_rel primary key (taxon_concept_rel_id);
ALTER TABLE taxon_concept_rel ADD CONSTRAINT fk_tcrel_ftc  FOREIGN KEY (from_taxon_concept_id)  REFERENCES taxon_concept(taxon_concept_id);
ALTER TABLE taxon_concept_rel ADD CONSTRAINT fk_tcrel_ttc  FOREIGN KEY (to_taxon_concept_id)  REFERENCES taxon_concept(taxon_concept_id);
ALTER TABLE taxon_concept_rel ADD CONSTRAINT fk_tcrel_pub  FOREIGN KEY (according_to_publication_id)  REFERENCES publication(publication_id);
ALTER TABLE taxon_concept_rel ADD CONSTRAINT fk_tcrel_relshp  FOREIGN KEY (relationship)  REFERENCES cttaxon_concept_relationship(relationship);


delete from taxon_concept_rel;
delete from cttaxon_concept_relationship;
insert into cttaxon_concept_relationship (relationship,description) values ('test','test');
      

relationship
intersects
intersects
intersects
intersects
intersects
intersects
includes
is disjunct with
includes
includes
includes
includes
is included in
is disjunct with
includes
intersects
intersects
intersects
intersects
includes
includes
includes
includes
overlaps with
is same as
is same as
is same as
is same as
intersects
intersects


insert into taxon_concept (
	taxon_concept_id,
	taxon_name_id,
	publication_id 
) values (
	sq_taxon_concept_id.nextval,
	59888,
	1000138
);


-- this is hard to display and will be confusing, so...

alter table taxon_concept add concept_label varchar2(255);

update taxon_concept set concept_label='<i>Claytonia scammaniana</i> Hulten <i>sensu</i> Hulton 1942';
alter table taxon_concept modify concept_label not null;


http://arctos.database.museum/editTaxonomy.cfm?action=editnoclass&taxon_name_id=
http://arctos.database.museum/publication/1000138









--------------------- PG


drop table taxon_concept;
create  sequence sq_taxon_concept_id;
GRANT USAGE, SELECT ON SEQUENCE sq_taxon_concept_id TO public;

create table taxon_concept (
	taxon_concept_id bigint  not null,
	taxon_name_id bigint not null,
	publication_id bigint not null
);

grant all on taxon_concept to manage_taxonomy;
grant select on taxon_concept to public;


alter table taxon_concept add constraint pktaxon_concept primary key (taxon_concept_id);
ALTER TABLE taxon_concept ADD CONSTRAINT fk_concept_name  FOREIGN KEY (taxon_name_id)  REFERENCES taxon_name(taxon_name_id);
ALTER TABLE taxon_concept ADD CONSTRAINT fk_concept_pub  FOREIGN KEY (publication_id)  REFERENCES publication(publication_id);

drop table taxon_concept_rel;
create sequence sq_taxon_concept_rel_id;
GRANT USAGE, SELECT ON SEQUENCE sq_taxon_concept_rel_id TO public;

create table taxon_concept_rel (
	taxon_concept_rel_id bigint not null,
	from_taxon_concept_id bigint not null,
	to_taxon_concept_id bigint not null,
	relationship varchar(255)  not null,
	according_to_publication_id bigint  not null
);

create table cttaxon_concept_relationship (
	relationship varchar(30) not null,
	description varchar(4000) not null
);

grant all on cttaxon_concept_relationship to manage_codetables;
grant select on cttaxon_concept_relationship to public;

alter table cttaxon_concept_relationship add constraint pkcttaxon_concept_relationship primary key (relationship);



grant all on taxon_concept_rel to manage_taxonomy;

alter table taxon_concept_rel add constraint pktaxon_concept_rel primary key (taxon_concept_rel_id);
ALTER TABLE taxon_concept_rel ADD CONSTRAINT fk_tcrel_ftc  FOREIGN KEY (from_taxon_concept_id)  REFERENCES taxon_concept(taxon_concept_id);
ALTER TABLE taxon_concept_rel ADD CONSTRAINT fk_tcrel_ttc  FOREIGN KEY (to_taxon_concept_id)  REFERENCES taxon_concept(taxon_concept_id);
ALTER TABLE taxon_concept_rel ADD CONSTRAINT fk_tcrel_pub  FOREIGN KEY (according_to_publication_id)  REFERENCES publication(publication_id);
ALTER TABLE taxon_concept_rel ADD CONSTRAINT fk_tcrel_relshp  FOREIGN KEY (relationship)  REFERENCES cttaxon_concept_relationship(relationship);


-- this is hard to display and will be confusing, so...

alter table taxon_concept add concept_label varchar(255);

update taxon_concept set concept_label='<i>Claytonia scammaniana</i> Hulten <i>sensu</i> Hulton 1942';
alter table taxon_concept alter concept_label not null;


http://arctos.database.museum/editTaxonomy.cfm?action=editnoclass&taxon_name_id=
http://arctos.database.museum/publication/1000138