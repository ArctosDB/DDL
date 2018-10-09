--- https://github.com/ArctosDB/arctos/issues/1704

-- done at test and prod
CREATE OR REPLACE FUNCTION isValidTaxonName (name  in varchar)...
-- done at test and prod

CREATE OR REPLACE function generateDisplayName (v_cid in varchar2 )....


-- prep
drop table temp_former_subgenus_id;

create table temp_former_subgenus_ids (
	guid varchar2(255),
	former_taxon_name varchar2(255),
	new_taxon_name varchar2(255),
	former_taxa_formula varchar2(255)
);
	
delete from temp_former_subgenus_id;

-- Part One
-- when scientific_name ends with parens, we just want the stuff inside
-- Aleochara (Calochara) becomes Calochara

insert into temp_former_subgenus_ids (
	guid,
	former_taxon_name,
	new_taxon_name,
	former_taxa_formula
) (
	 select
     	flat.guid,
        taxon_name.scientific_name,
        replace(regexp_replace(taxon_name.scientific_name,'^.*\((.*)\).*$','\1'),'  ',' '),
        identification.taxa_formula
        from
        	taxon_name,
          identification_taxonomy,
          identification,
          flat
        where
          identification_taxonomy.taxon_name_id=taxon_name.taxon_name_id and
          identification_taxonomy.identification_id=identification.identification_id and
          identification.collection_object_id=flat.collection_object_id and
          taxon_name.scientific_name like '%)'
);
-- Part Two
-- when scientific_name contains parens in the middle, we just want the stuff outside
-- Pleurobema (Pleurobema) raveneliana becomes Pleurobema raveneliana
insert into temp_former_subgenus_ids (
	guid,
	former_taxon_name,
	new_taxon_name,
	former_taxa_formula
) (
	 select
     	flat.guid,
        taxon_name.scientific_name,
        replace(regexp_replace(taxon_name.scientific_name,'\(.*\)'),'  ',' ') ,
        identification.taxa_formula
        from
        	taxon_name,
          identification_taxonomy,
          identification,
          flat
        where
          identification_taxonomy.taxon_name_id=taxon_name.taxon_name_id and
          identification_taxonomy.identification_id=identification.identification_id and
          identification.collection_object_id=flat.collection_object_id and
          taxon_name.scientific_name like '%(%' and 
          taxon_name.scientific_name not like '%)'
);

select
	substr(guid,1,instr(guid,':',1,2)) || ' @ ' ||	count(*) 
from 
	temp_former_subgenus_ids
group by
	substr(guid,1,instr(guid,':',1,2))
;

	
select former_taxon_name || '--->' || new_taxon_name from temp_former_subgenus_ids 
--where guid like 'MSB:Fish%'
group by former_taxon_name || '--->' || new_taxon_name order by former_taxon_name || '--->' || new_taxon_name;


drop table temp_taxon_sn_nn;
create table temp_taxon_sn_nn as select distinct new_taxon_name scientific_name from temp_former_subgenus_ids where new_taxon_name not in (select scientific_name from taxon_name);
-- ^^ table contains names we need to create
-- uploaded through bulkloader

-- run 
--http://arctos-test.tacc.utexas.edu/fix/fixSubGenusNames.cfm?action=createMissingSubgenera 
-- to create missing names and import classifications when possible


--- push new names to IDs


alter table temp_former_subgenus_ids add old_tid number;
alter table temp_former_subgenus_ids add new_tid number;

update temp_former_subgenus_ids set old_tid=(select taxon_name_id from taxon_name where scientific_name=FORMER_TAXON_NAME);
select count(*) from temp_former_subgenus_ids where old_tid is null;

update temp_former_subgenus_ids set new_tid=(select taxon_name_id from taxon_name where scientific_name=NEW_TAXON_NAME);

select count(*) from temp_former_subgenus_ids where new_tid is null;


alter table temp_former_subgenus_ids add id_id number;

update temp_former_subgenus_ids set id_id=(
	select 
		identification.identification_id 
	from 
		identification,
		identification_taxonomy, 
		flat
	where
		identification.identification_id=identification_taxonomy.identification_id and
		identification.collection_object_id=flat.collection_object_id and
		temp_former_subgenus_ids.guid=flat.guid and
		identification_taxonomy.taxon_name_id=old_tid
	);
	
	select count(*) from temp_former_subgenus_ids where id_id is null;

create table bak_identification_20181009 as select * from identification;
create table bak_id_tax_20181009 as select * from identification_taxonomy;


update identification set TAXA_FORMULA='A {string}' where identification_id in (select id_id from temp_former_subgenus_ids);

