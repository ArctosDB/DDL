/*
 	Get all specimen event determiner+date
 */
CREATE OR REPLACE FUNCTION getSpecimenEventDeterminer(coid IN number)
RETURN varchar2
AS
   rslt varchar2(4000);
   s varchar2(10);
BEGIN
	for r in (
		select
			getPreferredAgentName(specimen_event.ASSIGNED_BY_AGENT_ID) determiner,
			specimen_event.ASSIGNED_DATE
		from
			specimen_event
		where
			specimen_event.collection_object_id=coid
	) loop
		rslt:=rslt || s || r.determiner || ' on ' || r. ASSIGNED_DATE;
		s:='; ';
	end loop;
    RETURN rslt;
end;
/
sho err;


CREATE or replace PUBLIC SYNONYM getSpecimenEventDeterminer FOR getSpecimenEventDeterminer;
GRANT EXECUTE ON getSpecimenEventDeterminer TO PUBLIC;