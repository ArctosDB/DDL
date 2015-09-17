CREATE or replace FUNCTION isValidIP (ip in varchar2 )
return varchar2
as
begin
	-- accept wildcards as eg 
		-- 1.1.1.*
		-- 1.1.*.*
		-- but not upstream of subnet
	if 
		-- straight IP
		regexp_like(ip,'^(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))$')
		or 
		-- sub-subnet
		regexp_like(ip,'^(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.\*$')
		or
		-- subnet
		regexp_like(ip,'^(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.\*\.\*$')
	then
		return 'true';
	else
		return 'false';
	end if;
end;
/
sho err;