update identification_taxonomy set identification_taxonomy.taxon_name_id= (
	select new_tid from temp_former_subgenus_ids where 
	identification_taxonomy.identification_id=temp_former_subgenus_ids.id_id and
	identification_taxonomy.taxon_name_id=temp_former_subgenus_ids.old_tid
);
--ORA-01407: cannot update ("UAM"."IDENTIFICATION_TAXONOMY"."TAXON_NAME_ID") to NULL
-- wtf...


begin
	for r in (select * from temp_former_subgenus_ids) loop
		update identification_taxonomy set identification_taxonomy.taxon_name_id=r.new_tid 
		 where 
		identification_taxonomy.identification_id=r.id_id and
		identification_taxonomy.taxon_name_id=r.old_tid;
	end loop;
end;
/


create table temp_taxa_to_delete as select taxon_name_id,scientific_name from taxon_name where scientific_name like '%)%';



FK_IDTAXONOMY_TAXONOMY 	IDENTIFICATION_TAXONOMY.TAXON_NAME_ID 	SYS_C0077834 	TAXON_NAME.TAXON_NAME_ID
PK_PROJECTTAX_TAXONOMY 	PROJECT_TAXONOMY.TAXON_NAME_ID 	SYS_C0077834 	TAXON_NAME.TAXON_NAME_ID
FK_TNID 	TAXON_TERM.TAXON_NAME_ID 	SYS_C0077834 	TAXON_NAME.TAXON_NAME_ID 


select * from ANNOTATIONS where TAXON_NAME_ID  in (select TAXON_NAME_ID from temp_taxa_to_delete);
delete from ANNOTATIONS where TAXON_NAME_ID  in (select TAXON_NAME_ID from temp_taxa_to_delete);

select * from IDENTIFICATION_TAXONOMY where TAXON_NAME_ID  in (select TAXON_NAME_ID from temp_taxa_to_delete);

select * from PROJECT_TAXONOMY where TAXON_NAME_ID  in (select TAXON_NAME_ID from temp_taxa_to_delete);

delete from TAXON_TERM  where TAXON_NAME_ID  in (select TAXON_NAME_ID from temp_taxa_to_delete);
delete from taxon_relations  where TAXON_NAME_ID  in (select TAXON_NAME_ID from temp_taxa_to_delete);
delete from taxon_relations  where related_TAXON_NAME_ID  in (select TAXON_NAME_ID from temp_taxa_to_delete);

delete from TAXON_name  where TAXON_NAME_ID  in (select TAXON_NAME_ID from temp_taxa_to_delete);

select * from taxon_relations where TAXON_NAME_ID  in (select TAXON_NAME_ID from temp_taxa_to_delete);
select * from taxon_relations where related_TAXON_NAME_ID  in (select TAXON_NAME_ID from temp_taxa_to_delete);





	from taxon_name where scientific_name=NEW_TAXON_NAME);

select scientific_name,replace(regexp_replace(scientific_name,'^.*\((.*)\).*$','\1'),'  ',' ') from taxon_name where scientific_name like '%)';



select scientific_name,replace(regexp_replace(scientific_name,'\(.*\)'),'  ',' ') from taxon_name where scientific_name like '%(%' and scientific_name not like '%)';


	declare
  swb varchar2(255);
  startpos number;
  endpos number;
  strlen number;
begin
  for r in (select * from taxon_name where scientific_name like '%(%') loop
    dbms_output.put_line(r.scientific_name);
    startpos:=instr(r.scientific_name,'(');
    endpos:=instr(r.scientific_name,')');
      
    strlen:=endpos-startpos;

    swb:=substr(r.scientific_name,startpos+1,strlen-1);
    dbms_output.put_line(swb);

    insert into temp_former_subgenus_id (
      guid,
      former_taxon_name,
      new_taxon_name
    ) ( select
           flat.guid,
           r.scientific_name,
           swb
        from
          identification_taxonomy,
          identification,
          flat
        where
          identification_taxonomy.taxon_name_id=r.taxon_name_id and
          identification_taxonomy.identification_id=identification.identification_id and
          identification.collection_object_id=flat.collection_object_id
    );

  end loop;
end;
/

-- aiya nevermind...
-- need to deal withGalba (Galba) palustris and similar
select
	TAXA_FORMULA,
	count(*)
from
	identification,
	identification_taxonomy,
	taxon_name
where
	identification.identification_id=identification_taxonomy.identification_id and
	identification_taxonomy.taxon_name_id=taxon_name.taxon_name_id and
	taxon_name.scientific_name like '%(%'
group by
	TAXA_FORMULA
;
	

-- http://arctos-test.tacc.utexas.edu/fix/fixSubGenusNames.cfm?CaptureIntendedMoveSpecimenIDs
log this

--http://arctos-test.tacc.utexas.edu/fix/fixSubGenusNames.cfm?action=moveSpecimenIDs
-- to reidentify specimens using () names