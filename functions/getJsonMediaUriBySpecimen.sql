-- rewrite this to be "prettier" JSON so we can include it in downloads
create or replace function getJsonMediaUriBySpecimen (colObjId IN number)
return varchar2
as
    jsond varchar2(4000) :='[';
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
		jsond:=jsond || ',"MEDIA_TYPE":"' || escape_json(r.MEDIA_TYPE) || '"';
		jsond:=jsond || ',"PREVIEW_URI":"' || escape_json(r.PREVIEW_URI) || '"';
		jsond:=jsond || ',"MEDIA_URI":"' || escape_json(r.MEDIA_URI) || '"';
		jsond:=jsond || ',"MIME_TYPE":"' || escape_json(r.MIME_TYPE) || '"';
		jsond:=jsond || ',"MIMECAT":"' || escape_json(r.MEDIA_TYPE) || '"';
		jsond:=jsond || '}';
		rsep:=',';
	end loop;
	jsond:=jsond || ']';
	return jsond;
	exception when others then
		jsond:='[ ERROR CREATING JSON ]';
		return jsond;
end;
/

sho err;

select getJsonMediaUriBySpecimen(collection_object_id) from flat where guid='MVZ:Egg:12';


create or replace public synonym getJsonMediaUriBySpecimen for getJsonMediaUriBySpecimen;
grant execute on getJsonMediaUriBySpecimen to public;



begin	
	for r in mcur loop
		numrec:=numrec+1;
		dbms_output.put_line(r.rType);
		strlen:=nvl(length(medtype),0) + nvl(length(mid),0) + nvl(length(mt),0) + nvl(length(pu),0) + nvl(length(mu),0) + nvl(length(mimt),0) + nvl(length(sep),0) +  
		    nvl(length(r.rType),0) + nvl(length(r.preview_uri),0) + nvl(length(r.media_uri),0) + nvl(length(r.mime_type),0) + 10;
		IF strlen < 3000 THEN
    		mid:=mid || sep || '"' || r.media_id || '"';
    		mt:=mt || sep || '"' || r.rType || '"';
    		pu:=pu || sep || '"' ||  r.preview_uri || '"';
    		mu:=mu || sep || '"' || r.media_uri || '"';
    		mimt:=mimt || sep || '"' || r.mime_type || '"';
    		medtype:=medtype || sep || '"' || r.media_type || '"';
    		sep:=',';
		ELSE
		    numrec:=0;
		END IF;
	end loop;
	
	-- edit for https://github.com/ArctosDB/arctos/issues/1130
	-- return NULL is nothing is found
	--if numrec > 0 then
		reslt:='{"ROWCOUNT":' || numrec || ',"COLUMNS":["MEDIA_ID","MEDIA_TYPE","PREVIEW_URI","MEDIA_URI","MIME_TYPE","MIMECAT"],"DATA":{';
		reslt:=reslt || '"media_id":[' || mid || '],';
		reslt:=reslt || '"media_type":[';
		reslt:=reslt || mt || '],"preview_uri":[';
		reslt:=reslt || pu || '],"media_uri":[';
		reslt:=reslt || mu || '],"mimecat":[';
		reslt:=reslt || medtype || '],"mime_type":[';
		reslt:=reslt || mimt || ']}}';
	--else
	--	reslt:=NULL;
	--end if;
		
return reslt;

end;
/


create or replace public synonym getJsonMediaUriBySpecimen for getJsonMediaUriBySpecimen;
grant execute on getJsonMediaUriBySpecimen to public;












create or replace function getJsonMediaUriBySpecimen__OLD (colObjId IN number)
return varchar2
as
     numrec number :=0;
     reslt varchar2(4000);
     mt varchar2(4000);
     pu varchar2(4000);
     mu varchar2(4000);
     mimt varchar2(4000);
     medtype varchar2(4000);
     sep varchar2(10);
     strlen NUMBER;
     mid varchar2(4000);
     cursor mcur is
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
;
begin	
	for r in mcur loop
		numrec:=numrec+1;
		dbms_output.put_line(r.rType);
		strlen:=nvl(length(medtype),0) + nvl(length(mid),0) + nvl(length(mt),0) + nvl(length(pu),0) + nvl(length(mu),0) + nvl(length(mimt),0) + nvl(length(sep),0) +  
		    nvl(length(r.rType),0) + nvl(length(r.preview_uri),0) + nvl(length(r.media_uri),0) + nvl(length(r.mime_type),0) + 10;
		IF strlen < 3000 THEN
    		mid:=mid || sep || '"' || r.media_id || '"';
    		mt:=mt || sep || '"' || r.rType || '"';
    		pu:=pu || sep || '"' ||  r.preview_uri || '"';
    		mu:=mu || sep || '"' || r.media_uri || '"';
    		mimt:=mimt || sep || '"' || r.mime_type || '"';
    		medtype:=medtype || sep || '"' || r.media_type || '"';
    		sep:=',';
		ELSE
		    numrec:=0;
		END IF;
	end loop;
	
	-- edit for https://github.com/ArctosDB/arctos/issues/1130
	-- return NULL is nothing is found
	--if numrec > 0 then
		reslt:='{"ROWCOUNT":' || numrec || ',"COLUMNS":["MEDIA_ID","MEDIA_TYPE","PREVIEW_URI","MEDIA_URI","MIME_TYPE","MIMECAT"],"DATA":{';
		reslt:=reslt || '"media_id":[' || mid || '],';
		reslt:=reslt || '"media_type":[';
		reslt:=reslt || mt || '],"preview_uri":[';
		reslt:=reslt || pu || '],"media_uri":[';
		reslt:=reslt || mu || '],"mimecat":[';
		reslt:=reslt || medtype || '],"mime_type":[';
		reslt:=reslt || mimt || ']}}';
	--else
	--	reslt:=NULL;
	--end if;
		
return reslt;

end;
/
