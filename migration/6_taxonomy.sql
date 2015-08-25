

------------------------------------ TO DO --------------------------------------
			
			

Rewrite documentation, especially specimensearch

			
redirects from old taxonomy search form

/TaxonomySearch.cfm-->/taxonomy.cfm

			
			
scheduled tasks to maintain data from globalnames




CF permissions:

/taxonomy.cfm - public
/editTaxonomy.cfm - admin


------------------------------------ END todo --------------------------------------
alter table cf_users add taxaPickPrefs varchar2(255);

-- people have expressed a need to set "collection preferred classifications" and download them with specimen data.
-- modify collection to allow setting preference













------------ done at prod ---------------------

create table taxon_name (
	taxon_name_id number not null primary key,
	scientific_name varchar2(255) not null
);


create unique index ix_taxon_name_sciname on taxon_name(scientific_name) tablespace uam_idx_1;

create or replace public synonym taxon_name for taxon_name;
grant select on taxon_name to public;
grant all on taxon_name to manage_taxonomy;

create table taxon_term (
	taxon_term_id number not null primary key,
	taxon_name_id number not null,
	classification_id varchar2(4000) null,
	term varchar2(255) not null,
	term_type varchar2(255),
	source varchar2(255) not null,
	gn_score number,
	position_in_classification number,
	lastdate date default (sysdate) not null,
	match_type varchar2(255),
	CONSTRAINT fk_tnid FOREIGN KEY (taxon_name_id) REFERENCES taxon_name (taxon_name_id)
  );


 
  
create or replace public synonym taxon_term for taxon_term;
grant select on taxon_term to public;
grant all on taxon_term to manage_taxonomy;

  drop sequence sq_taxon_term_id;

  
create sequence sq_taxon_term_id;


create or replace public synonym sq_taxon_term_id for sq_taxon_term_id;
grant select on sq_taxon_term_id to public;

CREATE OR REPLACE TRIGGER tr_taxon_term_id before insert ON taxon_term for each row
   begin    
       IF :new.taxon_term_id IS NULL THEN
           select sq_taxon_term_id.nextval into :new.taxon_term_id from dual;
       END IF;
   end;                                                                                           
/
sho err




-- super-wonky code table; this does NOT get a fkey and it does NOT get values from globalnames
-- it's JUST used to set what "local" classifications can be updated and edited

create table cttaxonomy_source (
	source varchar2(255) not null,
	description varchar2(4000) not null
);

		
create or replace public synonym cttaxonomy_source for cttaxonomy_source;
grant select on cttaxonomy_source to public;
grant all on cttaxonomy_source to manage_codetables;



create index ix_taxonterm_clasid on taxon_term (classification_id) tablespace uam_idx_1;
create index ix_upper_taxonterm on taxon_term(upper(term)) tablespace uam_idx_1;
create index ix_upper_taxonname on taxon_name(upper(scientific_name)) tablespace uam_idx_1;
create index ix_taxonterm_termtype on taxon_term (term_type) tablespace uam_idx_1;
create index ix_taxonterm_term on taxon_term (term) tablespace uam_idx_1;

create index ix_taxonterm_taxonnameid on taxon_term (taxon_name_id) tablespace uam_idx_1;

----- these already exist, just checking.....
create index ix_flat_u_sciname on flat (upper(scientific_name)) tablespace uam_idx_1;
create index ix_flat_colobjid on flat (collection_object_id) tablespace uam_idx_1;
create index ix_identification_colobjid on identification (collection_object_id) tablespace uam_idx_1;
create index ix_identification_identid on identification (identification_id) tablespace uam_idx_1;
create index ix_identtax_taxidd on identification_taxonomy (taxon_name_id) tablespace uam_idx_1;
create index ix_taxrel_taxidd on taxon_relations (taxon_name_id) tablespace uam_idx_1;
create index ix_taxrel_reltaxidd on taxon_relations (related_taxon_name_id) tablespace uam_idx_1;

-- randomness that make go fast now

create index ix_taxonterm_taxonnameid on taxon_term (taxon_name_id) tablespace uam_idx_1;



----end fasteruppered

create index ix_flat_u_porder on flat (upper(phylorder)) tablespace uam_idx_1;
create index ix_flat_u_Kingdom on flat (upper(Kingdom)) tablespace uam_idx_1;
create index ix_flat_u_Phylum on flat (upper(Phylum)) tablespace uam_idx_1;
create index ix_flat_u_Class on flat (upper(PhylClass)) tablespace uam_idx_1;
create index ix_flat_u_Family on flat (upper(Family)) tablespace uam_idx_1;
create index ix_flat_u_Genus on flat (upper(Genus)) tablespace uam_idx_1;
create index ix_flat_u_Species on flat (upper(Species)) tablespace uam_idx_1;
create index ix_flat_u_Subspecies on flat (upper(Subspecies)) tablespace uam_idx_1;



