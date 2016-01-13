-- function getNearestPartBarcode 
---- accepts specimen_part.collection_object_id
---- returns
------ barcode of the container holding the part, if fail then
------ barcode of the container holding the part from which the specified part was subsampled, if fail then
------ NULL

CREATE or replace FUNCTION getNearestPartBarcode ( partid in integer)
	return varchar2
	as
		t varchar2(255);
		rslt varchar2(4000);
		sep varchar2(2):='';
	begin
		-- see if there's a barcode on the part-container's parent
		select 
			nvl(parent.barcode,NULL) 
		into 
			rslt 
		from 
			coll_obj_cont_hist, 
			container part, 
			container parent
		where
			coll_obj_cont_hist.container_id=part.container_id and
			part.parent_container_id=parent.container_id and
			coll_obj_cont_hist.collection_object_id=partid;	
		return rslt;
		exception when no_data_found then
			-- see if there's a barcoded parent
			select 
				'[ ' || parent.barcode || ' ]' 
			into 
				rslt 
			from 
				specimen_part thispart,
				specimen_part parentpart,
				coll_obj_cont_hist, 
				container part, 
				container parent
			where
				thispart.SAMPLED_FROM_OBJ_ID=parentpart.collection_object_id and
				parentpart.collection_object_id=coll_obj_cont_hist.collection_object_id and
				coll_obj_cont_hist.container_id=part.container_id and
				part.parent_container_id=parent.container_id and
				thispart.collection_object_id=partid;
		return rslt;
end;
/

sho err;



create or replace public synonym getNearestPartBarcode for getNearestPartBarcode;

grant execute on getNearestPartBarcode to public;




