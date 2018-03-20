 /*
	NEW AND HOT!!
		- old-n-busted below, in case
	
	rank various stuff, sum up the ranks, take the winner
	
	* specimen_event_type
		* heavily favor "manufacture" - this should always win when present
		* slightly favor 'collect' 
	* coordiantes
    		* slight favor for having coordinates
	* verificationstatus
		* this should basically control the winner when there's no 'manufacture' event type 

  */
CREATE OR REPLACE FUNCTION getPrioritySpecimenEvent(coid IN number)
RETURN number
AS
	sid number;
BEGIN
  select 
  	specimen_event_id 
  into 
  	sid
  from (
  	select 
    		specimen_event_id,
    		--specimen_event_type,
    		--verificationstatus,
    		-- sum up the points columns
    		lpt + sept + vspt ttlpts
    	from (
    		select
      		specimen_event.specimen_event_id,
      		--specimen_event.specimen_event_type,
      		--specimen_event.verificationstatus,
      		decode(locality.dec_lat,null,0,1) lpt,
			decode(specimen_event.specimen_event_type,
				'manufacture',10,
				'collection',1,
				0
  			) sept,
			decode(specimen_event.verificationstatus,
				'verified and locked',5,
				'accepted',4,
				'unverified',0,
				'unaccepted',-1,
        		0) vspt
 		from
      		specimen_event,
      		collecting_event,
      		locality
    		where
      		specimen_event.collecting_event_id=collecting_event.collecting_event_id and
      		collecting_event.locality_id=locality.locality_id and
      		--specimen_event.verificationstatus != 'unaccepted' and 
      		specimen_event.collection_object_id=coid
     ) 
	order by  
		ttlpts desc
	) where rownum=1;
	return sid;
end;
/




CREATE or replace PUBLIC SYNONYM getPrioritySpecimenEvent FOR getPrioritySpecimenEvent;
GRANT EXECUTE ON getPrioritySpecimenEvent TO PUBLIC;



select getPrioritySpecimenEvent2(23817647) from dual;


/*
 
 

old-n-busted follows


*/

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
			--specimen_event.verificationstatus != 'unaccepted' and 
			specimen_event.collection_object_id=coid
		order by began_date ASC
	) loop
		if r.specimen_event_type = 'manufacture' then
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