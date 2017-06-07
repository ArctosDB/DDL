alter table HTAX_NOCLASSTERM modify TERM_VALUE VARCHAR2(4000);
--- fix missing "required" data
-- bird without nomenclatural_code
begin
	for r in (
		select 
			tid 
		from 
			hierarchical_taxonomy 
		where 
			dataset_id=(select dataset_id from htax_dataset where dataset_name='bird') and
			tid not in (select tid from htax_noclassterm where TERM_TYPE='nomenclatural_code')
	)	loop
	
		dbms_output.put_line(r.tid);
		
		insert into htax_noclassterm (
			TID,
			TERM_TYPE,
			TERM_VALUE
		) values (
			r.tid,
			'nomenclatural_code',
			'ICZN'
		);

	end loop;
end;
/


	

-------- push a small dataset to the bulkloader
-- table to hold stuff
drop table htax_export;

create table htax_export (
	dataset_id number not null,
	seed_term varchar2(255) not null,
	username varchar2(255) not null,
	status varchar2(255) not null,
	export_id varchar2(255)
);

create public synonym htax_export for htax_export;
grant all on htax_export to manage_taxonomy;


delete from htax_export;
delete from cf_temp_classification_fh;

insert into htax_export (
	dataset_id,
	seed_term,
	username,
	status,
	export_id
) values (
	114013137,
	'Dendrocolaptinae',
	'DLM',
	'mark_to_export',
	SYS_GUID() 
);

insert into htax_export (
	dataset_id,
	seed_term,
	username,
	status,
	export_id
) values (
	114013137,
	'Reptilia',
	'DLM',
	'mark_to_export',
	SYS_GUID() 
);




create table htax_export_errors (
	export_id varchar2(255),
	term varchar2(255),
	term_type varchar2(255),
	message varchar2(255),
	detail varchar2(255),
	sql varchar2(4000)
);

alter table htax_export_errors modify sql varchar2(4000);

delete from cf_temp_classification_fh;

exec proc_hierac_tax_export;

-- run cf job

select * from htax_export;
select * from cf_temp_classification_fh;

select * from hierarchical_taxonomy where status='4F48782ADC66F761E0507281913464AA';


alter table hierarchical_taxonomy add status varchar2(255);

	select * from hierarchical_taxonomy where  status is null and parent_tid in (
			select tid from hierarchical_taxonomy where status='4F41F72EACF79996E050728191340891'
		);
		
		
		
		
	update hierarchical_taxonomy set status='boogity' where dataset_id=114013137 and term='Aix';

	update hierarchical_taxonomy set status='boogity' where status != 'boogity' and parent_tid in (
			select tid from hierarchical_taxonomy where status='boogity'
		);
	
		select * from hierarchical_taxonomy where (status is null or status != 'boogity') and parent_tid in (
			select tid from hierarchical_taxonomy where status='boogity'
		);
		
		
		
		
		select * from hierarchical_taxonomy where status='boogity';
		
		
		
	
update hierarchical_taxonomy set status=null where status is not null;

CREATE OR REPLACE PROCEDURE proc_hierac_tax_export IS
	v_tid number;
	c number;
	v_uid varchar2(255);
	v_dsid number;
	v_seed_term varchar2(255);
begin
	select 
		dataset_id,
		seed_term,
		export_id 
	into 
		v_dsid,
		v_seed_term,
		v_uid 
	FROM
		htax_export
	where
		export_id in (select min (export_id) from htax_export where status='mark_to_export')
	;
	
	-- set the seed
	update hierarchical_taxonomy set status=v_uid where dataset_id=v_dsid and term=v_seed_term;
	 -- now get children and their children etc.
	 -- hopefully never have >100 steps
	for i in 1..100 loop
		update hierarchical_taxonomy set status=v_uid where (status is null or status != v_uid) and parent_tid in (
			select tid from hierarchical_taxonomy where status=v_uid
		);
	end loop;
	-- now set to load
	--update hierarchical_taxonomy set status='ready_to_push_bl' where status=v_uid;
	update htax_export set status='ready_to_push_bl' where export_id=v_uid;
	

end;
/

select STATE,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_PROC_HIERAC_TAX_EXPORT';

BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'J_proc_hierac_tax_export',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'proc_hierac_tax_export',
   start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=minutely; interval=1',
   enabled             =>  TRUE,
   end_date           =>  NULL,
   comments           =>  'PROCESS HIERARCHICAL TAXONOMY for download');
END;
/


create table htax_markdeletetree (
	seed_tid number not null,
	seed_term varchar2(255) not null,
	username varchar2(255) not null,
	delete_id varchar2(4000) not null,
	status varchar2(4000)
);
create public synonym htax_markdeletetree for htax_markdeletetree;
grant all on htax_markdeletetree to manage_taxonomy;


CREATE OR REPLACE PROCEDURE proc_hierac_tax_deletefami IS
	v_tid number;
	v_uid varchar2(255);
