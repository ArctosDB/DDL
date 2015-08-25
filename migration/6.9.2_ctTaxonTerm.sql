-- download https://docs.google.com/spreadsheets/d/1PsHqTyJOjTDrB7Hrx2LvNpybOdiI5-5g2Il_8w6uyeA/edit#gid=0
-- upload

drop table cttaxon_term;

create table cttaxon_term as select * from dlm.my_temp_cf ;

update cttaxon_term set IS_CLASSIFICATION='0' where IS_CLASSIFICATION='no';

update cttaxon_term set IS_CLASSIFICATION='1' where IS_CLASSIFICATION='yes';


alter table cttaxon_term rename column IS_CLASSIFICATION to temp;
alter table cttaxon_term add IS_CLASSIFICATION number;
update cttaxon_term set IS_CLASSIFICATION=to_number(temp);

alter table cttaxon_term drop column temp;


ALTER TABLE cttaxon_term ADD CONSTRAINT is_class_bool CHECK (IS_CLASSIFICATION in (0,1));


alter table cttaxon_term modify IS_CLASSIFICATION  not null;

alter table cttaxon_term modify TERM_TYPE varchar2(255) not null;

create unique index iu_cttaxterm_term on cttaxon_term (TERM_TYPE) tablespace uam_idx_1;

create or replace public synonym cttaxon_term for cttaxon_term;
grant select on cttaxon_term to public;
grant all on cttaxon_term to manage_codetables;


alter table cttaxon_term rename column DEFINITION to description;
alter table cttaxon_term rename column term_type to taxon_term;


alter table cttaxon_term add relative_position number;

create unique index iu_taxonterm_relpos on cttaxon_term ( relative_position ) tablespace uam_idx_1;

alter table cttaxon_term add cttaxon_term_id number;

create sequence sq_cttaxon_term_id;

update cttaxon_term set cttaxon_term_id=sq_cttaxon_term_id.nextval;

ALTER TABLE cttaxon_term ADD CONSTRAINT PK_cttaxon_term PRIMARY KEY(cttaxon_term_id) USING INDEX TABLESPACE uam_idx_1;


drop trigger trg_taxonterm_relpos;

drop trigger trg_taxonterm_biud;


CREATE OR REPLACE TRIGGER trg_taxonterm_biud
     BEFORE update or insert or delete ON cttaxon_term
 FOR EACH ROW 
declare
	c number;
     BEGIN
   	if updating then
   		if :NEW.taxon_term != :OLD.taxon_term then
   			dbms_output.put_line('changing');
	   		select count(*) into c from taxon_term where source in (select source from CTTAXONOMY_SOURCE) and term_type=:OLD.taxon_term;
	   		   			dbms_output.put_line('c=' || c);

	   		if c>0 then
	           RAISE_APPLICATION_ERROR(-20001,'used terms cannot be updated');
	        end if;
	     end if;
    end if;
    
    if deleting then
   			dbms_output.put_line('deleting');
	   		select count(*) into c from taxon_term where source in (select source from CTTAXONOMY_SOURCE) and term_type=:OLD.taxon_term;
	   		   			dbms_output.put_line('c=' || c);

	   		if c>0 then
	           RAISE_APPLICATION_ERROR(-20001,'used terms cannot be deleted');
	        end if;
    end if;
   	if updating or inserting then
	     if :new.cttaxon_term_id is null then
	     	:new.cttaxon_term_id:=sq_cttaxon_term_id.nextval;
	     end if;
	     
	     IF :NEW.IS_CLASSIFICATION=1 and :NEW.relative_position is null THEN
	           RAISE_APPLICATION_ERROR(-20001,'is_classification terms must be accompanied by relative_posistion');
	      END IF;
	      
	     IF :NEW.IS_CLASSIFICATION=0 and :NEW.relative_position is not null THEN
	           RAISE_APPLICATION_ERROR(-20001,'NOT (is_classification) terms may not be accompanied by relative_posistion');
	      END IF;
	      
	      if :new.taxon_term != lower(:new.taxon_term) then  
	      	RAISE_APPLICATION_ERROR(-20001,'Terms must be lowercase');
	      END IF;
	  end if;
  
 END;
 /
 sho err;
 


desc cttaxon_term

-- should be....

 TAXON_TERM                                                        NOT NULL VARCHAR2(255)
 DESCRIPTION                                                                VARCHAR2(4000)
 IS_CLASSIFICATION                                                 NOT NULL NUMBER
 RELATIVE_POSITION                                                          NUMBER
 CTTAXON_TERM_ID                                                   NOT NULL NUMBER

 
 
 
 
-- modify code table editor

 -- modify editTaxonomy
 
 -- blargh, it's hard to edit without some ordering
 
 




         
 -- seed in order
 update cttaxon_term set relative_position=1 where taxon_term='superkingdom';
 update cttaxon_term set relative_position=2 where taxon_term='kingdom';
 update cttaxon_term set relative_position=3 where taxon_term='subkingdom';
 update cttaxon_term set relative_position=4 where taxon_term='infrakingdom';
 update cttaxon_term set relative_position=5 where taxon_term='superphylum';
 update cttaxon_term set relative_position=6 where taxon_term='phylum';
 update cttaxon_term set relative_position=7 where taxon_term='subphylum';
 update cttaxon_term set relative_position=8 where taxon_term='subdivision';
 update cttaxon_term set relative_position=9 where taxon_term='infraphylum';
 update cttaxon_term set relative_position=10 where taxon_term='superclass';
 update cttaxon_term set relative_position=11 where taxon_term='class';
 update cttaxon_term set relative_position=12 where taxon_term='subclass';
 update cttaxon_term set relative_position=13 where taxon_term='infraclass';
 update cttaxon_term set relative_position=14 where taxon_term='hyperorder';
 update cttaxon_term set relative_position=15 where taxon_term='superorder';
 update cttaxon_term set relative_position=16 where taxon_term='order';
 update cttaxon_term set relative_position=17 where taxon_term='suborder';
 update cttaxon_term set relative_position=18 where taxon_term='infraorder';
 update cttaxon_term set relative_position=19 where taxon_term='superfamily';
 update cttaxon_term set relative_position=20 where taxon_term='family';
 update cttaxon_term set relative_position=21 where taxon_term='subfamily';
 update cttaxon_term set relative_position=22 where taxon_term='supertribe';
 update cttaxon_term set relative_position=23 where taxon_term='tribe';
 update cttaxon_term set relative_position=24 where taxon_term='subtribe';
 update cttaxon_term set relative_position=25 where taxon_term='genus';
 update cttaxon_term set relative_position=26 where taxon_term='subgenus';
 update cttaxon_term set relative_position=27 where taxon_term='species';
 update cttaxon_term set relative_position=28 where taxon_term='subpspecies';
 update cttaxon_term set relative_position=29 where taxon_term='forma';
 update cttaxon_term set relative_position=30 where taxon_term='scientific_name';
 update cttaxon_term set relative_position=31 where taxon_term='subunderspecies';
 update cttaxon_term set relative_position=32 where taxon_term='this is still a test';
 
 
 
