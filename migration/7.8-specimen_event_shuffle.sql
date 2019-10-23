


--on hold waiting resolution of https://github.com/ArctosDB/arctos/issues/739
-- #739 is now https://github.com/ArctosDB/arctos/issues/1023
-- go go go!



/*
 * 
 
 Final event type vocabulary:
 
 
    use - Event at which an item was used. Generally refers to human use of cultural items.
    manufacture - Event at which an item was manufactured. Generally refers to human manufacture of cultural items, but could be extended to e.g., nests.
    encounter - Individual Specimen was encountered and not killed or removed from context; Biological Samples were taken. Biopsies belong here.
    observation - IndividualSpecimen was detected and not killed or removed from context; No biological samples were taken. Human sightings, camera traps, and GPS telemetry data are appropriate here.
    collection - Specimen was collected. The specimen was killed, found dead, or removed from functional cultural, biological, ecological, or archeological context.



 *
 */










-- delay flat updates

LOCK TABLE specimen_event IN EXCLUSIVE MODE NOWAIT;

 exec DBMS_SCHEDULER.DROP_JOB (JOB_NAME => 'check_flat_stale', FORCE => TRUE);


alter table specimen_event add verified_by_agent_id number;

ALTER TABLE SPECIMEN_EVENT add CONSTRAINT fk_SPECIMEN_EVENT_vfdby FOREIGN KEY (verified_by_agent_id) REFERENCES agent (agent_id);

alter table specimen_event add verified_date varchar2(30);

select trigger_name from all_triggers where table_name='SPECIMEN_EVENT';

CREATE OR REPLACE TRIGGER trg_SPECIMEN_EVENT_biu
    BEFORE INSERT OR UPDATE ON SPECIMEN_EVENT
    FOR EACH ROW
    declare status varchar2(255);
    BEGIN
        if :new.SPECIMEN_EVENT_ID is null then
        	select sq_specimen_event_id.nextval into :new.SPECIMEN_EVENT_ID from dual;
        end if;
        if :new.VERIFICATIONSTATUS is null then
        	:new.VERIFICATIONSTATUS:='unverified';
        end if;
        if :new.specimen_event_type is null then
        		:new.specimen_event_type:='collection';
        end if;
        status:=is_iso8601(:NEW.verified_date);
    	IF status != 'valid' THEN
        	raise_application_error(-20001,'Verified Date: ' || status);
    	END IF;
    end;
/


insert into CTSPECIMEN_EVENT_TYPE (SPECIMEN_EVENT_TYPE,DESCRIPTION) values 
	('collection','Specimen was collected. The specimen was killed, found dead, or removed from functional cultural, biological, ecological, or archeological context.');


update CTSPECIMEN_EVENT_TYPE set 
	DESCRIPTION='Specimen was encountered and not killed or removed from context; Biological Samples were taken. Biopsies belong here.' 
	where SPECIMEN_EVENT_TYPE='encounter';
	
update CTSPECIMEN_EVENT_TYPE set 
	DESCRIPTION='Specimen was detected and not killed or removed from context; No biological samples were taken. Human sightings, camera traps, and GPS telemetry data are appropriate here.' 
	where SPECIMEN_EVENT_TYPE='observation';
	
	
	insert into CTSPECIMEN_EVENT_TYPE (SPECIMEN_EVENT_TYPE,DESCRIPTION) values 
	('use','Event at which an item was used. Generally refers to human use of cultural items.');
	
	
	

insert into CTSPECIMEN_EVENT_TYPE (SPECIMEN_EVENT_TYPE,DESCRIPTION) values 
	('manufacture','Event at which an item was manufactured. Generally refers to human manufacture of cultural items, but could be extended to e.g., nests.');

	


    
    



	
update CTVERIFICATIONSTATUS set 
	DESCRIPTION='No assertion regarding the accuracy of the place and time information is made.' 
	where VERIFICATIONSTATUS='unverified';

	
