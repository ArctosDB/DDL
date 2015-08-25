CREATE OR REPLACE FUNCTION isValidAgent (name  in varchar)
return number as
	numRecs NUMBER;
	BEGIN
	-- cache agent check to try to improve performance
	-- return number of matching agent_id 
	-- if possible, match preferred_agent_name
	select /*+ RESULT_CACHE */ count(distinct(agent_id)) into numRecs from agent where preferred_agent_name = name;
	if numRecs != 1 then
		-- try agent names
		select /*+ RESULT_CACHE */ count(distinct(agent_id)) into numRecs from agent_name where agent_name = name and 
			agent_name_type not in ('first name','last name', 'middle name');
		if numRecs != 1 then
			-- ignore flagged-for-delete
			select /*+ RESULT_CACHE */ count(distinct(agent_id)) into numRecs from agent_name where agent_name = name and 
				agent_name_type not in ('first name','last name', 'middle name') and
				agent_id not in (select agent_id from agent_relations where agent_relationship='bad duplicate of');
		end if;
	end if;
	return numRecs;
end;
/
sho err;


CREATE OR REPLACE PUBLIC SYNONYM isValidAgent FOR isValidAgent;
GRANT execute ON isValidAgent TO PUBLIC;
