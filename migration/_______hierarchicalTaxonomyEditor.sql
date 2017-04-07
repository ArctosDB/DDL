
-- intent:

	--	import Arctos data
	-- manage that stuff here
	-- periodically re-export to Arctos (or globalnames????)

	-- eventually including non-classification stuff (???)
		-- maybe in another table linked by tid


	- keys (tid, parent_tid) are assigned at import and have no realationship to taxon_name_id/anything

	
	--- for function getTaxTreeSrch
	drop table htax_srchhlpr;
	create table htax_srchhlpr (
		-- one-time use key
		key number not null,
		parent_tid number,
		term varchar2(255),
		tid number,
		rank varchar2(255)
	);
	

-- for action findInconsistentData
	drop table htax_inconsistent_terms;
	
	create table htax_inconsistent_terms (
		dataset_id number,
		term varchar2(255),
		rank varchar2(255),
		fkey  varchar2(255)
	);
	create or replace public synonym htax_inconsistent_terms for htax_inconsistent_terms;
	grant all on htax_inconsistent_terms to manage_taxonomy;
	
	
-- create a half-key and metadata; make this a multi-user multi-classification environment

	create table htax_dataset (
		dataset_id number not null,
		dataset_name varchar2(255) not null,
		created_by varchar2(255) not null,
		created_date date not null,
		source varchar2(255) not null,
		comments varchar2(4000),
		status varchar2(255)  default 'working' not null
	);
	alter table htax_dataset add source varchar2(255) not null;


	-- status does stuff, so...

	alter table htax_dataset drop constraint ck_htax_dataset_status;

	alter table htax_dataset add constraint ck_htax_dataset_status
   	CHECK (status IN(
		'working',
		'process_to_bulkloader',
		'inserted_term',
		'inserted_noclassterm'
		)
	);



	ALTER TABLE htax_dataset ADD PRIMARY KEY (dataset_id);

	create or replace public synonym htax_dataset for htax_dataset;
	grant all on htax_dataset to manage_taxonomy;

	--	create a hierarchical data structure for classification data

	drop table hierarchical_taxonomy;

	create table hierarchical_taxonomy (
		tid number not null,
		parent_tid number,
		term varchar2(255),
		rank varchar2(255),
		dataset_id number not null
	);


	ALTER TABLE hierarchical_taxonomy ADD PRIMARY KEY (tid);


	--------------------- awaiting help from LKV

	ALTER TABLE hierarchical_taxonomy ADD CONSTRAINT fk_parent_tid  FOREIGN KEY (dataset_id) REFERENCES htax_dataset(dataset_id);
	-- do not accept terms we can't deal with

	-- in test anyway..
	create unique index IU_CTTAXTERM_TERM on cttaxon_term(taxon_term) tablespace uam_idx_1;
		ALTER TABLE cttaxon_term ADD PRIMARY KEY (taxon_term);

	ALTER TABLE hierarchical_taxonomy ADD CONSTRAINT fk_term_type  FOREIGN KEY (rank) REFERENCES cttaxon_term(taxon_term);

	-- unique within dataset
	drop index iu_term_ds;
	create unique index iu_term_ds on hierarchical_taxonomy (term,dataset_id);



	SELECT DBMS_METADATA.GET_DDL('CONSTRAINT','PK_CTTAXON_TERM') FROM DUAL;
	SELECT DBMS_METADATA.GET_DDL('CONSTRAINT','SYS_C0024359') FROM DUAL;
	SELECT DBMS_METADATA.GET_DDL('CONSTRAINT','SYS_C0024358') FROM DUAL;
	SELECT DBMS_METADATA.GET_DDL('CONSTRAINT','IS_CLASS_BOOL') FROM DUAL;

	SELECT DBMS_METADATA.GET_DDL('INDEX','IU_CTTAXTERM_TERM') FROM DUAL;


ALTER TABLE cttaxon_term DROP INDEX IU_CTTAXTERM_TERM;

------------------------------------------------------------------------------------------
IU_CTTAXTERM_TERM
IU_TAXONTERM_RELPOS
PK_CTTAXON_TERM




UAM@ARCTEST> select CONSTRAINT_NAME from all_constraints where table_name='CTTAXON_TERM';

CONSTRAINT_NAME
------------------------------------------------------------------------------------------
PK_CTTAXON_TERM
SYS_C0024359
SYS_C0024358
IS_CLASS_BOOL

