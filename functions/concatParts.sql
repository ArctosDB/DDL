-- https://github.com/ArctosDB/arctos/issues/658
-- no filtering by disposition

CREATE or replace FUNCTION "UAM"."CONCATPARTS" ( collobjid in integer)
	return varchar2
as
	result varchar2(4000);
	sep varchar2(2):='';
begin
	for r in (
		select
			decode(sampled_from_obj_id,null,part_name,part_name || ' sample') part_name
		from
			specimen_part,
			ctspecimen_part_list_order
		where
			specimen_part.part_name = ctspecimen_part_list_order.partname (+) and 
			derived_from_cat_item = collobjid
		ORDER BY 
			list_order,
			sampled_from_obj_id DESC
	) loop
		result:=result||sep||r.part_name;
		sep:='; ';
	end loop;
	return result;
end;
/
sho err;


CREATE  FUNCTION ======= old and busted ======= "UAM"."CONCATPARTS"( collobjid in integer)
return varchar2
as
t varchar2(255);
result varchar2(4000);
sep varchar2(2):='';
begin
for r in (
select
part_name,
sampled_from_obj_id
from
specimen_part,
ctspecimen_part_list_order,
coll_object
where
specimen_part.collection_object_id=coll_object.collection_object_id and
specimen_part.part_name = ctspecimen_part_list_order.partname (+)
-- https://github.com/ArctosDB/arctos/issues/658
-- no filtering
--and coll_obj_disposition not in
--('discarded','used up','deaccessioned','missing','transfer of custody')
and derived_from_cat_item = collobjid
ORDER BY list_order,sampled_from_obj_id DESC
) loop
t:=r.part_name;
if r.sampled_from_obj_id is not null then
t:=t||' sample';
end if;
result:=result||sep||t;
sep:='; ';
end loop;
return result;
end;