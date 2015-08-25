CREATE  or replace FUNCTION getRelatedCache ( collobjid in integer,termtype in varchar2)
return varchar2
as
collcde varchar2(255);
result varchar2(4000);
plc number :=0;
sep varchar2(2):='';
begin
	begin
	    select 
	       max(VALUE) into result 
	       from 
	           cf_relations_cache,
	           coll_obj_other_id_num
	       where 
	           cf_relations_cache.COLL_OBJ_OTHER_ID_NUM_ID = coll_obj_other_id_num.COLL_OBJ_OTHER_ID_NUM_ID and
	           coll_obj_other_id_num.collection_object_id=collobjid and 
	           cf_relations_cache.term=termtype;
		return result;
	exception when others then
	   return null;
	end;
end;
/
sho err;




CREATE or replace PUBLIC SYNONYM getRelatedCache FOR getRelatedCache;
GRANT EXECUTE ON getRelatedCache TO PUBLIC;


--- update flat set individualcount=getIndividualCount(collection_object_id) where collection_cde='Ento';