-------------END done at prod ---------------



------------- nope, maybe later.... -----------



create index ix_mv_sciname_term_u_tt on mv_sciname_term (upper(term)) tablespace uam_idx_1;
create index ix_mv_sciname_term_u_sname on mv_sciname_term (upper(SCIENTIFIC_NAME)) tablespace uam_idx_1;
create index ix_mv_sciname_term_cid on mv_sciname_term (classification_id) tablespace uam_idx_1;
create index ix_mv_sciname_term_u_ttype on mv_sciname_term (upper(term_type)) tablespace uam_idx_1;






drop index ix_taxonterm_clasid;
drop index ix_taxonterm_term;
drop index ix_taxonterm_termtype;
drop index ix_upper_taxonterm;
drop index ix_upper_taxonname;



create view v_mv_sciname_term
as select
  taxon_name.TAXON_NAME_ID,
  taxon_name.SCIENTIFIC_NAME,
  taxon_term.TAXON_TERM_ID,
  taxon_term.CLASSIFICATION_ID,
  taxon_term.TERM,
  taxon_term.TERM_TYPE,
  taxon_term.SOURCE,
  taxon_term.GN_SCORE,
  taxon_term.POSITION_IN_CLASSIFICATION,
  taxon_term.LASTDATE,
  taxon_term.MATCH_TYPE
from 
  taxon_name,
  taxon_term 
where 
  taxon_name.taxon_name_id=taxon_term.taxon_name_id (+)
;


create public synonym v_mv_sciname_term for v_mv_sciname_term;

grant select on v_mv_sciname_term to public;

drop index ix_taxonterm_clasid;
create index ix_taxonterm_clasid on taxon_term (classification_id) tablespace uam_idx_1;

drop index ix_taxonterm_term;
create index ix_taxonterm_term on taxon_term (term) tablespace uam_idx_1;

drop index ix_taxonterm_termtype;
create index ix_taxonterm_termtype on taxon_term (term_type) tablespace uam_idx_1;

create index ix_u_taxonterm_termtype on taxon_term (upper(term_type)) tablespace uam_idx_1;


drop index ix_upper_taxonterm;
create index ix_upper_taxonterm on taxon_term(upper(term)) tablespace uam_idx_1;

drop index ix_upper_taxonname;
create index ix_upper_taxonname on taxon_name(upper(scientific_name)) tablespace uam_idx_1;


--- and a materialized view to use in various forms, etc.

create materialized view mv_u_taxonterm_source REFRESH ON COMMIT as select source from taxon_term group by source;

create public synonym mv_u_taxonterm_source for mv_u_taxonterm_source;

grant select on mv_u_taxonterm_source to public;


--- make find-specimen joins easier
create or replace view taxon_term_aggregate as 
SELECT y.taxon_name_id, y.scientific_name,
       LISTAGG(y.term, ', ') WITHIN GROUP (ORDER BY y.term) terms
  FROM (
        select distinct tn.taxon_name_id, tn.scientific_name, tt.term
        from taxon_name tn, taxon_term tt
        where tn.taxon_name_id = tt.taxon_name_id and POSITION_IN_CLASSIFICATION is not null) y
  GROUP BY y.taxon_name_id, y.scientific_name
  ORDER BY y.taxon_name_id, y.scientific_name
;

create or replace public synonym taxon_term_aggregate for taxon_term_aggregate;
grant select on taxon_term_aggregate to public;


-- turns out we do need this one for reporting, and bad performance is OK for that use case

CREATE OR REPLACE function get_taxon(in_collection_object_id IN number, in_rank in varchar2 )
    return varchar2
    as
        l_str    varchar2(4000);
	begin
		select 
			term into l_str
		from 
			collection,
			cataloged_item,
			identification,
			identification_taxonomy,
			taxon_name,
			taxon_term
		where 
			collection.collection_id=cataloged_item.collection_id and
			cataloged_item.collection_object_id=identification.collection_object_id and 
			identification.identification_id = identification_taxonomy.identification_id AND
			identification.accepted_id_fg=1 AND
			identification_taxonomy.taxon_name_id = taxon_name.taxon_name_id AND
			taxon_name.taxon_name_id=taxon_term.taxon_name_id AND
			lower(taxon_term.term_type)=lower(in_rank)and
			taxon_term.source=collection.preferred_taxonomy_source and
			cataloged_item.collection_object_id = in_collection_object_id;	
	return l_str;
	EXCEPTION when others then
			l_str := '';
			return  trim(l_str);
  end;
  --create public synonym get_taxon for get_taxon;
  --grant execute on get_taxon to public;
  
  -- usage: select get_taxon(17,'family') from dual;
  
