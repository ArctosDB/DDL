-- EDIT: optional "future dates are not valid" flag
CREATE OR REPLACE FUNCTION "UAM"."ISDATE"
	( p_string in varchar2, p_blockFuture in number default 0)
return integer as
	l_date date;
begin
	l_date := to_date(p_string,'YYYY-MM-DD');
	if p_blockFuture=1 and l_date>to_char(sysdate,'yyyy-mm-dd') THEN
		return 0;
	end if;
   return 1;
exception when others then
	return 0;
end;
/



select isdate2('2900-01-01') from dual;


-- old
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