insert into CTVERIFICATIONSTATUS (VERIFICATIONSTATUS,DESCRIPTION) values 
	('unaccepted',
	'The place and time information as entered was reviewed and determined to be incorrect, or less correct or complete than other available data.'
);
		
	
insert into CTVERIFICATIONSTATUS (VERIFICATIONSTATUS,DESCRIPTION) values 
	('accepted',
	'The place and time information as entered was checked and determined to be correct against the information available from Arctos; original data were not consulted, and transcription or omission errors are possible.'
);
	
insert into CTVERIFICATIONSTATUS (VERIFICATIONSTATUS,DESCRIPTION) values 
	('verified and locked',
	'The place and time information as entered was checked against all available data, including labels, fieldnotes, collector itineraries, and associated digital data, and determined to be correct. Changes should only be made in the extremely unlikely event of more authoritative data surfacing. This value LOCKS linked Locality and Event data.'
);
	


select 
	VERIFICATIONSTATUS,
	guid_prefix,
	count(*) 
from 
	specimen_event,
	cataloged_item,
	collection
where 
	specimen_event.collection_object_id=cataloged_item.collection_object_id and
	cataloged_item.collection_id=collection.collection_id and	
	SPECIMEN_EVENT_TYPE='unaccepted place of collection' and
	verificationstatus!='unverified'
group by 
	guid_prefix,
	VERIFICATIONSTATUS;

select 
	guid_prefix || ':' || cat_num guid
from 
	specimen_event,
	cataloged_item,
	collection
where 
	specimen_event.collection_object_id=cataloged_item.collection_object_id and
	cataloged_item.collection_id=collection.collection_id and	
	SPECIMEN_EVENT_TYPE='unaccepted place of collection' and
	verificationstatus!='unverified'
;


-- this is super-slow so...


CREATE OR REPLACE PROCEDURE temp_update_junk IS
begin
  update specimen_event set verificationstatus='unaccepted' where specimen_event_type='unaccepted place of collection';
end;
/


BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_TEMP_UPDATE_JUNK',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_junk',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/ 

select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';


CREATE OR REPLACE PROCEDURE temp_update_junk IS
begin
  update specimen_event set specimen_event_type='collection' where specimen_event_type='unaccepted place of collection';
end;
/

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_TEMP_UPDATE_JUNK',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_junk',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/ 

select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';



alter trigger TRG_SPECIMEN_EVENT_AU_FLAT disable;
alter trigger  trg_SPECIMEN_EVENT_aiu disable;




CREATE OR REPLACE PROCEDURE temp_update_junk IS
begin
  update specimen_event set specimen_event_type='collection' where specimen_event_type='accepted place of collection' and rownum<250000;
end;
/

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_TEMP_UPDATE_JUNK',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_junk',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/ 

select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';

delete from ctspecimen_event_type where specimen_event_type='accepted place of collection';



select count(*) from specimen_event where specimen_event_type='accepted place of collection';



select stale_flag,count(*) from flat group by stale_flag;




CREATE OR REPLACE PROCEDURE temp_update_junk IS
begin
  update specimen_event set specimen_event_type='manufacture' where specimen_event_type='place of manufacture';
end;
/

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_TEMP_UPDATE_JUNK',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_junk',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/ 

select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';




CREATE OR REPLACE PROCEDURE temp_update_junk IS
begin
  update specimen_event set specimen_event_type='use' where specimen_event_type='place of use';
end;
/


BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_TEMP_UPDATE_JUNK',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_junk',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/ 

select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';

select count(*) from specimen_event where specimen_event_type='unaccepted place of collection';

select count(*) from specimen_event where specimen_event_type='place of manufacture';

delete from ctspecimen_event_type where specimen_event_type='place of manufacture';
delete from ctspecimen_event_type where specimen_event_type='place of use';