begin
	select 
		seed_tid,
		delete_id
	into 
		v_tid,
		v_uid 
	FROM
		htax_markdeletetree
	where
		status='mark_to_delete';
	
	
	-- set the seed
	update hierarchical_taxonomy set status=v_uid where tid=v_tid;
	 -- now get children and their children etc.
	 -- hopefully never have >100 steps
	for i in 1..100 loop
		update hierarchical_taxonomy set status=v_uid where (status is null or status != v_uid) and parent_tid in (
			select tid from hierarchical_taxonomy where status=v_uid
		);
	end loop;
	-- now set to load
	delete from htax_noclassterm where tid in (select tid from hierarchical_taxonomy where status=v_uid);
	delete from hierarchical_taxonomy where status=v_uid;
	update htax_markdeletetree set status='deleted' where delete_id=v_uid;
end;
/




select * from htax_markdeletetree;
exec proc_hierac_tax_deletefami;
select term from hierarchical_taxonomy where status='4F555EA60C2EF439E05072819134B38E' order by term;



update hierarchical_taxonomy set status='ready_to_push_bl' where status ='pushed_to_bl';

select * from htax_noclassterm where tid in (select tid from hierarchical_taxonomy where status is not null) ;




select distinct term_type from htax_noclassterm;


create table htax_noclassterm (
	nc_tid number not null,
	tid number not null,
	term_type varchar2(255) not null,
	term_value varchar2(255) not null
);


-- oracle has stupid restrictions on sequences and we need to mass-insert nomen_code so....
CREATE OR REPLACE TRIGGER trg_htax_noclassterm_sq
 before insert  ON htax_noclassterm
 for each row
    begin
	    IF :new.nc_tid IS NULL THEN
    		select someRandomSequence.nextval into :new.nc_tid from dual;
    	end if;
    end;
