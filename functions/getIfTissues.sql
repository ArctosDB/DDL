-- https://github.com/ArctosDB/arctos/issues/1447
-- returns a specimen's "tissueness"

CREATE  or replace FUNCTION getIfTissues ( collobjid in integer)
return number
as
result number :=0;
tmp number;
begin
	select 
		count(*) 
	into 
		tmp 
	from 
		specimen_part, 
		ctspecimen_part_name
	where
		specimen_part.part_name=ctspecimen_part_name.part_name and
		ctspecimen_part_name.IS_TISSUE=1 and
		specimen_part.derived_from_cat_item=collobjid;
	if tmp>0 then
		result:=1;
	end if;
	return result;	
end;
/
sho err;

CREATE or replace PUBLIC SYNONYM getIfTissues FOR getIfTissues;
GRANT EXECUTE ON getIfTissues TO PUBLIC;
