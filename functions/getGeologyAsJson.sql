/*
 
 	::::::::::::::::IMPORTANT::::::::::::::::
	
	Do not modify this function without also updating http://handbook.arctosdb.org/documentation/json.html
	
	Input: locality.locality_id
	
	Output: Geology as JSON
 
 
*/

CREATE OR REPLACE function getGeologyAsJson(lid  in number )
    return varchar2
    as
		jsond varchar2(4000) :='[';
		rsep varchar2(1);
		dsep varchar2(1);
   begin
    FOR r IN (
              select 
				GEOLOGY_ATTRIBUTE,
				GEO_ATT_VALUE,
				GEO_ATT_REMARK,
				GEO_ATT_DETERMINED_METHOD,
				GEO_ATT_DETERMINED_DATE,
				getPreferredAgentName(GEO_ATT_DETERMINER_ID) geo_determiner
			from
				geology_attributes
			where
				LOCALITY_ID=lid
			) loop
				jsond:=jsond || rsep || '{';
				jsond:=jsond || '"TY":"' || escape_json(r.GEOLOGY_ATTRIBUTE) || '"';
				jsond:=jsond || ',"VU":"' || escape_json(r.GEO_ATT_VALUE)  ||'"';
				jsond:=jsond || ',"RK":"' || escape_json(r.GEO_ATT_REMARK) || '"';
				jsond:=jsond || ',"MD":"' || escape_json(r.GEO_ATT_DETERMINED_METHOD) || '"';
				jsond:=jsond || ',"DA":"' || escape_json(r.GEO_ATT_DETERMINED_DATE) || '"';
				jsond:=jsond || ',"DT":"' || escape_json(r.geo_determiner) || '"';
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

CREATE PUBLIC SYNONYM getGeologyAsJson FOR getGeologyAsJson;
GRANT EXECUTE ON getGeologyAsJson TO PUBLIC;

