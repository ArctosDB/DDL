CREATE OR REPLACE FUNCTION getAgentID(name IN varchar)
 -- looks up agent_id from agent_name
 -- use this rather than a direct select for performance and 
 -- modularity. E.g, agent structure change means that we no longer
 -- want to find agents by any name - first, middle, last do NOT stand alone
 -- and are NOT independent identifiers
 

RETURN number
AS
   n number;
   a number;
begin
	-- if possible, match preferred_agent_name
    SELECT /*+ RESULT_CACHE */ count(distinct(agent_id)) INTO n FROM agent where preferred_agent_name = name;
 
    if n = 1 then
		SELECT /*+ RESULT_CACHE */ agent_id into a FROM agent where preferred_agent_name = name  group by agent_id;
    else
		SELECT /*+ RESULT_CACHE */ count(distinct(agent_id)) INTO n FROM agent_name where 
			agent_name_type not in ('first name','last name','middle name') AND
    		agent_name=name;
    	if n=1 then
			SELECT /*+ RESULT_CACHE */ agent_id INTO a FROM agent_name where 
			agent_name_type not in ('first name','last name','middle name') AND
    		agent_name=name group by agent_id;
    	else
    		select /*+ RESULT_CACHE */ count(distinct(agent_id)) into n from agent_name where agent_name = name and 
				agent_name_type not in ('first name','last name', 'middle name') and
				agent_id not in (select agent_id from agent_relations where agent_relationship='bad duplicate of');
			if n=1 then
				select /*+ RESULT_CACHE */ agent_id into a from agent_name where agent_name = name and 
				agent_name_type not in ('first name','last name', 'middle name') and
				agent_id not in (select agent_id from agent_relations where agent_relationship='bad duplicate of')
				 group by agent_id;
			end if;
		end if;
	end if;
	
    RETURN a;
    exception
    	when others then
    		return null;
end;
    /
    sho err;


CREATE or replace PUBLIC SYNONYM getAgentID FOR getAgentID;
GRANT EXECUTE ON getAgentID TO PUBLIC;





    	
    	