------------------- /awaiting LKV








	ALTER TABLE hierarchical_taxonomy ADD CONSTRAINT fk_dataset_id  FOREIGN KEY (dataset_id)
  REFERENCES htax_dataset(dataset_id);


	create or replace public synonym hierarchical_taxonomy for hierarchical_taxonomy;
	grant all on hierarchical_taxonomy to manage_taxonomy;


	-- add permissions and error logging

	drop table htax_temp_hierarcicized;

	create table htax_temp_hierarcicized (
		taxon_name_id number not null,
		dataset_id number not null,
		status varchar2(255)
	);

	create or replace public synonym htax_temp_hierarcicized for htax_temp_hierarcicized;
	grant all on htax_temp_hierarcicized to manage_taxonomy;


	ALTER TABLE htax_temp_hierarcicized ADD CONSTRAINT fk_th_dataset_id  FOREIGN KEY (dataset_id)
  REFERENCES htax_dataset(dataset_id);


	-- "seed" table
	create table htax_seed (
		scientific_name varchar2(255) not null,
		taxon_name_id number not null,
		dataset_id number not null,

	);
	create or replace public synonym htax_seed for htax_seed;
	grant all on htax_seed to manage_taxonomy;

	ALTER TABLE htax_seed ADD CONSTRAINT fk_htax_dataset_id  FOREIGN KEY (dataset_id)
  REFERENCES htax_dataset(dataset_id);

create unique index htax_seed_taxdataset on htax_seed (scientific_name,taxon_name_id,dataset_id) tablespace uam_idx_1;



 -- table for nonclassification terms

create table htax_noclassterm (
	nc_tid number not null,
	tid number not null,
	term_type varchar2(255) not null,
	term_value varchar2(255) not null
);

	create or replace public synonym htax_noclassterm for htax_noclassterm;
	grant all on htax_noclassterm to manage_taxonomy;

	ALTER TABLE htax_noclassterm ADD PRIMARY KEY (nc_tid);

	ALTER TABLE htax_noclassterm ADD CONSTRAINT fk_htaxnc_dataset_id  FOREIGN KEY (tid) REFERENCES hierarchical_taxonomy(tid);

	drop procedure proc_hierac_tax;

CREATE OR REPLACE PROCEDURE proc_hierac_tax IS
	-- note: https://github.com/ArctosDB/arctos/issues/1000#issuecomment-290556611
	--declare
		v_pid number;
		v_tid number;
		v_c number;
		err_num varchar2(4000);
		err_msg varchar2(4000);
		v_term varchar2(4000);
		v_term_type varchar2(4000);
	begin
		v_pid:=NULL;
		for t in (
			select
				htax_seed.taxon_name_id,
				htax_seed.scientific_name,
				htax_seed.dataset_id,
				htax_dataset.source
			from
				htax_seed,
				htax_dataset
			where
				htax_seed.dataset_id=htax_dataset.dataset_id and
				-- make sure we haven't already processed this record
				(htax_seed.taxon_name_id,htax_seed.dataset_id) not in (select taxon_name_id,dataset_id from htax_temp_hierarcicized) and
				rownum<10000
		) loop
			--dbms_output.put_line('got in ' || t.scientific_name);
			begin
				for r in (
					select
						term,
						term_type
					from
						taxon_term
					where
						taxon_term.taxon_name_id=t.taxon_name_id and
						source=t.source and
						position_in_classification is not null and
						term_type != 'scientific_name'
					order by
						position_in_classification ASC
				) loop
					-- assign to variables so we can use them in error reporting
					v_term:=r.term;
					v_term_type:=r.term_type;
					--dbms_output.put_line(v_term_type || '=' || v_term);
					-- see if we already have one
					select /*+ result_cache */ count(*) 
						into v_c 
						from hierarchical_taxonomy 
						where term=v_term 
							--and rank=r.term_type 
							and dataset_id=t.dataset_id;
					--dbms_output.put_line('v_c=' || v_c);
					if v_c=1 then
						-- grab the ID for use on the next record, move on
						select /*+ result_cache */ tid 
						into v_pid 
						from hierarchical_taxonomy 
						where term=v_term
						--and rank=r.term_type 
						and dataset_id=t.dataset_id;
						
						--dbms_output.put_line( 'already got one thx; for next record v_pid=' || v_pid);
					else
						-- create the term
						-- first grab the current ID
						select someRandomSequence.nextval into v_tid from dual;
						insert into hierarchical_taxonomy (
							tid,
							parent_tid,
							term,
							rank,
							dataset_id
						) values (
							v_tid,
							v_pid,
							v_term,
							v_term_type,
							t.dataset_id
						);

						--dbms_output.put_line( 'created term' );
						-- now assign the term we just made's ID to parent so we can use it in the next loop
						v_pid:=v_tid;
					end if;
				end loop;
				-- log
				insert into htax_temp_hierarcicized (taxon_name_id,dataset_id,status) values (t.taxon_name_id,t.dataset_id,'inserted_term');
				-- dbms_output.put_line('inserted_term: ');
				exception when others then
				  err_num := SQLCODE;
			      err_msg := SQLERRM;
			     -- dbms_output.put_line('fail with ' || t.scientific_name || ': ' || err_msg || ' at ' || v_term || '=' || v_term);

				insert into 
					htax_temp_hierarcicized (
						taxon_name_id,
						dataset_id,
						status
					) values (
						t.taxon_name_id,
						t.dataset_id,
						'fail with ' || t.scientific_name || ': ' || err_msg || ' at ' || v_term || '=' || v_term);
				end;
			
		end loop;
	end;
	/
