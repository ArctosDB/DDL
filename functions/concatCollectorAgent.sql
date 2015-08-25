CREATE or replace FUNCTION concatCollectorAgent (p_key_val in varchar2 , role in varchar2)
return varchar2
as
l_str varchar2(4000);
l_sep varchar2(3);
l_val varchar2(4000);
begin
	for r in (select agent_name from preferred_agent_name,collector where collector_role=role AND
		collector.agent_id=preferred_agent_name.agent_id AND
		collection_object_id = p_key_val
		order by coll_order) loop
			l_str := l_str || l_sep || r.agent_name;
			l_sep := ', ';
	end loop;
	return l_str;
end;
/


sho err;
CREATE OR REPLACE PUBLIC SYNONYM concatCollectorAgent FOR concatCollectorAgent;
GRANT EXECUTE ON concatCollectorAgent TO PUBLIC;