
CREATE OR REPLACE function escape_json (s in varchar2)
    return varchar2
    as
        tmp    varchar2(4000);
    begin
	    tmp:=s;
	    tmp:=replace(tmp,'"','\"');
	    tmp:=replace(tmp,'/','\/');
	    return tmp;
   end;
/


sho err;

select escape_json('The museum tag for this specimen also had the code "211 7/9" recorded on it.') from dual;


create public synonym escape_json for escape_json;
grant execute on escape_json to public;


--  select concatpartsdetail(12) from dual;
--  select concatpartsdetail(26091749) from dual;

 -- select concatpartsdetail(12) from dual;

