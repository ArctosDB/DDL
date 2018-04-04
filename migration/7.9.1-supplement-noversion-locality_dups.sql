
-- this is not a version
-- it just adds duplicate checking localities
-- could be incorporated most anywhere







-- clean up garbage data thats going to make unhappy triggers




select count(*) from locality
	where
		DEC_LAT is null and
		(
			MAX_ERROR_DISTANCE is not null or
			MAX_ERROR_UNITS is not null or
			DATUM is not null or
			GEOREFERENCE_SOURCE is not null or
			GEOREFERENCE_PROTOCOL is not null
		)
;

create table bak_locality20180403 as select * from locality;


lock table locality in exclusive mode nowait;

alter trigger TR_LOCALITY_AU_FLAT disable;
alter trigger TR_LOCALITY_FAKEERR_AID disable;
alter trigger TR_LOCALITY_BUD disable;


update locality set
	MAX_ERROR_DISTANCE=null,
	MAX_ERROR_UNITS=null,
	DATUM=null,
	GEOREFERENCE_SOURCE=null,
	GEOREFERENCE_PROTOCOL=null 
where
	DEC_LAT is null and
	(
		MAX_ERROR_DISTANCE is not null or
		MAX_ERROR_UNITS is not null or
		DATUM is not null or
		GEOREFERENCE_SOURCE is not null or
		GEOREFERENCE_PROTOCOL is not null
	);



alter trigger TR_LOCALITY_AU_FLAT enable;
alter trigger TR_LOCALITY_FAKEERR_AID enable;
alter trigger TR_LOCALITY_BUD enable;

commit;






-- add a column to collecting event
-- use it to bypass the verified and locked trigger
-- this is not changing any data, so no problems
-- name it something generic, pathetic attempt at future-proofing
alter table collecting_event add admin_flag varchar2(40);
-- rebuild the trigger to use this
CREATE OR REPLACE TRIGGER TR_COLLECTINGEVENT_BUD....



-- add a column to locality

alter table locality add last_dup_check_date date;


CREATE OR REPLACE PROCEDURE auto_merge_locality 
IS
	i number :=0;
	c number;