sho err;

exec proc_hierac_tax;



select distinct status from htax_temp_hierarcicized;



delete from htax_temp_hierarcicized where status like 'fail%';
delete from htax_temp_hierarcicized where status = 'inserted_term';


Elapsed: 00:00:00.31
UAM@ARCTEST> select * from hierarchical_taxonomy where term like '%Disogmus%';

       TID PARENT_TID
---------- ----------
TERM
------------------------------------------------------------------------------------------------------------------------
RANK
------------------------------------------------------------------------------------------------------------------------
DATASET_ID
----------
  84286769   84044348
Disogmus
genus
  83890292


1 row selected.

Elapsed: 00:00:00.47
UAM@ARCTEST> select * from hierarchical_taxonomy where PARENT_TID=84286769;

no rows selected






select * from htax_seed where scientific_name like 'Felis domesticus';

select * from htax_temp_hierarcicized where TAXON_NAME_ID=10030257;
 select * from hierarchical_taxonomy where term like 'Passeriformes%';

 
 

Elapsed: 00:00:00.01
UAM@ARCTEST> select * from htax_seed where scientific_name like 'Felis domesticus';

SCIENTIFIC_NAME
------------------------------------------------------------------------------------------------------------------------
TAXON_NAME_ID DATASET_ID
------------- ----------
Felis domesticus
     10030257	83661895


1 row selected.

Elapsed: 00:00:00.01
UAM@ARCTEST> desc htax_temp_hierarcicized
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 TAXON_NAME_ID							   NOT NULL NUMBER
 DATASET_ID							   NOT NULL NUMBER
 STATUS 								    VARCHAR2(255)

 
 
 
 

SCIENTIFIC_NAME
------------------------------------------------------------------------------------------------------------------------
TAXON_NAME_ID DATASET_ID
------------- ----------
Anas platyrhynchos domestic
     10001345	83465232


1 row selected.

Elapsed: 00:00:00.01
UAM@ARCTEST> desc htax_temp_hierarcicized
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 TAXON_NAME_ID							   NOT NULL NUMBER

 select * from hierarchical_taxonomy where term='platyrhynchos domestic';

 select * from htax_temp_hierarcicized where TAXON_NAME_ID=10001345;

 delete from htax_temp_hierarcicized where TAXON_NAME_ID=10001345;
 
 
 
BEGIN
DBMS_SCHEDULER.DROP_JOB('J_PROC_HIERAC_TAX');
END;
/

BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'J_PROC_HIERAC_TAX',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'proc_hierac_tax',
   start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=minutely; interval=3',
   enabled             =>  TRUE,
   end_date           =>  NULL,
   comments           =>  'PROCESS HIERARCHICAL TAXONOMY');
END;
/



drop procedure proc_hierac_tax_noclass;

CREATE OR REPLACE PROCEDURE proc_hierac_tax_noclass IS
begin
	 -- first get tid and DATASET_ID of inserted_term records
	for r in (
		select distinct
			hierarchical_taxonomy.tid,
			hierarchical_taxonomy.DATASET_ID,
			htax_dataset.source,
			htax_temp_hierarcicized.TAXON_NAME_ID
		from
			htax_temp_hierarcicized,
			htax_seed,
			htax_dataset,
			hierarchical_taxonomy
		where
			htax_temp_hierarcicized.status='inserted_term' and
			htax_temp_hierarcicized.TAXON_NAME_ID=htax_seed.TAXON_NAME_ID and
			htax_temp_hierarcicized.DATASET_ID=htax_seed.DATASET_ID and
			htax_seed.SCIENTIFIC_NAME=hierarchical_taxonomy.TERM and
			htax_seed.DATASET_ID = hierarchical_taxonomy.DATASET_ID and
			htax_seed.DATASET_ID = htax_dataset.DATASET_ID and
			rownum < 10000
	) loop
		--dbms_output.put_line(r.tid || '=>' || r.TAXON_NAME_ID);
		-- now get terms from Arctos
		for t in (
			select
				term,
				TERM_TYPE
			from
				taxon_term
			where
				TAXON_NAME_ID=r.TAXON_NAME_ID and
				source=r.source and
				POSITION_IN_CLASSIFICATION is null
		) loop
			--dbms_output.put_line('-----' || t.term || '=' || t.TERM_TYPE);
			insert into  htax_noclassterm (
				nc_tid,
				tid,
				term_type,
				term_value
			) values (
				somerandomsequence.nextval,
				r.tid,
				t.TERM_TYPE,
				t.term
			);
		end loop;
		update htax_temp_hierarcicized set status='inserted_noclassterm' where TAXON_NAME_ID=r.TAXON_NAME_ID and DATASET_ID=r.DATASET_ID;
	end loop;