delete from ctspecimen_event_type where specimen_event_type='unaccepted place of collection';


 select * from ctverification_status;
 

 
 select count(*) from specimen_event where VERIFICATIONSTATUS='unaccepted';
 select count(*) from specimen_event where VERIFICATIONSTATUS='accepted';
 select count(*) from specimen_event where VERIFICATIONSTATUS='checked by curator';
 
 
 select distinct SPECIMEN_EVENT_REMARK from specimen_event where VERIFICATIONSTATUS='accepted' order by SPECIMEN_EVENT_REMARK;
 


 update specimen_event set VERIFICATIONSTATUS='accepted', 
 SPECIMEN_EVENT_REMARK=decode(SPECIMEN_EVENT_REMARK,
 	null,'Former verification status: checked by curator.',
 	SPECIMEN_EVENT_REMARK || '; Former verification status: checked by curator.')
 where VERIFICATIONSTATUS='checked by curator';
 
 
 
  update specimen_event set VERIFICATIONSTATUS='accepted', 
 SPECIMEN_EVENT_REMARK=decode(SPECIMEN_EVENT_REMARK,
 	null,'Former verification status: checked by curator.',
 	SPECIMEN_EVENT_REMARK || '; Former verification status: checked by curator.')
 where VERIFICATIONSTATUS='checked by curator';
 
   update specimen_event set VERIFICATIONSTATUS='accepted', 
 SPECIMEN_EVENT_REMARK=decode(SPECIMEN_EVENT_REMARK,
 	null,'Former verification status: checked by collector.',
 	SPECIMEN_EVENT_REMARK || '; Former verification status: checked by collector.')
 where VERIFICATIONSTATUS='checked by collector';
 
 
 
    update specimen_event set VERIFICATIONSTATUS='verified and locked', 
 SPECIMEN_EVENT_REMARK=decode(SPECIMEN_EVENT_REMARK,
 	null,'Former verification status: verified by collector.',
 	SPECIMEN_EVENT_REMARK || '; Former verification status: verified by collector.')
 where VERIFICATIONSTATUS='verified by collector';
 
   update specimen_event set VERIFICATIONSTATUS='verified and locked', 
 SPECIMEN_EVENT_REMARK=decode(SPECIMEN_EVENT_REMARK,
 	null,'Former verification status: verified by curator.',
 	SPECIMEN_EVENT_REMARK || '; Former verification status: verified by curator.')
 where VERIFICATIONSTATUS='verified by curator';

 
 delete from ctVERIFICATIONSTATUS where VERIFICATIONSTATUS='verified by curator';
  delete from ctVERIFICATIONSTATUS where VERIFICATIONSTATUS='verified by collector';
 delete from ctVERIFICATIONSTATUS where VERIFICATIONSTATUS='checked by curator';
  delete from ctVERIFICATIONSTATUS where VERIFICATIONSTATUS='checked by collector';

  
  
  select 
  	VERIFICATIONSTATUS, 
  	SPECIMEN_EVENT_REMARK from specimen_event group by VERIFICATIONSTATUS, 
  	SPECIMEN_EVENT_REMARK order by SPECIMEN_EVENT_REMARK;

 

    
 -- turn flat updates back on
 
  	
  	alter trigger TRG_SPECIMEN_EVENT_AU_FLAT enable;
alter trigger  trg_SPECIMEN_EVENT_aiu enable;

  	update flat set stale_flag=1 where stale_flag=0 and rownum<1000000;
  	
  	
  	select stale_flag,count(*) from flat group by stale_flag;
  	
  	
 
    BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name           =>  'check_flat_stale',
    job_type           =>  'STORED_PROCEDURE',
	job_action         =>  'IS_FLAT_STALE',
	start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=minutely; interval=1',
	enabled            =>  TRUE,
	end_date           =>  NULL,
	comments           =>  'check flat for records marked as stale and update them');
END;
/

CREATE OR REPLACE TRIGGER TR_COLLECTINGEVENT_BUD....


compress and swap
ajax.js
specimenresults.js
style.css

create or replace function getJsonEventBySpecimen (colObjId IN number)....


add to popdocs
json_locality	JSON Locality			Locality stack in JSON				locality	99	yes	no	getJsonEventBySpecimen(flatTableName.collection_object_id)







------------------------------------- https://github.com/ArctosDB/arctos/issues/1755 edits----------------------------------------
-- comment out service-derived data
-- refresh, hope....
UAM@ARCTOS> select count(*) from cache_anygeog;

  COUNT(*)
