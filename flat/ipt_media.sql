-- have to figure out a way to refresh this table
-- for now, just rebuild it as necessary
-- when someone is demonstrably using it, we can add maintenance triggers to media


--- UPDATE 2015-04-15
-- change format of OccurrenceID from
-- 'urn:occurrence:Arctos:' || filtered_flat.guid || ':' || specimen_event.specimen_event_id occurrenceID,
-- to
-- http://arctos.database.museum/guid/{GUID}?seid={specimen_event_id}
-- and change specimen_event to map_specimen_event
-- since media are mapped to specimens, not events, so we might as well have a nice one....


/* 
 	IPT "consumers" cache, our refresh rate is low, and things shuffle around on servers occasionally
 	SO, replace the above with this, which abstracts filepaths and will still work when stale
*/


/* too slow
drop table ipt_better_media;


create table ipt_better_media
as select
	filtered_flat.collection_id collection_id,
	'urn:occurrence:Arctos:' || filtered_flat.guid || ':' || specimen_event.specimen_event_id occurrenceID,
	filtered_flat.guid guid,
	'http://arctos.database.museum/media/' || media.media_id || '?open' identifier,
	'http://arctos.database.museum/exit.cfm?target=' || replace(media_uri,' ','%20') old_identifier,
	'http://arctos.database.museum/media/' || media.media_id references,
	decode(relatedMedia.related_primary_key,null,null,'http://arctos.database.museum/media/' || relatedMedia.related_primary_key) source,
	media.mime_type format,
	media.media_type type,
	concatMediaDescription(media.media_id) title,
	concatMediaDescription(media.media_id) description,
	spec_locality spatial,
	dec_lat latitude,
	dec_long longitude,
	decode(is_iso8601(dcreat.label_value),'valid',dcreat.label_value,NULL) created,
	concatMediaCreatedByAgent(media.media_id) creator,
	URI license,
	sysdate last_updated,
	'http://arctos.database.museum/guid/'  || filtered_flat.guid || '?seid=' || specimen_event.specimen_event_id occurrenceID2
from
	media,
	(select media_id,related_primary_key from media_relations where media_relationship='shows cataloged_item') catItemMR,
	(select media_id,label_value from media_labels where media_label='made date') dcreat,
	ctmedia_license, 
	filtered_flat,
	specimen_event,
	(select media_id,related_primary_key from media_relations where media_relationship='derived from media') relatedMedia
where
	media.media_id=catItemMR.media_id and
	media.media_id=dcreat.media_id (+) and
	media.media_id=relatedMedia.media_id (+) and
	media.media_license_id=ctmedia_license.media_license_id (+) and
	catItemMR.related_primary_key=filtered_flat.collection_object_id and
	filtered_flat.collection_object_id=getPrioritySpecimenEvent(filtered_flat.collection_object_id)
;

*/

truncate table ipt_better_media;

CREATE OR REPLACE PROCEDURE temp_update_junk IS BEGIN 
	insert into ipt_better_media (
		collection_id,
		occurrenceID,
		guid,
		identifier,
		old_identifier,
		references,
		source,
		format,
		type,
		title,
		description,
		spatial,
		latitude,
		longitude,
		created,
		creator,
		license,
		last_updated,
		occurrenceID2
	) ( select
			filtered_flat.collection_id,
			'urn:occurrence:Arctos:' || filtered_flat.guid || ':' || specimen_event.specimen_event_id,
			filtered_flat.guid,
			'http://arctos.database.museum/media/' || media.media_id || '?open',
			'http://arctos.database.museum/exit.cfm?target=' || replace(media_uri,' ','%20'),
			'http://arctos.database.museum/media/' || media.media_id,
			decode(relatedMedia.related_primary_key,null,null,'http://arctos.database.museum/media/' || relatedMedia.related_primary_key),
			media.mime_type,
			media.media_type,
			concatMediaDescription(media.media_id),
			concatMediaDescription(media.media_id),
			spec_locality,
			dec_lat,
			dec_long,
			decode(is_iso8601(dcreat.label_value),'valid',dcreat.label_value,NULL),
			concatMediaCreatedByAgent(media.media_id),
			URI,
			sysdate,
			'http://arctos.database.museum/guid/'  || filtered_flat.guid || '?seid=' || specimen_event.specimen_event_id
		from
			media,
			(select media_id,related_primary_key from media_relations where media_relationship='shows cataloged_item') catItemMR,
			filtered_flat,
			(select media_id,label_value from media_labels where media_label='made date') dcreat,
			(select media_id,related_primary_key from media_relations where media_relationship='derived from media') relatedMedia,
			ctmedia_license,
			specimen_event
		where
			media.media_id=catItemMR.media_id and
			catItemMR.related_primary_key=filtered_flat.collection_object_id and
			media.media_id=dcreat.media_id (+) and
			media.media_id=relatedMedia.media_id (+) and
			media.media_license_id=ctmedia_license.media_license_id (+) and
			filtered_flat.collection_object_id=specimen_event.collection_object_id and
			specimen_event.specimen_event_id=getPrioritySpecimenEvent(filtered_flat.collection_object_id)
	);
