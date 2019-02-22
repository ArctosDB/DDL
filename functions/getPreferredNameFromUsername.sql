CREATE OR REPLACE FUNCTION getPreferredNameFromUsername(u IN varchar)
RETURN varchar
AS
   n varchar(255);
   c number;
BEGIN
	if u = 'UAM' then
		n:='DBA';
	else
		SELECT  /*+ RESULT_CACHE */ count(*)
	    INTO c FROM 
	    agent,agent_name WHERE 
	    agent.agent_id=agent_name.agent_id and agent_name_type='login' and upper(agent_name.agent_name)=u;
		if c=1 then
		    SELECT  /*+ RESULT_CACHE */ agent.preferred_agent_name
		    INTO n FROM 
		    agent,agent_name WHERE 
		    agent.agent_id=agent_name.agent_id and agent_name_type='login' and upper(agent_name.agent_name)=u;
	    else
	    	n:=u;
	    end if;
	end if;
	RETURN n;
end;
/
sho err;

CREATE or replace PUBLIC SYNONYM getPreferredNameFromUsername FOR getPreferredNameFromUsername;
GRANT EXECUTE ON getPreferredNameFromUsername TO PUBLIC;

