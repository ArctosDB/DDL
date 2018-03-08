-- get general outline of locality stuff for specimenresults
-- do not pull remarks, other long text fields
-- in an attempt to not break this thing
create or replace function getJsonEventBySpecimen (colObjId IN number)
return varchar2
as
	jsond varchar2(4000) :='[';
	rsep varchar2(1);
	dsep varchar2(1);
begin
	for r in (
		select 
			--SPECIMEN_EVENT.SPECIMEN_EVENT_ID,
			SPECIMEN_EVENT.SPECIMEN_EVENT_TYPE,
			getPreferredAgentName(SPECIMEN_EVENT.ASSIGNED_BY_AGENT_ID) ASSIGNEDBY,
			to_char(SPECIMEN_EVENT.ASSIGNED_DATE,'YYYY-MM-DD') ASSIGNEDDATE,
			getPreferredAgentName(SPECIMEN_EVENT.VERIFIED_BY_AGENT_ID) VERIFIEDBY,
			SPECIMEN_EVENT.VERIFIED_DATE VERIFIEDDATE,
			--SPECIMEN_EVENT.SPECIMEN_EVENT_REMARK,
			SPECIMEN_EVENT.COLLECTING_METHOD,
			SPECIMEN_EVENT.COLLECTING_SOURCE,
			SPECIMEN_EVENT.VERIFICATIONSTATUS,
			SPECIMEN_EVENT.HABITAT,
			COLLECTING_EVENT.VERBATIM_DATE,
			COLLECTING_EVENT.VERBATIM_LOCALITY,
			--COLLECTING_EVENT.COLL_EVENT_REMARKS,
			COLLECTING_EVENT.BEGAN_DATE,
			COLLECTING_EVENT.ENDED_DATE,
			LOCALITY.SPEC_LOCALITY,
			decode(locality.DEC_LAT,null,null, locality.DEC_LAT || ',' || locality.DEC_LONG) COORDINATES,
			decode(locality.MAX_ERROR_UNITS,
				null,null,
				locality.MAX_ERROR_DISTANCE ||  ' ' || locality.MAX_ERROR_UNITS
			) COORDINATE_ERROR,
			decode(locality.ORIG_ELEV_UNITS,
				null,null,
				locality.MINIMUM_ELEVATION || '-' || locality.MAXIMUM_ELEVATION || ' ' || locality.ORIG_ELEV_UNITS
			) ELEVATION,
			decode(locality.DEPTH_UNITS,
				null,null,
				locality.MIN_DEPTH || '-' || locality.MAX_DEPTH || ' ' || locality.DEPTH_UNITS
			) DEPTH,
			LOCALITY.MAX_ERROR_DISTANCE,
			LOCALITY.MAX_ERROR_UNITS,
			LOCALITY.DATUM,
			--LOCALITY.LOCALITY_REMARKS,
			LOCALITY.GEOREFERENCE_SOURCE,
			LOCALITY.GEOREFERENCE_PROTOCOL,
			LOCALITY.LOCALITY_NAME,
			--decode(LOCALITY.WKT_POLYGON,NULL,'','data available') hasLocalityWKT,
			geog_auth_rec.HIGHER_GEOG,
			--decode(geog_auth_rec.WKT_POLYGON,NULL,'','data available') hasGeographyWKT,
			concatGeologyAttribute(SPECIMEN_EVENT.COLLECTION_OBJECT_ID) GEOLOGY
		from
			SPECIMEN_EVENT,
			COLLECTING_EVENT,
			LOCALITY,
			geog_auth_rec
		where
			SPECIMEN_EVENT.collecting_event_id=COLLECTING_EVENT.collecting_event_id and
			COLLECTING_EVENT.locality_id=locality.locality_id and
			locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
			SPECIMEN_EVENT.COLLECTION_OBJECT_ID=colObjId
	) loop
		jsond:=jsond || rsep || '{';
		jsond:=jsond || '"SPECIMEN_EVENT_TYPE":"' || r.SPECIMEN_EVENT_TYPE || '"';
		jsond:=jsond || ',"VERIFICATIONSTATUS":"' || r.VERIFICATIONSTATUS || '"';
		jsond:=jsond || ',"VERIFIEDBY":"' || r.VERIFIEDBY || '"';
		jsond:=jsond || ',"VERIFIEDDATE":"' || r.VERIFIEDDATE || '"';
		jsond:=jsond || ',"ASSIGNEDBY":"' || r.ASSIGNEDBY || '"';
		jsond:=jsond || ',"ASSIGNEDDATE":"' || r.ASSIGNEDDATE || '"';
		--jsond:=jsond || ',"SPECIMEN_EVENT_REMARK":"' || r.SPECIMEN_EVENT_REMARK || '"';
		jsond:=jsond || ',"COLLECTING_METHOD":"' || escape_json(r.COLLECTING_METHOD) || '"';
		jsond:=jsond || ',"COLLECTING_SOURCE":"' || escape_json(r.COLLECTING_SOURCE) || '"';
		jsond:=jsond || ',"BEGAN_DATE":"' || r.BEGAN_DATE || '"';
		jsond:=jsond || ',"ENDED_DATE":"' || r.ENDED_DATE || '"';
		jsond:=jsond || ',"VERBATIM_DATE":"' || escape_json(r.VERBATIM_DATE) || '"';
		jsond:=jsond || ',"VERBATIM_LOCALITY":"' || escape_json(r.VERBATIM_LOCALITY) || '"';
		jsond:=jsond || ',"HABITAT":"' || escape_json(r.HABITAT) || '"';
		jsond:=jsond || ',"SPEC_LOCALITY":"' || escape_json(r.SPEC_LOCALITY) || '"';
		jsond:=jsond || ',"COORDINATES":"' || r.COORDINATES || '"';
		jsond:=jsond || ',"COORDINATE_ERROR":"' || r.COORDINATE_ERROR || '"';
		jsond:=jsond || ',"ELEVATION":"' || r.ELEVATION || '"';
		jsond:=jsond || ',"DEPTH":"' || r.DEPTH || '"';
		jsond:=jsond || ',"DATUM":"' || r.DATUM || '"';
		jsond:=jsond || ',"HIGHER_GEOG":"' || r.HIGHER_GEOG || '"';
		jsond:=jsond || ',"GEOLOGY":"' || r.GEOLOGY || '"';	
		--jsond:=jsond || ',"COLL_EVENT_REMARKS":"' || r.COLL_EVENT_REMARKS || '"';				
		jsond:=jsond || '}';
		rsep:=',';
	end loop;
	jsond:=jsond || ']';
	return jsond;
	exception when others then
		jsond:='[ ERROR CREATING JSON ]';
		return jsond;
end;
/

sho err;

select getJsonEventBySpecimen(22980151) from dual;


create or replace public synonym getJsonEventBySpecimen for getJsonEventBySpecimen;
grant execute on getJsonEventBySpecimen to public;
