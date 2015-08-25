REVOKE ALL ON specimen_part FROM manage_specimens;
REVOKE ALL ON specimen_part FROM uam_query;
REVOKE ALL ON specimen_part FROM PUBLIC;

CREATE TABLE pt_specimen_part AS SELECT * FROM specimen_part;

ALTER TABLE specimen_part MODIFY part_name VARCHAR2(255);
    
ALTER TRIGGER SPECIMEN_PART_CT_CHECK DISABLE;
DROP TRIGGER IS_TISSUE_DEFAULT;
ALTER TRIGGER MAKE_PART_COLL_OBJ_CONT DISABLE;
ALTER TRIGGER TR_CTSPECIMEN_PART_NAME_UD DISABLE;
ALTER TRIGGER TR_CTSPECIMEN_PRES_MET_UD  DISABLE;

ALTER TRIGGER TR_SPECPART_AIUD_FLAT DISABLE;

SELECT COUNT(*) FROM specimen_part,pt_specimen_part WHERE
specimen_part.collection_object_id=pt_specimen_part.collection_object_id AND
specimen_part.part_name!=pt_specimen_part.part_name ;
    


UPDATE specimen_part SET part_name=
DECODE(PART_MODIFIER,
      NULL,'',
      PART_MODIFIER || ' ')
    || part_name ||
    DECODE(PRESERVE_METHOD,
      NULL,'',
      ' (' || PRESERVE_METHOD || ')')
      ;

UPDATE specimen_part SET part_name=trim(part_name);
 
CREATE TABLE oldctpartname AS SELECT * FROM ctspecimen_part_name;
   
ALTER TRIGGER SPECIMEN_PART_CT_CHECK ENABLE;
ALTER TRIGGER MAKE_PART_COLL_OBJ_CONT ENABLE;
ALTER TRIGGER TR_CTSPECIMEN_PART_NAME_UD ENABLE;
ALTER TRIGGER TR_CTSPECIMEN_PRES_MET_UD  ENABLE;

    
ALTER TRIGGER TR_CTSPECIMEN_PART_NAME_UD DISABLE;

DELETE FROM ctspecimen_part_name;

ALTER TABLE ctspecimen_part_name DROP CONSTRAINT PK_CTSPECIMEN_PART_NAME;

drop index PK_CTSPECIMEN_PART_NAME;

alter table ctspecimen_part_name modify part_name varchar2(255);

ALTER TABLE ctspecimen_part_name ADD is_tissue NUMBER(1) DEFAULT 0 NOT NULL CHECK (is_tissue IN(0,1));

ALTER TABLE ctspecimen_part_name ADD ctspnid NUMBER NOT NULL PRIMARY KEY;

CREATE UNIQUE INDEX iu_ctspec_part_name ON ctspecimen_part_name(part_name,collection_cde);

CREATE OR REPLACE TRIGGER ctspecimen_part_name_seq before insert ON ctspecimen_part_name for each row
   begin     
       IF :new.ctspnid IS NULL THEN
           select someRandomSequence.nextval into :new.ctspnid from dual;
       END IF;
   end;                                                                                            
/
sho err


INSERT INTO ctspecimen_part_name (part_name,collection_cde,is_tissue)
(SELECT
    part_name,
    collection.collection_cde,
    0
 FROM
     specimen_part,
     cataloged_item,
     collection
 WHERE
     specimen_part.derived_from_cat_item=cataloged_item.collection_object_id AND
     cataloged_item.collection_id=collection.collection_id
  GROUP BY
      part_name,
    collection.collection_cde
 );
 
 
ALTER TRIGGER TR_CTSPECIMEN_PART_NAME_UD ENABLE;
 
BEGIN
    FOR r IN (SELECT part_name,description FROM oldctpartname WHERE description IS NOT NULL) LOOP
        UPDATE ctspecimen_part_name SET description=r.description WHERE part_name=r.part_name;
    END LOOP;
END;
/


 
CREATE OR REPLACE FUNCTION CONCATPARTS ( collobjid in integer)
return varchar2
as            
 	t varchar2(255);
 	result varchar2(4000);     
 	sep varchar2(2):='';
begin
for r in (
	select
		part_name,
		sampled_from_obj_id
	from
		specimen_part,
    	ctspecimen_part_list_order,
        coll_object
 	where 
        specimen_part.collection_object_id=coll_object.collection_object_id and
  		specimen_part.part_name =  ctspecimen_part_list_order.partname (+)
    	and coll_obj_disposition not in 
        	('discarded','used up','deaccessioned','missing','transfer of custody')
        and derived_from_cat_item = collobjid
    ORDER BY list_order,sampled_from_obj_id DESC
    ) loop
    	t:=r.part_name;
    	if r.sampled_from_obj_id is not null then
    		t:=t||' sample';
    	end if;
    	result:=result||sep||t;
    	sep:='; ';
    end loop;
    return result;
end;
/
sho err;	
 /*
  ADD permissions FOR 
  	/picks/findPart.cfm
 	/Admin/ctspecimen_part_name.cfm
 	/includes/forms/f_ctspecimen_part_name.cfm
 	/Reports/partusage.cfm
*/
 
 -- import cleaned data from spreadsheet as table fixpartnameit, and use it to clean the data and bulkloader
 -- for testing only....
 -- CREATE TABLE fixpartname AS SELECT part_name AS oldv,part_name AS newv FROM ctspecimen_part_name GROUP BY part_name;
 -- update fixpartname set newv='this is a test' where oldv='fragments of tibia';
 
 create table fixpartname (oldv varchar2(255),newv varchar2(255),tiss number);

