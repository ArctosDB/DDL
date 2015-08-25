-- make sure cf_collection updates

-- make sure cf_collection

alter table cf_collection add institution  VARCHAR2(255);

select PORTAL_NAME from cf_collection where collection_id is null;



update cf_collection set institution='All Arctos Collections' where PORTAL_NAME='ALL_ALL';
update cf_collection set institution='Museum of Vertebrate Zoology, University of California-Berkeley (MVZ)' where PORTAL_NAME='MVZ_ALL';
update cf_collection set institution='University of Alaska Museum (UAM)' where PORTAL_NAME='UAM_ENTO_ALL';
update cf_collection set institution='College of the Atlantic (COA)' where PORTAL_NAME='COA_ALL';
update cf_collection set institution='Natural History Museum of Utah (UMNH)' where PORTAL_NAME='UMNH_ALL';
update cf_collection set institution='Northern Michigan University (NMU)' where PORTAL_NAME='NMU_ALL';
update cf_collection set institution='Cornell University Museum of Vertebrates (CUMV)' where PORTAL_NAME='CUMV_ALL';


lock table collection in exclusive mode nowait;
alter trigger TR_collection_AU_FLAT disable;


begin
	for r in (select * from dlm.my_temp_cf ) loop
	 	
	 	dbms_output.put_line(r.institution);
	 	dbms_output.put_line(r.newcollection);
	 	update 
	 		collection 
	 	set 
	 		institution=r.institution,
	 		collection=r.newcollection 
	 	where 
	 		COLLECTION_ID=r.COLLECTION_ID;
	end loop; 
end;
/


alter trigger TR_collection_AU_FLAT enable;
commit;



begin
	for r in (select * from collection ) loop
	 	
	 	update 
	 		flat 
	 	set 
	 		COLLECTION=r.COLLECTION
	 	where 
	 		COLLECTION_ID=r.COLLECTION_ID;
	end loop; 
end;
/


begin
	for r in (select collection_id,institution from collection) loop
		update cf_collection set institution=r.institution where cf_collection_id=r.collection_id;
	end loop;
end;
/

-- block the collections with nothing in them

update cf_collection set public_portal_fg=0 where collection_id is not null and collection_id not in (select distinct collection_id from filtered_flat);

select institution from cf_collection where institution like '%DGR%';

update cf_collection set public_portal_fg=0 where institution like '%DGR%';



CREATE OR REPLACE TRIGGER TR_COLLECTION_SYNC_BUID .... (DONE @ test and prod, saved to DDL)



create or replace public synonym CF_COLLECTION for CF_COLLECTION;
grant select on cf_collection to public;





update cf_collection set institution='All Institutions' where collection ='All Collections';
update cf_collection set institution='College of the Atlantic (COA)' where collection ='COA Collections';
update cf_collection set institution='Cornell University Museum of Vertebrates (CUMV)' where collection ='CUMV Collections';
update cf_collection set institution='Museum of Vertebrate Zoology (MVZ)' where collection ='MVZ Collections';
update cf_collection set institution='Northern Michigan University (NMU)' where collection ='NMU Collections';
update cf_collection set institution='University of Alaska Museum (UAM)' where collection ='UAM Insects and Observations';
update cf_collection set institution='Natural History Museum of Utah (UMNH)' where collection ='UMNH Collections';




alter table cf_temp_id rename column collection_cde to guid_prefix;
alter table cf_temp_id drop column institution_acronym;
alter table cf_temp_id modify guid_prefix varchar2(30); - convert to GUID


alter table cf_temp_barcode_parts rename column  COLLECTION_CDE to guid_prefix;
alter table cf_temp_barcode_parts drop column  INSTITUTION_ACRONYM; 

alter table cf_temp_parts rename column collection_cde to guid_prefix;



alter table cf_temp_data_loan_item rename column COLLECTION_CDE to guid_prefix;
alter table cf_temp_data_loan_item modify guid_prefix varchar2(25);
alter table cf_temp_data_loan_item drop column INSTITUTION_ACRONYM;


alter table cf_temp_loan_item drop column INSTITUTION_ACRONYM;
alter table cf_temp_loan_item drop column COLLECTION_CDE;

---------------------------- shit ---------------------------
Insurmountable (or ignorable)-at-the-moment tasks

DO NOT DROP THE UNIQUE CONSTRAINT ON {COLLECTION,INSTITUTION_ACRONMY} UNTIL THESE ARE RESOLVED

* replace in VPD (and whatever) DDL ALL occurrences of 
	institution_acronym || '_' || collection_cde
	with
	upper(replace(collection.guid_prefix,':','_'))
	
	
* Bulkloader uses institution_acronym. Without rebuilding the bulkloader, we're stuck with institution and acronym not matching, 
and we can't build a fully dynamic home.cfm without those data

	- rebuild bulkloader to use guid_prefix as collection/institution designators
	- rebuild VPD DDL
	- add "is_observation_collection" flag to collection - get that concept out of instution_acronym
		- or don't - just use cataloged_item_type
		- or do, but just trigger cataloged_item_type changes
		- or something....
	- track down everything that uses this stuff and rebuild as necessary
	- make institution and acronym jive, rebuild home (drop REPLACE components)
	- see if we're breaking IPT

* Container "uses" (but doesn't do much with) institution_acronym
	- revisit the situation
		- what we're doing may work fine
		- change to guid_prefix?
		- change to FKEY(collection.collection_id)?
		- drop as a silly idea?

* Loan, Accn number suggestions - rebuild when and only when we have a final plan
	- probably filter on guid_prefix - it's just a few more IF statements

* Genbank: genbank_crawl needs a review/rebuild

* SpecimenDetailRDF.cfm - whatever, don't think it's being used, but revisit after all collection-change dust has settled


* BulkPartSample - convert to GUID

* dgr_locator

