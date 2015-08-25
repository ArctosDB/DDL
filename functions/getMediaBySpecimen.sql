create or replace function getMediaBySpecimen (tablName in varchar, colObjId IN number)
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
	l_val number;
begin
	case tablName 
		when 'locality' then
			open l_cur for 'select 
					media_id
				from 
					media_relations,
					flat
				where
					flat.locality_id = media_relations.related_primary_key and
					SUBSTR(media_relationship,instr(media_relationship,'' '',-1)+1)=''locality'' and
					flat.collection_object_id = :x' using colObjId;
		when 'cataloged_item' then
			open l_cur for 'select 
					media_id
				from 
					media_relations,
					flat
				where
					flat.collection_object_id = media_relations.related_primary_key and
					SUBSTR(media_relationship,instr(media_relationship,'' '',-1)+1)=''cataloged_item'' and
					flat.collection_object_id = :x' using colObjId;
	    when 'collecting_event' then
			open l_cur for 'select 
					media_id
				from 
					media_relations,
					flat
				where
					flat.collecting_event_id = media_relations.related_primary_key and
					SUBSTR(media_relationship,instr(media_relationship,'' '',-1)+1)=''collecting_event'' and
					flat.collection_object_id = :x' using colObjId;
		else
			null;
	end case;
	loop
          fetch l_cur into l_val;
          exit when l_cur%notfound;
          midlist := midlist || sep || l_val;
          sep := ',';
    end loop;
    close l_cur;
	return midlist;
end;
/
sho err;
create or replace public synonym getMediaBySpecimen for getMediaBySpecimen;
grant execute on getMediaBySpecimen to public;