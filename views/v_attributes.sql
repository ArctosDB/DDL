-- this view "pre-compiles" attribute summaries.
-- more importantly, it marks attributes as encumbered, there the encumbrance is of the format
-- "mask {space} {attribute}"

create or replace view v_attributes as select distinct
	attributes.ATTRIBUTE_ID,
	attributes.collection_object_id,
	attributes.DETERMINED_BY_AGENT_ID,
	preferred_agent_name.agent_name determiner,
	attributes.ATTRIBUTE_TYPE,
	attributes.ATTRIBUTE_VALUE,
	attributes.ATTRIBUTE_UNITS,
	attributes.ATTRIBUTE_REMARK,
	attributes.DETERMINATION_METHOD,
	attributes.DETERMINED_DATE,
	attributes.attribute_type || '=' || 
		attributes.attribute_value || 
		decode(attribute_units,
        	null,null,
            ' ' || attribute_units
        ) ||
		' (Determiner: ' || preferred_agent_name.agent_name || ' on ' || 
		determined_date|| 
		decode(determination_method,
        	null,null,
            '; Method: ' || determination_method
        ) || 
        decode(attribute_remark,
        	null,null,
            ' Remark: ' || attribute_remark
        ) 
        || ')' attribute_detail,
	attributes.attribute_type || '=' || 
		attributes.attribute_value || ' ' || 
		attribute_units attribute_summary,
	CASE
		WHEN concatEncumbrances(attributes.collection_object_id) LIKE '%mask ' || attributes.ATTRIBUTE_TYPE || '%'
        	THEN 1
            ELSE 0
	END is_encumbered
from
	attributes,
	preferred_agent_name
where
	attributes.DETERMINED_BY_AGENT_ID=preferred_agent_name.agent_id
;

create or replace public synonym v_attributes for v_attributes;
grant select on v_attributes to public;