/



/* 
 * 
 * -- these do NOT need built; performance was horrible, functionality is now directly in update_flat
 * -- but keep the code around, just in case....

-- function to be called from update_flat; returns the collection's preferred classification of given rank for 
-- a specimen
-- returns nothing if for any reason there is not exactly one matching term


CREATE OR REPLACE function get_formatted_taxname(in_collection_object_id IN number )
    -- if there is a term of type "display_value" under the collection's preferred taxonomy, use it.
    -- otherwise, use identification.scientific_name
	return varchar2
    as
        l_str    varchar2(4000);
	begin
		select 
			decode (term,
				null,identification.scientific_name,
				term)
			into 
				l_str
		from 
			collection,
			cataloged_item,
			identification,
			identification_taxonomy,
			taxon_name,
			taxon_term
		where 
			collection.collection_id=cataloged_item.collection_id and
			cataloged_item.collection_object_id=identification.collection_object_id and 
			identification.identification_id = identification_taxonomy.identification_id AND
			identification.accepted_id_fg=1 AND
			identification_taxonomy.taxon_name_id = taxon_name.taxon_name_id (+) AND
			taxon_name.taxon_name_id=taxon_term.taxon_name_id (+) AND
			taxon_term.term_type='display_name' and
			taxon_term.source=collection.preferred_taxonomy_source (+) and
			cataloged_item.collection_object_id = in_collection_object_id;	
	return l_str;
	EXCEPTION when others then
		select identification.scientific_name
			into 
				l_str
		from 
			identification
		where 
			identification.accepted_id_fg=1 AND
			identification.collection_object_id = in_collection_object_id;	
		return l_str;
  end;
  --create public synonym get_taxon for get_taxon;
  --grant execute on get_taxon to public;
  
  -- usage: select get_taxon(17,'family') from dual;
  
/

*/
-- please resume your normally-scheduled update




------------- END  nope, maybe later.... -----------

alter table collection add preferred_taxonomy_source varchar2(255);
update collection set preferred_taxonomy_source='Arctos';
alter table collection modify preferred_taxonomy_source not null;
alter table collection modify preferred_taxonomy_source default 'Arctos';

create index ix_coln_preftax_src on collection(preferred_taxonomy_source) tablespace uam_idx_1;












create index ix_taxonterm_source on taxon_term (source) tablespace uam_idx_1;

-- add pkey for taxon relations to simplify updates
alter table taxon_relations add taxon_relations_id number;
create sequence sq_taxon_relations_id;
create or replace public synonym sq_taxon_relations_id for sq_taxon_relations_id;
grant select on sq_taxon_relations_id to public;

begin
	for r in (select rowid from taxon_relations) loop
		update taxon_relations set taxon_relations_id=sq_taxon_relations_id.nextval where rowid=r.rowid;
	end loop;
end;
/


alter table taxon_relations drop constraint PK_TAXON_RELATIONS;

drop index PK_TAXON_RELATIONS;

ALTER TABLE taxon_relations add CONSTRAINT pk_taxon_relations PRIMARY KEY (taxon_relations_id);

CREATE UNIQUE INDEX iu_TAXON_RELATIONS
	ON TAXON_RELATIONS (TAXON_NAME_ID, RELATED_TAXON_NAME_ID, TAXON_RELATIONSHIP)
	TABLESPACE UAM_IDX_1;
	




CREATE UNIQUE INDEX iu_cttaxonomy_source_src ON cttaxonomy_source (source) TABLESPACE UAM_IDX_1;

insert into cttaxonomy_source (source,description) values ('Arctos','Legacy data migrated from Arctos flat tables.');


CREATE OR REPLACE TRIGGER taxon_relations_key before insert  ON taxon_relations  
    for each row 
    begin     
	    if :NEW.taxon_relations_id is null then                                                                                      
	    	select sq_taxon_relations_id.nextval into :new.taxon_relations_id from dual;
	    end if;                       
    end;                                                                                            
/
sho err

--- and one for common name too
alter table common_name add common_name_id number;
create sequence sq_common_name_id;
create or replace public synonym sq_common_name_id for sq_common_name_id;
grant select on sq_common_name_id to public;

begin
	for r in (select rowid from common_name) loop
		update common_name set common_name_id=sq_common_name_id.nextval where rowid=r.rowid;
	end loop;
end;
/


alter table common_name drop constraint PK_common_name;

drop index PK_common_name;

ALTER TABLE common_name add CONSTRAINT pk_common_name PRIMARY KEY (common_name_id);



select common_name, taxon_name_id from common_name having count(*) > 1 group by common_name, taxon_name_id;


