create table browse (
	insdate timestamp default systimestamp,
	link varchar2(4000),
	display varchar2(4000)
);
create or replace public synonym browse for browse;

grant select on browse to public;

-- 2018-09-27 update
-- ignore publications without DOI
-- ignore taxonomy without a "display_name" in a classification

CREATE OR REPLACE PROCEDURE set_browse
is
BEGIN
	insert into browse (link,display) (
		select link,display from (
		-- 12 seconds
		    select link,display from (
		       select 
		        '/guid/' || guid link,
		        guid || ' <i>' || scientific_name || '</i>' display
		      from
		        filtered_flat
		        sample(0.05)
		       where scientific_name != 'unidentifiable'
		       group by 
		        guid,
		        scientific_name
		       order by
		        dbms_random.value
		    )   WHERE rownum <= 500
			union
			-- 3 seconds
		    select link,display from (
		      select 
		        full_citation display,
		        '/publication/' || publication.publication_id link
		      from
		        publication,
		        citation,
		        filtered_flat
		        sample(50)
		      where 
		        full_citation not like '%Field Notes%' and
		        publication.doi is not null and
		        publication.publication_id=citation.publication_id and
		        citation.collection_object_id=filtered_flat.collection_object_id
		      group by 
		        full_citation,
		        publication.publication_id
		      order by 
		        dbms_random.value
		    ) WHERE rownum <= 500   
			 UNION
			 -- 1 second
			    select link,display from (
			      select 
			        '<img style="max-height:150px;" src="' || preview_uri || '">' display,
			        '/media/' || media.media_id link
			      from
			        media,
			        media_relations
			        sample(0.5)
			      where
			        mime_type not in ('image/dng') and
			        media_relationship not like '% project' and       
			        preview_uri is not null and
			        media.media_id=media_relations.media_id
			      group by
			        preview_uri,
			        media.media_id        
			      order by 
			        dbms_random.value
			    )
			    WHERE rownum <= 500
			  UNION
			  -- 10 s
			    select link,display from (
		            select 
		              '/name/' || taxon_name.scientific_name link,
		              taxon_term.term display
		            from
		              taxon_name,
		              taxon_term,
		              identification_taxonomy,
		              identification,
		              filtered_flat
		              sample(0.01)
		            where
		              taxon_name.taxon_name_id > 0 and
		              taxon_name.taxon_name_id=taxon_term.taxon_name_id and
		              taxon_term.TERM_TYPE='display_name' and
		              taxon_name.taxon_name_id=identification_taxonomy.taxon_name_id and
		              identification_taxonomy.identification_id=identification.identification_id and
		              identification.collection_object_id=filtered_flat.collection_object_id
		            group by
		              taxon_name.scientific_name,
		              taxon_term.term
		          ) WHERE rownum <= 500
			  UNION
			    select link,display from (
			      select link,display from (
			            select 
			              '/project/' || project.project_id link,
			              project_name display
			            from
			              project,
			              project_trans,
			              filtered_flat
			              sample(50)
			            where
			              project.project_description IS NOT NULL AND
			              length(project.project_description) > 100 AND
			              project.project_id=project_trans.project_id and
			              project_trans.transaction_id=filtered_flat.accn_id
			            group by
			              project.project_name,project.project_id
			            union
			            select 
			              '/project/' || project.project_id link,
			              project_name display
			            from
			              project,
			              project_trans,
			              loan_item,
			              specimen_part,
			              filtered_flat
			              sample(50)
			            where
			              project.project_description IS NOT NULL AND
			              length(project.project_description) > 100 AND
			              project.project_id=project_trans.project_id and
			              project_trans.transaction_id=loan_item.transaction_id and
			              loan_item.collection_object_id=specimen_part.collection_object_id and
			              specimen_part.derived_from_cat_item=filtered_flat.collection_object_id
			            group by
			              project.project_name,project.project_id
			      )
			    group by link,display
			    order by dbms_random.value)
			    WHERE rownum <= 500
	  		)
  GROUP BY LINK,DISPLAY);
	
	-- only keep stuff around for 2 hours
	delete from browse where ((cast(systimestamp as date)-cast(insdate as date))*24*60)>120;
end;
/


BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'j_set_browse',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'set_browse',
		start_date		=> systimestamp,
		repeat_interval	=> 'freq=HOURLY;interval=1',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'grab a random sample of the good stuff for the TSR widget');
END;
/ 
