create or replace view spec_with_loc AS 
	select 
			cataloged_item.collection_object_id,
			collecting_event.collecting_event_id,
			locality.LOCALITY_ID,
			geog_auth_rec.geog_auth_rec_id,
			MAXIMUM_ELEVATION,
			MINIMUM_ELEVATION,
			ORIG_ELEV_UNITS,
			SPEC_LOCALITY,
			LOCALITY_REMARKS,
			DEPTH_UNITS,
			MIN_DEPTH,
			MAX_DEPTH,
			NOGEOREFBECAUSE,
			LAT_LONG_ID,
			LAT_DEG,
			DEC_LAT_MIN,
			LAT_MIN,
			LAT_SEC,
			LAT_DIR,
			LONG_DEG,
			DEC_LONG_MIN,
			LONG_MIN,
			LONG_SEC,
			LONG_DIR,
			DEC_LAT,
			DEC_LONG,
			UTM_ZONE,
			UTM_EW,
			UTM_NS,				
			DATUM,
			ORIG_LAT_LONG_UNITS,
			DETERMINED_BY_AGENT_ID,
			cd.agent_name coordinate_determiner,
			DETERMINED_DATE,
			LAT_LONG_REMARKS,
			MAX_ERROR_DISTANCE,
			MAX_ERROR_UNITS,
			ACCEPTED_LAT_LONG_FG,
			EXTENT,
			GPSACCURACY,
			GEOREFMETHOD,
			VERIFICATIONSTATUS,
			LAT_LONG_REF_SOURCE,
			HIGHER_GEOG,
			BEGAN_DATE,
			ENDED_DATE,
			VERBATIM_DATE,
			VERBATIM_LOCALITY,
			COLL_EVENT_REMARKS,
			COLLECTING_SOURCE,
			COLLECTING_METHOD,
			HABITAT_DESC,
			GEOLOGY_ATTRIBUTE_ID,
			GEOLOGY_ATTRIBUTE,
			GEO_ATT_VALUE,
			GEO_ATT_DETERMINER_ID,
			gd.agent_name geo_att_determiner,
			GEO_ATT_DETERMINED_DATE,
			GEO_ATT_DETERMINED_METHOD,
			GEO_ATT_REMARK 
		from 
			locality, 
			accepted_lat_long,
			geog_auth_rec,
			collecting_event,
			cataloged_item,
			preferred_agent_name cd,
			geology_attributes,
			preferred_agent_name gd
		where 
			locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and 
			locality.locality_id=accepted_lat_long.locality_id (+) AND
			locality.locality_id=geology_attributes.locality_id (+) AND
			geology_attributes.GEO_ATT_DETERMINER_ID=gd.agent_id (+) AND
			locality.locality_id = collecting_event.locality_id AND
			determined_by_agent_id = cd.agent_id (+) AND
			collecting_event.collecting_event_id = cataloged_item.collecting_event_id 			
;			


create public synonym spec_with_loc for spec_with_loc;
grant select on spec_with_loc to public;