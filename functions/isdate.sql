CREATE OR REPLACE FUNCTION "UAM"."ISDATE"
( p_string in varchar2)
return integer
as
l_date date;
begin
l_date := to_date(p_string,'YYYY-MM-DD');
   return 1;
exception
when others then
return 0;
end;