BEGIN
	-- run this on new stuff and recheck every month or so
	-- need to monitor and adjust the "every month or so" bits
	-- locality_name is unique so those will never be duplicates
	-- but grab them anyway so we can flag them as being checked
	for r in (
		select * from locality where rownum<20 and (last_dup_check_date is null or sysdate-last_dup_check_date > 30)
	) loop
			--dbms_output.put_line(r.locality_id);
			--dbms_output.put_line(r.SPEC_LOCALITY);
			--dbms_output.put_line(r.last_dup_check_date);
		for dups in (
			select * from locality where
				LOCALITY_ID	!= r.LOCALITY_ID and
				GEOG_AUTH_REC_ID=r.GEOG_AUTH_REC_ID and
				nvl(SPEC_LOCALITY,'NULL')=nvl(r.SPEC_LOCALITY,'NULL') and
				nvl(DEC_LAT,-9999)=nvl(r.DEC_LAT,-9999) and
				nvl(DEC_LONG,-9999)=nvl(r.DEC_LONG,-9999) and
				nvl(MINIMUM_ELEVATION,-9999)=nvl(r.MINIMUM_ELEVATION,-9999) and
				nvl(MAXIMUM_ELEVATION,-9999)=nvl(r.MAXIMUM_ELEVATION,-9999) and
				nvl(ORIG_ELEV_UNITS,'NULL')=nvl(r.ORIG_ELEV_UNITS,'NULL') and
				nvl(MIN_DEPTH,-9999)=nvl(r.MIN_DEPTH,-9999) and
				nvl(MAX_DEPTH,-9999)=nvl(r.MAX_DEPTH,-9999) and
				nvl(DEPTH_UNITS,'NULL')=nvl(r.DEPTH_UNITS,'NULL') and
				nvl(MAX_ERROR_DISTANCE,-9999)=nvl(r.MAX_ERROR_DISTANCE,-9999) and
				nvl(MAX_ERROR_UNITS,'NULL')=nvl(r.MAX_ERROR_UNITS,'NULL') and
				nvl(DATUM,'NULL')=nvl(r.DATUM,'NULL') and
				nvl(LOCALITY_REMARKS,'NULL')=nvl(r.LOCALITY_REMARKS,'NULL') and
				nvl(GEOREFERENCE_SOURCE,'NULL')=nvl(r.GEOREFERENCE_SOURCE,'NULL') and
				nvl(GEOREFERENCE_PROTOCOL,'NULL')=nvl(r.GEOREFERENCE_PROTOCOL,'NULL') and
				nvl(LOCALITY_NAME,'NULL')=nvl(r.LOCALITY_NAME,'NULL') and
				nvl(md5hash(WKT_POLYGON),'NULL')=nvl(md5hash(r.WKT_POLYGON),'NULL') and
				nvl(concatGeologyAttributeDetail(locality_id),'NULL')=nvl(concatGeologyAttributeDetail(r.locality_id),'NULL')
		) loop
			BEGIN
				i:=i+1;
				--dbms_output.put_line('dup loc ID: ' || dups.locality_id);
				-- log; probably won't go to prod
				-- this seems happy; turn off the logging
				--update temp_pre_dup_locality set merged_as_duplicate_of_locid = r.locality_id where locality_id=dups.locality_id;
				-- send the trigger "it''s just me plz ignore"
				update 
					collecting_event 
				set 
					locality_id=r.locality_id, 
					admin_flag = 'proc auto_merge_locality' 
				where 
					locality_id=dups.locality_id;
				
				update 
					tag 
				set 
					locality_id=r.locality_id 
				where 
					locality_id=dups.locality_id;

				update 
					media_relations 
				set 
					related_primary_key=r.locality_id 
				where
					media_relationship like '% locality' and
					related_primary_key =dups.locality_id;

				update 
					bulkloader 
				set 
					locality_id=r.locality_id 
				where 
					locality_id=dups.locality_id;

				-- geology already exists on the "keeper" locality, just delete
				delete from geology_attributes where locality_id=dups.locality_id;

				-- and delete the duplicate locality
				delete from locality where locality_id=dups.locality_id;
			exception when others then
				null;
				-- these happen (at least) when the initial query contains the duplicate
				-- ignore, they'll get caught next time around/eventually
				--dbms_output.put_line('FAIL ID: ' || dups.locality_id);
				--dbms_output.put_line(sqlerrm);
			end;
		end loop;
		-- now that we're merged, DELETE if unused and unnamed
		-- DO NOT delete named localities
		if r.LOCALITY_NAME is null then
			select sum(x) into c from (
				select count(*) x from collecting_event where locality_id=r.locality_id
				union
				select count(*) x from tag where locality_id=r.locality_id
				union
				select count(*) x from media_relations where media_relationship like '% locality' and related_primary_key =r.locality_id
				union
				select count(*) x from bulkloader where locality_id=r.locality_id
			);
			if c=0 then
				--dbms_output.put_line('not used deleting');
				delete from geology_attributes where locality_id=r.locality_id;
				delete from locality where locality_id=r.locality_id;
			end if;
		end if;

		-- log the last check
		update locality set last_dup_check_date=sysdate where locality_id=r.locality_id;

		-- if there are a lot of not-so-duplicates found, this can process many per run
		-- if there are a log of duplicates, it'll get all choked up on trying to update FLAT
		-- so throttle - if we haven't merged much then keep going, if we have exit and start over next run
		if i > 100 then
			--dbms_output.put_line('i maxout: ' || i);
			return;
		--else
			--dbms_output.put_line('i stillsmall: ' || i);
		end if;
	end loop;
end;
/
sho err;

exec auto_merge_locality;





select count(*) from locality;
select count(*) from locality where last_dup_check_date is null;

select count(*) from temp_pre_dup_locality where merged_as_duplicate_of_locid is not null ;

select to_char(last_dup_check_date,'yyyy-mm-dd'), count(*) from locality group by to_char(last_dup_check_date,'yyyy-mm-dd');


select (select count(*) from bak_locality20180403) - (select count(*) from locality) from dual;

select stale_flag,count(*) from flat group by stale_flag;



BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name           =>  'j_auto_merge_locality',
    job_type           =>  'STORED_PROCEDURE',
	job_action         =>  'auto_merge_locality',
	start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=minutely; interval=1',
	enabled            =>  TRUE,
	end_date           =>  NULL,
	comments           =>  '');
END;
/


 select START_DATE,REPEAT_INTERVAL,END_DATE,ENABLED,STATE,RUN_COUNT,FAILURE_COUNT,LAST_START_DATE,LAST_RUN_DURATION,NEXT_RUN_DATE from all_scheduler_jobs where lower(job_name)='j_auto_merge_locality';


exec DBMS_SCHEDULER.DROP_JOB (JOB_NAME => 'j_auto_merge_locality', FORCE => TRUE);








-- this was for testing/development
-- DO NOT put this into PROD!!
-- keep it around, because why not.

-- log this while testing
-- make sure it's not being dumb


create table temp_pre_dup_locality as select * from locality;

alter table temp_pre_dup_locality add merged_as_duplicate_of_locid number;


select * from temp_pre_dup_locality where merged_as_duplicate_of_locid is not null order by merged_as_duplicate_of_locid;
select * from locality where last_dup_check_date is not null;



drop table temp_keeper_locmerge;

create table temp_keeper_locmerge as select
	merged_as_duplicate_of_locid,
	LOCALITY_ID,
	GEOG_AUTH_REC_ID,
	SPEC_LOCALITY,
	DEC_LAT,
	DEC_LONG,
	MINIMUM_ELEVATION,
	MAXIMUM_ELEVATION,
	ORIG_ELEV_UNITS,
	MIN_DEPTH,
	MAX_DEPTH,
	DEPTH_UNITS,
	MAX_ERROR_DISTANCE,
	MAX_ERROR_UNITS,
	DATUM,
	LOCALITY_REMARKS,
	GEOREFERENCE_SOURCE,
	GEOREFERENCE_PROTOCOL,
	LOCALITY_NAME,
	md5hash(WKT_POLYGON) wkt_hash,
	concatGeologyAttributeDetail(locality_id) geoconcat
from
	temp_pre_dup_locality
where
	merged_as_duplicate_of_locid is not null;


insert into temp_keeper_locmerge (
	merged_as_duplicate_of_locid,
	LOCALITY_ID,
	GEOG_AUTH_REC_ID,
	SPEC_LOCALITY,
	DEC_LAT,
	DEC_LONG,
	MINIMUM_ELEVATION,
	MAXIMUM_ELEVATION,
	ORIG_ELEV_UNITS,
	MIN_DEPTH,
	MAX_DEPTH,
	DEPTH_UNITS,
	MAX_ERROR_DISTANCE,
	MAX_ERROR_UNITS,
	DATUM,
	LOCALITY_REMARKS,
	GEOREFERENCE_SOURCE,
	GEOREFERENCE_PROTOCOL,
	LOCALITY_NAME,
	wkt_hash,
	geoconcat
) (
	select distinct
		LOCALITY_ID,
		LOCALITY_ID,
		GEOG_AUTH_REC_ID,
		SPEC_LOCALITY,
		DEC_LAT,
		DEC_LONG,
		MINIMUM_ELEVATION,
		MAXIMUM_ELEVATION,
		ORIG_ELEV_UNITS,
		MIN_DEPTH,
		MAX_DEPTH,
		DEPTH_UNITS,
		MAX_ERROR_DISTANCE,
		MAX_ERROR_UNITS,
		DATUM,
		LOCALITY_REMARKS,
		GEOREFERENCE_SOURCE,
		GEOREFERENCE_PROTOCOL,
		LOCALITY_NAME,
		md5hash(WKT_POLYGON) ,
		concatGeologyAttributeDetail(locality_id)
	from
		temp_pre_dup_locality
	where
		locality_id in (select distinct merged_as_duplicate_of_locid from temp_pre_dup_locality where merged_as_duplicate_of_locid is not null)
);

-- order for download
drop table temp_keeper_locmerge_dl;
create table temp_keeper_locmerge_dl as select * from temp_keeper_locmerge order by merged_as_duplicate_of_locid,LOCALITY_ID;






