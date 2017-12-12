create or replace function getJsonEventBySpecimen (colObjId IN number)
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
begin
	for r in (
		select 
			SPECIMEN_EVENT.SPECIMEN_EVENT_ID,
			getPreferredAgentName(SPECIMEN_EVENT.ASSIGNED_BY_AGENT_ID) EventAssignedByAgent,
			to_char(SPECIMEN_EVENT.ASSIGNED_DATE,'YYYY-MM-DD') EventAssignedDate,
			SPECIMEN_EVENT.SPECIMEN_EVENT_REMARK,
			SPECIMEN_EVENT.SPECIMEN_EVENT_TYPE,
			SPECIMEN_EVENT.COLLECTING_METHOD,
			SPECIMEN_EVENT.COLLECTING_SOURCE,
			SPECIMEN_EVENT.VERIFICATIONSTATUS,
			SPECIMEN_EVENT.HABITAT,
			COLLECTING_EVENT.VERBATIM_DATE,
			COLLECTING_EVENT.VERBATIM_LOCALITY,
			COLLECTING_EVENT.COLL_EVENT_REMARKS,
			COLLECTING_EVENT.BEGAN_DATE,
			COLLECTING_EVENT.ENDED_DATE,
			LOCALITY.SPEC_LOCALITY,
			LOCALITY.DEC_LAT,
			LOCALITY.DEC_LONG,
			LOCALITY.MINIMUM_ELEVATION,
			LOCALITY.MAXIMUM_ELEVATION,
			LOCALITY.ORIG_ELEV_UNITS,
			LOCALITY.MIN_DEPTH,
			LOCALITY.MAX_DEPTH,
			LOCALITY.DEPTH_UNITS,
			LOCALITY.MAX_ERROR_DISTANCE,
			LOCALITY.MAX_ERROR_UNITS,
			LOCALITY.DATUM,
			LOCALITY.LOCALITY_REMARKS,
			LOCALITY.GEOREFERENCE_SOURCE,
			LOCALITY.GEOREFERENCE_PROTOCOL,
			LOCALITY.LOCALITY_NAME,
			decode(LOCALITY.WKT_POLYGON,
				NULL,'',
				'data available'
			) hasLocalityWKT,
			geog_auth_rec.HIGHER_GEOG,
			decode(geog_auth_rec.WKT_POLYGON,
				NULL,'',
				'data available'
			) hasLocalityWKT
		from
			SPECIMEN_EVENT,
			COLLECTING_EVENT,
			LOCALITY,
			geog_auth_rec
		where
			SPECIMEN_EVENT.collecting_event_id=COLLECTING_EVENT.collecting_event_id and
			COLLECTING_EVENT.locality_id=locality.locality_id and
			locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
			SPECIMEN_EVENT.COLLECTION_OBJECT_ID=colObjId
	) loop
		dbms_output.put_line(r.SPECIMEN_EVENT_TYPE);
	end loop;
	
	 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 						   NOT NULL NUMBER
 COLLECTION_OBJECT_ID						   NOT NULL NUMBER
 COLLECTING_EVENT_ID						   NOT NULL NUMBER
 						   NOT NULL NUMBER
 							   NOT NULL DATE
 SPECIMEN_EVENT_REMARK							    VARCHAR2(4000)
 						   NOT NULL VARCHAR2(60)
 							    VARCHAR2(4000)
 							    VARCHAR2(60)
 						   NOT NULL VARCHAR2(60)
 								    VARCHAR2(4000)
	

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


create or replace public synonym getJsonEventBySpecimen for getJsonEventBySpecimen;
grant execute on getJsonEventBySpecimen to public;
