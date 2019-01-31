
/*

exec report_cache.rpt_cache_runall;

select * from cf_report_cache;

delete from cf_report_cache;



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

create unique index pk_cf_report_cache on cf_report_cache (cf_report_cache_id) tablespace uam_idx_1;


CREATE OR REPLACE TRIGGER tr_cf_report_cache_bi before insert ON cf_report_cache for each row
   begin
       IF :new.cf_report_cache_id IS NULL THEN
           select somerandomsequence.nextval into :new.cf_report_cache_id from dual;
       END IF;
   end;
/

sho err;


 */
set define off;

CREATE OR REPLACE PACKAGE report_cache as
  PROCEDURE rpt_cache_runall;
END;
/

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
			(loan.RETURN_DUE_DATE is null or loan.RETURN_DUE_DATE > sysdate)
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
				'x',
				'Used taxa with no preferred classification',
				to_char(sysdate,'YYYY-MM-DD'),
				x.c || ' taxa are used by ' || x.guid_prefix || ' and do not have a preferred classification. NOTE: Contact a DBA for a report of names; there is no appropriate form.'
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
				'x',
				'Parts entered more than 365 days ago with disposition being processed',
				to_char(sysdate,'YYYY-MM-DD'),
				x.c || ' parts in ' || x.guid_prefix || ' were entered more than 365 days ago with disposition being processed. NOTE:  Contact a DBA for a report of parts; there is no appropriate form.'
			);
		end loop;
	end;
	-------
	-- this has to be last because Oracle is weird
	 PROCEDURE rpt_cache_runall IS
	BEGIN
		rpt_cache_loan;
		rpt_cache_s_anno;
		rpt_cache_prj_anno;
		rpt_cache_tax_anno;
		rpt_cache_pub_anno;
		rpt_cache_sciname_nocl;
		--rpt_cache_locsrvcmp
		rpt_cache_oldpartdisr;
		
	end;
---------------------------------------------------------------------------------------------------------------------------------------------

	------------------------------------------------------------------------------------------------------------------------------------
END;
/

sho err;
































