create or replace view specimen_media as select
	filtered_flat.guid,
	media.media_uri,
	media.mime_type
from
	filtered_flat,
	media_relations,
	media
WHERE
	filtered_flat.collection_object_id=media_relations.related_primary_key and
	media_relations.media_relationship = 'shows cataloged_item' and
	media.media_id=media_relations.media_id
;

create or replace public synonym specimen_media for specimen_media;


grant select on specimen_media to public;