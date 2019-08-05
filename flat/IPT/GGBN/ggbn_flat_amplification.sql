-- https://terms.tdwg.org/wiki/GGBN_Amplification_Vocabulary

-- just including this for BOLD/GenBank
-- these data are not tied to specific tissues in Arctos
-- because we often do not have those data - eg, 
-- sequence appears in GB (because some grad student found an unreturned loan in a freezer, 
-- or because the specimen had not yet been cataloged in Arctos, or ....) all we can do is
-- enter what we have, which is generally specimen+genbank.
-- SO, this is extremely redundant. Perhaps it's better to drop the UnidID and just link this to
-- Occurrences (which are also redundant)????


 
create or replace view digir_query.ggbn_flat_amplification as select
	-- primary key for tissue samples
	-- barcode is not unique in this context - a barcode may contain multiple tissues
	--   so use the only unique (if ephemeral) ID we have available 
	'http://arctos.database.museum/guid/'  || filtered_flat.guid || '?pid=' || specimen_part.collection_object_id UnitID,
	filtered_flat.collection_id,
	-- key to Occurrences; this is a foreign key here
	--OCCURRENCEID2 because reasons
	'http://arctos.database.museum/guid/' || filtered_flat.guid || '?seid=' || specimen_event.specimen_event_id OccurrenceID2,
	BASE_URL || DISPLAY_VALUE geneticAccessionURI,
	DISPLAY_VALUE geneticAccessionNumber
from
	filtered_flat,
	specimen_event,
	specimen_part,
	ctspecimen_part_name,
	coll_obj_other_id_num,
	ctcoll_other_id_type
where
	filtered_flat.collection_object_id=specimen_part.derived_from_cat_item and	
	specimen_part.part_name=ctspecimen_part_name.part_name and
	ctspecimen_part_name.IS_TISSUE=1 and
	filtered_flat.collection_object_id=specimen_event.collection_object_id and
	filtered_flat.collection_object_id=coll_obj_other_id_num.collection_object_id and
	coll_obj_other_id_num.OTHER_ID_TYPE=ctcoll_other_id_type.OTHER_ID_TYPE and
	coll_obj_other_id_num.OTHER_ID_TYPE in ('BoLD barcode ID','GenBank')
;


-- from gabi via tuco:
--Can you add a field BOLDPROCESSID to the amplification view and populate it with the BOLD accession number if the accession number is for BOLD?
-- And for those, include no GENETICACCESSIONURI?

create or replace view digir_query.ggbn_flat_amplification as select * from (
select
	'http://arctos.database.museum/guid/'  || filtered_flat.guid || '?pid=' || specimen_part.collection_object_id UnitID,
	filtered_flat.collection_id,
	-- key to Occurrences; this is a foreign key here
	--OCCURRENCEID2 because reasons
	'http://arctos.database.museum/guid/' || filtered_flat.guid || '?seid=' || specimen_event.specimen_event_id OccurrenceID2,
	BASE_URL || DISPLAY_VALUE geneticAccessionURI,
	DISPLAY_VALUE geneticAccessionNumber,
	'' BOLDPROCESSID
from
	filtered_flat,
	specimen_event,
	specimen_part,
	ctspecimen_part_name,
	coll_obj_other_id_num,
	ctcoll_other_id_type
where
	filtered_flat.collection_object_id=specimen_part.derived_from_cat_item and	
	specimen_part.part_name=ctspecimen_part_name.part_name and
	ctspecimen_part_name.IS_TISSUE=1 and
	filtered_flat.collection_object_id=specimen_event.collection_object_id and
	filtered_flat.collection_object_id=coll_obj_other_id_num.collection_object_id and
	coll_obj_other_id_num.OTHER_ID_TYPE=ctcoll_other_id_type.OTHER_ID_TYPE and
	coll_obj_other_id_num.OTHER_ID_TYPE ='GenBank'
union
select
	'http://arctos.database.museum/guid/'  || filtered_flat.guid || '?pid=' || specimen_part.collection_object_id UnitID,
	filtered_flat.collection_id,
	-- key to Occurrences; this is a foreign key here
	--OCCURRENCEID2 because reasons
	'http://arctos.database.museum/guid/' || filtered_flat.guid || '?seid=' || specimen_event.specimen_event_id OccurrenceID2,
	'' geneticAccessionURI,
	DISPLAY_VALUE geneticAccessionNumber,
	DISPLAY_VALUE BOLDPROCESSID
from
	filtered_flat,
	specimen_event,
	specimen_part,
	ctspecimen_part_name,
	coll_obj_other_id_num,
	ctcoll_other_id_type
where
	filtered_flat.collection_object_id=specimen_part.derived_from_cat_item and	
	specimen_part.part_name=ctspecimen_part_name.part_name and
	ctspecimen_part_name.IS_TISSUE=1 and
	filtered_flat.collection_object_id=specimen_event.collection_object_id and
	filtered_flat.collection_object_id=coll_obj_other_id_num.collection_object_id and
	coll_obj_other_id_num.OTHER_ID_TYPE=ctcoll_other_id_type.OTHER_ID_TYPE and
	coll_obj_other_id_num.OTHER_ID_TYPE ='BoLD barcode ID'
)
;





 select...BASE_URL || DISPLAY_VALUE geneticAccessionURI,
	DISPLAY_VALUE geneticAccessionNumber
from...coll_obj_other_id_num,
	ctcoll_other_id_type
where
	....coll_obj_other_id_num.OTHER_ID_TYPE in ('BoLD barcode ID','GenBank')
;
