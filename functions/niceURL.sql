CREATE OR REPLACE FUNCTION niceURL (s  in VARCHAR)
return varchar2
deterministic as
 r VARCHAR2(255);
begin
	r:=trim(regexp_replace(s,'<[^<>]+>'));
	r:=regexp_replace(r,'[^A-Za-z ]*');
	r:=regexp_replace(r,' +','-');
	r:=lower(r);
	if length(r)>149 then
		r:=substr(r,0,149);
	end if;
	IF (substr(r, -1)='-') THEN
	    r:=substr(r,1,length(r)-1);
	END IF;
    RETURN r;	
end;
/

sho err;


create or replace public synonym niceURL for niceURL;
grant execute on niceURL to public;