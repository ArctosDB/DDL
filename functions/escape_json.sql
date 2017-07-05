
CREATE OR REPLACE function escape_json (s in varchar2)
    return varchar2
    as
        tmp    varchar2(4000);
    begin
	    tmp:=s;
	    tmp:=replace(tmp,'"','\"');
	    return tmp;
   end;
/


sho err;




create public synonym escape_json for escape_json;
grant execute on escape_json to public;


--  select concatpartsdetail(12) from dual;
--  select concatpartsdetail(26091749) from dual;

 -- select concatpartsdetail(12) from dual;

