create or replace function getMediaUriBySpecimen (tablName in varchar, colObjId IN number)
/*
	ACCEPT: 
		1) table name
		2) cataloged_item.collection_object_id
	RETURN: list of media_ids
*/
return varchar2
as
	midlist varchar2(4000);
	sep varchar2(1);
	type rc is ref cursor;
	l_cur    rc;
	l_val VARCHAR2(255);
begin
	case tablName 
		when 'locality' then
			open l_cur for 'select 
					preview_uri || ''|'' || media_uri
				from 
					media,
					media_relations,
					flat
				where
					flat.locality_id = media_relations.related_primary_key and
					media_relations.media_id=media.media_id and
					SUBSTR(media_relationship,instr(media_relationship,'' '',-1)+1)=''locality'' and
					flat.collection_object_id = :x' using colObjId;
		when 'cataloged_item' then
			open l_cur for 'select 
					preview_uri || ''|'' || media_uri
				from 
					media,
					media_relations,
					flat
				where
					flat.collection_object_id = media_relations.related_primary_key and
					media_relations.media_id=media.media_id and
					SUBSTR(media_relationship,instr(media_relationship,'' '',-1)+1)=''cataloged_item'' and
					flat.collection_object_id = :x' using colObjId;
	    when 'collecting_event' then
			open l_cur for 'select 
					preview_uri || ''|'' || media_uri
				from 
					media,
					media_relations,
					flat
				where
					flat.collecting_event_id = media_relations.related_primary_key and
					media_relations.media_id=media.media_id and
					SUBSTR(media_relationship,instr(media_relationship,'' '',-1)+1)=''collecting_event'' and
					flat.collection_object_id = :x' using colObjId;
		else
			null;
	end case;
	loop
          fetch l_cur into l_val;
          exit when l_cur%notfound;
          midlist := midlist || sep || l_val;
          sep := ';';
    end loop;
    close l_cur;
	return midlist;
end;
/
sho err;
create or replace public synonym getMediaUriBySpecimen for getMediaUriBySpecimen;
grant execute on getMediaUriBySpecimen to public;

---- select getMediaUriBySpecimen('cataloged_item',11470) from dual;
