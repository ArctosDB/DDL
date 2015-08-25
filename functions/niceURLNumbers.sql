CREATE OR REPLACE FUNCTION niceURLNumbers (s  in VARCHAR)
return varchar2
as
 r VARCHAR2(4000);
begin
	r:=trim(regexp_replace(s,'<[^<>]+>'));
	r:=regexp_replace(r,'[^A-Za-z0-9 ]*');
	r:=regexp_replace(r,' +','-');
	r:=lower(r);
	if length(r)>150 then
		r:=substr(r,1,150);
	end if;
    RETURN r;	
end;
/

sho err;


create or replace public synonym niceURLNumbers for niceURLNumbers;
grant execute on niceURLNumbers to public;