create or replace view digir_query.ggbn_flat_permit as select
	-- key to Occurrences
	'http://arctos.database.museum/guid/' || filtered_flat.guid || '?seid=' || specimen_event.specimen_event_id OccurrenceID,
	-- each permit can have multiple types
	-- doesn't seem right to normalize this further so concat them in
	-- this does NOT include permit_regulation
	getPermitType(permit.permit_id) permitType,
	decode (
		getPermitType(permit.permit_id),
		NULL,'Permit not available',
		'permit not required','Permit not required',
		'Permit available'
	) permitStatus,
	-- don't think we'll ever need this since 'permit not required' is a permit type
	' ' permitStatusQualifier,
	'Permit Number ' || permit.PERMIT_NUM || ' issued to ' || 
		getPermitAgents (permit.permit_id,'issued to') || ' by ' ||
		getPermitAgents (permit.permit_id,'issued by')
		permitText
from
	filtered_flat,
	specimen_event,
	accn,
	permit_trans,
	permit,
	specimen_part,
	ctspecimen_part_name
where
	filtered_flat.collection_object_id=specimen_part.derived_from_cat_item and	
	specimen_part.part_name=ctspecimen_part_name.part_name and
	ctspecimen_part_name.IS_TISSUE=1 and
	filtered_flat.accn_id=accn.transaction_id and
	accn.transaction_id=permit_trans.transaction_id and
	permit_trans.permit_id=permit.permit_id and
	filtered_flat.collection_object_id=specimen_event.collection_object_id
;
