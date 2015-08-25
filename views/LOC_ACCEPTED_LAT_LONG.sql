create or replace view LOC_ACCEPTED_LAT_LONG AS 
	select 
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
			HIGHER_GEOG
		from 
			locality, 
			accepted_lat_long,
			geog_auth_rec,
			preferred_agent_name cd
		where 
			locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and 
			locality.locality_id=accepted_lat_long.locality_id (+) AND
			determined_by_agent_id = cd.agent_id (+)
		;			


create or replace public synonym LOC_ACCEPTED_LAT_LONG for LOC_ACCEPTED_LAT_LONG;
grant select on LOC_ACCEPTED_LAT_LONG to public;