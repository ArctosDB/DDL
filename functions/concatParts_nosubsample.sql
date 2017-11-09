/*
 
	get parts excluding 
		- subsamples
		- those with various "not here" dispositions
		
	call with  concatParts_nosubsample (cataloged_item.collection_object_id)
	
	
	e.g.
	
	select
		scientific_name,
		concatParts_nosubsample(collection_object_id) AS partsWithoutSubsamples
	from
		flat
	where
		...
  
 
 */
CREATE or replace FUNCTION concatParts_nosubsample ( collobjid in integer)
	return varchar2
as
	t varchar2(255);
	result varchar2(4000);
	sep varchar2(2):='';
begin
	for r in (
		select
			specimen_part.part_name
		from
			specimen_part,
			ctspecimen_part_list_order,
			coll_object
		where
			specimen_part.collection_object_id=coll_object.collection_object_id and
			specimen_part.part_name = ctspecimen_part_list_order.partname (+) and 
			coll_obj_disposition not in (
				'discarded',
				'used up',
				'deaccessioned',
				'missing',
				'transfer of custody'
			) and 
			specimen_part.derived_from_cat_item = collobjid and
			specimen_part.sampled_from_obj_id is null
		ORDER BY 
			list_order DESC
	) loop
		t:=r.part_name;
		result:=result||sep||t;
		sep:='; ';
	end loop;
	return result;
end;
/
sho err;


create public synonym concatParts_nosubsample for concatParts_nosubsample;
grant execute on concatParts_nosubsample to public;