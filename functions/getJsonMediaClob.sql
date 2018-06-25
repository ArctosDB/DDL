-- make Media JSON as a CLOB
-- provides room for everything, including verbose labels

create or replace function getJsonMediaClob (colObjId IN number)
return clob
as
    jsond clob :='[';
	rsep varchar2(1);
	dsep varchar2(1);
begin
	for r in (
		select 
			'lo' rType,preview_uri,media_uri,mime_type,media_type,media.media_id
		from 
			media,
			media_relations,
			flat
		where
			flat.locality_id = media_relations.related_primary_key and
			media_relations.media_id=media.media_id and
			SUBSTR(media_relationship,instr(media_relationship,' ',-1)+1)='locality' and
			flat.collection_object_id = colObjId
		union
		select 
			'ci' rType,preview_uri,media_uri,mime_type,media_type,media.media_id
		from 
			media,
			media_relations,
			flat
		where
			flat.collection_object_id = media_relations.related_primary_key and
			media_relations.media_id=media.media_id and
			SUBSTR(media_relationship,instr(media_relationship,' ',-1)+1)='cataloged_item' and
			flat.collection_object_id = colObjId
		union
		select 
			'ce' rType,preview_uri,media_uri,mime_type,media_type,media.media_id
		from 
			media,
			media_relations,
			flat
		where
			flat.collecting_event_id = media_relations.related_primary_key and
			media_relations.media_id=media.media_id and
			SUBSTR(media_relationship,instr(media_relationship,' ',-1)+1)='collecting_event' and
			flat.collection_object_id = colObjId
	) loop
		jsond:=jsond || rsep || '{';
		jsond:=jsond || '"MEDIA_ID":"' || r.MEDIA_ID || '"';
		jsond:=jsond || ',"MEDIA_DETAIL":"https://arctos.database.museum/media/' || r.MEDIA_ID || '"';
		jsond:=jsond || ',"MEDIA_TYPE":"' || escape_json(r.MEDIA_TYPE) || '"';
		jsond:=jsond || ',"PREVIEW_URI":"' || escape_json(r.PREVIEW_URI) || '"';
		jsond:=jsond || ',"MEDIA_URI":"' || escape_json(r.MEDIA_URI) || '"';
		jsond:=jsond || ',"MIME_TYPE":"' || escape_json(r.MIME_TYPE) || '"';
		jsond:=jsond || ',"MIMECAT":"' || escape_json(r.MEDIA_TYPE) || '"';
		for l in (select MEDIA_LABEL,LABEL_VALUE from media_labels where media_id=r.media_id) loop
			jsond:=jsond || ',"' || l.MEDIA_LABEL || '":"' || escape_json(l.LABEL_VALUE) || '"';
		end loop;
		jsond:=jsond || '}';
		rsep:=',';
	end loop;
	jsond:=jsond || ']';
	return jsond;
	exception when others then
		jsond:='[';
		jsond:=jsond || '{"STATUS":"Error Creating JSON"},';
		jsond:=jsond || '{"MEDIA_ACCESS_URL" : https://arctos.database.museum/MediaSearch.cfm?collection_object_id=' || colObjId || '"}';
		jsond:=jsond || ']';
		return jsond;
end;
/

create or replace public synonym getJsonMediaClob for getJsonMediaClob;
grant execute on getJsonMediaClob to public;