----------
   3,834,085

   exec pause_maintenance('off');
   update cache_anygeog set stale_fg=1;
      exec pause_maintenance('on');

   select stale_fg,count(*) from cache_anygeog group by stale_fg;
   exec pause_maintenance('on');

   
   -- Plan B-or-so
   alter table flat add locality_search_terms varchar2(4000);
   
   
   create or replace function getFlatLocalitySearchTerms.....
   
   flat_procedures
   filtered_flat
			
	-- not needed for this approach
	exec DBMS_SCHEDULER.DROP_JOB (JOB_NAME => 'J_UPDATE_CACHE_ANYGEOG', FORCE => TRUE);

			----initial update
			
			update flat set locality_search_terms=getFlatLocalitySearchTerms(collection_object_id) where stale_flag!=1 and locality_search_terms is null and rownum<100000;
			
			select count(*) from flat where locality_search_terms='pending';
			select count(*) from flat where locality_search_terms is null;
			
			update flat set locality_search_terms='pending' where locality_search_terms  is null;
			update flat set locality_search_terms=getFlatLocalitySearchTerms(collection_object_id) where locality_search_terms='pending' and rownum<100000;
			
			create index ix_f_loc_srch_trm on flat(locality_search_terms) tablespace uam_idx_1;
			create index ix_f_f_loc_srch_trm on flat(locality_search_terms) tablespace uam_idx_1;
			
			update filtered_flat set locality_search_terms='pending' where locality_search_terms  is null;

			select count(*) from filtered_flat where locality_search_terms is null;
						
			
			
			DROP INDEX ix_f_txt_tloc_srch_trms;
			DROP INDEX ix_f_f_txt_tloc_srch_trms;
			
			CTXCAT
			
			CREATE INDEX ix_f_txt_tloc_srch_trms ON flat(locality_search_terms) INDEXTYPE IS CTXSYS.CTXCAT;
			
			PARAMETERS ('SYNC (EVERY "SYSDATE + 1/24")'); 

		exec ctx_ddl.drop_preference ( 'idx_tablespace' );
exec ctx_ddl.create_preference( 'idx_tablespace', 'UAM_IDX_1' );
exec ctx_ddl.set_attribute ( 'idx_tablespace', 'UAM_IDX_1', 'true' );



			-- this may be messing with performance
			-- try hourly below
		--	CREATE INDEX ix_f_txt_tloc_srch_trms ON flat(locality_search_terms) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS ('sync (on commit)'); 
		--	CREATE INDEX ix_f_f_txt_tloc_srch_trms ON FILTERED_flat(locality_search_terms) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS ('sync (on commit)'); 
			-- hourly
			drop index ix_f_f_txt_tloc_srch_trms;
			CREATE INDEX ix_f_f_txt_tloc_srch_trms ON FILTERED_flat(locality_search_terms) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS ('sync (EVERY "SYSDATE + 1/24")'); 
			drop index ix_f_txt_tloc_srch_trms;
			CREATE INDEX ix_f_txt_tloc_srch_trms ON flat(locality_search_terms) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS ('sync (EVERY "SYSDATE + 1/24")'); 

			
		CREATE INDEX ix_f_has_tissues ON flat(has_tissues) tablespace uam_idx_1;
		
		
		
			CREATE INDEX message_content_ctx_ix ON my_test_table(message_content)
  INDEXTYPE IS CTXSYS.CONTEXT
  PARAMETERS ('SYNC (EVERY "SYSDATE + 15/24")');
 
  
  
  
			CREATE INDEX ix_f_f_txt_tloc_srch_trms ON FILTERED_flat(locality_search_terms) INDEXTYPE IS CTXSYS.CONTEXT; 
			
			SELECT COUNT(*) FROM flat WHERE CONTAINS (locality_search_terms, 'BARROW') > 0;
						SELECT COUNT(*) FROM flat WHERE locality_search_terms LIKE '%BARROW%';

			
			
			
CREATE OR REPLACE PROCEDURE temp_update_junk 
is begin
				update filtered_flat set locality_search_terms=(select locality_search_terms from flat where filtered_flat.collection_object_id=flat.collection_object_id)
				where locality_search_terms is null and rownum<100000;
				
	end;
/

