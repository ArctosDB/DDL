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

-- for post-https://github.com/ArctosDB/arctos/issues/1875
-- needs implemented as part of https://github.com/ArctosDB/arctos/issues/1460

CREATE  or replace FUNCTION getIfTissues_2 ( collobjid in integer)
return number
as
result number;
is_tissue number;
is_not_tissue number;
begin
	for r in (
		select 
			tissue_fg
		from 
			specimen_part, 
			specimen_part_attribute,
			CTPART_PRESERVATION
		where
			specimen_part.collection_object_id=specimen_part_attribute.collection_object_id and
			specimen_part_attribute.ATTRIBUTE_TYPE='preservation' and
			specimen_part_attribute.ATTRIBUTE_VALUE=CTPART_PRESERVATION.PART_PRESERVATION and
			tissue_fg is not null and
			specimen_part.derived_from_cat_item=collobjid
	) loop
		if r.tissue_fg=1 then
			is_tissue:=1;
		end if;
		if r.tissue_fg=0 then
			is_not_tissue:=1;
		end if;
	end loop;
	-- if we got anything it might be a tissue
	if is_tissue=1 then
		result:=1;
	end if;
	-- if we got anything here it definitely isn't a tissue
	if is_not_tissue=1 then
		result:=0;
	end if;
	return result;	
end;
/
sho err;

CREATE or replace PUBLIC SYNONYM getIfTissues_2 FOR getIfTissues_2;
GRANT EXECUTE ON getIfTissues_2 TO PUBLIC;

