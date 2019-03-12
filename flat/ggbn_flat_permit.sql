drop table temp_ggbn_permit;

alter table temp_ggbn_permit rename column OccurrenceID to OccurrenceID2;


create 
--or replace 
--view digir_query.ggbn_flat_permit 
-- table for performance reasons; this is not a viable long-term solution, we need a way to maintain these data
table temp_ggbn_permit as select distinct
	-- each tissue may have multiple permits
	-- each permit may apply to multiple tissues
	-- I don't think these data need a primary key and I have no idea what we'll use if they do
	--
	-- foreign key to tissues
	'http://arctos.database.museum/guid/'  || filtered_flat.guid || '?pid=' || specimen_part.collection_object_id UnitID,
	filtered_flat.collection_id,
	-- key to Occurrences; probably don't need this here but why not...
	-- name OCCURRENCEID2 because reasons
	'http://arctos.database.museum/guid/' || filtered_flat.guid || '?seid=' || specimen_event.specimen_event_id OccurrenceID2,
	-- each permit can have multiple types
	-- doesn't seem right to normalize this further so concat them in
	-- this does NOT include permit_regulation
	getPermitType(permit_trans.permit_id) permitType,
	--- when permit type is 'permit not required' then that
	-- if no permit then Permit not available
	-- if there is a permit then Permit available
	case 
		when getPermitType(permit_trans.permit_id) = 'permit not required' then 
			'Permit not required'
		when getPermitType(permit_trans.permit_id) is null then
    		'Permit not available'
		else 
			'Permit available'
	end permitStatus,
	--- "required" to provide info when permit not required 
	decode (
		getPermitType(permit_trans.permit_id),
		'permit not required','no requirement for permit at date of access',
		' '
	) permitStatusQualifier,
	-- AWG: do not share permit number
	--'Permit Number ' || permit.PERMIT_NUM || ' issued to ' || 
	--	getPermitAgents (permit.permit_id,'issued to') || ' by ' ||
	--	getPermitAgents (permit.permit_id,'issued by')
	'contact collection for information' permitText
from
	filtered_flat,
	specimen_event,
	collecting_event,
	accn,
	permit_trans,
	specimen_part,
	ctspecimen_part_name
where
	filtered_flat.collection_object_id=specimen_part.derived_from_cat_item and	
	specimen_part.part_name=ctspecimen_part_name.part_name and
	ctspecimen_part_name.IS_TISSUE=1 and
	filtered_flat.accn_id=accn.transaction_id and
	accn.transaction_id=permit_trans.transaction_id (+) and
	filtered_flat.collection_object_id=specimen_event.collection_object_id and
	specimen_event.collecting_event_id=collecting_event.collecting_event_id
;


-- and a view for digir_query

grant select on temp_ggbn_permit to digir_query;


create or replace view digir_query.ggbn_flat_permit as select * from uam.temp_ggbn_permit;

