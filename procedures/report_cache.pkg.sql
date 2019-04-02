
/*

create table cf_report_cache (
	cf_report_cache_id number not null,
	guid_prefix varchar2(255),
	report_name varchar2(255),
	report_URL varchar2(255),
	report_descr varchar2(255),
	report_date date,
	summary_data varchar2(4000)
);

create public synonym  cf_report_cache for cf_report_cache;

grant select on cf_report_cache to coldfusion_user;

create unique index pk_cf_report_cache on cf_report_cache (cf_report_cache_id) tablespace uam_idx_1;


CREATE OR REPLACE TRIGGER tr_cf_report_cache_bi before insert ON cf_report_cache for each row
   begin
       IF :new.cf_report_cache_id IS NULL THEN
           select somerandomsequence.nextval into :new.cf_report_cache_id from dual;
       END IF;
   end;
/

-- table to keep track of running these

drop table cf_report_cache_control;

create table cf_report_cache_control (
	proc_name varchar2(255) not null,
	last_run date not null
);

-- INIT: insert for every procedure in the package

insert into cf_report_cache_control (proc_name,last_run) values ('rpt_cache_loan',sysdate);
insert into cf_report_cache_control (proc_name,last_run) values ('rpt_cache_s_anno',sysdate);
insert into cf_report_cache_control (proc_name,last_run) values ('rpt_cache_prj_anno',sysdate);
insert into cf_report_cache_control (proc_name,last_run) values ('rpt_cache_tax_anno',sysdate);
insert into cf_report_cache_control (proc_name,last_run) values ('rpt_cache_pub_anno',sysdate);
insert into cf_report_cache_control (proc_name,last_run) values ('rpt_cache_sciname_nocl',sysdate);
insert into cf_report_cache_control (proc_name,last_run) values ('rpt_cache_oldpartdisr',sysdate);
insert into cf_report_cache_control (proc_name,last_run) values ('rpt_cache_genbank_no_loan',sysdate);
insert into cf_report_cache_control (proc_name,last_run) values ('rpt_cache_genbank_no_cite',sysdate);
insert into cf_report_cache_control (proc_name,last_run) values ('rpt_cache_cite_no_loan',sysdate);
  

-- run a job every day for now
  
BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'j_cf_report_cache',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'report_cache.rpt_cache_runone',
		start_date		=> systimestamp,
		repeat_interval	=> 'freq=daily; byhour=2; byminute=19',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'refresh cf_report_cache');
END;
/ 




 */

CREATE OR REPLACE PACKAGE report_cache as
  procedure rpt_cache_runone;
  PROCEDURE rpt_cache_loan;
  PROCEDURE rpt_cache_s_anno;
  PROCEDURE rpt_cache_prj_anno;
  PROCEDURE rpt_cache_tax_anno;
  PROCEDURE rpt_cache_pub_anno;
  PROCEDURE rpt_cache_sciname_nocl;
  --PROCEDURE rpt_cache_locsrvcmp;
  PROCEDURE rpt_cache_oldpartdisr;
  PROCEDURE rpt_cache_genbank_no_loan;
  PROCEDURE rpt_cache_genbank_no_cite;
  PROCEDURE rpt_cache_cite_no_loan;
  PROCEDURE rpt_cache_genbank_mia;
  
END;
/



--PROCEDURE rpt_cache_runall;
  
  
set define off;  
CREATE OR REPLACE PACKAGE BODY report_cache as
	------------------------------------------------------------------------------------------------------------------------------------------
 PROCEDURE rpt_cache_loan IS
	BEGIN
		delete from cf_report_cache where report_name='overdue_loan';
	for x in (
		select
			collection.guid_prefix,
			collection.collection_id,
			count(*) c
		from
			loan,
			trans,
			collection
		where
			loan.transaction_id=trans.transaction_id and
			trans.collection_id=collection.collection_id and
			loan.loan_status != 'closed' and
			loan.RETURN_DUE_DATE < sysdate
		group by
			collection.guid_prefix,
			collection.collection_id
		order by
			guid_prefix
		) loop

			insert into cf_report_cache (
				guid_prefix,
				report_name,
				report_URL,
				report_descr,
				report_date,
				summary_data
			) values (
				x.guid_prefix,
				'overdue_loan',
				'/Loan.cfm?action=listLoans&collection_id=' || x.collection_id || '&notClosed=true&return_due_date=1400-01-01&to_return_due_date=' || to_char(sysdate,'YYYY-MM-DD'),
				'Overdue loans with a not-closed status',
				to_char(sysdate,'YYYY-MM-DD'),
				x.c || ' ' || x.guid_prefix || ' loans are not closed and have a due date before ' || to_char(sysdate,'YYYY-MM-DD') || '.'
			);
	end loop;