CREATE UNIQUE INDEX iu_common_name
	ON common_name (TAXON_NAME_ID, common_name)
	TABLESPACE UAM_IDX_1;
	
	


CREATE OR REPLACE TRIGGER common_name_key before insert  ON common_name  
    for each row 
    begin     
	    if :NEW.common_name_id is null then                                                                                      
	    	select sq_common_name_id.nextval into :new.common_name_id from dual;
	    end if;                       
    end;                                                                                            
/
sho err


CREATE OR REPLACE TRIGGER trg_taxon_name_nochangeused before update or delete ON taxon_NAME
    for each row 
      DECLARE 
        c INTEGER;
    begin     
	    select count(*) into c from identification_taxonomy where taxon_name_id=:OLD.taxon_name_id;
	     if c > 0 then
	    	Raise_application_error(-20012,'Used names may not be altered.');
	    end if;
	    select count(*) into c from media_relations where media_relationship like '% taxonomy' and related_primary_key=:OLD.taxon_name_id;
	    if c > 0 then
	    	Raise_application_error(-20012,'Used names may not be altered.');
	    end if;                       
    end;                                                                                            
/
sho err


-------------------------------------------------- run scripts to populate the used taxonomy, then ------------------------------------------




alter table common_name drop constraint FK_COMMONNAME_TAXONOMY;

ALTER TABLE common_name ADD CONSTRAINT FK_COMMONNAME_TAXONNAME FOREIGN KEY (TAXON_NAME_ID) REFERENCES TAXON_NAME(TAXON_NAME_ID);


alter table annotations drop constraint FK_ANNOTATIONS_TAXONOMY;

ALTER TABLE annotations ADD CONSTRAINT FK_ANNOTATIONS_TAXONOMY FOREIGN KEY (TAXON_NAME_ID) REFERENCES TAXON_NAME(TAXON_NAME_ID);

alter table IDENTIFICATION_TAXONOMY drop constraint FK_IDTAXONOMY_TAXONOMY;
ALTER TABLE IDENTIFICATION_TAXONOMY ADD CONSTRAINT FK_IDTAXONOMY_TAXONOMY FOREIGN KEY (TAXON_NAME_ID) REFERENCES TAXON_NAME(TAXON_NAME_ID);


alter table PROJECT_TAXONOMY drop constraint PK_PROJECTTAX_TAXONOMY;
ALTER TABLE PROJECT_TAXONOMY ADD CONSTRAINT PK_PROJECTTAX_TAXONOMY FOREIGN KEY (TAXON_NAME_ID) REFERENCES TAXON_NAME(TAXON_NAME_ID);



alter table TAB_MEDIA_REL_FKEY drop constraint CFK_TAXONOMY;

ALTER TABLE TAB_MEDIA_REL_FKEY ADD CONSTRAINT CFK_TAXONOMY FOREIGN KEY (CFK_TAXONOMY) REFERENCES TAXON_NAME(TAXON_NAME_ID);

alter table TAXON_RELATIONS drop constraint FK_TAXONRELN_TAXONOMY_TNID;

alter table TAXON_RELATIONS drop constraint FK_TAXONRELN_TAXONOMY_RTNID;

ALTER TABLE TAXON_RELATIONS ADD CONSTRAINT FK_TAXONRELN_TAXONOMY_TNID FOREIGN KEY (TAXON_NAME_ID) REFERENCES TAXON_NAME(TAXON_NAME_ID);
ALTER TABLE TAXON_RELATIONS ADD CONSTRAINT FK_TAXONRELN_TAXONOMY_RTNID FOREIGN KEY (RELATED_TAXON_NAME_ID) REFERENCES TAXON_NAME(TAXON_NAME_ID);


alter table taxonomy_publication drop constraint FK_TAX_PUB_TAX;
ALTER TABLE taxonomy_publication ADD CONSTRAINT FK_TAX_PUB_TAX FOREIGN KEY (TAXON_NAME_ID) REFERENCES TAXON_NAME(TAXON_NAME_ID);

----------------------------------------------- rebuild flat - make sure to copy this back to the ddl/flat folders ----------------


alter table flat add formatted_scientific_name varchar2(255);

--- moved to flat folder



-- rebuild bulkloader

alter table flat add formatted_scientific_name varchar2(255);
update cf_spec_res_cols set SQL_ELEMENT='flatTableName.family' where column_name='family';
update cf_spec_res_cols set SQL_ELEMENT='flatTableName.phylorder' where column_name='phylorder';
update cf_spec_res_cols set SQL_ELEMENT='flatTableName.phylclass' where column_name='phylclass';
update cf_spec_res_cols set SQL_ELEMENT='flatTableName.formatted_scientific_name' where column_name='sci_name_with_auth';
			