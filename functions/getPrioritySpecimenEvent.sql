/*
 	Finds "best" specimen event, where "best" is ordered by
 		event type is place of manufacture
 		has coordinates
 		grab something random
 */
CREATE OR REPLACE FUNCTION getPrioritySpecimenEvent(coid IN number)
RETURN number
AS
   reid number;
   p number := 900;
   tp number;
BEGIN
	for r in (
		select
			specimen_event.specimen_event_id,
			specimen_event.specimen_event_type,
			decode(locality.dec_lat,null,0,1) hascoords
		from
			specimen_event,
			collecting_event,
			locality
		where
			specimen_event.collecting_event_id=collecting_event.collecting_event_id and
			collecting_event.locality_id=locality.locality_id and
			specimen_event.specimen_event_type != 'unaccepted place of collection' and 
			specimen_event.collection_object_id=coid
		order by began_date ASC
	) loop
		if r.specimen_event_type = 'place of manufacture' then
			tp:=1;
			if tp < p then
				p:=tp;
				reid:= r.specimen_event_id;
			end if;
		elsif r.hascoords=1 then
			tp:=2;
			if tp < p then
				p:=tp;
				reid:= r.specimen_event_id;
			end if;
		else
			tp:=400;
			if tp < p then
				p:=tp;
				reid:= r.specimen_event_id;
			end if;
		end if;
	end loop;
    RETURN reid;
end;
/
sho err;


CREATE or replace PUBLIC SYNONYM getPrioritySpecimenEvent FOR getPrioritySpecimenEvent;
GRANT EXECUTE ON getPrioritySpecimenEvent TO PUBLIC;