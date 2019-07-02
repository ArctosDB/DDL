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




-- test for https://github.com/ArctosDB/arctos/issues/2141

CREATE or replace FUNCTION concatCollectors_JSONTEST (p_key_val in varchar2)
return varchar2
as
	jsond varchar2(4000) :='[';
	rsep varchar2(1);
	dsep varchar2(1);
begin
	for r in (
		select
			coll_order,
			collector_role,
			agent_name,
			preferred_agent_name.agent_id
		from 
			preferred_agent_name,
			collector 
		where 
			collector.agent_id=preferred_agent_name.agent_id AND
			collection_object_id = p_key_val
		order by collector_role,coll_order) loop
			jsond:=jsond || rsep || '{';
			jsond:=jsond || '"AN":"' || escape_json(r.agent_name) || '"';
			jsond:=jsond || ',"CR":"' || r.collector_role ||'"';
			jsond:=jsond || ',"CO":"' || r.coll_order || '"';
			jsond:=jsond || ',"MI":"http://arctos.database.museum/agent.cfm?agent_id=' || r.agent_id || '"';
			jsond:=jsond || '}';
			rsep:=',';		
	end loop;
		jsond:=jsond || ']';
		return jsond;
end;
/
sho err;

select collectors,preparators from flat where collection_object_id=60674;

select concatCollectors_JSONTEST(60674) from dual;
