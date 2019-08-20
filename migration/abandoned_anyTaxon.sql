-- 20180402:  still cooking no code on this, test performance is bat ATM not very easy to test
--https://github.com/ArctosDB/arctos/issues/1485

-- meh, let's try normalized

drop table cache_anytaxonname;


create table cache_anytaxonname (
	collection_object_id number,
	taxon_name_id number,
	stale_fg number,
	taxonstring varchar2(4000)
);


CREATE OR REPLACE PROCEDURE temp_update_junk IS
begin

insert into cache_anytaxonname (
	collection_object_id,
	taxon_name_id,
	stale_fg
) (
	select distinct 
		identification.collection_object_id,
		identification_taxonomy.taxon_name_id,
		1 
	from 
		identification,
		identification_taxonomy
	where 
		identification.collection_object_id not in (select collection_object_id from cache_anytaxonname) and
		identification.identification_id=identification_taxonomy.identification_id 
);
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

select count(*) from cache_anytaxonname;

-- PLAN C
-- just make a table of taxonomy terms which are used in IDs


drop table cache_anytaxonname;

create table cache_anytaxonname (
	taxon_name_id number,
	stale_fg number,
	taxonstring varchar2(4000)
);



create index ix_cache_anytaxonname_tid on cache_anytaxonname (taxon_name_id) tablespace uam_idx_1;
create index ix_cache_anytaxonname_ts on cache_anytaxonname (taxonstring) tablespace uam_idx_1;

alter index ix_cache_anytaxonname_ts rebuild;

insert into cache_anytaxonname (taxon_name_id,stale_fg) (select taxon_name_id,1 from identification_taxonomy group by taxon_name_id);


CREATE OR REPLACE PROCEDURE UPDATE_cache_anytaxonname IS 
	lid number;
	gid number;
	s varchar2(4000);
	sep varchar2(2);
begin
	for r in (select distinct taxon_name_id from cache_anytaxonname where stale_fg=1 and rownum<1000) loop
		--dbms_output.put_line('collection_object_id: ' || r.collection_object_id);
		--dbms_output.put_line('taxon_name_id: ' || r.taxon_name_id);
		s:=null;
		sep:=null;
		--just delete
		delete from cache_anytaxonname where taxon_name_id=r.taxon_name_id;

		for t in (
			select tterm from (
				select 
					upper(taxon_term.term) tterm 
				from 
					taxon_term 
				where 
					taxon_term.POSITION_IN_CLASSIFICATION is not null and
					taxon_term.taxon_name_id=r.taxon_name_id
			    union 
			    select upper(common_name) tterm from common_name where common_name.taxon_name_id=r.taxon_name_id 
			    union
		    		select 
		    			upper(taxon_term.term) tterm 
		    		from 
		    			taxon_relations,
		    			taxon_term 
		    		where 
		    			taxon_term.POSITION_IN_CLASSIFICATION is not null and
		    			taxon_relations.related_taxon_name_id=taxon_term.taxon_name_id and 
		    			taxon_relations.taxon_name_id=r.taxon_name_id 
			    UNION 
		    		select 
		    			upper(taxon_term.term) tterm 
		    		from 
		    			taxon_relations,
		    			taxon_term 
		    		where 
		    			taxon_term.POSITION_IN_CLASSIFICATION is not null and
		    			taxon_relations.taxon_name_id=taxon_term.taxon_name_id and 
		    			taxon_relations.related_taxon_name_id=r.taxon_name_id 
			)
		group by tterm) loop
			insert into cache_anytaxonname (
				taxon_name_id,
				stale_fg,
				taxonstring
			) values (
				r.taxon_name_id,
				0,
				t.tterm
			);
		end loop;
 	end loop;
end;
/
sho err;



SELECT STALE_FG, COUNT(*) FROM cache_anytaxonname GROUP BY STALE_FG;