end;
/
sho err;



BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_temp_update_junk',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_junk',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/ 

select STATE,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';

select count(*) from ipt_better_media;

create or replace public synonym ipt_better_media for ipt_better_media;
grant select on ipt_better_media to public;

create or replace view digir_query.ipt_better_media as select * from uam.ipt_better_media;




/*
 * 
 OLD n BUSTED

drop table ipt_media_table2;
drop public synonym ipt_media_table2;

drop table ipt_media_table;
drop view  digir_query.ipt_media2;




drop table ipt_media_table;



create table ipt_media_table 
as select
	filtered_flat.collection_id collection_id,
	'urn:occurrence:Arctos:' || filtered_flat.guid || ':' || map_specimen_event.specimen_event_id occurrenceID,
	filtered_flat.guid guid,
	--'http://arctos.database.museum/media/' || media.media_id || '?open' identifier
	'http://arctos.database.museum/exit.cfm?target=' || replace(media_uri,' ','%20') identifier,
	'http://arctos.database.museum/media/' || media.media_id references,
	decode(relatedMedia.related_primary_key,null,null,'http://arctos.database.museum/media/' || relatedMedia.related_primary_key) source,
	media.mime_type format,
	media.media_type type,
	concatMediaDescription(media.media_id) title,
	concatMediaDescription(media.media_id) description,
	spec_locality spatial,
	dec_lat latitude,
	dec_long longitude,
	decode(is_iso8601(dcreat.label_value),'valid',dcreat.label_value,NULL) created,
	concatMediaCreatedByAgent(media.media_id) creator,
	URI license,
	sysdate last_updated,
	'http://arctos.database.museum/guid/'  || filtered_flat.guid || '?seid=' || map_specimen_event.specimen_event_id occurrenceID2
from
	media,
	(select media_id,related_primary_key from media_relations where media_relationship='shows cataloged_item') catItemMR,
	(select media_id,label_value from media_labels where media_label='made date') dcreat,
	ctmedia_license, 
	filtered_flat,
	specimen_event,
	(select media_id,related_primary_key from media_relations where media_relationship='derived from media') relatedMedia
where
	media.media_id=catItemMR.media_id and
	media.media_id=dcreat.media_id (+) and
	media.media_id=relatedMedia.media_id (+) and
	media.media_license_id=ctmedia_license.media_license_id (+) and
	catItemMR.related_primary_key=filtered_flat.collection_object_id and
	filtered_flat.collection_object_id=getPrioritySpecimenEvent(filtered_flat.collection_object_id)
;

	
create or replace public synonym ipt_media_table for ipt_media_table;
grant select on ipt_media_table to public;

create or replace view digir_query.ipt_media as select * from ipt_media_table;
create or replace view digir_query.ipt_media2 as select * from ipt_media_table;
 */

--------------------------------------------------------------



/*
-- OLD
create table ipt_media_table 
as select
	filtered_flat.collection_id collection_id,
	'urn:occurrence:Arctos:' || filtered_flat.guid || ':' || specimen_event.specimen_event_id occurrenceID,
	filtered_flat.guid guid,
	'http://arctos.database.museum/exit.cfm?target=' || media_uri identifier,
	'http://arctos.database.museum/media/' || media.media_id references,
	media.mime_type format,
	media.media_type type,
	concatMediaDescription(media.media_id) title,
	spec_locality spatial,
	dec_lat latitude,
	dec_long longitude,
	dcreat.label_value created,
	concatMediaCreatedByAgent(media.media_id) creator,
	URI license,
	sysdate last_updated
from
	media,
	(select media_id,related_primary_key from media_relations where media_relationship='shows cataloged_item') catItemMR,
	(select media_id,label_value from media_labels where media_label='made date') dcreat,
	ctmedia_license, 
	filtered_flat,
	specimen_event
where
	media.media_id=catItemMR.media_id and
	media.media_id=dcreat.media_id (+) and
	media.media_license_id=ctmedia_license.media_license_id (+) and
	catItemMR.related_primary_key=filtered_flat.collection_object_id and
	filtered_flat.collection_object_id=specimen_event.collection_object_id 
;




create or replace public synonym ipt_media_table for ipt_media_table;
grant select on ipt_media_table to public;

create or replace view digir_query.ipt_media as select * from ipt_media_table;


*/