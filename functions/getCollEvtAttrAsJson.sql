
CREATE OR REPLACE function getCollEvtAttrAsJson(ceid  in number )
	-- this is intended to better avoid the 4K character limit
	-- see getCollEvtAttrAsJson for a less cryptic alternative; albeit one that won't work for most data
    return varchar2
    as
		jsond varchar2(4000) :='[';
		rsep varchar2(1);
		dsep varchar2(1);
   begin
    FOR r IN (
              select 
				event_attribute_type,
				event_attribute_value,
				event_attribute_units,
				event_attribute_remark,
				event_determination_method,
				event_determined_date,
				getPreferredAgentName(determined_by_agent_id) event_determiner
			from
				collecting_event_attributes
			where
				collecting_event_id=ceid
			) loop
				jsond:=jsond || rsep || '{';
				jsond:=jsond || '"TY":"' || escape_json(r.event_attribute_type) || '"';
				jsond:=jsond || ',"VU":"' || trim(escape_json(r.event_attribute_value) || ' ' || escape_json(r.event_attribute_units)) ||'"';
				jsond:=jsond || ',"RK":"' || escape_json(r.event_attribute_remark) || '"';
				jsond:=jsond || ',"MD":"' || escape_json(r.event_determination_method) || '"';
				jsond:=jsond || ',"DA":"' || escape_json(r.event_determined_date) || '"';
				jsond:=jsond || ',"DT":"' || escape_json(r.event_determiner) || '"';
				jsond:=jsond || '}';
				rsep:=',';
		end loop;
		jsond:=jsond || ']';
		return jsond;
	exception when others then
		jsond:='[{"STATUS":"ERROR CREATING JSON"}]';
		return jsond;
end;
/



CREATE or replace PUBLIC SYNONYM getCollEvtAttrAsJson FOR getCollEvtAttrAsJson;
GRANT EXECUTE ON getCollEvtAttrAsJson TO PUBLIC;
