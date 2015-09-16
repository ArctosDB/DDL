CREATE or replace FUNCTION isValidIP (ip in varchar2 )
return varchar2
as
iip varchar2(255);
begin
	-- accept wildcards as eg 
		-- 1.1.1.*
		-- 1.1.*.*
	iip:=replace(ip,'*','111');
	
	if regexp_like(iip,'^(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))$') then
		return 'true';
	else
		return 'false';
	end if;
end;
/
sho err;