CREATE  or replace FUNCTION getIndividualCount ( collobjid in integer)
return number
as
collcde varchar2(255);
result varchar2(4000);
plc number :=0;
sep varchar2(2):='';
begin
	for r in (
		select
			collection.collection_cde,
			specimen_part.part_name,
			coll_object.lot_count,
			coll_object.coll_obj_disposition
		from
			collection,
			cataloged_item,
			specimen_part,
			coll_object
		where
			collection.collection_id=cataloged_item.collection_id and
			cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and			
			specimen_part.collection_object_id=coll_object.collection_object_id and
			specimen_part.derived_from_cat_item = collobjid
	) loop
	
		if r.collection_cde='Ento' then
			if r.lot_count > plc then
				plc:=r.lot_count;
      		end if;
		elsif r.collection_cde='Fish' then
			if r.coll_obj_disposition  not in ('discarded','used up','deaccessioned','missing','transfer of custody') and r.part_name like '%whole%' then
				plc:=plc+r.lot_count;
			end if;
		else
			plc:=1;
		end if;
	end loop;
	return plc;	
end;
/
sho err;



CREATE or replace PUBLIC SYNONYM getIndividualCount FOR getIndividualCount;
GRANT EXECUTE ON getIndividualCount TO PUBLIC;


--- update flat set individualcount=getIndividualCount(collection_object_id) where collection_cde='Ento';

