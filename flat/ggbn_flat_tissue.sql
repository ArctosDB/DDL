create or replace view digir_query.ggbn_flat_tissue as select
	-- key to Occurrences
	'http://arctos.database.museum/guid/' || filtered_flat.guid || '?seid=' || specimen_event.specimen_event_id OccurrenceID,
	-- the only type of materialSample we have at the moment
	'tissue' materialSampleType,
	specimen_part.part_name preparationType,
	part_coll_object.COLL_OBJECT_ENTERED_DATE preparationDate,
	-- preparationMaterials is 
	--    "Materials and chemicals used in the preparation of the specimen, tissue, DNA or RNA sample"
	-- it should become available as we do more with part attributes
	' ' preparationMaterials,
	-- this isn't quite correct, but I have no better data at the moment
	-- will update with more Attributes as collections begin using them
	getPreferredAgentName(part_coll_object.ENTERED_PERSON_ID) preparationStaff
from
	filtered_flat,
	specimen_event,
	specimen_part,
	ctspecimen_part_name,
	coll_object part_coll_object
where
	filtered_flat.collection_object_id=specimen_part.derived_from_cat_item and	
	specimen_part.part_name=ctspecimen_part_name.part_name and
	ctspecimen_part_name.IS_TISSUE=1 and
	filtered_flat.collection_object_id=specimen_event.collection_object_id and
	specimen_part.collection_object_id=part_coll_object.collection_object_id
;

