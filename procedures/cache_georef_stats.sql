
create table colln_coords_summary (
	guid_prefix varchar2(255),
	number_of_specimens number,
	number_of_georeferences number,
	specimens_with_georeference number,
	gref_with_calc_georeference number,
	georeferences_with_error number,
	georeferences_with_elevation number,
	calc_error_lt_1 number,
	calc_error_lt_10 number,
	calc_error_gt_10 number,
	calc_elev_fits number);



create table colln_coords (
	numUsingSpecimens number,
	guid_prefix varchar2(4000),
	dec_lat number,
	dec_long number,
	s$dec_lat number,
	s$dec_long number,
	err_m number,
	s_err_km number,
	min_elev_m number,
	max_elev_m number,
	s_elev_m number,
	higher_geog varchar2(4000),
	S$GEOGRAPHY varchar2(4000)
);


create index ix_colln_coords_guid_prefix on colln_coords(guid_prefix) tablespace uam_idx_1;






CREATE OR REPLACE PROCEDURE CACHE_GEOREF_STATS IS
	numGeoRefedSpecimens number;
	v_number_of_georeferences number;
	gwce number;
	swg number;
	gwv number;
	el1 number;
	el10 number;
	eg10 number;
	evg number;
begin
	-- Expensive, but easy to maintain and seldom-run procedure to gather some georef stats
	--dbms_output.put_line('k');
	--delete from colln_coords_summary;

	execute immediate 'truncate table colln_coords';
	execute immediate 'truncate table colln_coords_summary';

	-- see Reports/georef for create (by select) SQL
	insert into colln_coords (
	  numUsingSpecimens,
	  guid_prefix,
	  dec_lat,
	  dec_long,
	  s$dec_lat,
	  s$dec_long,
	  err_m,
	  s_err_km,
	  min_elev_m,
	  max_elev_m,
	  s_elev_m,
	  higher_geog,
	  S$GEOGRAPHY
	) (
		select
	  	count(distinct(cataloged_item.collection_object_id)) ,
	  guid_prefix,
	  locality.dec_lat,
	  locality.dec_long,
	  locality.s$dec_lat,
	  locality.s$dec_long,
	  to_meters(locality.MAX_ERROR_DISTANCE,locality.MAX_ERROR_UNITS) ,
	  getHaversineDistance(locality.dec_lat,locality.dec_long,locality.s$dec_lat,locality.s$dec_long) ,
	  to_meters(locality.MINIMUM_ELEVATION,locality.ORIG_ELEV_UNITS) ,
	  to_meters(locality.MAXIMUM_ELEVATION,locality.ORIG_ELEV_UNITS) ,
	  locality.s$elevation ,
	  geog_auth_rec.higher_geog,
	  locality.S$GEOGRAPHY
	from
	  cataloged_item,
	  collection,
	  specimen_event,
	  collecting_event,
	  locality,
	  geog_auth_rec
	where
	  cataloged_item.collection_id=collection.collection_id and
	  cataloged_item.collection_object_id=specimen_event.collection_object_id and
	  specimen_event.collecting_event_id=collecting_event.collecting_event_id and
	  collecting_event.locality_id=locality.locality_id and
	  locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
	  locality.dec_lat is not null
	group by
	  guid_prefix,
	  locality.dec_lat,
	  locality.dec_long,
	  locality.s$dec_lat,
	  locality.s$dec_long,
	  to_meters(locality.MAX_ERROR_DISTANCE,locality.MAX_ERROR_UNITS),
	  getHaversineDistance(locality.dec_lat,locality.dec_long,locality.s$dec_lat,locality.s$dec_long),
	  to_meters(locality.MINIMUM_ELEVATION,locality.ORIG_ELEV_UNITS),
	  to_meters(locality.MAXIMUM_ELEVATION,locality.ORIG_ELEV_UNITS),
	  locality.s$elevation,
	  geog_auth_rec.higher_geog,
	  locality.S$GEOGRAPHY
	);



	-- NOTE: In all the below, "locality" means "distinct values of stuff we're pulling from locality"
	--    and NOT anything involving locality_id

	for r in (select guid_prefix, count(*) c from COLLECTION ,
					cataloged_item
				where
					collection.collection_id=cataloged_item.collection_id group by guid_prefix) loop



		 -- total distinct "georeferences" used by the collection






		-- specimens having at least one georeference
		 select
		  count(distinct(cataloged_item.collection_object_id)) into numGeoRefedSpecimens
		from
		  cataloged_item,
		  collection,
		  specimen_event,
		  collecting_event,
		  locality
		where
		  cataloged_item.collection_id=collection.collection_id and
		  cataloged_item.collection_object_id=specimen_event.collection_object_id and
		  specimen_event.collecting_event_id=collecting_event.collecting_event_id and
		  collecting_event.locality_id=locality.locality_id and
		  locality.dec_lat is not null and
		collection.guid_prefix=r.guid_prefix
		;


		insert into colln_coords_summary (
			guid_prefix,
			number_of_specimens,
			number_of_georeferences,
			specimens_with_georeference,
			gref_with_calc_georeference,
			georeferences_with_error,
			georeferences_with_elevation,
			calc_error_lt_1,
			calc_error_lt_10,
			calc_error_gt_10,
			calc_elev_fits
		) values (
			r.guid_prefix,
			r.c,
			(
				-- number_of_georeferences - number of localities used by a collection
				-- colln_coords already filteres for asserted coordinates
				select
					count(*)
				from
					colln_coords
				where
					guid_prefix=r.guid_prefix
			),
			numGeoRefedSpecimens,
			(
				--gref_with_calc_georeference - number of localities with both asserted and calculated georeferences
				select count(*) from colln_coords where
					guid_prefix=r.guid_prefix and
					S_ERR_KM is not null -- this will be NULL if either asserted or calculated is MIA
			),
			(
				--georeferences_with_error - number of localities which have asserted georeferences and asserted error
				select
					count(*)
				from
					colln_coords
				where
					err_m is not null and
					guid_prefix=r.guid_prefix
			),
			(
				-- georeferences_with_elevation - number of localities with a curatorial assertion of elevation
				select count(*)
					from colln_coords where min_elev_m is not null and
					guid_prefix=r.guid_prefix
			),
			(
				--calc_error_lt_1 - number of localities with a difference between asserted and calculated points of <1KM
				select count(*) from colln_coords where
					s_err_km is not null and
					getHaversineDistance(dec_lat,dec_long,s$dec_lat,s$dec_long)<1 and
					guid_prefix=r.guid_prefix
			),
			(
				--calc_error_lt_10 - number of localities with a difference between asserted and calculated points between 1 and 10 KM
				select
					count(*)
				from
					colln_coords
				where
					s_err_km is not null and
					getHaversineDistance(dec_lat,dec_long,s$dec_lat,s$dec_long) between 1 and 10 and
					guid_prefix=r.guid_prefix
			),
			(
				--calc_error_gt_10 - number of localities with a difference between asserted and calculated points above 10 KM
				select
					count(*)
				from
					colln_coords
				where
					s_err_km is not null and
					getHaversineDistance(dec_lat,dec_long,s$dec_lat,s$dec_long)>10 and
					guid_prefix=r.guid_prefix
			),
			(
				--calc_elev_fits -  number of localities where calculated elevation is between asserted
				select
					count(*)
				from
					colln_coords
				where
					s_elev_m between min_elev_m and max_elev_m and
					guid_prefix=r.guid_prefix
			)
		);
	end loop;
end;
/
sho err;


BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name           =>  'J_CACHE_GEOREF_STATS',
    job_type           =>  'STORED_PROCEDURE',
	job_action         =>  'CACHE_GEOREF_STATS',
	start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=weekly; byday=sun',
	enabled            =>  TRUE,
	end_date           =>  NULL,
	comments           =>  'Rebuild cache used by /Reports/georef.cfm');
END;
/



select STATE,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_CACHE_GEOREF_STATS';

