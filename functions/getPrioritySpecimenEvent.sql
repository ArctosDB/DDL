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
	) loop
		--dbms_output.put_line(r.specimen_event_id || ': ' || r.specimen_event_type || ':' || r.hascoords);
		if r.specimen_event_type = 'place of manufacture' then
			tp:=1;
			--dbms_output.put_line('place of manufacture');
			--dbms_output.put_line('p=' || p);
			--dbms_output.put_line('tp=' || tp);
			if tp < p then
				p:=tp;
				reid:= r.specimen_event_id;
				--dbms_output.put_line('grabbed because place of manufacture');
			end if;
		elsif r.hascoords=1 then
			tp:=2;
			--dbms_output.put_line('coordinates');
			--dbms_output.put_line('p=' || p);
			--dbms_output.put_line('tp=' || tp);
			if tp < p then
				p:=tp;
				reid:= r.specimen_event_id;
				--dbms_output.put_line('grabbed because coordinates');
			end if;
		else
			tp:=400;
			--dbms_output.put_line('def');
			--dbms_output.put_line('p=' || p);
			--dbms_output.put_line('tp=' || tp);
			if tp < p then
				p:=tp;
				reid:= r.specimen_event_id;
				--dbms_output.put_line('grabbed because default');
			end if;
		end if;
			
	end loop;
			
    RETURN reid;
end;
/
sho err;


CREATE or replace PUBLIC SYNONYM getPrioritySpecimenEvent FOR getPrioritySpecimenEvent;
GRANT EXECUTE ON getPrioritySpecimenEvent TO PUBLIC;