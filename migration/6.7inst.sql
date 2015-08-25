update collection set institution='i am blank!' where institution is null;

create table temp as select  collection_id,collection from collection;


alter table collection modify institution  not null;

select 'update collection set institution=''xxxx'',collection=''xxxx'' where collection=''' || collection || ''';' from collection order by collection;


update collection set institution='College of the Atlantic',collection='Bird specimens' where collection='COA Birds';
update collection set institution='College of the Atlantic',collection='Bird eggs' where collection='COA Eggs';
update collection set institution='College of the Atlantic',collection='Amphibian and reptile specimens' where collection='COA Herps';
update collection set institution='College of the Atlantic',collection='Insect specimens' where collection='COA Insects';
update collection set institution='College of the Atlantic',collection='Mammal specimens' where collection='COA Mammals';
update collection set institution='College of the Atlantic',collection='Reptile specimens' where collection='COA Reptiles';

update collection set institution='',collection='Bird specimens' where collection='CRCM Birds';
 
  
update collection set institution='Cornell University Museum of Vertebrates (CUMV)',collection='Amphibian specimens' where collection='CUMV Amphibian';
update collection set institution='Cornell University Museum of Vertebrates (CUMV)',collection='Bird specimens' where collection='CUMV Bird';
update collection set institution='Cornell University Museum of Vertebrates (CUMV)',collection='Fish specimens' where collection='CUMV Fish';
update collection set institution='Cornell University Museum of Vertebrates (CUMV)',collection='Mammal specimens' where collection='CUMV Mammal';
update collection set institution='Cornell University Museum of Vertebrates (CUMV)',collection='Reptile specimens' where collection='CUMV Reptile';


  
update collection set institution='Denver Museum of Nature and Science (DMNS)',collection='Bird specimens' where collection='DMNS Birds';
update collection set institution='Denver Museum of Nature and Science (DMNS)',collection='Bird eggs/nests' where collection='DMNS Egg/Nest';
update collection set institution='Denver Museum of Nature and Science (DMNS)',collection='Mammal specimens' where collection='DMNS Mammals';
update collection set institution='Denver Museum of Nature and Science (DMNS)',collection='Marine invertebrate specimens' where collection='DMNS Marine Invertebrates';


update collection set institution='Harold W. Manter Laboratory of Parasitology Collection',collection='Parasite specimens' where collection='HWML Para';



  
  

update collection set institution='Kenai National Wildlife Refuge, Alaska',collection='Insect specimens' where collection='KNWR ENTO';
update collection set institution='Kenai National Wildlife Refuge, Alaska',collection='Plant specimens' where collection='KNWR Herb';

update collection set institution='Kenelm W. Philip Lepidoptera Collection (KWP)',collection='Lepidopteran specimens' where collection='Alaska Lepidoptera';




  
 
update collection set institution='Moore Laboratory of Zoology (MLZ)',collection='Bird specimens' where collection='MLZ Bird';
update collection set institution='Moore Laboratory of Zoology (MLZ)',collection='Mammal specimens' where collection='MLZ Mamm';



  
  
  
update collection set institution='Museum of Southwestern Biology (MSB), University of New Mexico',collection='Amphibian and reptile specimens' where collection='MSB Amphibians and Reptiles';
update collection set institution='Museum of Southwestern Biology (MSB), University of New Mexico',collection='Bird specimens' where collection='MSB Birds';
update collection set institution='Museum of Southwestern Biology (MSB), University of New Mexico',collection='Host (of parasite) specimens' where collection='MSB Host';
update collection set institution='Museum of Southwestern Biology (MSB), University of New Mexico',collection='Mammal observations' where collection='MSB Mamm Observation';
update collection set institution='Museum of Southwestern Biology (MSB), University of New Mexico',collection='Mammal specimens' where collection='MSB Mammals';
update collection set institution='Museum of Southwestern Biology (MSB), University of New Mexico',collection='Parasite specimens' where collection='MSB Parasites';

update collection set institution='Museum of Southwestern Biology Division of Genomic Resources (DGR)',collection='Arthropod tissues' where collection='DGR Arthropods';
update collection set institution='Museum of Southwestern Biology Division of Genomic Resources (DGR)',collection='Bird tissues' where collection='DGR Birds';
update collection set institution='Museum of Southwestern Biology Division of Genomic Resources (DGR)',collection='Fish tissues' where collection='DGR Fishes';
update collection set institution='Museum of Southwestern Biology Division of Genomic Resources (DGR)',collection='Mammal tissues' where collection='DGR Mammals';



  

  Bird specimens
  Bird eggs/nests
  Bird observations
  Amphibian and reptile specimens
  Amphibian and reptile observations
  Mammal specimens
  Mammal observations
  Field notes
  Fish observations
  Hildebrand
  Field photos

update collection set institution='xxxx',collection='xxxx' where collection='MVZ Birds';
update collection set institution='xxxx',collection='xxxx' where collection='MVZ Egg/Nest';
update collection set institution='xxxx',collection='xxxx' where collection='MVZ Herps';
update collection set institution='xxxx',collection='xxxx' where collection='MVZ Hildebrand';
update collection set institution='xxxx',collection='xxxx' where collection='MVZ Images';
update collection set institution='xxxx',collection='xxxx' where collection='MVZ Mammals';
update collection set institution='xxxx',collection='xxxx' where collection='MVZ Notebook Pages';
update collection set institution='xxxx',collection='xxxx' where collection='MVZ Observations-Bird';
update collection set institution='xxxx',collection='xxxx' where collection='MVZ Observations-Fish';
update collection set institution='xxxx',collection='xxxx' where collection='MVZ Observations-Herp';
update collection set institution='xxxx',collection='xxxx' where collection='MVZ Observations-Mammal';




update collection set institution='xxxx',collection='xxxx' where collection='NBSB Bird';
update collection set institution='xxxx',collection='xxxx' where collection='NMU Birds';
update collection set institution='xxxx',collection='xxxx' where collection='NMU Fishes';
update collection set institution='xxxx',collection='xxxx' where collection='NMU Invertebrates';
update collection set institution='xxxx',collection='xxxx' where collection='NMU Mammals';
update collection set institution='xxxx',collection='xxxx' where collection='NMU Plants';
update collection set institution='xxxx',collection='xxxx' where collection='PSU Mamm';
update collection set institution='xxxx',collection='xxxx' where collection='UAM Archeology';
update collection set institution='xxxx',collection='xxxx' where collection='UAM Art';
update collection set institution='xxxx',collection='xxxx' where collection='UAM Bird';
update collection set institution='xxxx',collection='xxxx' where collection='UAM Earth Science';
update collection set institution='xxxx',collection='xxxx' where collection='UAM Ento Observation';
update collection set institution='xxxx',collection='xxxx' where collection='UAM Ethnology';
update collection set institution='xxxx',collection='xxxx' where collection='UAM Fish Observation';
update collection set institution='xxxx',collection='xxxx' where collection='UAM Fishes';
update collection set institution='xxxx',collection='xxxx' where collection='UAM Herbarium (ALA) Cryptogams';
update collection set institution='xxxx',collection='xxxx' where collection='UAM Herbarium (ALA) Vascular Plants';
update collection set institution='xxxx',collection='xxxx' where collection='UAM Herpetology';
update collection set institution='xxxx',collection='xxxx' where collection='UAM Insects';
update collection set institution='xxxx',collection='xxxx' where collection='UAM Invertebrates';
update collection set institution='xxxx',collection='xxxx' where collection='UAM Mamm Observation';
update collection set institution='xxxx',collection='xxxx' where collection='UAM Mammals';
update collection set institution='xxxx',collection='xxxx' where collection='UMNH Birds';
update collection set institution='xxxx',collection='xxxx' where collection='UMNH Entomology';
update collection set institution='xxxx',collection='xxxx' where collection='UMNH Herpetology';
update collection set institution='xxxx',collection='xxxx' where collection='UMNH Malacology';
update collection set institution='xxxx',collection='xxxx' where collection='UMNH Mammals';
update collection set institution='xxxx',collection='xxxx' where collection='USNPC Parasites';
update collection set institution='xxxx',collection='xxxx' where collection='UWBM Herp';
update collection set institution='xxxx',collection='xxxx' where collection='UWYMV Bird';
update collection set institution='xxxx',collection='xxxx' where collection='UWYMV Herp';
update collection set institution='xxxx',collection='xxxx' where collection='UWYMV Mamm';
update collection set institution='xxxx',collection='xxxx' where collection='WNMU Birds';
update collection set institution='xxxx',collection='xxxx' where collection='WNMU Fishes';
update collection set institution='xxxx',collection='xxxx' where collection='WNMU Mammals';


update collection set institution='College of the Atlantic',collection='Amphibian and reptile specimens' where collection='COA Herps';
update collection set institution='xxxx',collection='xxxx' where collection='xxxx';




  
NBSB
  Bird specimens
Northern Michigan University (NMU)
  Bird specimens
  Fish specimens
  Invertebrate specimens
  Mammal specimens
  Plant specimens
PSU Mamm
University of Alaska Museum (UAM)
  Archeology
  Art
  Bird specimens
  Ethnology and History artifacts
  Ethnology and History observations
  Earth Science
  Fish specimens
  Fish observations
  Cryptogam specimens (ALA)
  Plant specimens (ALA)
  Amphibian and reptile specimens
  Insect specimens
  Insect observations
  Invertebrate specimens
  Mammal specimens
  Mammal observations
Natural History Museum of Utah (UMNH)
  Bird specimens
  Insect specimens
  Amphibian and reptile specimens
  Mollusc specimens
  Mammal specimens
U.S. National Parasite Collection (USNPC)
  Parasite specimens
Burke Museum of Natural History and Culture, University of Washington (UWBM)
  Amphibian and reptile specimens
University of Wyoming Museum of Vertebrates (UWYMV)
  Bird specimens
  Amphibian and reptile specimens
  Mammal specimens
Western New Mexico University (WNMU)
  Bird specimens
  Fish specimens
  Mammal specimens







COA Mammals
COA Reptiles
CRCM Birds
CUMV Amphibian
CUMV Bird
CUMV Fish
CUMV Mammal
CUMV Reptile
DGR Arthropods
DGR Birds
DGR Fishes
DGR Mammals
DMNS Birds
DMNS Egg/Nest
DMNS Mammals
DMNS Marine Invertebrates
HWML Para
KNWR ENTO
KNWR Herb
MLZ Bird
MLZ Mamm
MSB Amphibians and Reptiles
MSB Birds
MSB Host
MSB Mamm Observation
MSB Mammals
MSB Parasites
MVZ Birds
MVZ Egg/Nest
MVZ Herps
MVZ Hildebrand
MVZ Images
MVZ Mammals
MVZ Notebook Pages
MVZ Observations-Bird
MVZ Observations-Fish
MVZ Observations-Herp
MVZ Observations-Mammal
NBSB Bird
NMU Birds
NMU Fishes
NMU Invertebrates
NMU Mammals
NMU Plants
PSU Mamm
UAM Archeology
UAM Art
UAM Bird
UAM Earth Science
UAM Ento Observation
UAM Ethnology
UAM Fish Observation
UAM Fishes
UAM Herbarium (ALA) Cryptogams
UAM Herbarium (ALA) Vascular Plants
UAM Herpetology
UAM Insects
UAM Invertebrates
UAM Mamm Observation
UAM Mammals
UMNH Birds
UMNH Entomology
UMNH Herpetology
UMNH Malacology
UMNH Mammals
USNPC Parasites
UWBM Herp
UWYMV Bird
UWYMV Herp
UWYMV Mamm
WNMU Birds
WNMU Fishes
WNMU Mammals

78 rows selected.

Elapsed: 00:00:00.02
uam@arctest> 





create table cf_temp_recipr_proc (
		collection_id number,
		lastdate date
	);
	
	
	
	create table cf_temp_recip_oids (
		key number,
		collection_id number,
		guid_prefix varchar2(20) not null,
		existing_other_id_type varchar2(60) not null,
		existing_other_id_number varchar2(60) not null,
		new_other_id_type varchar2(60) not null,
		new_other_id_number varchar2(60) not null,
		new_other_id_references varchar2(60),
		found_date date
	);
	
	create public synonym cf_temp_recip_oids for cf_temp_recip_oids;
	grant all on cf_temp_recip_oids to manage_specimens;

	 CREATE OR REPLACE TRIGGER cf_temp_recip_oids_key
	 before insert  ON cf_temp_recip_oids
	 for each row
	    begin
	    	if :NEW.key is null then
	    		select somerandomsequence.nextval into :new.key from dual;
	    	end if;
	    end;
	/
	sho err


	create unique index ix_u_cf_temp_recip_oids_key on cf_temp_recip_oids (key) tablespace uam_idx_1;
	
	create unique index ix_ucf_temp_oids_key on cf_temp_oids (key) tablespace uam_idx_1;

	
	scheduler: pendingRelations
	
	alter table cf_temp_oids add username varchar2(255) not null;
	
	
 CREATE OR REPLACE TRIGGER cf_temp_oids_key
 before insert  ON cf_temp_oids
 for each row
    begin
	    :new.username:=sys_context('USERENV', 'SESSION_USER');
	    
    	if :NEW.key is null then
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;
    end;
/
sho err



alter table cf_temp_lbl2contr add label varchar2(255) not null;
alter table cf_temp_lbl2contr modify label null;
alter table cf_temp_lbl2contr modify CONTAINER_TYPE not null;


-- edit permissions for /tools/bulkEditContainer.cfm

	   