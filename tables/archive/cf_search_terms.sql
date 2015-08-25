drop table cf_search_terms;
create table cf_search_terms (
	term varchar2(60) not null,
	display varchar2(60) not null,
	code_table varchar2(60),
	definition varchar2(255)
	);
create or replace public synonym cf_search_terms for cf_search_terms;
grant select on cf_search_terms to public ;
grant update,insert,delete on cf_search_terms to GLOBAL_ADMIN;


insert into cf_search_terms (term,display,code_table,definition) values ('catnum','catalog number','','integer, list, or range');
insert into cf_search_terms (term,display,code_table,definition) values ('mime_type','mime type','ctmime_type','media mime type');
insert into cf_search_terms (term,display,code_table,definition) values ('geology_attribute','geology atribute','ctgeology_attribute','');
insert into cf_search_terms (term,display,code_table,definition) values ('geology_hierarchies','traverse geology hierarchies?','boolean','');
insert into cf_search_terms (term,display,code_table,definition) values ('geology_attribute_value','geology attribute value','','');
insert into cf_search_terms (term,display,code_table,definition) values ('media_type','','','');
insert into cf_search_terms (term,display,code_table,definition) values ('barcode','','','');
insert into cf_search_terms (term,display,code_table,definition) values ('media_type','Media Type','','');
insert into cf_search_terms (term,display,code_table,definition) values ('ShowObservations','ShowObservations','boolean','');
insert into cf_search_terms (term,display,code_table,definition) values ('coll_obj_disposition','specimen disposition','ctcoll_obj_disp','');
insert into cf_search_terms (term,display,code_table,definition) values ('coll','collector or preparator','','');
insert into cf_search_terms (term,display,code_table,definition) values ('coll_role','collector role','ctcollector_role','');
insert into cf_search_terms (term,display,code_table,definition) values ('scientific_name','scientific name','','');
insert into cf_search_terms (term,display,code_table,definition) values ('sciNameOper','scientific name operator','IN(LIKE,OR,AND,=,NOT LIKE','accepted identification');
insert into cf_search_terms (term,display,code_table,definition) values ('AnySciName','scientific name','','any identification or synonym');
insert into cf_search_terms (term,display,code_table,definition) values ('genus','genus','','');
insert into cf_search_terms (term,display,code_table,definition) values ('species','species','','');
insert into cf_search_terms (term,display,code_table,definition) values ('subspecies','subspecies','','');
insert into cf_search_terms (term,display,code_table,definition) values ('phylclass','class','','');
insert into cf_search_terms (term,display,code_table,definition) values ('any_taxa_term','taxonomy','','identification, taxonomy, and common name');
insert into cf_search_terms (term,display,code_table,definition) values ('identification_remarks','identification remarks','','');
insert into cf_search_terms (term,display,code_table,definition) values ('nature_of_id','nature of id','ctnature_of_id','');
insert into cf_search_terms (term,display,code_table,definition) values ('identified_agent','identifier','','');
insert into cf_search_terms (term,display,code_table,definition) values ('begYear','began year','','');
insert into cf_search_terms (term,display,code_table,definition) values ('inclDateSearch','inclusive date search','boolean','');
insert into cf_search_terms (term,display,code_table,definition) values ('endYear','ended year','','');
insert into cf_search_terms (term,display,code_table,definition) values ('begMon','began month','','');
insert into cf_search_terms (term,display,code_table,definition) values ('endMon','ended month','','');
insert into cf_search_terms (term,display,code_table,definition) values ('begDay','began day','','');
insert into cf_search_terms (term,display,code_table,definition) values ('endDay','ended day','','');
insert into cf_search_terms (term,display,code_table,definition) values ('begDate','began date','','');
insert into cf_search_terms (term,display,code_table,definition) values ('endDate','ended date','','');
insert into cf_search_terms (term,display,code_table,definition) values ('verificationstatus','verification status','','');
insert into cf_search_terms (term,display,code_table,definition) values ('inMon','in month list','','');
insert into cf_search_terms (term,display,code_table,definition) values ('verbatim_date','verbatim date','','');
insert into cf_search_terms (term,display,code_table,definition) values ('accn_number','accession number','','');
insert into cf_search_terms (term,display,code_table,definition) values ('accn_agency','accession agency','','');
insert into cf_search_terms (term,display,code_table,definition) values ('OIDType','identifier type','ctcoll_other_id_type','');
insert into cf_search_terms (term,display,code_table,definition) values ('OIDNum','identifier','','');
insert into cf_search_terms (term,display,code_table,definition) values ('continent_ocean','continent or ocean','','');
insert into cf_search_terms (term,display,code_table,definition) values ('sea','sea','','');
insert into cf_search_terms (term,display,code_table,definition) values ('country','country','','');
insert into cf_search_terms (term,display,code_table,definition) values ('state_prov','state or prov','','');
insert into cf_search_terms (term,display,code_table,definition) values ('island_group','island group','','');
insert into cf_search_terms (term,display,code_table,definition) values ('island','island','','');
insert into cf_search_terms (term,display,code_table,definition) values ('min_max_error','lower maximum error','','');
insert into cf_search_terms (term,display,code_table,definition) values ('max_error_units','error units','ctlat_long_error_units','');
insert into cf_search_terms (term,display,code_table,definition) values ('max_max_error','upper maximum error','','');
insert into cf_search_terms (term,display,code_table,definition) values ('max_error_in_meters','maximum error in meters','','error converted to meters <= max_error_in_meters');
insert into cf_search_terms (term,display,code_table,definition) values ('chronological_extent','chronological extent','','');
insert into cf_search_terms (term,display,code_table,definition) values ('NWLat','NW latitude','','part of bounding box definition');
insert into cf_search_terms (term,display,code_table,definition) values ('NWLong','NW longitude','','part of bounding box definition');
insert into cf_search_terms (term,display,code_table,definition) values ('SELat','SE latitude','','part of bounding box definition');
insert into cf_search_terms (term,display,code_table,definition) values ('SELong','SE longitude','','part of bounding box definition');
insert into cf_search_terms (term,display,code_table,definition) values ('spec_locality','specific locality','','');
insert into cf_search_terms (term,display,code_table,definition) values ('verbatim_locality','verbatim locality','','');
insert into cf_search_terms (term,display,code_table,definition) values ('minimum_elevation','minimum elevation','','');
insert into cf_search_terms (term,display,code_table,definition) values ('orig_elev_units','original elevation units','ctorig_elev_units','');
insert into cf_search_terms (term,display,code_table,definition) values ('maximum_elevation','maximum elevation','','');
insert into cf_search_terms (term,display,code_table,definition) values ('feature','geographic feature','','');
insert into cf_search_terms (term,display,code_table,definition) values ('any_geog','geography, specific locality, verbatim locality','','');
insert into cf_search_terms (term,display,code_table,definition) values ('higher_geog','higher geography','','');
insert into cf_search_terms (term,display,code_table,definition) values ('county','county','','');
insert into cf_search_terms (term,display,code_table,definition) values ('quad','USGS quadrangle','','');
insert into cf_search_terms (term,display,code_table,definition) values ('part_name','part name','ctspecimen_part_name','');
insert into cf_search_terms (term,display,code_table,definition) values ('is_tissue','is_tissue','boolean','');
insert into cf_search_terms (term,display,code_table,definition) values ('preserv_method','preservation method','ctspecimen_preserv_method','');
insert into cf_search_terms (term,display,code_table,definition) values ('part_modifier','part modifier','ctspecimen_part_modifier','');
insert into cf_search_terms (term,display,code_table,definition) values ('common_name','common name','','');
insert into cf_search_terms (term,display,code_table,definition) values ('relationship','biological individual relationship','ctbiol_relations','');
insert into cf_search_terms (term,display,code_table,definition) values ('derived_relationship','derived relationship','','inverse of relationship');
insert into cf_search_terms (term,display,code_table,definition) values ('type_status','type status','ctcitation_type_status','');
insert into cf_search_terms (term,display,code_table,definition) values ('project_sponsor','project sponsor','','');
insert into cf_search_terms (term,display,code_table,definition) values ('loan_project_name','loan_project_name','','');
insert into cf_search_terms (term,display,code_table,definition) values ('project_name','project_name','','');
insert into cf_search_terms (term,display,code_table,definition) values ('permit_issued_by','permit_issued_by','','');
insert into cf_search_terms (term,display,code_table,definition) values ('permit_issued_to','permit_issued_to','','');
insert into cf_search_terms (term,display,code_table,definition) values ('permit_type','permit_type','','');
insert into cf_search_terms (term,display,code_table,definition) values ('permit_num','permit number','','');
insert into cf_search_terms (term,display,code_table,definition) values ('collecting_source','collecting_source','','');
insert into cf_search_terms (term,display,code_table,definition) values ('remark','remark','','');
insert into cf_search_terms (term,display,code_table,definition) values ('attribute_type','attribute_type','ctattribute_type','');
insert into cf_search_terms (term,display,code_table,definition) values ('attribute_operator','attribute_operator','IN(like,equals,greater)','');
insert into cf_search_terms (term,display,code_table,definition) values ('attribute_value','attribute_value','','');


update cf_search_terms set display=replace(display,'_',' ');