exec UPDATE_cache_anytaxonname;



 BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name           =>  'J_UPDATE_CACHE_ANYTAXONNAME',
    job_type           =>  'STORED_PROCEDURE',
	job_action         =>  'UPDATE_CACHE_ANYTAXONNAME',
	start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=minutely; interval=1',
	enabled            =>  TRUE,
	end_date           =>  NULL,
	comments           =>  'check cache_anytaxonname for records marked as stale and update them');
END;
/

select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION from all_scheduler_jobs where JOB_NAME='J_UPDATE_CACHE_ANYTAXONNAME';

set autotrace traceonly;


select 
	count(*) 
from
	cache_anytaxonname,
	identification_taxonomy,
	identification
where
	identification.identification_id=identification_taxonomy.identification_id and
	identification_taxonomy.taxon_name_id=cache_anytaxonname.taxon_name_id and
	cache_anytaxonname.taxonstring like '%SCIURUS%'
;



select 
	count(*) 
from 
	flat,
	identification, 
	identification_taxonomy,
	cache_anytaxonname 
where
	flat.collection_object_id=identification.collection_object_id and
	identification.identification_id=identification_taxonomy.identification_id and
	identification_taxonomy.taxon_name_id=cache_anytaxonname.taxon_name_id and
	cache_anytaxonname.taxonstring like '%SCIURUS%'
;


BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'UAM'
     ,TabName        => 'FLAT'
    ,Cascade           => TRUE);
END;


-- TEST THIS AT TEST!!!
-- copy back to proper place if it works
CREATE OR REPLACE TRIGGER TR_IDTAXONOMY_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON IDENTIFICATION_TAXONOMY
FOR EACH ROW
DECLARE 
	id NUMBER;
	tid number;
BEGIN
    IF deleting THEN 
        id := :OLD.identification_id;
        tid := :OLD.taxon_name_id;
    ELSE 
        id := :NEW.identification_id;
        tid := :NEW.taxon_name_id;
    END IF;
       
    	insert into cache_anytaxonname(taxon_name_id,stale_fg) values (tid,1);

    	UPDATE flat SET 
        stale_flag = 1,
        lastuser = sys_context('USERENV', 'SESSION_USER'),
        lastdate = SYSDATE
    WHERE identification_id = id;
END;



-- TEST THIS AT TEST!!!
-- copy back to proper place if it works
create or replace trigger trg_pushtaxontermtoflat after insert or update or delete on taxon_term
	FOR EACH ROW 
	begin
		-- just insert into the any taxon term search cache	
		if inserting or updating then
			insert into cache_anytaxonname(taxon_name_id,stale_fg) values (:NEW.taxon_name_id,1);
		end if;
		if deleting then
			insert into cache_anytaxonname(taxon_name_id,stale_fg) values (:OLD.taxon_name_id,1);
		end if;
		-- capture insert and changes
		-- push them to flat as necessary

		if inserting then
			-- there is no OLD data
			-- flat always deals with ranked terms, so just ignore anything that's not
			if :NEW.term_type is not null THEN
				insert into taxon_term_updated (
					taxon_name_id,
					term_type,
					source
				) values (
					:NEW.taxon_name_id,
					:NEW.term_type,
					:NEW.source
				);
			end if;
		elsif deleting then
			-- there is no NEW data 
			-- flat always deals with ranked terms, so just ignore anything that's not
			if :OLD.term_type is not null THEN
				insert into taxon_term_updated (
					taxon_name_id,
					term_type,
					source
				) values (
					:OLD.taxon_name_id,
					:OLD.term_type,
					:OLD.source
				);
			end if;
		elsif updating then
			--dbms_output.put_line(:NEW.term_type);
			--dbms_output.put_line(:OLD.term_type);
			--dbms_output.put_line(:NEW.term);
			--dbms_output.put_line(:OLD.term);

			-- flat always deals with ranked terms, so just ignore anything that's not
			-- and we can ignore anything where term_type AND term did not change
			if (:NEW.term_type != :OLD.term_type or :NEW.term != :OLD.term) then
				--dbms_output.put_line(:NEW.term_type || '!=' || :OLD.term_type || ' OR ' || :NEW.term || '!=' || :OLD.term);
				-- and we can ignore anything where new and old term type are NULL
				if (:NEW.term_type is not null or :OLD.term_type is not null) THEN
					insert into taxon_term_updated (
						taxon_name_id,
						term_type,
						source
					) values (
						:NEW.taxon_name_id,
						:NEW.term_type,
						:NEW.source
					);
				end if;
			end if;
		end if;
	end;
