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
	map_specimen_event,
	(select media_id,related_primary_key from media_relations where media_relationship='derived from media') relatedMedia
where
	media.media_id=catItemMR.media_id and
	media.media_id=dcreat.media_id (+) and
	media.media_id=relatedMedia.media_id (+) and
	media.media_license_id=ctmedia_license.media_license_id (+) and
	catItemMR.related_primary_key=filtered_flat.collection_object_id and
	filtered_flat.collection_object_id=map_specimen_event.collection_object_id 
;

	
create or replace public synonym ipt_media_table for ipt_media_table;
grant select on ipt_media_table to public;

create or replace view digir_query.ipt_media as select * from ipt_media_table;
create or replace view digir_query.ipt_media2 as select * from ipt_media_table;


--------------------------------------------------------------
/* 
 	IPT "consumers" cache, our refresh rate is low, and things shuffle around on servers occasionally
 	SO, replace the above with this, which abstracts filepaths and will still work when stale
*/


create table ipt_better_media
as select
	filtered_flat.collection_id collection_id,
	'urn:occurrence:Arctos:' || filtered_flat.guid || ':' || map_specimen_event.specimen_event_id occurrenceID,
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
	'http://arctos.database.museum/guid/'  || filtered_flat.guid || '?seid=' || map_specimen_event.specimen_event_id occurrenceID2
from
	media,
	(select media_id,related_primary_key from media_relations where media_relationship='shows cataloged_item') catItemMR,
	(select media_id,label_value from media_labels where media_label='made date') dcreat,
	ctmedia_license, 
	filtered_flat,
	map_specimen_event,
	(select media_id,related_primary_key from media_relations where media_relationship='derived from media') relatedMedia
where
	media.media_id=catItemMR.media_id and
	media.media_id=dcreat.media_id (+) and
	media.media_id=relatedMedia.media_id (+) and
	media.media_license_id=ctmedia_license.media_license_id (+) and
	catItemMR.related_primary_key=filtered_flat.collection_object_id and
	filtered_flat.collection_object_id=map_specimen_event.collection_object_id 
;

create or replace public synonym ipt_better_media for ipt_better_media;
grant select on ipt_better_media to public;

create or replace view digir_query.ipt_better_media as select * from uam.ipt_better_media;




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