insert into fixpartname (oldv,tiss,newv) values ('	acanthocephala	',	0	,'	acanthocephala	');			
insert into fixpartname (oldv,tiss,newv) values ('	alisphenoid	',	0	,'	alisphenoid	');			
insert into fixpartname (oldv,tiss,newv) values ('	antler	',	0	,'	antler	');			
insert into fixpartname (oldv,tiss,newv) values ('	antler (dry)	',	0	,'	antler	');			
insert into fixpartname (oldv,tiss,newv) values ('	astragalus	',	0	,'	astragalus	');			
insert into fixpartname (oldv,tiss,newv) values ('	astragulus	',	0	,'	astragalus	');			
insert into fixpartname (oldv,tiss,newv) values ('	atlas	',	0	,'	atlas vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	atlas vertebra	',	0	,'	atlas vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	atlas vertebra (dry)	',	0	,'	atlas vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	audio recording	',	0	,'	audio recording	');			
insert into fixpartname (oldv,tiss,newv) values ('	auditory bulla	',	0	,'	auditory bulla	');			
insert into fixpartname (oldv,tiss,newv) values ('	axial skeleton	',	0	,'	axial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	axis vertebra	',	0	,'	axis vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	baculum	',	0	,'	baculum	');			
insert into fixpartname (oldv,tiss,newv) values ('	baculum (dry)	',	0	,'	baculum	');			
insert into fixpartname (oldv,tiss,newv) values ('	baculum (70% ETOH)	',	0	,'	baculum (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	baculum (95% ETOH)	',	0	,'	baculum (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	baculum (dried)	',	0	,'	baculum	');			
insert into fixpartname (oldv,tiss,newv) values ('	baculum (ethanol)	',	0	,'	baculum (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	baculum (frozen)	',	0	,'	baculum (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	baculum (glycerin)	',	0	,'	baculum (glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	baculum (slide smear)	',	0	,'	baculum (slide)	');			
insert into fixpartname (oldv,tiss,newv) values ('	baculum (slide)	',	0	,'	baculum (slide)	');			
insert into fixpartname (oldv,tiss,newv) values ('	baculum (other)	',	0	,'	baculum (unknown)	');			
insert into fixpartname (oldv,tiss,newv) values ('	baleen plate	',	0	,'	baleen plate	');			
insert into fixpartname (oldv,tiss,newv) values ('	basioccipital	',	0	,'	basioccipital	');			
insert into fixpartname (oldv,tiss,newv) values ('	blood	',	1	,'	blood	');			
insert into fixpartname (oldv,tiss,newv) values ('	blood (95% ETOH)	',	1	,'	blood (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	blood (Alsever's solution)	',	1	,'	blood (Alsever's solution)	');			
insert into fixpartname (oldv,tiss,newv) values ('	blood (dry)	',	1	,'	blood (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	blood (EDTA)	',	1	,'	blood (EDTA)	');			
insert into fixpartname (oldv,tiss,newv) values ('	blood (ethanol-fixed)	',	1	,'	blood (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	blood (flash-frozen)	',	1	,'	blood (flash-frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	blood (frozen)	',	1	,'	blood (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	blood (Queen Lysis buffer)	',	1	,'	blood (Queen Lysis buffer)	');			
insert into fixpartname (oldv,tiss,newv) values ('	blood (RNAlater)	',	1	,'	blood (RNAlater)	');			
insert into fixpartname (oldv,tiss,newv) values ('	blood (slide smear)	',	1	,'	blood (slide smear)	');			
insert into fixpartname (oldv,tiss,newv) values ('	slide blood	',	1	,'	blood (slide smear)	');			
insert into fixpartname (oldv,tiss,newv) values ('	blood plasma (frozen)	',	1	,'	blood plasma (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	blood plasma (other)	',	1	,'	blood plasma (unknown)	');			
insert into fixpartname (oldv,tiss,newv) values ('	blood serum (frozen)	',	1	,'	blood serum (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	blood serum, muscle (frozen)	',	1	,'	blood serum, muscle (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	blubber	',	1	,'	blubber (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	blubber (frozen)	',	1	,'	blubber (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	body (cleared and stained)	',	0	,'	body (cleared and stained)	');			
insert into fixpartname (oldv,tiss,newv) values ('	body (95% ETOH)	',	1	,'	body (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	body (ethanol)	',	0	,'	body (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	body (formalin-fixed, 70% ETOH)	',	0	,'	body (formalin-fixed, 70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	body (frozen)	',	0	,'	body (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	body (mummified)	',	0	,'	body (mummified)	');			
insert into fixpartname (oldv,tiss,newv) values ('	body mount	',	0	,'	body mount	');			
insert into fixpartname (oldv,tiss,newv) values ('	body mount (dry)	',	0	,'	body mount	');			
insert into fixpartname (oldv,tiss,newv) values ('	body parts	',	0	,'	body parts	');			
insert into fixpartname (oldv,tiss,newv) values ('	body parts (cleared and stained)	',	0	,'	body parts (cleared and stained)	');			
insert into fixpartname (oldv,tiss,newv) values ('	body parts (dry)	',	0	,'	body parts (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	body parts (ethanol)	',	0	,'	body parts (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	body skin	',	0	,'	body skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	bone marrow (frozen)	',	1	,'	bone marrow (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	marrow (frozen)	',	1	,'	bone marrow (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	brain	',	1	,'	brain	');			
insert into fixpartname (oldv,tiss,newv) values ('	brain (70% ETOH)	',	1	,'	brain (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	brain (frozen)	',	1	,'	brain (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	brain (other)	',	1	,'	brain (unknown)	');			
insert into fixpartname (oldv,tiss,newv) values ('	broken cranium	',	0	,'	broken cranium	');			
insert into fixpartname (oldv,tiss,newv) values ('	damaged cranium	',	0	,'	broken cranium	');			
insert into fixpartname (oldv,tiss,newv) values ('	broken exoskeleton	',	0	,'	broken exoskeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	broken skull (dry)	',	0	,'	broken skull	');			
insert into fixpartname (oldv,tiss,newv) values ('	damaged skull (dry)	',	0	,'	broken skull	');			
insert into fixpartname (oldv,tiss,newv) values ('	broken thoracic vertebra	',	0	,'	broken thoracic vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	broken vertebra	',	0	,'	broken vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	brood patch (ethanol)	',	0	,'	brood patch (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	brown fat (frozen)	',	0	,'	brown fat (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	bulla	',	0	,'	bulla	');			
insert into fixpartname (oldv,tiss,newv) values ('	calcaneum	',	0	,'	calcaneum	');			
insert into fixpartname (oldv,tiss,newv) values ('	complete calcaneum	',	0	,'	calcaneum	');			
insert into fixpartname (oldv,tiss,newv) values ('	cape	',	0	,'	cape	');			
insert into fixpartname (oldv,tiss,newv) values ('	cape (dry)	',	0	,'	cape	');			
insert into fixpartname (oldv,tiss,newv) values ('	carapace	',	0	,'	carapace	');			
insert into fixpartname (oldv,tiss,newv) values ('	carapace (dried)	',	0	,'	carapace	');			
insert into fixpartname (oldv,tiss,newv) values ('	carapace (slide)	',	0	,'	carapace (slide)	');			
insert into fixpartname (oldv,tiss,newv) values ('	carcass (95% EtOH)	',	0	,'	carcass (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	carcass (alcohol)	',	0	,'	carcass (alcohol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	carcass (dried)	',	0	,'	carcass (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	carcass (dry)	',	0	,'	carcass (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	carcass (ethanol-fixed)	',	0	,'	carcass (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	carcass (ethanol)	',	0	,'	carcass (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	carcass (formalin-fixed, 70% ETOH)	',	0	,'	carcass (formalin-fixed, 70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	carcass (formalin)	',	0	,'	carcass (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	carcass (frozen)	',	1	,'	carcass (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	carcass (isopropanol, formalin-fixed)	',	0	,'	carcass (isopropanol, formalin-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	carcass (mummified)	',	0	,'	carcass (mummified)	');			
insert into fixpartname (oldv,tiss,newv) values ('	carpal	',	0	,'	carpal	');			
insert into fixpartname (oldv,tiss,newv) values ('	cast	',	0	,'	cast	');			
insert into fixpartname (oldv,tiss,newv) values ('	caudal centrum	',	0	,'	caudal centrum	');			
insert into fixpartname (oldv,tiss,newv) values ('	caudal vertebra	',	0	,'	caudal vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	caudal vertebra	',	0	,'	caudal vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	centrum	',	0	,'	centrum	');			
insert into fixpartname (oldv,tiss,newv) values ('	3rd cervical vertebra	',	0	,'	cervical vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	4th cervical vertebra	',	0	,'	cervical vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	5th cervical vertebra	',	0	,'	cervical vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	6th cervical vertebra	',	0	,'	cervical vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	7th cervical vertebra	',	0	,'	cervical vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	cervical vertebra	',	0	,'	cervical vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	cervical vertebra	',	0	,'	cervical vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	cervical vertebra (dry)	',	0	,'	cervical vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	cestode	',	0	,'	cestode(s)	');			
insert into fixpartname (oldv,tiss,newv) values ('	cestode (70% ETOH)	',	0	,'	cestode(s) (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	cestode (70% EtOH)	',	0	,'	cestode(s) (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	cestode (95% ETOH)	',	0	,'	cestode(s) (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	cestode (alcohol)	',	0	,'	cestode(s) (alcohol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	cestode (ethanol-fixed)	',	0	,'	cestode(s) (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	cestode (ethanol)	',	0	,'	cestode(s) (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	cestode (EtOH/Glycerin)	',	0	,'	cestode(s) (ethanol/glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	cestode (formalin-fixed, 70% ETOH)	',	0	,'	cestode(s) (formalin-fixed, 70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	cestode (formalin)	',	0	,'	cestode(s) (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	cestode (frozen)	',	0	,'	cestode(s) (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	cestode (other)	',	0	,'	cestode(s) (unknown)	');			
insert into fixpartname (oldv,tiss,newv) values ('	claw	',	0	,'	claw	');			
insert into fixpartname (oldv,tiss,newv) values ('	claws	',	0	,'	claw	');			
insert into fixpartname (oldv,tiss,newv) values ('	cranium	',	0	,'	cranium	');			
insert into fixpartname (oldv,tiss,newv) values ('	cranium (dry)	',	0	,'	cranium	');			
insert into fixpartname (oldv,tiss,newv) values ('	crop	',	0	,'	crop	');			
insert into fixpartname (oldv,tiss,newv) values ('	crop (70% ETOH)	',	0	,'	crop (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	crop (95% ETOH)	',	0	,'	crop (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	crop (ethanol)	',	0	,'	crop (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	crop (frozen)	',	0	,'	crop (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	damaged skin	',	0	,'	damaged skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	damaged skull	',	0	,'	damaged skull	');			
insert into fixpartname (oldv,tiss,newv) values ('	dentary	',	0	,'	dentary	');			
insert into fixpartname (oldv,tiss,newv) values ('	dentary (frozen)	',	0	,'	dentary	');			
insert into fixpartname (oldv,tiss,newv) values ('	diaphragm	',	0	,'	diaphragm	');			
insert into fixpartname (oldv,tiss,newv) values ('	diaphragm (frozen)	',	0	,'	diaphragm (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	dissected carcass (ethanol)	',	0	,'	dissected carcass (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	dissected whole animal (ethanol)	',	0	,'	dissected whole animal (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	dissected whole organism	',	0	,'	dissected whole organism	');			
insert into fixpartname (oldv,tiss,newv) values ('	dissected whole organism (alcohol)	',	0	,'	dissected whole organism (alcohol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	dissected whole organism (ethanol, formalin-fixed)	',	0	,'	dissected whole organism (ethanol, formalin-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	dissected whole organism (ethanol)	',	0	,'	dissected whole organism (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	dissected whole organism (formalin)	',	0	,'	dissected whole organism (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	DNA	',	1	,'	DNA	');			
insert into fixpartname (oldv,tiss,newv) values ('	DNA (dry)	',	1	,'	DNA (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	DNA (frozen)	',	1	,'	DNA (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	dorsal centrum	',	0	,'	dorsal centrum	');			
insert into fixpartname (oldv,tiss,newv) values ('	dorsal rib	',	0	,'	dorsal rib	');			
insert into fixpartname (oldv,tiss,newv) values ('	dorsal vertebra	',	0	,'	dorsal vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	ear bones	',	0	,'	ear bones	');			
insert into fixpartname (oldv,tiss,newv) values ('	ear clip	',	1	,'	ear clip	');			
insert into fixpartname (oldv,tiss,newv) values ('	ear clip (70% ETOH)	',	1	,'	ear clip (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ear clip (95% ETOH)	',	1	,'	ear clip (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ear clip (Alsever's solution)	',	1	,'	ear clip (Alsever's solution)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ear clip (dry)	',	1	,'	ear clip (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ear clip (EDTA)	',	1	,'	ear clip (EDTA)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ear clip (frozen)	',	1	,'	ear clip (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ectoparasite	',	0	,'	ectoparasite(s)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ectoparasite(s)	',	0	,'	ectoparasite(s)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ectoparasite (70% ETOH)	',	0	,'	ectoparasite(s) (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ectoparasite(s) (70% EtOH)	',	0	,'	ectoparasite(s) (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ectoparasite(s) (70% ETOH)	',	0	,'	ectoparasite(s) (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ectoparasite (95% ETOH)	',	0	,'	ectoparasite(s) (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ectoparasite(s) (95% ETOH)	',	0	,'	ectoparasite(s) (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ectoparasite(s) (dry)	',	0	,'	ectoparasite(s) (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ectoparasite (ethanol)	',	0	,'	ectoparasite(s) (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ectoparasite(s) (ethanol)	',	0	,'	ectoparasite(s) (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ectoparasite (EtOH/Glycerin)	',	0	,'	ectoparasite(s) (ethanol/glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ectoparasite(s) (EtOH/Glycerin)	',	0	,'	ectoparasite(s) (ethanol/glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ectoparasite(s) (formalin-fixed, 70% ETOH)	',	0	,'	ectoparasite(s) (formalin-fixed, 70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ectoparasite (frozen)	',	0	,'	ectoparasite(s) (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ectoparasite(s) (frozen)	',	0	,'	ectoparasite(s) (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ectoparasite(s) (K2Cr2O7)	',	0	,'	ectoparasite(s) (K2Cr2O7)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ectoparasite (other)	',	0	,'	ectoparasite(s) (unknown)	');			
insert into fixpartname (oldv,tiss,newv) values ('	egg	',	0	,'	egg	');			
insert into fixpartname (oldv,tiss,newv) values ('	egg (70% ETOH)	',	0	,'	egg (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	egg (95% ETOH)	',	0	,'	egg (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	egg (ethanol)	',	0	,'	egg (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	egg (formalin)	',	0	,'	egg (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	egg (other)	',	0	,'	egg (unknown)	');			
insert into fixpartname (oldv,tiss,newv) values ('	egg case	',	0	,'	egg case	');			
insert into fixpartname (oldv,tiss,newv) values ('	egg contents (frozen)	',	0	,'	egg contents (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	egg shell (dry)	',	0	,'	egg shell (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	embryo	',	0	,'	embryo	');			
insert into fixpartname (oldv,tiss,newv) values ('	embryos (70% ETOH)	',	0	,'	embryo (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	embryo (95% EtOH)	',	0	,'	embryo (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	embryo (95% ETOH)	',	0	,'	embryo (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	embryos (95% ETOH)	',	0	,'	embryo (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	embryo (alcohol)	',	0	,'	embryo (alcohol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	embryo (cleared and stained)	',	0	,'	embryo (cleared and stained)	');			
insert into fixpartname (oldv,tiss,newv) values ('	embryo (dry)	',	0	,'	embryo (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	embryo (ethanol-fixed)	',	0	,'	embryo (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	embryo (ethanol)	',	0	,'	embryo (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	embryos (ethanol)	',	0	,'	embryo (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	embryo (EtOH/Glycerin)	',	0	,'	embryo (ethanol/glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	embryo (formalin-fixed, 70% ETOH)	',	0	,'	embryo (formalin-fixed, 70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	embryos (formalin-fixed, 70% ETOH)	',	0	,'	embryo (formalin-fixed, 70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	embryo (formalin)	',	0	,'	embryo (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	embryo (frozen)	',	0	,'	embryo (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	embryos (frozen)	',	0	,'	embryo (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole embryo (frozen)	',	0	,'	embryo (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	embryo (isopropanol, formalin-fixed)	',	0	,'	embryo (isopropanol, formalin-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	endoparasite	',	0	,'	endoparasite(s)	');			
insert into fixpartname (oldv,tiss,newv) values ('	endoparasite(s)	',	0	,'	endoparasite(s)	');			
insert into fixpartname (oldv,tiss,newv) values ('	endoparasite (70% ETOH)	',	0	,'	endoparasite(s) (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	endoparasite(s) (70% ETOH)	',	0	,'	endoparasite(s) (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	endoparasite (95% ETOH)	',	0	,'	endoparasite(s) (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	endoparasite(s) (95% ETOH)	',	0	,'	endoparasite(s) (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	endoparasite(s) (alcohol)	',	0	,'	endoparasite(s) (alcohol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	endoparasite(s) (ethanol-fixed)	',	0	,'	endoparasite(s) (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	endoparasite (ethanol)	',	0	,'	endoparasite(s) (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	endoparasite(s) (ethanol)	',	0	,'	endoparasite(s) (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	endoparasite (EtOH/Glycerin)	',	0	,'	endoparasite(s) (ethanol/glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	endoparasite(s) (EtOH/Glycerin)	',	0	,'	endoparasite(s) (ethanol/glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	endoparasite(s) (formalin)	',	0	,'	endoparasite(s) (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	endoparasite (frozen)	',	0	,'	endoparasite(s) (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	endoparasite(s) (frozen)	',	0	,'	endoparasite(s) (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	endoparasite (other)	',	0	,'	endoparasite(s) (unknown)	');			
insert into fixpartname (oldv,tiss,newv) values ('	endoparasite(s) (other)	',	0	,'	endoparasite(s) (unknown)	');			
insert into fixpartname (oldv,tiss,newv) values ('	epidermal sloughing (slide)	',	0	,'	epidermal sloughing (slide)	');			
insert into fixpartname (oldv,tiss,newv) values ('	exoccipital	',	0	,'	exoccipital	');			
insert into fixpartname (oldv,tiss,newv) values ('	exoskeleton	',	0	,'	exoskeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	slide exoskeleton	',	0	,'	exoskeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	eye	',	0	,'	eye	');			
insert into fixpartname (oldv,tiss,newv) values ('	eye (70% ETOH)	',	0	,'	eye (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	eye (ethanol)	',	0	,'	eye (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	eye (formalin)	',	0	,'	eye (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	eye (frozen)	',	0	,'	eye (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	fat (frozen)	',	0	,'	fat (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	feather	',	0	,'	feather	');			
insert into fixpartname (oldv,tiss,newv) values ('	feather (dried)	',	0	,'	feather	');			
insert into fixpartname (oldv,tiss,newv) values ('	feather (dry)	',	0	,'	feather (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	feather (frozen)	',	0	,'	feather (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	coccidia	',	0	,'	feces	');			
insert into fixpartname (oldv,tiss,newv) values ('	feces	',	0	,'	feces	');			
insert into fixpartname (oldv,tiss,newv) values ('	coccidia (95% ETOH)	',	0	,'	feces (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	feces (dry)	',	0	,'	feces (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	feces (ethanol)	',	0	,'	feces (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	feces (formalin)	',	0	,'	feces (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	coccidia (frozen)	',	0	,'	feces (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	feces (frozen)	',	0	,'	feces (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	coccidia (K2Cr2O7)	',	0	,'	feces (K2Cr2O7)	');			
insert into fixpartname (oldv,tiss,newv) values ('	feces (K2Cr2O7)	',	0	,'	feces (K2Cr2O7)	');			
insert into fixpartname (oldv,tiss,newv) values ('	feces (RNAlater)	',	0	,'	feces (RNAlater)	');			
insert into fixpartname (oldv,tiss,newv) values ('	femur	',	0	,'	femur	');			
insert into fixpartname (oldv,tiss,newv) values ('	femur (frozen)	',	0	,'	femur (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	fetus (cleared and stained)	',	0	,'	fetus (cleared and stained)	');			
insert into fixpartname (oldv,tiss,newv) values ('	fetus (ethanol)	',	0	,'	fetus (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	fetus (frozen)	',	0	,'	fetus (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	fetus (isopropanol, formalin-fixed)	',	0	,'	fetus (isopropanol, formalin-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	fibula	',	0	,'	fibula	');			
insert into fixpartname (oldv,tiss,newv) values ('	fin (alcohol)	',	0	,'	fin (alcohol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	flat metacarpal	',	0	,'	flat metacarpal	');			
insert into fixpartname (oldv,tiss,newv) values ('	flat rib	',	0	,'	flat rib	');			
insert into fixpartname (oldv,tiss,newv) values ('	flat skin	',	0	,'	flat skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	flat skin (dry)	',	0	,'	flat skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	flat skin (ethanol)	',	0	,'	flat skin (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	flat wing (dry)	',	0	,'	flat wing (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	complete foot	',	0	,'	foot	');			
insert into fixpartname (oldv,tiss,newv) values ('	foot	',	0	,'	foot	');			
insert into fixpartname (oldv,tiss,newv) values ('	foot (dried)	',	0	,'	foot (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	foot (dry)	',	0	,'	foot (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	forelimb	',	0	,'	forelimb	');			
insert into fixpartname (oldv,tiss,newv) values ('	forelimb (dry)	',	0	,'	forelimb (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	front foot foot	',	0	,'	front foot foot	');			
insert into fixpartname (oldv,tiss,newv) values ('	frontal bone	',	0	,'	frontal bone	');			
insert into fixpartname (oldv,tiss,newv) values ('	gastrointestinal tract	',	0	,'	gastrointestinal tract	');			
insert into fixpartname (oldv,tiss,newv) values ('	gastrointestinal tract (70% ETOH)	',	0	,'	gastrointestinal tract (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	gastrointestinal tract (ethanol-fixed)	',	0	,'	gastrointestinal tract (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	gastrointestinal tract (ethanol)	',	0	,'	gastrointestinal tract (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	gastrointestinal tract (frozen)	',	0	,'	gastrointestinal tract (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	glans penis	',	0	,'	glans penis	');			
insert into fixpartname (oldv,tiss,newv) values ('	glans penis (70% ETOH)	',	0	,'	glans penis (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	glans penis (95% ETOH)	',	0	,'	glans penis (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	glans penis (cleared and stained)	',	0	,'	glans penis (cleared and stained)	');			
insert into fixpartname (oldv,tiss,newv) values ('	glans penis (dried)	',	0	,'	glans penis (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	glans penis (ethanol)	',	0	,'	glans penis (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	glans penis (formalin-fixed, 70% ETOH)	',	0	,'	glans penis (formalin-fixed, 70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	glans penis (formalin)	',	0	,'	glans penis (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	glans penis (glycerin)	',	0	,'	glans penis (glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	gonad (70% ETOH)	',	0	,'	gonad (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	gonad (ethanol-fixed)	',	0	,'	gonad (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	gonad (ethanol)	',	0	,'	gonad (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	gonad (formalin)	',	0	,'	gonad (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	gonad (frozen)	',	0	,'	gonad (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	gonads (frozen)	',	0	,'	gonad (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	gonad (slide)	',	0	,'	gonad (slide)	');			
insert into fixpartname (oldv,tiss,newv) values ('	hair	',	0	,'	hair	');			
insert into fixpartname (oldv,tiss,newv) values ('	hair (dry)	',	0	,'	hair	');			
insert into fixpartname (oldv,tiss,newv) values ('	hair (frozen)	',	0	,'	hair (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	hard palate	',	0	,'	hard palate	');			
insert into fixpartname (oldv,tiss,newv) values ('	head	',	0	,'	head	');			
insert into fixpartname (oldv,tiss,newv) values ('	head (ethanol)	',	0	,'	head (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	head mount	',	0	,'	head mount	');			
insert into fixpartname (oldv,tiss,newv) values ('	headless carcass (ethanol)	',	0	,'	headless carcass (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart	',	1	,'	heart	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart (DMSO/EDTA)	',	0	,'	heart (DMSO/EDTA)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart (dry)	',	1	,'	heart (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart (ethanol)	',	1	,'	heart (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart (freeze-dried)	',	1	,'	heart (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart (frozen)	',	1	,'	heart (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney	',	1	,'	heart, kidney	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney (dry)	',	1	,'	heart, kidney (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney (ethanol)	',	1	,'	heart, kidney (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney (frozen)	',	1	,'	heart, kidney (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, liver	',	1	,'	heart, kidney, liver	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, liver (frozen)	',	1	,'	heart, kidney, liver (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, liver, lung, spleen	',	1	,'	heart, kidney, liver, lung, spleen	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, liver, lung, spleen (95% ETOH)	',	1	,'	heart, kidney, liver, lung, spleen (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, liver, lung, spleen (alcohol)	',	1	,'	heart, kidney, liver, lung, spleen (alcohol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, liver, lung, spleen (dry)	',	1	,'	heart, kidney, liver, lung, spleen (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, liver, lung, spleen (ethanol)	',	1	,'	heart, kidney, liver, lung, spleen (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, liver, lung, spleen (frozen)	',	1	,'	heart, kidney, liver, lung, spleen (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, liver, spleen	',	1	,'	heart, kidney, liver, spleen	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, liver, spleen (frozen)	',	1	,'	heart, kidney, liver, spleen (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, lung	',	1	,'	heart, kidney, lung	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, lung (95% ETOH)	',	1	,'	heart, kidney, lung (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, lung (95% EtOH)	',	1	,'	heart, kidney, lung (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, lung (ethanol-fixed)	',	1	,'	heart, kidney, lung (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, lung (ethanol)	',	1	,'	heart, kidney, lung (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, lung (EtOH/Glycerin)	',	1	,'	heart, kidney, lung (ethanol/glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, lung (frozen)	',	1	,'	heart, kidney, lung (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, lung, spleen	',	1	,'	heart, kidney, lung, spleen	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, lung, spleen (95% EtOH)	',	1	,'	heart, kidney, lung, spleen (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, lung, spleen (95% ETOH)	',	1	,'	heart, kidney, lung, spleen (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, lung, spleen (dry)	',	1	,'	heart, kidney, lung, spleen (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, lung, spleen (ethanol-fixed)	',	1	,'	heart, kidney, lung, spleen (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, lung, spleen (ethanol)	',	1	,'	heart, kidney, lung, spleen (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, lung, spleen (frozen)	',	1	,'	heart, kidney, lung, spleen (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, lung, spleen (RNAlater)	',	1	,'	heart, kidney, lung, spleen (RNAlater)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, spleen	',	1	,'	heart, kidney, spleen	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, spleen (dry)	',	1	,'	heart, kidney, spleen (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, spleen (ethanol)	',	1	,'	heart, kidney, spleen (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, kidney, spleen (frozen)	',	1	,'	heart, kidney, spleen (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, liver	',	1	,'	heart, liver	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, liver (frozen)	',	1	,'	heart, liver (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, liver, muscle (alcohol)	',	1	,'	heart, liver, muscle (alcohol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, liver, muscle	',	1	,'	heart, liver, muscle (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, liver, muscle (frozen)	',	1	,'	heart, liver, muscle (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, lung	',	1	,'	heart, lung	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, lung (ethanol-fixed)	',	1	,'	heart, lung (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, lung (ethanol)	',	1	,'	heart, lung (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, lung (frozen)	',	1	,'	heart, lung (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, lung, spleen	',	1	,'	heart, lung, spleen	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, lung, spleen (frozen)	',	1	,'	heart, lung, spleen (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	heart, muscle (frozen)	',	1	,'	heart, muscle (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	hind foot	',	0	,'	hind foot	');			
insert into fixpartname (oldv,tiss,newv) values ('	hind podials	',	0	,'	hind podials	');			
insert into fixpartname (oldv,tiss,newv) values ('	hind podials (dry)	',	0	,'	hind podials	');			
insert into fixpartname (oldv,tiss,newv) values ('	hindgut content (70% ETOH)	',	0	,'	hindgut content (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	hindgut content (ethanol)	',	0	,'	hindgut content (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	hindlimb	',	0	,'	hindlimb	');			
insert into fixpartname (oldv,tiss,newv) values ('	hindlimb (dry)	',	0	,'	hindlimb (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	hindlimb (frozen)	',	0	,'	hindlimb (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	hindquarters (latex vascular injection)	',	0	,'	hindquarters (latex vascular injection)	');			
insert into fixpartname (oldv,tiss,newv) values ('	horn	',	0	,'	horn	');			
insert into fixpartname (oldv,tiss,newv) values ('	horn (dry)	',	0	,'	horn	');			
insert into fixpartname (oldv,tiss,newv) values ('	humerus	',	0	,'	humerus	');			
insert into fixpartname (oldv,tiss,newv) values ('	hyoid	',	0	,'	hyoid	');			
insert into fixpartname (oldv,tiss,newv) values ('	hyoid (frozen)	',	0	,'	hyoid (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	innominate	',	0	,'	innominate	');			
insert into fixpartname (oldv,tiss,newv) values ('	interparietal bone	',	0	,'	interparietal	');			
insert into fixpartname (oldv,tiss,newv) values ('	intestine	',	0	,'	intestine	');			
insert into fixpartname (oldv,tiss,newv) values ('	intestine (ethanol-fixed)	',	0	,'	intestine (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	intestine (ethanol)	',	0	,'	intestine (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	intestine (EtOH/Glycerin)	',	0	,'	intestine (ethanol/glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	intestine (formalin)	',	0	,'	intestine (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	intestine (frozen)	',	0	,'	intestine (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	intestine (K2Cr2O7)	',	0	,'	intestine (K2Cr2O7)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ischium	',	0	,'	ischium	');			
insert into fixpartname (oldv,tiss,newv) values ('	jugal	',	0	,'	jugal	');			
insert into fixpartname (oldv,tiss,newv) values ('	karyotype	',	0	,'	karyotype	');			
insert into fixpartname (oldv,tiss,newv) values ('	karyotype (frozen)	',	0	,'	karyotype (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	kidney	',	1	,'	kidney	');			
insert into fixpartname (oldv,tiss,newv) values ('	kidney (DMSO/EDTA)	',	1	,'	kidney (DMSO/EDTA)	');			
insert into fixpartname (oldv,tiss,newv) values ('	kidney (ethanol)	',	1	,'	kidney (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	kidney (frozen)	',	1	,'	kidney (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	left kidney (frozen)	',	1	,'	kidney (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	right kidney (frozen)	',	1	,'	kidney (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	kidney, liver (frozen)	',	1	,'	kidney, liver (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	kidney, liver, spleen (frozen)	',	1	,'	kidney, liver, spleen (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	kidney, muscle (frozen)	',	1	,'	kidney, muscle (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	leaf	',	0	,'	leaf	');			
insert into fixpartname (oldv,tiss,newv) values ('	left antler (dry)	',	0	,'	left antler	');			
insert into fixpartname (oldv,tiss,newv) values ('	left dentary	',	0	,'	left dentary	');			
insert into fixpartname (oldv,tiss,newv) values ('	left femur	',	0	,'	left femur	');			
insert into fixpartname (oldv,tiss,newv) values ('	left fibula	',	0	,'	left fibula	');			
insert into fixpartname (oldv,tiss,newv) values ('	left forelimb	',	0	,'	left forelimb	');			
insert into fixpartname (oldv,tiss,newv) values ('	left horn	',	0	,'	left horn	');			
insert into fixpartname (oldv,tiss,newv) values ('	left humerus	',	0	,'	left humerus	');			
insert into fixpartname (oldv,tiss,newv) values ('	left innominate	',	0	,'	left innominate	');			
insert into fixpartname (oldv,tiss,newv) values ('	left jugal	',	0	,'	left jugal	');			
insert into fixpartname (oldv,tiss,newv) values ('	left lacrimal	',	0	,'	left lacrimal	');			
insert into fixpartname (oldv,tiss,newv) values ('	left mandible	',	0	,'	left mandible	');			
insert into fixpartname (oldv,tiss,newv) values ('	left maxilla	',	0	,'	left maxilla	');			
insert into fixpartname (oldv,tiss,newv) values ('	left metatarsal	',	0	,'	left metatarsal	');			
insert into fixpartname (oldv,tiss,newv) values ('	left radius	',	0	,'	left radius	');			
insert into fixpartname (oldv,tiss,newv) values ('	left scapula	',	0	,'	left scapula	');			
insert into fixpartname (oldv,tiss,newv) values ('	left tibia	',	0	,'	left tibia	');			
insert into fixpartname (oldv,tiss,newv) values ('	left vibrissa	',	0	,'	left vibrissa	');			
insert into fixpartname (oldv,tiss,newv) values ('	left wing	',	0	,'	left wing	');			
insert into fixpartname (oldv,tiss,newv) values ('	left wing (dry)	',	0	,'	left wing (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	left zygomatic arch	',	0	,'	left zygomatic arch	');			
insert into fixpartname (oldv,tiss,newv) values ('	leg (95% ETOH)	',	0	,'	leg (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	leg bones	',	0	,'	leg bones	');			
insert into fixpartname (oldv,tiss,newv) values ('	leg bones (dry)	',	0	,'	leg bones	');			
insert into fixpartname (oldv,tiss,newv) values ('	leg bones (frozen)	',	0	,'	leg bones (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	liver	',	1	,'	liver	');			
insert into fixpartname (oldv,tiss,newv) values ('	liver (70% EtOH)	',	1	,'	liver (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	liver (95% EtOH)	',	1	,'	liver (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	liver (95% ETOH)	',	1	,'	liver (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	liver (DMSO)	',	1	,'	liver (DMSO)	');			
insert into fixpartname (oldv,tiss,newv) values ('	liver (DMSO/EDTA)	',	1	,'	liver (DMSO/EDTA)	');			
insert into fixpartname (oldv,tiss,newv) values ('	liver (dry)	',	1	,'	liver (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	liver (ethanol-fixed)	',	1	,'	liver (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	liver (ethanol)	',	1	,'	liver (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	liver (formalin)	',	1	,'	liver (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	liver (frozen)	',	1	,'	liver (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	liver (isopropanol, formalin-fixed)	',	1	,'	liver (isopropanol, formalin-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	liver (RNAlater)	',	1	,'	liver (RNAlater)	');			
insert into fixpartname (oldv,tiss,newv) values ('	liver, muscle (frozen)	',	1	,'	liver, muscle (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	complete lumbar vertebra	',	0	,'	lumbar vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	lumbar vertebra	',	0	,'	lumbar vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	lumbar vertebra	',	0	,'	lumbar vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	lung	',	1	,'	lung	');			
insert into fixpartname (oldv,tiss,newv) values ('	lung (dry)	',	1	,'	lung (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	lung (ethanol)	',	1	,'	lung (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	lung (formalin)	',	1	,'	lung (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	lung (frozen)	',	1	,'	lung (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	lung (isopropanol, formalin-fixed)	',	1	,'	lung (isopropanol, formalin-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	lymph node(s) (ethanol)	',	0	,'	lymph node(s) (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	lymph node(s) (frozen)	',	0	,'	lymph node(s) (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	mammary tissue	',	0	,'	mammary tissue	');			
insert into fixpartname (oldv,tiss,newv) values ('	mammary tissue (frozen)	',	0	,'	mammary tissue (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	mandible	',	0	,'	mandible	');			
insert into fixpartname (oldv,tiss,newv) values ('	mandible (dry)	',	0	,'	mandible	');			
insert into fixpartname (oldv,tiss,newv) values ('	maxilla	',	0	,'	maxilla	');			
insert into fixpartname (oldv,tiss,newv) values ('	maxilla (ethanol)	',	0	,'	maxilla (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	metacarpal	',	0	,'	metacarpal	');			
insert into fixpartname (oldv,tiss,newv) values ('	metapodial	',	0	,'	metapodial	');			
insert into fixpartname (oldv,tiss,newv) values ('	metatarsal	',	0	,'	metatarsal	');			
insert into fixpartname (oldv,tiss,newv) values ('	molar tooth	',	0	,'	molar tooth	');			
insert into fixpartname (oldv,tiss,newv) values ('	mounted postcranial skeleton	',	0	,'	mounted postcranial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	mounted skeleton	',	0	,'	mounted skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	mounted skin	',	0	,'	mounted skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	mounted skull	',	0	,'	mounted skull	');			
insert into fixpartname (oldv,tiss,newv) values ('	muscle	',	1	,'	muscle	');			
insert into fixpartname (oldv,tiss,newv) values ('	muscle (95% EtOH)	',	1	,'	muscle (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	muscle (95% ETOH)	',	1	,'	muscle (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	muscle (DMSO)	',	1	,'	muscle (DMSO)	');			
insert into fixpartname (oldv,tiss,newv) values ('	muscle (DMSO/EDTA)	',	1	,'	muscle (DMSO/EDTA)	');			
insert into fixpartname (oldv,tiss,newv) values ('	muscle (dried)	',	1	,'	muscle (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	muscle (dry)	',	1	,'	muscle (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	muscle (ethanol-fixed)	',	1	,'	muscle (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	muscle (ethanol)	',	1	,'	muscle (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	muscle (frozen)	',	1	,'	muscle (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	muscle, eye (frozen)	',	1	,'	muscle, eye (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	muscle, spleen	',	1	,'	muscle, spleen	');			
insert into fixpartname (oldv,tiss,newv) values ('	muscle, spleen (frozen)	',	1	,'	muscle, spleen (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	nematode	',	0	,'	nematode(s)	');			
insert into fixpartname (oldv,tiss,newv) values ('	nematode(s)	',	0	,'	nematode(s)	');			
insert into fixpartname (oldv,tiss,newv) values ('	nematode (70% ETOH)	',	0	,'	nematode(s) (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	nematode (70% EtOH)	',	0	,'	nematode(s) (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	nematode(s) (70% ETOH)	',	0	,'	nematode(s) (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	nematode (alcohol)	',	0	,'	nematode(s) (alcohol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	nematode(s) (alcohol)	',	0	,'	nematode(s) (alcohol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	nematode(s) (ethanol-fixed)	',	0	,'	nematode(s) (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	nematode (ethanol)	',	0	,'	nematode(s) (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	nematode(s) (ethanol)	',	0	,'	nematode(s) (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	nematode (EtOH/Glycerin)	',	0	,'	nematode(s) (ethanol/glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	nematode(s) (EtOH/Glycerin)	',	0	,'	nematode(s) (ethanol/glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	nematode (formalin)	',	0	,'	nematode(s) (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	nematode(s) (formalin)	',	0	,'	nematode(s) (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	nematode (frozen)	',	0	,'	nematode(s) (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	nematode(s) (frozen)	',	0	,'	nematode(s) (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	nematode (other)	',	0	,'	nematode(s) (unknown)	');			
insert into fixpartname (oldv,tiss,newv) values ('	nematode(s) (other)	',	0	,'	nematode(s) (unknown)	');			
insert into fixpartname (oldv,tiss,newv) values ('	nest	',	0	,'	nest	');			
insert into fixpartname (oldv,tiss,newv) values ('	nest (pinned)	',	0	,'	nest (pinned)	');			
insert into fixpartname (oldv,tiss,newv) values ('	neural arch	',	0	,'	neural arch	');			
insert into fixpartname (oldv,tiss,newv) values ('	observation	',	0	,'	observation	');			
insert into fixpartname (oldv,tiss,newv) values ('	oral swab	',	0	,'	oral swab	');			
insert into fixpartname (oldv,tiss,newv) values ('	oral swab (formalin)	',	0	,'	oral swab (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	oral swab (frozen)	',	0	,'	oral swab (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	os clitoris	',	0	,'	os clitoris	');			
insert into fixpartname (oldv,tiss,newv) values ('	os clitoris (glycerin)	',	0	,'	os clitoris (glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ovary	',	0	,'	ovary	');			
insert into fixpartname (oldv,tiss,newv) values ('	ovaries (70% ETOH)	',	0	,'	ovary (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ovary (formalin)	',	0	,'	ovary (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ovary (frozen)	',	0	,'	ovary (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	parasitic eggs	',	0	,'	parasitic eggs	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment antler	',	0	,'	partial antler	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial antler	',	0	,'	partial antler	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of astragulus	',	0	,'	partial astragalus	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial astragalus	',	0	,'	partial astragalus	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial axial skeleton	',	0	,'	partial axial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete baleen plate	',	0	,'	partial baleen plate	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment basioccipital	',	0	,'	partial basioccipital	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete body (ethanol)	',	0	,'	partial body (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete body (frozen)	',	0	,'	partial body (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial calcaneum	',	0	,'	partial calcaneum	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete carapace	',	0	,'	partial carapace	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete carcass (ethanol)	',	0	,'	partial carcass (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete carcass (frozen)	',	0	,'	partial carcass (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment carpal	',	0	,'	partial carpal	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment caudal vertebra	',	0	,'	partial caudal vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment centrum	',	0	,'	partial centrum	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of centrum	',	0	,'	partial centrum	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial centrum	',	0	,'	partial centrum	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete cervical vertebra	',	0	,'	partial cervical vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial cervical vertebra	',	0	,'	partial cervical vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment cranium	',	0	,'	partial cranium	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial cranium	',	0	,'	partial cranium	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment dentary	',	0	,'	partial dentary	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of dentary	',	0	,'	partial dentary	');			
insert into fixpartname (oldv,tiss,newv) values ('	molar dentary	',	0	,'	partial dentary	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial dentary	',	0	,'	partial dentary	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete embryo	',	0	,'	partial embryo	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete embryo (ethanol)	',	0	,'	partial embryo (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment exoccipital	',	0	,'	partial exoccipital	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of exoskeleton	',	0	,'	partial exoskeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete exoskeleton	',	0	,'	partial exoskeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment femur	',	0	,'	partial femur	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment fibula	',	0	,'	partial fibula	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of fibula	',	0	,'	partial fibula	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial fibula	',	0	,'	partial fibula	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete foot (95% ETOH)	',	0	,'	partial foot (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial forelimb	',	0	,'	partial forelimb	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete hindlimb	',	0	,'	partial hindlimb	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial horn	',	0	,'	partial horn	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment humerus	',	0	,'	partial humerus	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial humerus	',	0	,'	partial humerus	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete hyoid	',	0	,'	partial hyoid	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment innominate	',	0	,'	partial innominate	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial innominate	',	0	,'	partial innominate	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial ischium	',	0	,'	partial ischium	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment jugal	',	0	,'	partial jugal	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of jugal	',	0	,'	partial jugal	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial jugal	',	0	,'	partial jugal	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial lumbar vertebra	',	0	,'	partial lumbar vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete mandible	',	0	,'	partial mandible	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial mandible	',	0	,'	partial mandible	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial mandible (dry)	',	0	,'	partial mandible (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial manus 	',	0	,'	partial manus 	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete maxilla	',	0	,'	partial maxilla	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial maxilla	',	0	,'	partial maxilla	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial metacarpal	',	0	,'	partial metacarpal	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of metatarsal	',	0	,'	partial metatarsal	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial metatarsal	',	0	,'	partial metatarsal	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment neural arch	',	0	,'	partial neural arch	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of neural arch	',	0	,'	partial neural arch	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial neural arch	',	0	,'	partial neural arch	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete occipital condyle	',	0	,'	partial occipital condyle	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete pectoral girdle	',	0	,'	partial pectoral girdle	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete pelvis	',	0	,'	partial pelvis	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial pes	',	0	,'	partial pes	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment phalanx	',	0	,'	partial phalanx	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial phalanx	',	0	,'	partial phalanx	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial post-cranial postcranial skeleton (dry)	',	0	,'	partial postcranial postcranial skeleton (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete postcranial skeleton	',	0	,'	partial postcranial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete postcranial skeleton (dry)	',	0	,'	partial postcranial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete postcranium	',	0	,'	partial postcranial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial post-cranial postcranial skeleton	',	0	,'	partial postcranial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial post-cranial skeleton	',	0	,'	partial postcranial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial post-cranial skeleton (dry)	',	0	,'	partial postcranial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial postcranial skeleton	',	0	,'	partial postcranial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial post-cranial skeleton (dried)	',	0	,'	partial postcranial skeleton (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial postcranial skeleton (dry)	',	0	,'	partial postcranial skeleton (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of postcranium	',	0	,'	partial postcranium	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of pubis	',	0	,'	partial pubis	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete radius	',	0	,'	partial radius	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete reproductive tract	',	0	,'	partial reproductive tract	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete reproductive tract (ethanol)	',	0	,'	partial reproductive tract (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment rib	',	0	,'	partial rib	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of rib	',	0	,'	partial rib	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial rib	',	0	,'	partial rib	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment scapula	',	0	,'	partial scapula	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of scapula	',	0	,'	partial scapula	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial scapula	',	0	,'	partial scapula	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of skeleton (dry)	',	0	,'	partial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete skeleton	',	0	,'	partial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial skeleton	',	0	,'	partial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial skeleton (dry)	',	0	,'	partial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial skeleton (dried)	',	0	,'	partial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of skin	',	0	,'	partial skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete skin	',	0	,'	partial skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete skin (dry)	',	0	,'	partial skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial skin	',	0	,'	partial skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial skin (dried)	',	0	,'	partial skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial skin (dry)	',	0	,'	partial skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial skin (tanned)	',	0	,'	partial skin (tanned)	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment skull	',	0	,'	partial skull	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of skull	',	0	,'	partial skull	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of skull (dry)	',	0	,'	partial skull	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete skull	',	0	,'	partial skull	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete skull (dry)	',	0	,'	partial skull	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial skull	',	0	,'	partial skull	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete skull (95% ETOH)	',	0	,'	partial skull (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial skull (dry)	',	0	,'	partial skull	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment tree trunk	',	0	,'	partial stem	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete stem	',	0	,'	partial stem	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete tail	',	0	,'	partial tail	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial tail	',	0	,'	partial tail	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete tail (ethanol)	',	0	,'	partial tail (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial tarsal	',	0	,'	partial tarsal	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment thoracic vertebra	',	0	,'	partial thoracic vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial thoracic vertebra	',	0	,'	partial thoracic vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment tibia	',	0	,'	partial tibia	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of tibia	',	0	,'	partial tibia	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment tooth	',	0	,'	partial tooth	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of tooth	',	0	,'	partial tooth	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial tooth	',	0	,'	partial tooth	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment ulna	',	0	,'	partial ulna	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete ulna	',	0	,'	partial ulna	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial ulna	',	0	,'	partial ulna	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment vertebra	',	0	,'	partial vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of vertebra	',	0	,'	partial vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete vertebra	',	0	,'	partial vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial vertebra	',	0	,'	partial vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of whole organism (dry)	',	0	,'	partial whole organism (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	incomplete whole organism (ethanol-fixed)	',	0	,'	partial whole organism (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment zygapophysis	',	0	,'	partial zygapophysis	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial zygapophysis	',	0	,'	partial zygapophysis	');			
insert into fixpartname (oldv,tiss,newv) values ('	pectoral girdle	',	0	,'	pectoral girdle	');			
insert into fixpartname (oldv,tiss,newv) values ('	pelvis	',	0	,'	pelvis	');			
insert into fixpartname (oldv,tiss,newv) values ('	pelvis (dry)	',	0	,'	pelvis	');			
insert into fixpartname (oldv,tiss,newv) values ('	pelvis (frozen)	',	0	,'	pelvis (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	penis (ethanol)	',	0	,'	penis (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	penis (formalin)	',	0	,'	penis (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	penis (glycerin)	',	0	,'	penis (glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	periosteum (frozen)	',	0	,'	periosteum (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	pes	',	0	,'	pes	');			
insert into fixpartname (oldv,tiss,newv) values ('	phalanx	',	0	,'	phalanx	');			
insert into fixpartname (oldv,tiss,newv) values ('	phallus	',	0	,'	phallus	');			
insert into fixpartname (oldv,tiss,newv) values ('	phallus (70% ETOH)	',	0	,'	phallus (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	phallus (95% ETOH)	',	0	,'	phallus (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	phallus (ethanol)	',	0	,'	phallus (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	phallus (formalin-fixed, 70% ETOH)	',	0	,'	phallus (formalin-fixed, 70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	phallus (formalin)	',	0	,'	phallus (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	photograph	',	0	,'	photograph	');			
insert into fixpartname (oldv,tiss,newv) values ('	photograph (other)	',	0	,'	photograph	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism photograph	',	0	,'	photograph	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism photograph (slide)	',	0	,'	photograph	');			
insert into fixpartname (oldv,tiss,newv) values ('	placenta (frozen)	',	0	,'	placenta (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	plastron	',	0	,'	plastron	');			
insert into fixpartname (oldv,tiss,newv) values ('	podials	',	0	,'	podials	');			
insert into fixpartname (oldv,tiss,newv) values ('	podials (frozen)	',	0	,'	podials (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	postcranial postcranial skeleton	',	0	,'	postcranial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	postcranial postcranial skeleton (dry)	',	0	,'	postcranial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	complete post-cranial skeleton	',	0	,'	postcranial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	complete post-cranial skeleton (dry)	',	0	,'	postcranial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	complete postcranial skeleton	',	0	,'	postcranial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	postcranial skeleton	',	0	,'	postcranial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	postcranial skeleton (dry)	',	0	,'	postcranial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	postcranial skeleton (dry)	',	0	,'	postcranial skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	complete post-cranial skeleton (70% ETOH)	',	0	,'	postcranial skeleton (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	postcranial skeleton (DMSO)	',	0	,'	postcranial skeleton (DMSO)	');			
insert into fixpartname (oldv,tiss,newv) values ('	postcranial skeleton (ethanol, formalin-fixed)	',	0	,'	postcranial skeleton (ethanol, formalin-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	postcranial skeleton (ethanol)	',	0	,'	postcranial skeleton (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	postcranial skeleton (EtOH/Glycerin)	',	0	,'	postcranial skeleton (ethanol/glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	postcranial skeleton (frozen)	',	0	,'	postcranial skeleton (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	postcranial skeleton (glycerin)	',	0	,'	postcranial skeleton (glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	complete post-cranial whole organism (ethanol, formalin-fixed)	',	0	,'	postcranial whole organism (ethanol, formalin-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skull-less whole organism (ethanol, formalin-fixed)	',	0	,'	postcranial whole organism (ethanol, formalin-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	complete post-cranial whole organism (ethanol)	',	0	,'	postcranial whole organism (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	postcranial whole organism (ethanol)	',	0	,'	postcranial whole organism (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	postcranial whole organism (formalin)	',	0	,'	postcranial whole organism (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	postcranium	',	0	,'	postcranium	');			
insert into fixpartname (oldv,tiss,newv) values ('	Power skin	',	0	,'	Power skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	premaxilla	',	0	,'	premaxilla	');			
insert into fixpartname (oldv,tiss,newv) values ('	print: woodblock	',	0	,'	print: woodblock	');			
insert into fixpartname (oldv,tiss,newv) values ('	pubis	',	0	,'	pubis	');			
insert into fixpartname (oldv,tiss,newv) values ('	quadrate	',	0	,'	quadrate	');			
insert into fixpartname (oldv,tiss,newv) values ('	radius	',	0	,'	radius	');			
insert into fixpartname (oldv,tiss,newv) values ('	reproductive tract (70% ETOH)	',	0	,'	reproductive tract (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	reproductive tract (ethanol-fixed)	',	0	,'	reproductive tract (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	reproductive tract (ethanol, formalin-fixed)	',	0	,'	reproductive tract (ethanol, formalin-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	reproductive tract (ethanol)	',	0	,'	reproductive tract (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	reproductive tract (formalin-fixed, 70% ETOH)	',	0	,'	reproductive tract (formalin-fixed, 70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	reproductive tract (formalin)	',	0	,'	reproductive tract (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	reproductive tract (frozen)	',	0	,'	reproductive tract (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	rib	',	0	,'	rib	');			
insert into fixpartname (oldv,tiss,newv) values ('	rib (dry)	',	0	,'	rib	');			
insert into fixpartname (oldv,tiss,newv) values ('	rib (frozen)	',	0	,'	rib (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	right calcaneum	',	0	,'	right calcaneum	');			
insert into fixpartname (oldv,tiss,newv) values ('	right dentary	',	0	,'	right dentary	');			
insert into fixpartname (oldv,tiss,newv) values ('	right femur	',	0	,'	right femur	');			
insert into fixpartname (oldv,tiss,newv) values ('	right foot	',	0	,'	right foot	');			
insert into fixpartname (oldv,tiss,newv) values ('	right forelimb	',	0	,'	right forelimb	');			
insert into fixpartname (oldv,tiss,newv) values ('	right horn	',	0	,'	right horn	');			
insert into fixpartname (oldv,tiss,newv) values ('	right humerus	',	0	,'	right humerus	');			
insert into fixpartname (oldv,tiss,newv) values ('	right innominate	',	0	,'	right innominate	');			
insert into fixpartname (oldv,tiss,newv) values ('	right kidney (latex vascular injection)	',	1	,'	right kidney (latex vascular injection)	');			
insert into fixpartname (oldv,tiss,newv) values ('	right mandible	',	0	,'	right mandible	');			
insert into fixpartname (oldv,tiss,newv) values ('	right maxilla	',	0	,'	right maxilla	');			
insert into fixpartname (oldv,tiss,newv) values ('	right metatarsal	',	0	,'	right metatarsal	');			
insert into fixpartname (oldv,tiss,newv) values ('	right radius	',	0	,'	right radius	');			
insert into fixpartname (oldv,tiss,newv) values ('	right scapula	',	0	,'	right scapula	');			
insert into fixpartname (oldv,tiss,newv) values ('	right tibia	',	0	,'	right tibia	');			
insert into fixpartname (oldv,tiss,newv) values ('	right ulna	',	0	,'	right ulna	');			
insert into fixpartname (oldv,tiss,newv) values ('	right vibrissa	',	0	,'	right vibrissa	');			
insert into fixpartname (oldv,tiss,newv) values ('	right wing	',	0	,'	right wing	');			
insert into fixpartname (oldv,tiss,newv) values ('	right wing (dry)	',	0	,'	right wing (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	rostrum	',	0	,'	rostrum	');			
insert into fixpartname (oldv,tiss,newv) values ('	sacrum	',	0	,'	sacrum	');			
insert into fixpartname (oldv,tiss,newv) values ('	saliva	',	0	,'	saliva	');			
insert into fixpartname (oldv,tiss,newv) values ('	scapula	',	0	,'	scapula	');			
insert into fixpartname (oldv,tiss,newv) values ('	scapula (dry)	',	0	,'	scapula	');			
insert into fixpartname (oldv,tiss,newv) values ('	sectioned carapace	',	0	,'	sectioned carapace	');			
insert into fixpartname (oldv,tiss,newv) values ('	sectioned femur	',	0	,'	sectioned femur	');			
insert into fixpartname (oldv,tiss,newv) values ('	sectioned humerus	',	0	,'	sectioned humerus	');			
insert into fixpartname (oldv,tiss,newv) values ('	sectioned testis (other)	',	0	,'	sectioned testis	');			
insert into fixpartname (oldv,tiss,newv) values ('	sectioned testis (slide)	',	0	,'	sectioned testis (slide)	');			
insert into fixpartname (oldv,tiss,newv) values ('	sectioned tooth	',	0	,'	sectioned tooth	');			
insert into fixpartname (oldv,tiss,newv) values ('	sectioned tooth (EtOH/Glycerin)	',	0	,'	sectioned tooth (ethanol/glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	sectioned tooth (slide)	',	0	,'	sectioned tooth (slide)	');			
insert into fixpartname (oldv,tiss,newv) values ('	SEM stub	',	0	,'	SEM stub	');			
insert into fixpartname (oldv,tiss,newv) values ('	SEM stub (ethanol)	',	0	,'	SEM stub (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	serum (dry)	',	0	,'	serum (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	serum (frozen)	',	0	,'	serum (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	shed skin (95% ETOH)	',	0	,'	shed skin (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	shed skin (dried)	',	0	,'	shed skin (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	complete skeleton	',	0	,'	skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	skeleton	',	0	,'	skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	skeleton (dried)	',	0	,'	skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	skeleton (dry)	',	0	,'	skeleton	');			
insert into fixpartname (oldv,tiss,newv) values ('	skeleton (cleared and stained)	',	0	,'	skeleton (cleared and stained)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skeleton (ethanol)	',	0	,'	skeleton (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	pelt skin	',	0	,'	skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	pelt skin (dry)	',	0	,'	skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	skin	',	0	,'	skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	skin (dried)	',	0	,'	skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	skin (dry)	',	0	,'	skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	skin (other)	',	0	,'	skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	skin (alcohol)	',	0	,'	skin (alcohol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skin (DMSO)	',	0	,'	skin (DMSO)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skin (ethanol-fixed)	',	0	,'	skin (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skin (ethanol)	',	0	,'	skin (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skin (EtOH/Glycerin)	',	0	,'	skin (ethanol/glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skin (frozen)	',	0	,'	skin (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skin (tanned)	',	0	,'	skin (tanned)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skin clip	',	0	,'	skin clip	');			
insert into fixpartname (oldv,tiss,newv) values ('	skin clip (95% ETOH)	',	0	,'	skin clip (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skin clip (dry)	',	0	,'	skin clip (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skin clip (frozen)	',	0	,'	skin clip (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skinned body (ethanol)	',	0	,'	skinned body (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skinned carcass (ethanol)	',	0	,'	skinned carcass (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skinned karyotype (dry)	',	0	,'	skinned karyotype (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skinned whole organism (ethanol)	',	0	,'	skinned whole organism (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	complete skull	',	0	,'	skull	');			
insert into fixpartname (oldv,tiss,newv) values ('	skull	',	0	,'	skull	');			
insert into fixpartname (oldv,tiss,newv) values ('	skull (dry)	',	0	,'	skull	');			
insert into fixpartname (oldv,tiss,newv) values ('	skull (alcohol)	',	0	,'	skull (alcohol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skull (cleared and stained)	',	0	,'	skull (cleared and stained)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skull (dried)	',	0	,'	skull (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skull (ethanol)	',	0	,'	skull (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skull (EtOH/Glycerin)	',	0	,'	skull (ethanol/glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skull (formalin)	',	0	,'	skull (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skull (frozen)	',	0	,'	skull (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skull (phosphate buffer)	',	0	,'	skull (phosphate buffer)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skull-less whole organism (ethanol)	',	0	,'	skull-less whole organism (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	slide karyotype	',	0	,'	slide karyotype	');			
insert into fixpartname (oldv,tiss,newv) values ('	slide karyotype (dry)	',	0	,'	slide karyotype (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	spines	',	0	,'	spines	');			
insert into fixpartname (oldv,tiss,newv) values ('	spines (frozen)	',	0	,'	spines (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	spleen	',	1	,'	spleen	');			
insert into fixpartname (oldv,tiss,newv) values ('	spleen (95% EtOH)	',	1	,'	spleen (95% EtOH)	');			
insert into fixpartname (oldv,tiss,newv) values ('	spleen (Alsever's solution)	',	1	,'	spleen (Alsever's solution)	');			
insert into fixpartname (oldv,tiss,newv) values ('	spleen (DMSO/EDTA)	',	1	,'	spleen (DMSO/EDTA)	');			
insert into fixpartname (oldv,tiss,newv) values ('	spleen (dry)	',	1	,'	spleen (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	spleen (ethanol)	',	1	,'	spleen (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	spleen (formalin)	',	1	,'	spleen (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	spleen (frozen)	',	1	,'	spleen (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	spleen (slide smear)	',	1	,'	spleen (slide smear)	');			
insert into fixpartname (oldv,tiss,newv) values ('	spleen, lung	',	1	,'	spleen, lung	');			
insert into fixpartname (oldv,tiss,newv) values ('	spleen, lung (frozen)	',	1	,'	spleen, lung (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	spread skeleton (dried)	',	0	,'	spread skeleton (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	spread tail	',	0	,'	spread tail	');			
insert into fixpartname (oldv,tiss,newv) values ('	spread wing	',	0	,'	spread wing	');			
insert into fixpartname (oldv,tiss,newv) values ('	spread wing (dried)	',	0	,'	spread wing (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	spread wing (dry)	',	0	,'	spread wing (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	squamosal	',	0	,'	squamosal	');			
insert into fixpartname (oldv,tiss,newv) values ('	stem	',	0	,'	stem	');			
insert into fixpartname (oldv,tiss,newv) values ('	tree trunk	',	0	,'	stem	');			
insert into fixpartname (oldv,tiss,newv) values ('	sternum	',	0	,'	sternum	');			
insert into fixpartname (oldv,tiss,newv) values ('	stomach	',	0	,'	stomach	');			
insert into fixpartname (oldv,tiss,newv) values ('	stomach (70% ETOH)	',	0	,'	stomach (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	stomach (95% ETOH)	',	0	,'	stomach (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	stomach (ethanol)	',	0	,'	stomach (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	stomach (formalin)	',	0	,'	stomach (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	stomach (frozen)	',	0	,'	stomach (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	stomach content	',	0	,'	stomach content	');			
insert into fixpartname (oldv,tiss,newv) values ('	stomach content (70% ETOH)	',	0	,'	stomach content (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	stomach content (95% ETOH)	',	0	,'	stomach content (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	stomach content (bouins fluid)	',	0	,'	stomach content (bouins fluid)	');			
insert into fixpartname (oldv,tiss,newv) values ('	stomach content (dried)	',	0	,'	stomach content (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	stomach content (ethanol-fixed)	',	0	,'	stomach content (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	stomach content (ethanol)	',	0	,'	stomach content (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	stomach content (frozen)	',	0	,'	stomach content (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	study skin	',	0	,'	study skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	study skin (dry)	',	0	,'	study skin	');			
insert into fixpartname (oldv,tiss,newv) values ('	study skin (formalin-fixed, 70% ETOH)	',	0	,'	study skin (formalin-fixed, 70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	supraoccipital	',	0	,'	supraoccipital	');			
insert into fixpartname (oldv,tiss,newv) values ('	syrinx (70% ETOH)	',	0	,'	syrinx (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	syrinx (cleared and stained)	',	0	,'	syrinx (cleared and stained)	');			
insert into fixpartname (oldv,tiss,newv) values ('	syrinx (dried)	',	0	,'	syrinx (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	syrinx (ethanol)	',	0	,'	syrinx (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	syrinx (frozen)	',	0	,'	syrinx (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tail	',	0	,'	tail	');			
insert into fixpartname (oldv,tiss,newv) values ('	tail (95% ETOH)	',	0	,'	tail (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tail (dried)	',	0	,'	tail (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tail (dry)	',	0	,'	tail (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tail (ethanol-fixed)	',	0	,'	tail (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tail (ethanol)	',	0	,'	tail (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tail (frozen)	',	0	,'	tail (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tail tip (70% ETOH)	',	0	,'	tail tip (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tail tip (95% ETOH)	',	0	,'	tail tip (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tail tip (ethanol)	',	0	,'	tail tip (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tail tip (frozen)	',	0	,'	tail tip (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	complete tarsal	',	0	,'	tarsal	');			
insert into fixpartname (oldv,tiss,newv) values ('	tarsal	',	0	,'	tarsal	');			
insert into fixpartname (oldv,tiss,newv) values ('	temporal	',	0	,'	temporal	');			
insert into fixpartname (oldv,tiss,newv) values ('	testis	',	0	,'	testis	');			
insert into fixpartname (oldv,tiss,newv) values ('	testis (70% ETOH)	',	0	,'	testis (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	testis (ethanol-fixed)	',	0	,'	testis (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	testis (ethanol)	',	0	,'	testis (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	testes (formalin-fixed, 70% ETOH)	',	0	,'	testis (formalin-fixed, 70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	testis (formalin)	',	0	,'	testis (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	testis (frozen)	',	0	,'	testis (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	10th thoracic vertebra	',	0	,'	thoracic vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	11th thoracic vertebra	',	0	,'	thoracic vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	6th thoracic vertebra	',	0	,'	thoracic vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	7th thoracic vertebra	',	0	,'	thoracic vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	8th thoracic vertebra	',	0	,'	thoracic vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	9th thoracic vertebra	',	0	,'	thoracic vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	thoracic vertebra	',	0	,'	thoracic vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	thoracic vertebra	',	0	,'	thoracic vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	tibia	',	0	,'	tibia	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissue	',	1	,'	tissue	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissues	',	1	,'	tissue	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissues only	',	1	,'	tissue	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissue (70% ETOH)	',	1	,'	tissue (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissue (95% ETOH)	',	1	,'	tissue (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissues (95% ETOH)	',	1	,'	tissue (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissues (Alsever's solution)	',	1	,'	tissue (Alsever's solution)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissue (DMSO/EDTA)	',	1	,'	tissue (DMSO/EDTA)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissue (dried)	',	1	,'	tissue (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissue (dry)	',	1	,'	tissue (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissues (ethanol-fixed)	',	1	,'	tissue (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissue (ethanol)	',	1	,'	tissue (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissues (ethanol)	',	1	,'	tissue (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissue (flash-frozen)	',	1	,'	tissue (flash-frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissue (formalin)	',	1	,'	tissue (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissue (freeze-dried)	',	1	,'	tissue (freeze-dried)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissue (frozen)	',	1	,'	tissue (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissues (frozen)	',	1	,'	tissue (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissues only (frozen)	',	1	,'	tissue (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissue (RNAlater)	',	1	,'	tissue (RNAlater)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tissue extract (frozen)	',	1	,'	tissue extract (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	toe (95% ETOH)	',	0	,'	toe (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	toe (DMSO/EDTA)	',	0	,'	toe (DMSO/EDTA)	');			
insert into fixpartname (oldv,tiss,newv) values ('	toe (frozen)	',	0	,'	toe (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	toe clip (frozen)	',	0	,'	toe clip (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tongue (70% ETOH)	',	0	,'	tongue (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tongue (ethanol)	',	0	,'	tongue (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tongue and trachea (70% ETOH)	',	0	,'	tongue and trachea (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tongue, trachea, and syrinx	',	0	,'	tongue, trachea, and syrinx	');			
insert into fixpartname (oldv,tiss,newv) values ('	tongue, trachea, and syrinx (70% ETOH)	',	0	,'	tongue, trachea, and syrinx (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tongue, trachea, and syrinx (ethanol)	',	0	,'	tongue, trachea, and syrinx (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	complete tooth	',	0	,'	tooth	');			
insert into fixpartname (oldv,tiss,newv) values ('	tooth	',	0	,'	tooth	');			
insert into fixpartname (oldv,tiss,newv) values ('	tooth (dry)	',	0	,'	tooth	');			
insert into fixpartname (oldv,tiss,newv) values ('	tooth (ethanol)	',	0	,'	tooth (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tooth (frozen)	',	0	,'	tooth (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	slide tooth	',	0	,'	tooth (slide mounted)	');			
insert into fixpartname (oldv,tiss,newv) values ('	tooth (slide mounted)	',	0	,'	tooth (slide mounted)	');			
insert into fixpartname (oldv,tiss,newv) values ('	trace fossil	',	0	,'	trace fossil	');			
insert into fixpartname (oldv,tiss,newv) values ('	track	',	0	,'	trace fossil	');			
insert into fixpartname (oldv,tiss,newv) values ('	transverse process	',	0	,'	transverse process	');			
insert into fixpartname (oldv,tiss,newv) values ('	trematode(s)	',	0	,'	trematode(s)	');			
insert into fixpartname (oldv,tiss,newv) values ('	trematode(s) (70% ETOH)	',	0	,'	trematode(s) (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	trematode(s) (ethanol)	',	0	,'	trematode(s) (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	trematode(s) (formalin)	',	0	,'	trematode(s) (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	trematode(s) (frozen)	',	0	,'	trematode(s) (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ulna	',	0	,'	ulna	');			
insert into fixpartname (oldv,tiss,newv) values ('	umbilical cord (frozen)	',	0	,'	umbilical cord (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	ungual	',	0	,'	ungual	');			
insert into fixpartname (oldv,tiss,newv) values ('	flat unidentified	',	0	,'	unknown	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment unidentified	',	0	,'	unknown	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragment unknown	',	0	,'	unknown	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of unidentified	',	0	,'	unknown	');			
insert into fixpartname (oldv,tiss,newv) values ('	fragments of unknown	',	0	,'	unknown	');			
insert into fixpartname (oldv,tiss,newv) values ('	not recorded	',	0	,'	unknown	');			
insert into fixpartname (oldv,tiss,newv) values ('	other	',	0	,'	unknown	');			
insert into fixpartname (oldv,tiss,newv) values ('	other (other)	',	0	,'	unknown	');			
insert into fixpartname (oldv,tiss,newv) values ('	partial unknown	',	0	,'	unknown	');			
insert into fixpartname (oldv,tiss,newv) values ('	unidentified	',	0	,'	unknown	');			
insert into fixpartname (oldv,tiss,newv) values ('	unknown	',	0	,'	unknown	');			
insert into fixpartname (oldv,tiss,newv) values ('	other (70% ETOH)	',	0	,'	unknown (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	unknown (70% ETOH)	',	0	,'	unknown (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	unknown (70% EtOH)	',	0	,'	unknown (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	unknown (alcohol)	',	0	,'	unknown (alcohol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	other (dried)	',	0	,'	unknown (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	other (dry)	',	0	,'	unknown (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	unknown (dry)	',	0	,'	unknown (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	other (ethanol)	',	0	,'	unknown (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	unknown (EtOH/Glycerin)	',	0	,'	unknown (ethanol/glycerin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	other (frozen)	',	0	,'	unknown (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	unknown (frozen)	',	0	,'	unknown (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	unknown (latex vascular injection)	',	0	,'	unknown (latex vascular injection)	');			
insert into fixpartname (oldv,tiss,newv) values ('	upper mandible	',	0	,'	upper mandible	');			
insert into fixpartname (oldv,tiss,newv) values ('	uterus	',	0	,'	uterus	');			
insert into fixpartname (oldv,tiss,newv) values ('	uterus (ethanol)	',	0	,'	uterus (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	uterus (frozen)	',	0	,'	uterus (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	vaginal plug (dried)	',	0	,'	vaginal plug (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	complete vertebra	',	0	,'	vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	vertebra	',	0	,'	vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	vertebra (dry)	',	0	,'	vertebra	');			
insert into fixpartname (oldv,tiss,newv) values ('	vertebral disc	',	0	,'	vertebral disc	');			
insert into fixpartname (oldv,tiss,newv) values ('	vibrissa	',	0	,'	vibrissa	');			
insert into fixpartname (oldv,tiss,newv) values ('	vibrissa (ethanol, formalin-fixed)	',	0	,'	vibrissa (ethanol, formalin-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	vibrissa (frozen)	',	0	,'	vibrissa (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	viscera (ethanol)	',	0	,'	viscera (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	viscera (formalin)	',	0	,'	viscera (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	viscera (frozen)	',	0	,'	viscera (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	skin whole organism	',	0	,'	whole organism	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole animal	',	0	,'	whole organism	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism	',	0	,'	whole organism	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole animal (70% ETOH)	',	0	,'	whole organism (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (70% ethanol)	',	0	,'	whole organism (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (70% ETOH)	',	0	,'	whole organism (70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (95% ethanol)	',	0	,'	whole organism (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (95% ETOH)	',	0	,'	whole organism (95% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (alcohol)	',	0	,'	whole organism (alcohol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (cleared and stained)	',	0	,'	whole organism (cleared and stained)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (dried)	',	0	,'	whole organism (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (dry)	',	0	,'	whole organism (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (envelope)	',	0	,'	whole organism (envelope)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (ethanol-fixed)	',	0	,'	whole organism (ethanol-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole animal (ethanol, formalin-fixed)	',	0	,'	whole organism (ethanol, formalin-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (ethanol, formalin-fixed)	',	0	,'	whole organism (ethanol, formalin-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (ethanol)	',	0	,'	whole organism (ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole animal (formalin-fixed, 70% ETOH)	',	0	,'	whole organism (formalin-fixed, 70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (formalin-fixed, 70% ETOH)	',	0	,'	whole organism (formalin-fixed, 70% ethanol)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (formalin-fixed)	',	0	,'	whole organism (formalin-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (formalin)	',	0	,'	whole organism (formalin)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (freeze-dried)	',	0	,'	whole organism (freeze-dried)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole animal (frozen)	',	0	,'	whole organism (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (frozen)	',	0	,'	whole organism (frozen)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (isopropanol, formalin-fixed)	',	0	,'	whole organism (isopropanol, formalin-fixed)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (isopropyl)	',	0	,'	whole organism (isopropyl)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole animal (mummified)	',	0	,'	whole organism (mummified)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (mummified)	',	0	,'	whole organism (mummified)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism skin (mummified)	',	0	,'	whole organism (mummified)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (pinned)	',	0	,'	whole organism (pinned)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (slide)	',	0	,'	whole organism (slide)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (other)	',	0	,'	whole organism (unknown)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (vial)	',	0	,'	whole organism (vial)	');			
insert into fixpartname (oldv,tiss,newv) values ('	whole organism (wet)	',	0	,'	whole organism (wet)	');			
insert into fixpartname (oldv,tiss,newv) values ('	wing	',	0	,'	wing	');			
insert into fixpartname (oldv,tiss,newv) values ('	wing (dried)	',	0	,'	wing (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	wing (dry)	',	0	,'	wing (dry)	');			
insert into fixpartname (oldv,tiss,newv) values ('	zygapophysis	',	0	,'	zygapophysis	');			
insert into fixpartname (oldv,tiss,newv) values ('	zygomatic arch	',	0	,'	zygomatic arch	');	
 update fixpartname set oldv=trim(oldv),newv=trim(newv);
 ALTER TABLE fixpartname RENAME TO fixpartnameit;
 
 
