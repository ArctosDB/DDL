CREATE or replace FUNCTION CONCATPREP (p_key_val in varchar2 )
return varchar2
as
l_str varchar2(4000);
begin
	select concatCollectorAgent(p_key_val,'preparator') into l_str from dual;
	return l_str;
end;
/


sho err;
CREATE OR REPLACE PUBLIC SYNONYM CONCATPREP FOR CONCATPREP;
GRANT EXECUTE ON CONCATPREP TO PUBLIC;
