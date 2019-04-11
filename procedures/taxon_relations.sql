CREATE OR REPLACE PROCEDURE proc_ref_taxon_relation_oneway 
	(
		tid IN number
	)
	IS
	--	temp varchar2(4000);
		cid varchar2(255);
begin
	--dbms_output.put_line(tid);
	--dbms_output.put_line('deleting all "Arctos Relationships" classifications FROM ' || tid);
	delete from taxon_term where source='Arctos Relationships' and taxon_name_id=tid;
	--dbms_output.put_line('rebuilding all "Arctos Relationships" classifications FROM ' || tid);
	-- get all related IDs
	for r in (select RELATED_TAXON_NAME_ID,TAXON_RELATIONSHIP,RELATION_AUTHORITY from taxon_relations where TAXON_NAME_ID=tid) loop
		-- for each of those, create the FROM relationship 
		for relt in (
			select 
				classification_id, 
				source 
			from 
				taxon_term 
			where 
				taxon_name_id=r.related_taxon_name_id and
				source in (select source from cttaxonomy_source)
			group by classification_id, source
		) loop
			--dbms_output.put_line('insert for relt.classification_id::' || relt.classification_id);
			select sys_guid() into cid from dual;
			--dbms_output.put_line('got a guid');
			insert into taxon_term (
				TAXON_NAME_ID,
				CLASSIFICATION_ID,
				TERM,
				TERM_TYPE,
				SOURCE,
				POSITION_IN_CLASSIFICATION
			) (
				select distinct
					tid,
					cid,
					term,
					term_type,
					'Arctos Relationships',
					POSITION_IN_CLASSIFICATION
				from
					taxon_term
				where
					classification_id=relt.classification_id
			);
			insert into taxon_term (
				TAXON_NAME_ID,
				CLASSIFICATION_ID,
				TERM,
				TERM_TYPE,
				SOURCE
			) values (
				tid,
				cid,
				'Autogenerated from relationship "' || r.TAXON_RELATIONSHIP || '."' || decode(r.RELATION_AUTHORITY,NULL,'',' Authority: ' || r.RELATION_AUTHORITY) || '. Source Classification: ' || relt.source,
				'remark',
				'Arctos Relationships'
			);
			
		end loop;
	end loop;
end;
/
sho err;


BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'j_proc_ref_taxon_relations',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'proc_ref_taxon_relations',
   start_date         =>  SYSTIMESTAMP,
   repeat_interval    =>  'freq=MINUTELY',
   enabled             =>  TRUE,
   end_date           =>  NULL,
   comments           =>  'push taxon relations to classifications');
END;
/
CREATE OR REPLACE PROCEDURE proc_ref_taxon_relations IS
	cid varchar2(4000);
	temp varchar2(4000);
begin
	-- from https://github.com/ArctosDB/arctos/issues/1866
	-- added last_refresh_date
	-- if it's NULL, and the relationship is not already flagged for update, the relationship should be flagged as stale
	update taxon_relations set stale_fg=1 where last_refresh_date is null and stale_fg!=1;
	-- if it's older than 6 months, and the relationship is not already flagged for update, the relationship should be flagged as stale
	update taxon_relations set stale_fg=1 where last_refresh_date <= TRUNC(SYSDATE) - 180 and stale_fg!=1;
	-- now on to your regularly scheduled refresh
	for r in (select distinct taxon_name_id from taxon_relations where stale_fg=1 and rownum<50) loop
		-- update the anchor
		--dbms_output.put_line('refreshing anchor: ' || r.taxon_name_id);
		proc_ref_taxon_relation_oneway(r.taxon_name_id);
		--- now get ALL related IDs
		-- update them and reset stale flag; 
		  --it's probably only one of them which caused this.
		  -- the loop will get that one, along with everything else involved
		for relns in (select * from taxon_relations where taxon_name_id=r.taxon_name_id) loop
			--dbms_output.put_line('refreshing related term: ' || relns.related_taxon_name_id);
			proc_ref_taxon_relation_oneway(relns.related_taxon_name_id);
			--dbms_output.put_line('marking relationship refreshed: ' || relns.TAXON_RELATIONS_ID);
			update taxon_relations set last_refresh_date=sysdate,stale_fg=0 where TAXON_RELATIONS_ID = relns.TAXON_RELATIONS_ID;
		end loop;
	end loop;
end;
/
sho err;