-- from https://github.com/ArctosDB/arctos/issues/1585
-- changing format of "label" 
create or replace function getContainerDisplay (
  cid in number
) return varchar2
as
  v_res varchar2(4000);
begin
	select '[ ' || barcode || ' ] ' || label || ' (' ||container_type || ')' into v_res from container where container_id = cid;	
  	return v_res;
end;
/
sho err;

create or replace public synonym getContainerDisplay for getContainerDisplay;
grant execute on getContainerDisplay to public;



select getContainerDisplay(16284183) from dual;
select getContainerDisplay(4534534354) from dual;