CREATE OR REPLACE FUNCTION getAgentNameType(iagent_id IN number, iagent_name_type in varchar)
RETURN varchar
AS
   rtn varchar2(255);
   cnt number :=0;
BEGIN
   for loopty in (
		SELECT  
	    	/*+ RESULT_CACHE */ agent_name 
	    FROM 
	    	agent_name 
	    WHERE 
	    	agent_name_type = iagent_name_type AND
	    	agent_id=iagent_id
	    group by
	    	agent_name
	    ) loop
	    rtn:=loopty.agent_name;
	    cnt:=cnt+1;
    end loop;    
	if cnt = 1 then
		RETURN rtn;
	else
		return null;
	end if;
end;
    /
    sho err;


CREATE or replace PUBLIC SYNONYM getAgentNameType FOR getAgentNameType;
GRANT EXECUTE ON getAgentNameType TO PUBLIC;