/










-- PLAN B
-- insert ID string with INSERT or UPDATE to IDENTIFICATION
-- just synchronize taxonomy

CREATE OR REPLACE PROCEDURE UPDATE_cache_anytaxonname IS 
	lid number;
	gid number;
	s varchar2(4000);
	sep varchar2(2);
begin
	for r in (select collection_object_id,taxon_name_id from cache_anytaxonname where stale_fg=1 and rownum<1000) loop
		--dbms_output.put_line('collection_object_id: ' || r.collection_object_id);
		--dbms_output.put_line('taxon_name_id: ' || r.taxon_name_id);
		s:=null;
		sep:=null;
		--just delete
		delete from cache_anytaxonname where collection_object_id=r.collection_object_id;
				
		for t in (select upper(scientific_name) tterm from identification where collection_object_id=r.collection_object_id) loop
			insert into cache_anytaxonname (
				collection_object_id,
				taxon_name_id,
				stale_fg,
				taxonstring
			) values (
				r.collection_object_id,
				r.taxon_name_id,
				0,
				t.tterm
			);
		end loop;
		for t in (
				select tterm from (
					select 
						upper(taxon_term.term) tterm 
					from 
						taxon_term 
					where 
						taxon_term.POSITION_IN_CLASSIFICATION is not null and
						taxon_term.taxon_name_id=r.taxon_name_id
				    union 
				    select upper(common_name) tterm from common_name where common_name.taxon_name_id=r.taxon_name_id 
				    union
			    		select 
			    			upper(taxon_term.term) tterm 
			    		from 
			    			taxon_relations,
			    			taxon_term 
			    		where 
			    			taxon_term.POSITION_IN_CLASSIFICATION is not null and
			    			taxon_relations.related_taxon_name_id=taxon_term.taxon_name_id and 
			    			taxon_relations.taxon_name_id=r.taxon_name_id 
				    UNION 
			    		select 
			    			upper(taxon_term.term) tterm 
			    		from 
			    			taxon_relations,
			    			taxon_term 
			    		where 
			    			taxon_term.POSITION_IN_CLASSIFICATION is not null and
			    			taxon_relations.taxon_name_id=taxon_term.taxon_name_id and 
			    			taxon_relations.related_taxon_name_id=r.taxon_name_id 
				)
			group by tterm) loop
				insert into cache_anytaxonname (
					collection_object_id,
					taxon_name_id,
					stale_fg,
					taxonstring
				) values (
					r.collection_object_id,
					r.taxon_name_id,
					0,
					t.tterm
				);
			end loop;
		
 		


 	end loop;
end;
/
sho err;
UPDATE_cache_anytaxonname

SELECT STALE_FG, COUNT(*) FROM cache_anytaxonname GROUP BY STALE_FG;

 BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name           =>  'J_UPDATE_CACHE_ANYTAXONNAME',
    job_type           =>  'STORED_PROCEDURE',
	job_action         =>  'UPDATE_CACHE_ANYTAXONNAME',
	start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=minutely; interval=1',
	enabled            =>  TRUE,
	end_date           =>  NULL,
	comments           =>  'check cache_anytaxonname for records marked as stale and update them');
END;
/

select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION from all_scheduler_jobs where JOB_NAME='J_UPDATE_CACHE_ANYTAXONNAME';

select count(*) from cache_anytaxonname where taxonstring like 'CLETHRIONOMYS';

