
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
		select * from locality where rownum<50 and (last_dup_check_date is null or sysdate-last_dup_check_date > 30) order by last_dup_check_date desc
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
				dbms_output.put_line('dup loc ID: ' || dups.locality_id);
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
		dbms_output.put_line('check delete');
		dbms_output.put_line('r.locality_id:'||r.locality_id);
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
				dbms_output.put_line('not used deleting');
				--delete from geology_attributes where locality_id=r.locality_id;
				--delete from locality where locality_id=r.locality_id;
			end if;
		end if;

		-- log the last check
		--update locality set last_dup_check_date=sysdate where locality_id=r.locality_id;

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