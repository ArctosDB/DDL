CREATE or replace FUNCTION concatPartBarcode ( collobjid in integer)
	return varchar2
	as
		t varchar2(255);
		result varchar2(4000);
		sep varchar2(2):='';
	begin
		for r in (
			select
				theonewewant.barcode
			from
				specimen_part,
				coll_obj_cont_hist,
				container thepart,
				container theonewewant
			where
				specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
				coll_obj_cont_hist.container_id = thepart.container_id and
				thepart.parent_container_id=theonewewant.container_id and
				specimen_part.derived_from_cat_item = collobjid
		) loop
			t:=r.barcode;
			result:=result||sep||t;
			sep:='; ';
		end loop;
	return result;
end;
/

sho err;



create or replace public synonym concatPartBarcode for concatPartBarcode;

grant execute on concatPartBarcode to public;

