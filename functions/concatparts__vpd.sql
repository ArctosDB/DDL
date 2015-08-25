CREATE OR REPLACE FUNCTION CONCATPARTS ( collobjid in integer)
return varchar2
as            
 	t varchar2(255);
 	result varchar2(4000);     
 	sep varchar2(2):='';
begin
for r in (
	select
		part_name,
		part_modifier,
		preserve_method,
		sampled_from_obj_id
	from
		specimen_part,
    	ctspecimen_part_list_order,
        coll_object
 	where 
        specimen_part.collection_object_id=coll_object.collection_object_id and
  		specimen_part.part_name =  ctspecimen_part_list_order.partname (+)
    	and coll_obj_disposition not in 
        	('discarded','used up','deaccessioned','missing','transfer of custody')
        and derived_from_cat_item = collobjid
    ORDER BY list_order,sampled_from_obj_id DESC
    ) loop
    	t:='';
    	if r.part_modifier is not null then
    		t:=r.part_modifier || ' ' || r.part_name;
    	else
    		t:=r.part_name;
    	end if;
    	if r.sampled_from_obj_id is not null then
    		t:=t||' sample';
    	end if;
    	if r.preserve_method is not null then
    		t:=t||' (' || r.preserve_method || ')';
    	end if;
    	result:=result||sep||t;
    	sep:='; ';
    end loop;
        --	dbms_output.put_line(result);
    return result;
end;
/
sho err;		