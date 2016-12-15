-- #992
select scientific_name,taxon_name_id from taxon_name where scientific_name in ('Rana (Lithobates) pipiens','Rana (Lithobates) clamitans');
Rana (Lithobates) clamitans
     10953801

Rana (Lithobates) pipiens
     10953825

     
select distinct TAXA_FORMULA from identification,identification_taxonomy where 
	identification.identification_id=identification_taxonomy.identification_id and
	taxon_name_id in (10953801,10953825);
	
update identification set TAXA_FORMULA='A {string}' where identification_id in (
	select identification_id from identification_taxonomy where taxon_name_id in (10953801,10953825));
	
select scientific_name,taxon_name_id from taxon_name where scientific_name in ('Lithobates pipiens','Lithobates clamitans');
Lithobates clamitans
     10531099

Lithobates pipiens
     10529192

update identification_taxonomy set taxon_name_id=10531099 where taxon_name_id=10953801;
update identification_taxonomy set taxon_name_id=10529192 where taxon_name_id=10953825;

delete from taxon_term where taxon_name_id in (10953801,10953825);
delete from taxon_relations where taxon_name_id in (10953801,10953825);
delete from taxon_name where taxon_name_id in (10953801,10953825);
-- /#992