END;

-------------
PROCEDURE rpt_cache_s_anno IS
	BEGIN
		delete from cf_report_cache where report_name='specimen_annotation';
		for x in (
			select
				collection.guid_prefix,
				count(*) c
			from
				annotations,
				cataloged_item,
				collection
			where
				annotations.COLLECTION_OBJECT_ID=cataloged_item.COLLECTION_OBJECT_ID and
				cataloged_item.collection_id=collection.collection_id and
				annotations.reviewer_comment is null
			group by
				collection.guid_prefix
		) loop

			insert into cf_report_cache (
				guid_prefix,
				report_name,
				report_URL,
				report_descr,
				report_date,
				summary_data
			) values (
				x.guid_prefix,
				'specimen_annotation',
				'/info/reviewAnnotation.cfm?action=show&atype=specimen&guid_prefix=' || x.guid_prefix || '&reviewer_comment=NULL',
				'Unreviewed specimen annotations',
				to_char(sysdate,'YYYY-MM-DD'),
				x.c || ' unreviewed annotations refer to ' || x.guid_prefix || ' specimens.'
			);
		end loop;
	end;
	--------
	PROCEDURE rpt_cache_prj_anno IS
	BEGIN
		delete from cf_report_cache where report_name='project_annotation';
		-- don't have a good way to summarize these, so just add them all. There are currently very few,
		-- we may need to rebuild the annotation form to deal with collection eventually
		for x in (
			select
				collection.guid_prefix,
				count(*) c
			from
				annotations,
				project_trans,
				collection,
				trans
			where
				annotations.project_id=project_trans.project_id and
				project_trans.TRANSACTION_ID=trans.TRANSACTION_ID and
				trans.collection_id=collection.collection_id and
				annotations.reviewer_comment is null
			group by
				collection.guid_prefix
		) loop
			--dbms_output.put_line(x.guid_prefix);
			insert into cf_report_cache (
				guid_prefix,
				report_name,
				report_URL,
				report_descr,
				report_date,
				summary_data
			) values (
				x.guid_prefix,
				'project_annotation',
				'/info/reviewAnnotation.cfm?action=show&atype=project&reviewer_comment=NULL',
				'Unreviewed project annotations',
				to_char(sysdate,'YYYY-MM-DD'),
				x.c || ' unreviewed annotations refer to projects which use ' || x.guid_prefix || ' specimens. NOTE: the form is missing a filter, you may find results not relevant to your collection.'
			);
		end loop;
	end;
	
	
	PROCEDURE rpt_cache_tax_anno IS
	BEGIN
		delete from cf_report_cache where report_name='taxonomy_annotation';
		-- don't have a good way to summarize these, so just add them all. There are currently very few,
		-- we may need to rebuild the annotation form to deal with collection eventually
		for x in (
			select
				collection.guid_prefix,
				count(*) c
			from
				annotations,
				identification_taxonomy,
				identification,
				cataloged_item,
				collection
			where
				annotations.taxon_name_id=identification_taxonomy.taxon_name_id and
				identification_taxonomy.identification_id=identification.identification_id and
				identification.collection_object_id=cataloged_item.collection_object_id and
				cataloged_item.collection_id=collection.collection_id and
				annotations.reviewer_comment is null
			group by
				collection.guid_prefix
		) loop
			--dbms_output.put_line(x.guid_prefix);
			insert into cf_report_cache (
				guid_prefix,
				report_name,
				report_URL,
				report_descr,
				report_date,
				summary_data
			) values (
				x.guid_prefix,
				'taxonomy_annotation',
				'/info/reviewAnnotation.cfm?action=show&atype=taxon&reviewer_comment=NULL',
				'Unreviewed taxonomy annotations',
				to_char(sysdate,'YYYY-MM-DD'),
				x.c || ' unreviewed annotations refer to taxonomy used by ' || x.guid_prefix || ' specimens. NOTE: the form is missing a filter, you may find results not relevant to your collection.'
			);
		end loop;
	end;
	
	
	
	 PROCEDURE rpt_cache_pub_anno IS
	BEGIN
		delete from cf_report_cache where report_name='publication_annotation';
		-- don't have a good way to summarize these, so just add them all. There are currently very few,
		-- we may need to rebuild the annotation form to deal with collection eventually
		for x in (
			select
				collection.guid_prefix,
				count(*) c
			from
				annotations,
				publication,
				citation,
				cataloged_item,
				collection
			where
				annotations.publication_id=publication.publication_id and
				publication.publication_id=citation.publication_id and
				citation.collection_object_id=cataloged_item.collection_object_id and
				cataloged_item.collection_id=collection.collection_id and
				annotations.reviewer_comment is null
			group by
				collection.guid_prefix
		) loop
			--dbms_output.put_line(x.guid_prefix);
			insert into cf_report_cache (
				guid_prefix,
				report_name,
				report_URL,
				report_descr,
				report_date,
				summary_data
			) values (
				x.guid_prefix,
				'publication_annotation',
				'/info/reviewAnnotation.cfm?action=show&atype=publication&reviewer_comment=NULL',
				'Unreviewed publication annotations',
				to_char(sysdate,'YYYY-MM-DD'),
				x.c || ' unreviewed annotations refer to publications used by ' || x.guid_prefix || ' specimens. NOTE: the form is missing a filter, you may find results not relevant to your collection.'
			);
		end loop;
	end;
	
	PROCEDURE rpt_cache_sciname_nocl IS
	BEGIN
		delete from cf_report_cache where report_name='bare_names';
		for x in (
			select
			    collection.guid_prefix,
			    count(*) c
			  from
			    identification_taxonomy,
			    identification,
			    cataloged_item,
			    collection,
			    taxon_name
			  where
			    identification_taxonomy.identification_id=identification.identification_id and
			    identification.collection_object_id=cataloged_item.collection_object_id and
			    cataloged_item.collection_id=collection.collection_id and
			    identification_taxonomy.taxon_name_id=taxon_name.taxon_name_id and
			    --collection.guid_prefix='OWU:Fish' and
			    taxon_name.taxon_name_id not in
			    (select taxon_name_id from taxon_term where
			      taxon_term.taxon_name_id = taxon_name.taxon_name_id and
			      taxon_term.source=collection.PREFERRED_TAXONOMY_SOURCE
			      )
			 group by
			    collection.guid_prefix
		) loop
			--dbms_output.put_line(x.guid_prefix);
			insert into cf_report_cache (
				guid_prefix,
				report_name,
				report_URL,
				report_descr,
				report_date,
				summary_data
			) values (
				x.guid_prefix,
				'bare_names',
				'https://github.com/ArctosDB/arctos/issues/1894',
				'Used taxa with no preferred classification',
				to_char(sysdate,'YYYY-MM-DD'),
				x.c || ' taxa are used by ' || x.guid_prefix || ' and do not have a preferred classification. '
			);
		end loop;
	end;
	
	
	/*
	PROCEDURE rpt_cache_locsrvcmp IS
	BEGIN
		delete from cf_report_cache where report_name='locality_georef';
		for x in (
			select
			    collection.guid_prefix,
			    collection.collection_id,
			    count(*) c
			  from
			    locality,
			    collecting_event,
			    specimen_event,
			    cataloged_item,
			    collection
			  where
			    locality.locality_id=collecting_event.locality_id and
			    collecting_event.collecting_event_id=specimen_event.collecting_event_id and
			    specimen_event.collection_object_id=cataloged_item.collection_object_id and
			    cataloged_item.collection_id=collection.collection_id and
			    locality.dec_lat is not null and
			    locality.MAX_ERROR_DISTANCE is not null and
			    getHaversineDistance(locality.dec_lat,locality.dec_long,locality.s$dec_lat,locality.s$dec_long) > 100
			 group by
			    collection.guid_prefix,
			    collection.collection_id
		) loop
			--dbms_output.put_line(x.guid_prefix);
			insert into cf_report_cache (
				guid_prefix,
				report_name,
				report_URL,
				report_descr,
				report_date,
				summary_data
			) values (
				x.guid_prefix,
				'locality_georef',
				'/Locality.cfm?action=findLocality&collnOper=usedBy&collection_id=' || x.collection_id || '&coord_serv_diff=%3E100',
				'Localities with very large asserted/derived georeference difference',
				to_char(sysdate,'YYYY-MM-DD'),
				x.c || ' localities are used by ' || x.guid_prefix || ' and have > 100 KM differene between asserted and derived georeference points.'
			);
		end loop;
	end;
	*/
	
	PROCEDURE rpt_cache_oldpartdisr IS
	BEGIN
		delete from cf_report_cache where report_name='part_disposition';
		for x in (
			select
			    collection.guid_prefix,
			    count(*) c
			  from
			    coll_object,
			    specimen_part,
			    cataloged_item,
			    collection
			  where
			    coll_object.collection_object_id=specimen_part.collection_object_id and
			    specimen_part.derived_from_cat_item=cataloged_item.collection_object_id and
			    cataloged_item.collection_id=collection.collection_id and
			    coll_object.COLL_OBJ_DISPOSITION='being processed' and
			    sysdate-coll_object.COLL_OBJECT_ENTERED_DATE>365
			 group by
			    collection.guid_prefix
		) loop
			--dbms_output.put_line(x.guid_prefix);
			insert into cf_report_cache (
				guid_prefix,
				report_name,
				report_URL,
				report_descr,
				report_date,
				summary_data
			) values (
				x.guid_prefix,
				'part_disposition',
				'https://github.com/ArctosDB/arctos/issues',
				'Parts entered more than 365 days ago with disposition being processed',
				to_char(sysdate,'YYYY-MM-DD'),
				x.c || ' parts in ' || x.guid_prefix || ' were entered more than 365 days ago with disposition being processed. NOTE:  File an Issue for a report of parts; there is no appropriate form.'
			);
		end loop;
	end;
	
	PROCEDURE rpt_cache_genbank_no_loan IS
	BEGIN
		delete from cf_report_cache where report_name='genbank_no_loan';
		for x in (
			select
				collection.guid_prefix,
				collection.collection_id,
				count(*) c
			from
				collection,
				cataloged_item,
				coll_obj_other_id_num
			where
				collection.collection_id=cataloged_item.collection_id and
				cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id and
				coll_obj_other_id_num.other_id_type='GenBank' and
				cataloged_item.collection_object_id not in (
      				-- data loans
  					select collection_object_id from loan_item
  					-- real loans
					union
					select derived_from_cat_item from specimen_part,loan_item where specimen_part.collection_object_id=loan_item.collection_object_id
   			)
 			group by 
 				collection.guid_prefix,
				collection.collection_id
 		) loop
			insert into cf_report_cache (
				guid_prefix,
				report_name,
				report_URL,
				report_descr,
				report_date,
				summary_data
			) values (
				x.guid_prefix,
				'genbank_no_loan',
				'/info/undocumentedCitations.cfm?action=genbanknocite&collectionid=' || x.collection_id,
				'Specimens with GenBank numbers and no loan history',
				to_char(sysdate,'YYYY-MM-DD'),
				x.c || ' ' || x.guid_prefix || ' specimens have GenBank numbers and do not have a loan history.'
			);
		end loop;
	end;
	
	
	PROCEDURE rpt_cache_genbank_no_cite IS
	BEGIN
		delete from cf_report_cache where report_name='genbank_no_cite';
		for x in (
			select
				collection.guid_prefix,
				collection.collection_id,
				count(*) c
			from
				collection,
				cataloged_item,
				coll_obj_other_id_num
			where
				collection.collection_id=cataloged_item.collection_id and
				cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id and
				coll_obj_other_id_num.other_id_type='GenBank' and
				cataloged_item.collection_object_id not in (
      				select collection_object_id from citation
      			)
 			group by 
 				collection.guid_prefix,
				collection.collection_id
 		) loop
			insert into cf_report_cache (
				guid_prefix,
				report_name,
				report_URL,
				report_descr,
				report_date,
				summary_data
			) values (
				x.guid_prefix,
				'genbank_no_cite',
				'/info/undocumentedCitations.cfm?action=genbanknocite&collectionid=' || x.collection_id,
				'Specimens with GenBank numbers and no citation',
				to_char(sysdate,'YYYY-MM-DD'),
				x.c || ' ' || x.guid_prefix || ' specimens have GenBank numbers and do not have a citation.'
			);
		end loop;
	end;
	
	
	
	PROCEDURE rpt_cache_cite_no_loan IS
	BEGIN
		delete from cf_report_cache where report_name='cite_no_loan';
		for x in (
			select
				collection.guid_prefix,
				collection.collection_id,
				count(*) c
			from
				collection,
				cataloged_item,
				citation
			where
				collection.collection_id=cataloged_item.collection_id and
				cataloged_item.collection_object_id=citation.collection_object_id and
				cataloged_item.collection_object_id not in (
      				-- data loans
				    select collection_object_id from loan_item
				    -- real loans
				    union
					select derived_from_cat_item from specimen_part,loan_item where specimen_part.collection_object_id=loan_item.collection_object_id
				)
 			group by 
 				collection.guid_prefix,
				collection.collection_id
 		) loop
			insert into cf_report_cache (
				guid_prefix,
				report_name,
				report_URL,
				report_descr,
				report_date,
				summary_data
			) values (
				x.guid_prefix,
				'cite_no_loan',
				'/info/undocumentedCitations.cfm?action=citsnoloan&collectionid=' || x.collection_id,
				'Specimens with citations and no loan history.',
				to_char(sysdate,'YYYY-MM-DD'),
				x.c || ' ' || x.guid_prefix || ' specimens have citations and do not have a loan history.'
			);
		end loop;
	end;
	
	
	PROCEDURE rpt_cache_genbank_mia IS
	BEGIN
		delete from cf_report_cache where report_name='genbank_mia';
		for x in (
			select owner, FOUND_COUNT from cf_genbank_crawl where QUERY_TYPE='specimen_voucher:collection' and FOUND_COUNT>0
 		) loop
			insert into cf_report_cache (
				guid_prefix,
				report_name,
				report_URL,
				report_descr,
				report_date,
				summary_data
			) values (
				x.owner,
				'genbank_mia',
				'/info/mia_in_genbank.cfm',
				'Specimens with specimen_voucher:collection in GenBank and no GenBank link.',
				to_char(sysdate,'YYYY-MM-DD'),
				x.FOUND_COUNT || ' ' || x.owner || ' specimens have unlinked data in GenBank.'
			);
		end loop;
	end;
	
				    
	-------
	-- this has to be last because Oracle is weird
	
	 PROCEDURE rpt_cache_runone IS
	 	rpt varchar2(255);
	 	v_sql varchar2(4000);
	BEGIN
		select max(proc_name) into rpt from cf_report_cache_control where  last_run=(select min(last_run) from cf_report_cache_control);
		v_sql:='begin report_cache.' || rpt || '; end;';
		--dbms_output.put_line('v_sql ' || v_sql);
		--dbms_output.put_line('running ' || rpt);
		execute immediate (v_sql);
		update cf_report_cache_control set last_run=sysdate where proc_name=rpt;
	end;
---------------------------------------------------------------------------------------------------------------------------------------------

	------------------------------------------------------------------------------------------------------------------------------------
END;
/

sho err;



-- exec report_cache.rpt_cache_genbank_no_cite;
-- exec report_cache.rpt_cache_cite_no_loan;
-- exec report_cache.rpt_cache_runone	;	

-- exec rpt_cache_genbank_mia




--select max(report_date) from cf_report_cache where report_name ='taxonomy_annotation';



















