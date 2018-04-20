-- see if there are "extras" from bulkloader

CREATE OR REPLACE FUNCTION bulkloaderHasExtraData (cid in number)
return number as
	v_tf number;
	v_uuid varchar2(255);
begin
	select OTHER_ID_NUM_4 into v_uuid from bulkloader where OTHER_ID_NUM_TYPE_4='UUID' and collection_object_id=cid;
	if v_uuid is null then
		return 0;
	end if;
	
	select sum(c) into v_tf from (
		select count(*) c from  cf_temp_specevent  where UUID=v_uuid
		union
		select count(*) c from  cf_temp_parts  where other_id_number=v_uuid
		union
		select count(*) c from  cf_temp_attributes  where other_id_number=v_uuid
		union
		select count(*) c from  cf_temp_oids  where EXISTING_OTHER_ID_NUMBER=v_uuid
		union
		select count(*) c  from  cf_temp_collector  where other_id_number=v_uuid
	);
	
	return v_tf;
end;
/
sho err;
CREATE OR REPLACE PUBLIC SYNONYM bulkloaderHasExtraData FOR bulkloaderHasExtraData;
GRANT EXECUTE ON bulkloaderHasExtraData TO PUBLIC;