BEGIN
  DBMS_SCHEDULER.drop_job (
   job_name => 'J_TEMP_UPDATE_JUNK',
   force    => TRUE);
END;
/





		select getFlatLocalitySearchTerms(12) from dual;
   select getFlatLocalitySearchTerms(collection_object_id) from flat where rownum<100;
   
------------------------------------- END https://github.com/ArctosDB/arctos/issues/1755 ----------------------------------------

-- cache any_geog search
-- get this going at prod - BELOW HERE IS DONE AT PROD

create table cache_anygeog (
	specimen_event_id number,
	collecting_event_id number,
	locality_id number,
	geog_auth_rec_id number,
	stale_fg number,
	geostring varchar2(4000)
);

create public synonym cache_anygeog for cache_anygeog;

grant select on cache_anygeog to public;

-- insert into cache_anygeog when inserting specimen_event
CREATE OR REPLACE TRIGGER trg_SPECIMEN_EVENT_aiu
    AFTER INSERT OR UPDATE ON SPECIMEN_EVENT
    FOR EACH ROW
    		declare c number;
    BEGIN
	    select count(*) into c from cache_anygeog where specimen_event_id=:NEW.specimen_event_id;
	    if c=0 then
	    		insert into cache_anygeog(specimen_event_id,collecting_event_id) values (:NEW.specimen_event_id,:NEW.collecting_event_id);
	    	end if;
	    update cache_anygeog set stale_fg=1,collecting_event_id=:NEW.collecting_event_id where specimen_event_id=:NEW.specimen_event_id;
	END;
/

-- does it work?




-- update specimen_event set specimen_event_id=specimen_event_id where collecting_event_id=10207700;
-- select * from cache_anygeog;
--- sweet!

CREATE OR REPLACE PROCEDURE UPDATE_cache_anygeog IS 
	lid number;
	gid number;
	s varchar2(4000);
begin
	for r in (
		select collecting_event_id from (
			select collecting_event_id,lastdate from cache_anygeog where stale_fg=1 group by collecting_event_id,lastdate order by lastdate
		) where rownum<2500 group by collecting_event_id
	) loop
		--dbms_output.put_line('collecting_event_id: ' || r.collecting_event_id);
		--- first grab identifiers
		-- sometimes something gets deleted - ignore it
		begin
			select
				locality.locality_id,
				locality.geog_auth_rec_id
			INTO
				lid,
				gid
			from
				collecting_event,
				locality
			where
				collecting_event.locality_id=locality.locality_id and
				collecting_event.collecting_event_id=r.collecting_event_id
			;
			--dbms_output.put_line('lid: ' || lid);
			--dbms_output.put_line('gid: ' || gid);

			update cache_anygeog set 
				stale_fg=0,
				locality_id=lid,
				geog_auth_rec_id=gid,
				lastdate=sysdate,
				geostring=(
				select substr(terms,0,4000) from (
					select listagg(term,', ') within group(order by term) terms
					  from (
							select
						    		upper(geog_search_term.search_term) term
						    	from
								collecting_event,locality,geog_search_term
							where
								geog_search_term.search_term is not null and
								collecting_event.collecting_event_id=r.collecting_event_id and
								collecting_event.locality_id=locality.locality_id and
								locality.geog_auth_rec_id=geog_search_term.geog_auth_rec_id
							UNION
								select
									upper(spec_locality) term
								from
									collecting_event,locality
								where
									spec_locality is not null and
									collecting_event.collecting_event_id=r.collecting_event_id and
									collecting_event.locality_id=locality.locality_id 
							UNION
								select
									upper(higher_geog) term
								from
									collecting_event,locality,geog_auth_rec
								where
									collecting_event.collecting_event_id=r.collecting_event_id and
									collecting_event.locality_id=locality.locality_id and
									locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id 
							/*
							 *  https://github.com/ArctosDB/arctos/issues/1755 edits----------------------------------------
							 * comment out service-derived data
							 * refresh, hope....
							UNION
								select
									upper(S$GEOGRAPHY) term
								from
									collecting_event,locality
								where
									S$GEOGRAPHY is not null and
									collecting_event.collecting_event_id=r.collecting_event_id and
									collecting_event.locality_id=locality.locality_id
							*/
							UNION
								select
									upper(LOCALITY_NAME) term
								from
									collecting_event,locality
								where
									LOCALITY_NAME is not null and
									collecting_event.collecting_event_id=r.collecting_event_id and
									collecting_event.locality_id=locality.locality_id
							UNION
								select
									upper(verbatim_locality) term
								from
									collecting_event
								where
									verbatim_locality is not null and
									collecting_event.collecting_event_id=r.collecting_event_id 
					    )
					)
				) where
				collecting_event_id=r.collecting_event_id;
			exception when others then
				--null;
				s:=SQLERRM;
				update cache_anygeog set 
				stale_fg=0,
				geostring='ERROR: ' || s
				where
				collecting_event_id=r.collecting_event_id ;
				--dbms_output.put_line('im handling errors');
			end;
	end loop;