exec DBMS_SCHEDULER.DROP_JOB (JOB_NAME => 'J_UPDATE_CACHE_ANYTAXONNAME', FORCE => TRUE);



exec UPDATE_cache_anytaxonname;



create index ix_cache_anytaxonname_cid on cache_anytaxonname (collection_object_id) tablespace uam_idx_1;
create index ix_cache_anytaxonname_tid on cache_anytaxonname (taxon_name_id) tablespace uam_idx_1;
create index ix_cache_anytaxonname_ts on cache_anytaxonname (taxonstring) tablespace uam_idx_1;

select count(*) from cache_anytaxonname;













create table cache_anytaxonname (
	collection_object_id number,
	stale_fg number,
	taxonstring varchar2(4000)
);

insert into cache_anytaxonname (collection_object_id,stale_fg) (select distinct collection_object_id,1 from identification where rownum<500);

CREATE OR REPLACE PROCEDURE UPDATE_cache_anytaxonname IS 
	lid number;
	gid number;
	s varchar2(4000);
	sep varchar2(2);
begin
	for r in (select collection_object_id from cache_anytaxonname where stale_fg=1 and rownum<10) loop
		dbms_output.put_line('collection_object_id: ' || r.collection_object_id);
		s:=null;
		sep:=null;
				
		for t in (select upper(scientific_name) tterm from identification where collection_object_id=r.collection_object_id) loop
			if s is null or length(s) < 3990 then
				dbms_output.put_line('add: ' || t.tterm);
				s:=s||sep||t.tterm;
				sep:=',';
			else
				dbms_output.put_line('CANNOT add: ' || t.tterm);
			end if;
		end loop;
		
		for t in (
			select 
				taxon_name_id 
			from 
				identification, 
				identification_taxonomy 
			where 
				identification.identification_id=identification_taxonomy.identification_id and
				identification.collection_object_id=r.collection_object_id
			group by 
				taxon_name_id
		) loop
			dbms_output.put_line('taxon_name_id: ' || t.taxon_name_id);
			for x in (
				select tterm from (
					select 
						upper(taxon_term.term) tterm 
					from 
						taxon_term 
					where 
						taxon_term.POSITION_IN_CLASSIFICATION is not null and
						taxon_term.taxon_name_id=t.taxon_name_id
				    union 
				    select upper(common_name) tterm from common_name where common_name.taxon_name_id=t.taxon_name_id 
				    union
			    		select 
			    			upper(taxon_term.term) tterm 
			    		from 
			    			taxon_relations,
			    			taxon_term 
			    		where 
			    			taxon_term.POSITION_IN_CLASSIFICATION is not null and
			    			taxon_relations.related_taxon_name_id=taxon_term.taxon_name_id and 
			    			taxon_relations.taxon_name_id=t.taxon_name_id 
				    UNION 
			    		select 
			    			upper(taxon_term.term) tterm 
			    		from 
			    			taxon_relations,
			    			taxon_term 
			    		where 
			    			taxon_term.POSITION_IN_CLASSIFICATION is not null and
			    			taxon_relations.taxon_name_id=taxon_term.taxon_name_id and 
			    			taxon_relations.related_taxon_name_id=t.taxon_name_id 
				)
			group by tterm) loop
				if s is null or length(s) < 3990 then
					dbms_output.put_line('add: ' || x.tterm);
					s:=s||sep||x.tterm;
					sep:=',';
				else
					dbms_output.put_line('CANNOT add: ' || x.tterm);
				end if;
			end loop;
		
 		end loop;
 		
		dbms_output.put_line('s: ' || s);
		update cache_anytaxonname set
		stale_fg=0,
		taxonstring=s
		where
		collection_object_id =r.collection_object_id;


 	end loop;
end;
/
sho err;

exec UPDATE_cache_anytaxonname;


select * from cache_anytaxonname where taxonstring like '%SCIURUS%';