CREATE TABLE fixpartname AS SELECT oldv,newv FROM fixpartnameit GROUP BY oldv,newv;

-- clean up the parts table
DELETE FROM fixpartname WHERE oldv=newv;


CREATE TABLE bulk_bak AS SELECT * FROM bulkloader;
 
-- the run /fix/bl_partfix.cfm to concatenate the parts in the bulkloader

-- then update the new parts with the lookup table

DECLARE
    s varchar2(4000);
    n VARCHAR2(255);
    o varchar2(255);
BEGIN
    FOR r IN 1..12 LOOP
        FOR u IN (SELECT * FROM fixpartname) LOOP
            n:=REPLACE(u.newv,'''','''''');
            o:=REPLACE(u.oldv,'''','''''');
            
            s:='update bulkloader set part_name_' || r || '= ''' || n || ''' where part_name_' || r || ' = ''' || o || '''';
            --dbms_output.put_line(s);
            EXECUTE IMMEDIATE(s);
        END LOOP;
    END LOOP;            
END;
/


DECLARE
    s varchar2(4000);
    n VARCHAR2(255);
    o varchar2(255);
BEGIN
    FOR r IN 1..12 LOOP
        FOR u IN (SELECT * FROM fixpartname) LOOP
            n:=REPLACE(u.newv,'''','''''');
            o:=REPLACE(u.oldv,'''','''''');
            
            s:='update bulkloader_stage set part_name_' || r || '= ''' || n || ''' where part_name_' || r || ' = ''' || o || '''';
            --dbms_output.put_line(s);
            EXECUTE IMMEDIATE(s);
        END LOOP;
    END LOOP;            
END;
/


-- and specimen part
UPDATE specimen_part SET part_name=(SELECT newv FROM fixpartname WHERE part_name=oldv);
UPDATE ctspecimen_part SET part_name=(SELECT newv FROM fixpartname WHERE part_name=oldv);
UPDATE ctspecimen_part SET is_tissue=(SELECT is_tissue FROM fixpartnameit WHERE part_name=newv);



 drop index UAM.IU_CTSPEC_PART_NAME;



BEGIN
    FOR r IN (SELECT * FROM fixpartname) LOOP
     
        UPDATE specimen_part SET part_name=r.newv WHERE part_name=r.oldv;
    END LOOP;
    END;
    /
    
    
BEGIN
    FOR r IN (SELECT * FROM fixpartname) LOOP
        UPDATE ctspecimen_part_name SET part_name=r.newv WHERE part_name=r.oldv;
    END LOOP;
    END;
    /
    
    
    
   BEGIN
    FOR r IN (SELECT * FROM fixpartnameit) LOOP
     
        UPDATE ctspecimen_part_name SET is_tissue=r.tiss WHERE part_name=r.newv;
    END LOOP;
    END;
    /          


 BEGIN
    FOR r IN (SELECT part_name,collection_cde FROM ctspecimen_part_name HAVING COUNT(*) > 1 GROUP BY part_name,collection_cde) LOOP
         DELETE FROM ctspecimen_part_name WHERE part_name=r.part_name AND 
         collection_cde=r.collection_cde AND 
         CTSPNID NOT IN (SELECT MIN(CTSPNID) FROM ctspecimen_part_name);
    END LOOP;
    END;
    /  

CREATE UNIQUE INDEX iu_ctspec_part_name ON ctspecimen_part_name(part_name,collection_cde);


-- clean up temp tables
ALTER TABLE cf_temp_parts DROP COLUMN part_modifier;
ALTER TABLE cf_temp_parts DROP COLUMN preserve_method;
  

ALTER TABLE cf_temp_part_sample DROP COLUMN exist_part_modifier;
ALTER TABLE cf_temp_part_sample DROP COLUMN exist_preserve_method;
ALTER TABLE cf_temp_part_sample DROP COLUMN sample_modifier;
ALTER TABLE cf_temp_part_sample DROP COLUMN sample_preserve_method;

-- REBUILD /DDL/PACKAGE/bulkload.sql
-- REBUILD procedure/bulkloader_stage_check.sql
-- rebuild functions/bulk_check_one.sql
-- rebuild functions/concatpartsdetail.sql
-- rebuild trigger/uam_triggers/bulkloader.sql
-- REBUILD trigger/uam_triggers/specimen_part.sql


ALTER TABLE specimen_part DROP COLUMN part_modifier;
ALTER TABLE specimen_part DROP COLUMN preserve_method;

ALTER TABLE specimen_part DROP COLUMN is_tissue;

CREATE INDEX ix_ctspecimenpartnameit ON ctspecimen_part_name(is_tissue) TABLESPACE uam_idx_1;


ALTER TABLE bulkloader_stage DROP COLUMN PART_MODIFIER_1;
ALTER TABLE bulkloader_stage DROP COLUMN PART_MODIFIER_2;
ALTER TABLE bulkloader_stage DROP COLUMN PART_MODIFIER_3;
ALTER TABLE bulkloader_stage DROP COLUMN PART_MODIFIER_4;
ALTER TABLE bulkloader_stage DROP COLUMN PART_MODIFIER_5;
ALTER TABLE bulkloader_stage DROP COLUMN PART_MODIFIER_6;
ALTER TABLE bulkloader_stage DROP COLUMN PART_MODIFIER_7;
ALTER TABLE bulkloader_stage DROP COLUMN PART_MODIFIER_8;
ALTER TABLE bulkloader_stage DROP COLUMN PART_MODIFIER_9;
ALTER TABLE bulkloader_stage DROP COLUMN PART_MODIFIER_10;
ALTER TABLE bulkloader_stage DROP COLUMN PART_MODIFIER_11;
ALTER TABLE bulkloader_stage DROP COLUMN PART_MODIFIER_12;
    
    
ALTER TABLE bulkloader_stage DROP COLUMN PRESERV_METHOD_1;
ALTER TABLE bulkloader_stage DROP COLUMN PRESERV_METHOD_2;
ALTER TABLE bulkloader_stage DROP COLUMN PRESERV_METHOD_3;
ALTER TABLE bulkloader_stage DROP COLUMN PRESERV_METHOD_4;
ALTER TABLE bulkloader_stage DROP COLUMN PRESERV_METHOD_5;
ALTER TABLE bulkloader_stage DROP COLUMN PRESERV_METHOD_6;
ALTER TABLE bulkloader_stage DROP COLUMN PRESERV_METHOD_7;
ALTER TABLE bulkloader_stage DROP COLUMN PRESERV_METHOD_8;
ALTER TABLE bulkloader_stage DROP COLUMN PRESERV_METHOD_9;
ALTER TABLE bulkloader_stage DROP COLUMN PRESERV_METHOD_10;
ALTER TABLE bulkloader_stage DROP COLUMN PRESERV_METHOD_11;
ALTER TABLE bulkloader_stage DROP COLUMN PRESERV_METHOD_12;


ALTER TABLE bulkloader DROP COLUMN PART_MODIFIER_1;
ALTER TABLE bulkloader DROP COLUMN PART_MODIFIER_2;
ALTER TABLE bulkloader DROP COLUMN PART_MODIFIER_3;
ALTER TABLE bulkloader DROP COLUMN PART_MODIFIER_4;
ALTER TABLE bulkloader DROP COLUMN PART_MODIFIER_5;
ALTER TABLE bulkloader DROP COLUMN PART_MODIFIER_6;
ALTER TABLE bulkloader DROP COLUMN PART_MODIFIER_7;
ALTER TABLE bulkloader DROP COLUMN PART_MODIFIER_8;
ALTER TABLE bulkloader DROP COLUMN PART_MODIFIER_9;
ALTER TABLE bulkloader DROP COLUMN PART_MODIFIER_10;
ALTER TABLE bulkloader DROP COLUMN PART_MODIFIER_11;
ALTER TABLE bulkloader DROP COLUMN PART_MODIFIER_12;
    
    
ALTER TABLE bulkloader DROP COLUMN PRESERV_METHOD_1;
ALTER TABLE bulkloader DROP COLUMN PRESERV_METHOD_2;
ALTER TABLE bulkloader DROP COLUMN PRESERV_METHOD_3;
ALTER TABLE bulkloader DROP COLUMN PRESERV_METHOD_4;
ALTER TABLE bulkloader DROP COLUMN PRESERV_METHOD_5;
ALTER TABLE bulkloader DROP COLUMN PRESERV_METHOD_6;
ALTER TABLE bulkloader DROP COLUMN PRESERV_METHOD_7;
ALTER TABLE bulkloader DROP COLUMN PRESERV_METHOD_8;
ALTER TABLE bulkloader DROP COLUMN PRESERV_METHOD_9;
ALTER TABLE bulkloader DROP COLUMN PRESERV_METHOD_10;
ALTER TABLE bulkloader DROP COLUMN PRESERV_METHOD_11;
ALTER TABLE bulkloader DROP COLUMN PRESERV_METHOD_12;
<<<<<<< .mine

DELETE FROM ctspecimen_part_name;

INSERT INTO ctspecimen_part_name (part_name,collection_cde,is_tissue)
(SELECT
    part_name,
    collection.collection_cde,
    0
 FROM
     specimen_part,
     cataloged_item,
     collection
 WHERE
     specimen_part.derived_from_cat_item=cataloged_item.collection_object_id AND
     cataloged_item.collection_id=collection.collection_id
  GROUP BY
      part_name,
    collection.collection_cde
 );
 
 
 Elapsed: 00:00:00.03
uam> update bulkloader set part_name_1=null where part_name_1 like ' %'
  2  ;

0 rows updated.

Elapsed: 00:00:00.06
uam> update bulkloader set part_name_2=null where part_name_2 like ' %';

6 rows updated.

Elapsed: 00:00:00.03
uam> update bulkloader set part_name_3=null where part_name_3 like ' %';

6 rows updated.

Elapsed: 00:00:00.03
uam> update bulkloader set part_name_4=null where part_name_4 like ' %';

20 rows updated.

Elapsed: 00:00:00.03
uam> update bulkloader set part_name_5=null where part_name_5 like ' %';

25 rows updated.

Elapsed: 00:00:15.50
uam> update bulkloader set part_name_6=null where part_name_6 like ' %';

10 rows updated.

Elapsed: 00:00:00.34
uam> update bulkloader set part_name_7=null where part_name_7 like ' %';

5 rows updated.

Elapsed: 00:00:00.03
uam> update bulkloader set part_name_8=null where part_name_8 like ' %';

4 rows updated.

Elapsed: 00:00:00.03
uam> update bulkloader set part_name_9=null where part_name_9 like ' %';

0 rows updated.

Elapsed: 00:00:00.03
uam> update bulkloader set part_name_10=null where part_name_10 like ' %';

0 rows updated.

Elapsed: 00:00:00.03
uam> update bulkloader set part_name_11=null where part_name_11 like ' %';

0 rows updated.

Elapsed: 00:00:00.03
uam> update bulkloader set part_name_12=null where part_name_12 like ' %';

0 rows updated.

Elapsed: 00:00:00.03
uam> 
 

SELECT part_name FROM specimen_part WHERE part_name NOT IN (SELECT part_name FROM ctspecimen_part_name);

SELECT part_name FROM ctspecimen_part_name WHERE part_name NOT IN (SELECT part_name FROM specimen_part);

alter trigger SPECIMEN_PART_CT_CHECK enable;


UPDATE flat SET PARTS=concatParts(collection_object_id);


ALTER TRIGGER TR_SPECPART_AIUD_FLAT ENABLE;


REBUILD TR_CTSPECIMEN_PART_NAME_UD




/* 26APR2010 - more cleanup */

DECLARE
    s varchar2(4000);
    n VARCHAR2(255);
    o varchar2(255);
BEGIN
    FOR r IN 1..12 LOOP
        FOR u IN (SELECT * FROM fixpartname) LOOP
            n:=REPLACE(u.newv,'''','''''');
            o:=REPLACE(u.oldv,'''','''''');
            
            s:='update bulkloader_stage set part_name_' || r || '= ''' || n || ''' where part_name_' || r || ' = ''' || o || '''';
            --dbms_output.put_line(s);
            EXECUTE IMMEDIATE(s);
        END LOOP;
    END LOOP;            
END;
/

select part_name_1,part_condition_1 from bulkloader where (part_name_1 like '%partial%' OR part_name_1 LIKE '%broken%' OR part_name_1 LIKE '%damaged%' OR 
  part_name_1 LIKE '%partial%' OR part_name_1 LIKE '%incomplete%' OR part_name_1 LIKE '%fragment%');

DECLARE
    npn VARCHAR2(255);
    npf VARCHAR2(255);
    s varchar2(4000);
BEGIN
    FOR r IN (SELECT DISTINCT part_name FROM ctspecimen_part_name WHERE (
         part_name LIKE '%broken%' OR part_name LIKE '%damaged%' OR part_name LIKE '%partial%' OR
         part_name LIKE '%incomplete%' OR part_name LIKE '%fragment%')) loop
         dbms_output.put_line('-----------------------------------------------------------------------------------------------------');
         npn:=r.part_name;
         npn:=REPLACE(npn,'fragments of ','');
         npn:=REPLACE(npn,'fragment ','');
         npn:=REPLACE(npn,'broken ','');
         npn:=REPLACE(npn,'damaged ','');
         npn:=REPLACE(npn,'partial ','');
         npn:=REPLACE(npn,'incomplete ','');
         npf:=trim(REPLACE(r.part_name,npn,''));
         dbms_output.put_line(r.part_name || chr(9) || chr(9) || '---------->' || chr(9) || '==' || npn || '=========' || npf || '=====');
         for ubc in (select distinct collection.collection_cde from specimen_part,cataloged_item,collection where
         	specimen_part.derived_from_cat_item=cataloged_item.collection_object_id and
         	cataloged_item.collection_id=collection.collection_id and
         	part_name=r.part_name) loop
         	begin
         		dbms_output.put_line('creating ' || npn || ' for ' || ubc.collection_cde);
         		insert into ctspecimen_part_name (collection_cde,part_name) values (ubc.collection_cde,npn);
         	exception when others then
         		dbms_output.put_line('failed at creating ' || npn || ' for ' || ubc.collection_cde);
         	end;
         end loop;
         UPDATE coll_object SET condition=condition || '; ' || npf WHERE collection_object_id IN (SELECT collection_object_id FROM specimen_part WHERE part_name=r.part_name);
         UPDATE specimen_part SET part_name=npn WHERE part_name=r.part_name;
         
         FOR l IN 1..12 LOOP
             s:='update bulkloader set part_name_' || l || '= ''';
             s:=s || npn || ''',part_condition_' || l;
             s:=s || '= part_condition_' || l;
             s:=s|| ' || ' || '''; ' || npf || '''';
             s:=s || ' where part_name_' || l || ' = ''' || r.part_name || '''';
             dbms_output.put_line(s);
             EXECUTE IMMEDIATE(s);         
         	
         	 s:='update bulkloader_stage set part_name_' || l || '= ''';
             s:=s || npn || ''',part_condition_' || l;
             s:=s || '= part_condition_' || l;
             s:=s|| ' || ' || '''; ' || npf || '''';
             s:=s || ' where part_name_' || l || ' = ''' || r.part_name || '''';
             EXECUTE IMMEDIATE(s);         

         END LOOP;
         
         delete FROM ctspecimen_part_name WHERE part_name=r.part_name;
         
    END LOOP;
END;
/
 
    
GRANT DELETE ON specimen_part TO MANAGE_SPECIMENS;
GRANT INSERT ON specimen_part TO MANAGE_SPECIMENS;
GRANT UPDATE ON specimen_part TO MANAGE_SPECIMENS;
GRANT SELECT ON specimen_part TO UAM_QUERY;
GRANT SELECT ON specimen_part TO PUBLIC;