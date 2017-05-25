
CREATE OR REPLACE PROCEDURE remove_expired_encumbrance IS 
BEGIN
	-- find encumbrances which have expired
	-- and which hold specimens that are encumbered in flat
	-- this will ignore encumbrances which don't mess with data (eg "restrict usage")
	-- and those which have already been expired
	FOR r IN (
		SELECT DISTINCT 
		    encumbrance.encumbrance_id
		from
			encumbrance,
			coll_object_encumbrance,
			flat
		where
			-- expired
			encumbrance.EXPIRATION_DATE < sysdate and
			encumbrance.encumbrance_id=coll_object_encumbrance.encumbrance_id and
			coll_object_encumbrance.collection_object_id=flat.collection_object_id and
			-- doing something
			flat.encumbrances is not null
	) loop		
		update flat set stale_flag=1 where collection_object_id in (
			select collection_object_id from coll_object_encumbrance where encumbrance_id=r.encumbrance_id
		);
	END LOOP;
END;
/
sho err;


BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'j_remove_expired_encumbrance',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'remove_expired_encumbrance',
		start_date		=> to_timestamp_tz('30-APR-2010 00:00:00', 'DD-MON-YYYY HH24:MI:SS'),
		repeat_interval	=> 'freq=daily; byhour=1; byminute=23',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'remove expired encumbrances from flat');
END;
/ 