end;
/
sho err;


select STALE_FG,count(*) from cache_anygeog group by STALE_FG;



	
	
	-- works?
	exec UPDATE_cache_anygeog;
	select * from cache_anygeog;
	--- sweet!

	-- clear testing
	delete from cache_anygeog;
	
	-- pre-prime
	insert into cache_anygeog (
		specimen_event_id,
		collecting_event_id,
		stale_fg
	) (select
		specimen_event_id,
		collecting_event_id,
		1
	from
		specimen_event
	);
	

	
	
	
	
	
	exec DBMS_SCHEDULER.DROP_JOB (JOB_NAME => 'J_UPDATE_CACHE_ANYGEOG', FORCE => TRUE);
	alter table cache_anygeog add lastdate date;
	
	update cache_anygeog set lastdate=to_date('2018-03-01');
	
	
	select collecting_event_id from cache_anygeog where stale_fg=1 and rownum<100 group by collecting_event_id
	
	select collecting_event_id from (
		select collecting_event_id,lastdate from cache_anygeog where stale_fg=1 group by collecting_event_id order by lastdate
	) where rownum<100 group by collecting_event_id;
	
	select * from (
	select collecting_event_id,ASSIGNED_DATE from specimen_event group by collecting_event_id,ASSIGNED_DATE order by ASSIGNED_DATE
	) where rownum<100;

	
	-- now triggers to set the stale flag
	--in flat_triggers
	CREATE OR REPLACE TRIGGER TR_LOCALITY_AU_FLAT....

	CREATE OR REPLACE TRIGGER TR_GEOGAUTHREC_AU_FLAT....

	CREATE OR REPLACE TRIGGER TR_geog_search_term_AU_FLAT....
	
	CREATE OR REPLACE TRIGGER TR_COLLEVENT_AU_FLAT....
	
	
	
	
	-- indexes
	
    create index ix_cache_anygeog_seid on cache_anygeog (specimen_event_id) tablespace uam_idx_1; 
    create index ix_cache_anygeog_geostr on cache_anygeog (geostring) tablespace uam_idx_1; 
	create index ix_cache_anygeog_ceid on cache_anygeog (collecting_event_id) tablespace uam_idx_1; 
	create index ix_cache_anygeog_locid on cache_anygeog (LOCALITY_ID) tablespace uam_idx_1; 
	create index ix_cache_anygeog_stfg on cache_anygeog (stale_fg) tablespace uam_idx_1; 
    
	desc all_indexes
    
    select * from all_indexes where lower(index_name)='ix_cache_anygeog_geostr';
	-- and a new job to maintain
	-- in flat_jobs
	
 BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name           =>  'J_UPDATE_CACHE_ANYGEOG',
    ....
    
    
    
    
    
    
    
    select stale_fg,count(*) from cache_anygeog group by stale_fg;
    
    select count(*) from cache_anygeog where geostring like '%CALIFORNIA%';
    
    
    
    
    
    select count(*) from cache_anygeog where geostring is not null;

	-- index
	



CREATE OR REPLACE TRIGGER trg_SPECIMEN_EVENT_AD....
    --- garbage below
    
    
    
    
    
    
    
    
    
    
    
    
