--from https://github.com/ArctosDB/arctos/issues/983

insert into  CTTAXONOMY_SOURCE (SOURCE,DESCRIPTION) values ('Arctos Relationships','Place to store relationship data in classifications. This resource exists as a search aid. It is not an authoritative source of taxonomy relationships; [hemi]homonyms will create false assertions, for example.');

-- ignore that in triggers
create or replace trigger trg_taxon_term_cts....

-- seed with existing data
-- temp for performance
UAM@ARCTOSTE> desc taxon_relations
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 TAXON_NAME_ID							   NOT NULL NUMBER(10)
 RELATED_TAXON_NAME_ID						   NOT NULL NUMBER(10)
 TAXON_RELATIONSHIP						   NOT NULL VARCHAR2(50)
 RELATION_AUTHORITY							    VARCHAR2(255)
 TAXON_RELATIONS_ID						   NOT NULL NUMBER

