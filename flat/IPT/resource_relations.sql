
----------------------------------------- NEW TABLE: resource relationship --------------------------------------------
-- by request of JRW
-- view names are weird
-- drop table ipt_oldoccurrenceIDs;
create table ipt_oldoccurrenceIDs as select
	'http://arctos.database.museum/guid/'  || filtered_flat.guid || '?seid=' || specimen_event.specimen_event_id occurrenceID,
    'urn:occurrence:Arctos:' || filtered_flat.guid || ':' || specimen_event.specimen_event_id relatedResourceID,
    'sameAs' relationshipOfResource,
    collection_id collectionID
from
	filtered_flat,
	specimen_event
where
	filtered_flat.collection_object_id=specimen_event.collection_object_id and
	specimen_event.verificationstatus != 'unaccepted'
;


create or replace public synonym ipt_oldoccurrenceIDs for ipt_oldoccurrenceIDs;
grant select on ipt_oldoccurrenceIDs to public;
create or replace view digir_query.oldoccurrenceIDs as select * from ipt_oldoccurrenceIDs;
select * from digir_query.oldoccurrenceIDs where rownum<10;


select count(*) from digir_query.oldoccurrenceIDs;

-- procedure to rebuild
CREATE OR REPLACE PROCEDURE proc_ref_ipt_relt_resrce IS
BEGIN
	execute immediate 'truncate table ipt_oldoccurrenceIDs';
	insert into ipt_oldoccurrenceIDs ( 
		occurrenceID,
		relatedResourceID,
		relationshipOfResource,
		collectionID
	) (
		select
			'http://arctos.database.museum/guid/'  || filtered_flat.guid || '?seid=' || specimen_event.specimen_event_id,
    		'urn:occurrence:Arctos:' || filtered_flat.guid || ':' || specimen_event.specimen_event_id,
    		'sameAs',
    		collection_id
		from
			filtered_flat,
			specimen_event
		where
			filtered_flat.collection_object_id=specimen_event.collection_object_id and
			specimen_event.verificationstatus != 'unaccepted'
	);
end;
/
sho err;
-- monthly refresh
-- this just takes a few minutes
-- run it at 10:30PM

BEGIN
  DBMS_SCHEDULER.drop_job (
   job_name => 'j_proc_ref_ipt_relt_resrce',
   force    => TRUE);
END;
/

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'j_proc_ref_ipt_relt_resrce',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'proc_ref_ipt_relt_resrce',
    enabled     => TRUE,
    start_date  =>  '26-AUG-17 10.30.00 AM -05:00',
   repeat_interval    =>  'freq=monthly; bymonthday=26'
  );
END;
/ 

select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION from all_scheduler_jobs where lower(JOB_NAME)='j_proc_ref_ipt_relt_resrce';



-- immediate refresh
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_TEMP_UPDATE_JUNK',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'j_proc_ref_ipt_relt_resrce',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/ 
select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION,systimestamp from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';




----------------------------------------- /NEW TABLE: resource relationship --------------------------------------------