end;
/
sho err;



BEGIN
DBMS_SCHEDULER.DROP_JOB('J_PROC_HIERAC_TAX_NC');
END;
/

BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'J_PROC_HIERAC_TAX_NC',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'proc_hierac_tax_noclass',
   start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=minutely; interval=3',
   enabled             =>  TRUE,
   end_date           =>  NULL,
   comments           =>  'PROCESS HIERARCHICAL TAXONOMY (noclassification)');
END;
/

exec proc_hierac_tax_noclass

select STATE,LAST_RUN_DURATION,MAX_RUN_DURATION,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_PROC_HIERAC_TAX';
select STATE,LAST_RUN_DURATION,MAX_RUN_DURATION,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_PROC_HIERAC_TAX_NC';

select ':' || status || ':',count(*) from htax_temp_hierarcicized group by ':' || status || ':';

exec proc_hierac_tax;

BEGIN
DBMS_SCHEDULER.DROP_JOB('J_PROC_HIERAC_TAX');
END;
/

BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'J_PROC_HIERAC_TAX',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'proc_hierac_tax',
   start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=minutely; interval=3',
   enabled             =>  TRUE,
   end_date           =>  NULL,
   comments           =>  'PROCESS HIERARCHICAL TAXONOMY');
END;
/

select STATE,LAST_RUN_DURATION,MAX_RUN_DURATION,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_PROC_HIERAC_TAX';






































------------------ old-n-busted follows -------------------------
alter table hierarchical_taxonomy add status varchar2(255);

update hierarchical_taxonomy set status='ready_to_push_bl' where status is null and rownum<20000;


-- temp_ht is a list of terms we need to get data and make it hierarchical for
drop table temp_ht;

create table temp_ht (
	TAXON_NAME_ID number not null,
	SCIENTIFIC_NAME varchar2(255) not null,
	dataset_name varchar2(255) not null,
	source varchar2(255) not null
);



-- temp_hierarcicized is a log table so we can avoid weird oracle errors
drop table temp_hierarcicized;
create table temp_hierarcicized (taxon_name_id number,dataset_name varchar2(255));



-- small test

insert into temp_ht (scientific_name,taxon_name_id,dataset_name,source) (
			select distinct
				scientific_name,
				taxon_name.taxon_name_id,
				'small_test',
				'Arctos Plants'
			from
				taxon_name,
				taxon_term
			where
				taxon_name.taxon_name_id=taxon_term.taxon_name_id and
				taxon_term.source='Arctos Plants' and
				scientific_name like 'Veronica %'
			);

-- wut?

select count(*) from temp_ht;

commit;

-- performance is awesome, so move on to...

-- very large test

delete from temp_hierarcicized;
delete from temp_ht;
delete from hierarchical_taxonomy;

insert into temp_ht (scientific_name,taxon_name_id,dataset_name,source) (
	select distinct
		scientific_name,
		taxon_name.taxon_name_id,
		'small_test',
		'Arctos'
	from
		taxon_name,
		taxon_term
	where
		taxon_name.taxon_name_id=taxon_term.taxon_name_id and
		taxon_term.source='Arctos'
	);




-- unprocessed
select count(*) from temp_ht where scientific_name not in (select TERM from hierarchical_taxonomy);


1402338 rows created.

Elapsed: 00:03:56.85

-- running for 10000 rows...
exec proc_hierac_tax;
00:00:56.33
Elapsed: 00:02:05.43

select count(*) from hierarchical_taxonomy;
select count(*) from temp_hierarcicized;

-- yea that's slow - will run in ~day or so tho - try more realistic import

delete from temp_ht;

delete from temp_hierarcicized;
delete from hierarchical_taxonomy;

insert into temp_ht (scientific_name,taxon_name_id,dataset_name,source) (
	select distinct
		scientific_name,
		taxon_name.taxon_name_id,
		'med_test',
		'Arctos'
	from
		taxon_name,
		taxon_term
	where
		taxon_name.taxon_name_id=taxon_term.taxon_name_id and
		taxon_term.source='Arctos' and
		term_type='class' and
		term='Aves'
	);

-- now let the stored procedure chew on things



select count(*) from temp_hierarcicized;
select count(*) from hierarchical_taxonomy;

delete from temp_hierarcicized;
delete from hierarchical_taxonomy;

