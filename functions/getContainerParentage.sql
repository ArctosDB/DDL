create or replace function getContainerParentage (
  cid in number,
  i_sep in varchar2 default ':'
) return varchar2
as
  v_res varchar2(4000);
begin
  with tmp as (
    select label, level as name_level from container
    start with container_id = cid connect by prior parent_container_id =  container_id)
  select i_sep || listagg(label, i_sep) within group (order by name_level desc)
    into v_res from tmp;
    v_res:=trim(both i_sep from v_res);
    
  return v_res;
end;
/


create public synonym getContainerParentage for getContainerParentage;
grant execute on getContainerParentage to public;


create or replace function getContainerParentage_tff (
  cid in number,
  i_sep in varchar2 default ':'
) return varchar2
as
  v_res varchar2(4000);
begin
  with tmp as (
    select '[ ' || barcode || ' ] ' || label || ' (' ||container_type || ')' as label, level as name_level from container
    start with container_id = cid connect by prior parent_container_id =  container_id)
  select i_sep || listagg(label, i_sep) within group (order by name_level desc)
    into v_res from tmp;
    v_res:=trim(both i_sep from v_res);
    
  return v_res;
end;
/
select getContainerParentage_tff(14848352) from dual;


create public synonym getContainerParentage for getContainerParentage;
grant execute on getContainerParentage to public;


