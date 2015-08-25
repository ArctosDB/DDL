CREATE TABLE arctos_audit AS
SELECT * FROM arctos_audit_vw;

INSERT INTO arctos_audit (
        db_user, 
    	timestamp, 
    	sql_text)
	select
        upper(u.username), 
    	d.date_stamp, 
    	regexp_replace(regexp_replace(d.sql_statement,'[^[:print:]]',' '),'[    ]+',' ')
	FROM 
	    cf_database_activity d, 
	    cf_users u
	WHERE d.user_id = u.user_id (+)
    AND d.activity_id != 10000519;

insert into arctos_audit (db_user, timestamp, sql_text)
        select
        upper(u.username),
        d.date_stamp, 
        trim(regexp_replace(regexp_replace(regexp_replace(regexp_replace(d.sql_statement,'[^[:print:]]',' '),'[    ]+',' '),'> <','><'),' ,',','))
        FROM
            cf_database_activity d,
            cf_users u
        WHERE d.user_id = u.user_id (+)
    AND d.activity_id = 10000519;

GRANT SELECT ON arctos_audit TO global_admin;

/* activity_id 100005190
	
2006-11-30 00:00:00
INSERT INTO lat_long ( LAT_LONG_ID ,LOCALITY_ID <cfif len(NAD27) gt 0> ,DATUM </cfif> <cfif len(Used Santa Barbara Airports website and used the topomap feature to find approx location of airstrip on Terran Navigator. Also used Google Maps in satellite mode to find the airstrip. Took extent to halfway to Christi Ranch. By road on road running through canyon.) gt 0> ,LAT_LONG_REMARKS </cfif> <cfif len(2600.000) gt 0> ,MAX_ERROR_DISTANCE </cfif> <cfif len(ft) gt 0> ,MAX_ERROR_UNITS </cfif> <cfif len(1) gt 0> ,ACCEPTED_LAT_LONG_FG </cfif> <cfif len(Terrain Navigator Pro 7.0 USGS 1:2400 Santa Cruz Island A, http://www.hometownlocator.com/DisplayCountyFeatures.cfm?FeatureType=airport&SCFIPS=06083, Google Maps in satellite mode) gt 0> ,lat_long_ref_source </cfif> ,determined_by_agent_id ,determined_date ,ORIG_LAT_LONG_UNITS ,DEC_LAT ,DEC_LONG ) VALUES ( 108388 ,65751 <cfif len(NAD27) gt 0> ,'NAD27' </cfif> <cfif len(Used Santa Barbara Airports website and used the topomap feature to find approx location of airstrip on Terran Navigator. Also used Google Maps in satellite mode to find the airstrip. Took extent to halfway to Christi Ranch. By road on road running through canyon.) gt 0> ,'Used Santa Barbara Airports website and used the topomap feature to find approx location of airstrip on Terran Navigator. Also used Google Maps in satellite mode to find the airstrip. Took extent to halfway to Christi Ranch. By road on road running through canyon.' </cfif> <cfif len(2600.000) gt 0> ,2600.000 </cfif> <cfif len(ft) gt 0> ,'ft' </cfif> <cfif len(1) gt 0> ,1 </cfif> <cfif len(Terrain Navigator Pro 7.0 USGS 1:2400 Santa Cruz Island A, http://www.hometownlocator.com/DisplayCountyFeatures.cfm?FeatureType=airport&SCFIPS=06083, Google Maps in satellite mode) gt 0> ,'Terrain Navigator Pro 7.0 USGS 1:2400 Santa Cruz Island A, http://www.hometownlocator.com/DisplayCountyFeatures.cfm?FeatureType=airport&SCFIPS=06083, Google Maps in satellite mode' </cfif> ,15584 ,'30-Nov-2006' ,'decimal degrees' ,34.0196557 ,-119.8447114
*/