/
sho err


	
	create table htax_dataset (
		dataset_id number not null,
		dataset_name varchar2(255) not null,
		created_by varchar2(255) not null,
		created_date date not null,
		source varchar2(255) not null,
		comments varchar2(4000),
		status varchar2(255)  default 'working' not 



-- intent:

	--	import Arctos data
	-- manage that stuff here
	-- periodically re-export to Arctos (or globalnames????)

	-- eventually including non-classification stuff (???)
		-- maybe in another table linked by tid


	-- keys (tid, parent_tid) are assigned at import and have no realationship to taxon_name_id/anything

	
	
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
		dataset_id number not null
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
	-- this should always at least insert the seed term
	--declare
		v_pid number;
		v_tid number;
		v_c number;
		err_num varchar2(4000);
		err_msg varchar2(4000);
		v_term varchar2(4000);
		v_term_type varchar2(4000);
		v_wrk varchar2(4000);
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
-			-- see if there's any classification data
			-- if not, see what we can do....
			select count(*) into v_c from taxon_term where 
				taxon_term.taxon_name_id=t.taxon_name_id and
				source=t.source and
				position_in_classification is not null and
				term_type != 'scientific_name';
			--dbms_output.put_line('terms:  ' || v_c);
			if v_c = 0 then
				-- if all this fails, just insert as top-level term
				v_pid:=NULL;
				--dbms_output.put_line('no classification data panic and fail!!!;');
				--dbms_output.put_line('didnt find rank try to guess by structure');
				if t.scientific_name like '% % %' then
					v_term_type:='subspecies';
					--dbms_output.put_line('subspecies');
					-- see if we can find a species
					v_wrk:=substr(t.scientific_name,0,instr(t.scientific_name,' ',1,2));
					--dbms_output.put_line('species is ' || v_wrk);
					select count(*) into v_c from hierarchical_taxonomy where term=trim(v_wrk);
					if v_c=1 then
						select tid into v_pid from hierarchical_taxonomy where term=trim(v_wrk);
					end if;
				elsif t.scientific_name like '% %' then
					v_term_type:='species';
					v_wrk:=substr(t.scientific_name,0,instr(t.scientific_name,' '));
					--dbms_output.put_line('genus is ' || v_wrk);
					select count(*) into v_c from hierarchical_taxonomy where term=trim(v_wrk);
					if v_c=1 then
						select tid into v_pid from hierarchical_taxonomy where term=trim(v_wrk);
					end if;
					--dbms_output.put_line('species');
				elsif t.scientific_name like '% % % %' then
					v_term_type:='too_many_spaces';
					--dbms_output.put_line('too_many_spaces');
				else
					v_term_type:='genus or something maybe IDK';
					--dbms_output.put_line('genus or something maybe IDK');
				end if;
				insert into hierarchical_taxonomy (
					tid,
					parent_tid,
					term,
					rank,
					dataset_id
				) values (
					somerandomsequence.nextval,
					v_pid,
					t.scientific_name,
					v_term_type,
					t.dataset_id
				);
				insert into htax_temp_hierarcicized (taxon_name_id,dataset_id,status) values (t.taxon_name_id,t.dataset_id,'guessed_at_rank_noclass');
			else
				--dbms_output.put_line('nrml:  ' || v_c);
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
				
				-- did we get the scientifif name we started with??
				
				select count(*) into v_c from hierarchical_taxonomy where dataset_id=t.dataset_id and term=t.scientific_name;
				if v_c = 1 then
					-- yay
				-- log
					insert into htax_temp_hierarcicized (taxon_name_id,dataset_id,status) values (t.taxon_name_id,t.dataset_id,'inserted_term');
					--dbms_output.put_line('inserted_term: ');
				else
					insert into htax_temp_hierarcicized (taxon_name_id,dataset_id,status) values (t.taxon_name_id,t.dataset_id,'missed_taxonname');
					 --dbms_output.put_line('missed_taxonname: ');
				end if;
				
				exception when others then
				  err_num := SQLCODE;
			      err_msg := SQLERRM;
			      --dbms_output.put_line('fail with ' || t.scientific_name || ': ' || err_msg || ' at ' || v_term || '=' || v_term);

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
			end if;
		end loop;
	end;
	/
sho err;

-- fix messy birds



delete from hierarchical_taxonomy where term in (select htax_seed.scientific_name from htax_seed,htax_temp_hierarcicized where
htax_seed.taxon_name_id=htax_temp_hierarcicized.taxon_name_id and htax_temp_hierarcicized.status='guessed_at_rank_noclass');

delete from htax_temp_hierarcicized where status='guessed_at_rank_noclass';

exec proc_hierac_tax;


delete from htax_temp_hierarcicized where status='inserted_term';
Elapsed: 00:00:00.00
UAM@ARCTOS> select * from htax_seed where scientific_name='Dendroica aestiva rubinginosa';

SCIENTIFIC_NAME
------------------------------------------------------------------------------------------------------------------------
TAXON_NAME_ID DATASET_ID
------------- ----------
Dendroica aestiva rubinginosa
     10955657  114013137


1 row selected.

select * from htax_temp_hierarcicized where TAXON_NAME_ID=10955657;

delete from hierarchical_taxonomy where term in (select htax_seed.scientific_name from htax_seed,htax_temp_hierarcicized where
htax_seed.taxon_name_id=htax_temp_hierarcicized.taxon_name_id and htax_temp_hierarcicized.status='guessed_at_rank_noclass');

delete from htax_temp_hierarcicized where status='guessed_at_rank_noclass';

exec proc_hierac_tax;

select * from hierarchical_taxonomy where term='Perisoreus canadensis canadensis fumifrons';


exec DBMS_SCHEDULER.DROP_JOB('J_PROC_HIERAC_TAX');



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









--- for function getTaxTreeSrch
	drop table htax_srchhlpr;
	create table htax_srchhlpr (
		-- one-time use key
		key number not null,
		-- what we need a list of
		parent_tid number,
		tid number,
		term varchar2(255),
		rank varchar2(255)
	);
	
	create or replace public synonym htax_srchhlpr for htax_srchhlpr;
	grant all on htax_srchhlpr to manage_taxonomy;
	
	
	-- only allow terms to appear once in a result set; this allows use of unique-only hint
	create unique index ux_htax_srchhlpr_full on htax_srchhlpr (key,parent_tid,tid) tablespace uam_idx_1;

CREATE OR REPLACE procedure proc_htax_srch (dsid number, schterm varchar2,v_key number) 
AS
	v_pid number;
	v_tid number;
	v_c number;
	err_num varchar2(4000);
	err_msg varchar2(4000);
	v_term varchar2(4000);
	v_term_type varchar2(4000);
begin
	-- pass in a search term, dataset_id and hopefully-unique temp key (to access the data after this runs)
	-- starting with the search term and working up until parent is null, find
	-- tid, parent_tid, term, rank
	-- store in table for later query
	for seed in (select * from hierarchical_taxonomy where dataset_id=dsid and term like '%' || schterm || '%') loop
		insert  /*+ ignore_row_on_dupkey_index(htax_srchhlpr,ux_htax_srchhlpr_full) */   into htax_srchhlpr (
			key,
			parent_tid,
			tid,
			term,
			rank
		) values (
			v_key,
			seed.parent_tid,
			seed.tid,
			seed.term,
			seed.rank
		);
			
		-- grab the parent for the next loop
		v_pid:=seed.parent_tid;
		-- assume this will never be >100 terms deep; nothing is close as of writing
		for c in 1..100 loop
			if v_pid is not null then
				select term,rank,tid, parent_tid into v_term,v_term_type,v_tid,v_pid from 
					hierarchical_taxonomy where dataset_id=dsid and
					tid=v_pid;				
				insert  /*+ ignore_row_on_dupkey_index(htax_srchhlpr,ux_htax_srchhlpr_full) */ into htax_srchhlpr (
					key,
					parent_tid,
					tid,
					term,
					rank
				) values (
					v_key,
					v_pid,
					v_tid,
					v_term,
					v_term_type
				);
			end if;
		end loop;
	end loop;
end;
/

sho err;


create or replace public synonym proc_htax_srch for proc_htax_srch;
grant execute on proc_htax_srch to manage_taxonomy;





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

