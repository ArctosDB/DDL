-- code table
insert into CTTAXONOMY_SOURCE (source,description) values ('MVZ Mammals','Classification of the MVZ Mammals Collection');


-- clone everything from the Arctos classification used by MVZ:Mamm
-- first create a table of the taxon_name_ids we want to clone
-- in this case "everything used by MVZ:Mamm

drop table temp_tid;

create table temp_tid as select distinct 
	taxon_name_id 
from 
	identification_taxonomy,
	identification,
	cataloged_item,
	Collection
where
	identification_taxonomy.identification_id=identification.identification_id and
	identification.collection_object_id=cataloged_item.collection_object_id and
	cataloged_item.Collection_id=Collection.Collection_id and
	Collection.guid_prefix='MVZ:Mamm'
;

select count(*) from temp_tid;


-- re-insert that under the new Source


-- first create a temp table from which we can directly insert.
drop table temp_tterm;

-- pull data as they are
-- here from only the Arctos classification
create table temp_tterm as select
	TAXON_TERM_ID,
	temp_tid.TAXON_NAME_ID,
	CLASSIFICATION_ID,
	TERM,
	TERM_TYPE,
	SOURCE,
	GN_SCORE,
	POSITION_IN_CLASSIFICATION,
	LASTDATE,
	MATCH_TYPE
from
	temp_tid,
	taxon_term
where
	temp_tid.TAXON_NAME_ID=taxon_term.TAXON_NAME_ID and
	taxon_term.source='Arctos'
;

select count(*) from temp_tterm;
-- should be approximately select count(*) from temp_tid; times 10-ish

select count(distinct(taxon_name_id)) from temp_tterm;

-- should be VERY close to count(*) from temp_tid; - a little variation for multiple classifications is expected

-- new insertable TAXON_TERM_ID

update temp_tterm set TAXON_TERM_ID=sq_TAXON_TERM_ID.nextval;

-- taxon_name_id does not change

-- classification_id needs to be new, but must stay grouped. Loopidy-loop
declare
	myguid varchar2(4000);
begin
	for r in (select distinct CLASSIFICATION_ID from temp_tterm) loop
		select sys_guid() into myguid from dual;
		update temp_tterm set CLASSIFICATION_ID=myguid where CLASSIFICATION_ID=r.CLASSIFICATION_ID;
	end loop;
end;
/


select count(distinct(CLASSIFICATION_ID)) from temp_tterm;
-- should be about taxon_name_id count

-- TERM does not change
-- TERM_TYPE does not change
-- here's the point
update temp_tterm set SOURCE='MVZ Mammals';
--should be but make sure...
update temp_tterm set GN_SCORE=null;
-- POSITION_IN_CLASSIFICATION does not change
-- today, I guess....
update temp_tterm set LASTDATE=sysdate;
--should be but make sure...
update temp_tterm set MATCH_TYPE=null;


-- now should be a straight insert
-- this will NOT affect specimens, so....

lock table taxon_term in exclusive mode nowait;
alter trigger trg_pushtaxontermtoflat disable;
update collection set PREFERRED_TAXONOMY_SOURCE='MVZ Mammals' where guid_prefix='MVZ:Mamm';
insert into taxon_term (select * from temp_tterm);
alter trigger trg_pushtaxontermtoflat enable;
commit;

-- check stuff out




