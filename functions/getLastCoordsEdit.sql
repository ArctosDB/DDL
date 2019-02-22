CREATE OR REPLACE FUNCTION getLastCoordsEdit(lid IN number)
 -- get date/agent who last edited a locality's coordinates from the archive
RETURN varchar
AS
   ss varchar2(255);
   lc varchar2(4000);
   lcid number;
   lcd date;
begin
	for r in (
		select 
			to_char(DEC_LAT) || '|' || to_char(DEC_LONG) crd,
			CHANGED_AGENT_ID,
			CHANGEDATE
		from 
			locality_archive 
		where 
			DEC_LAT is not null and
			locality_id=lid 
		order by 
			CHANGEDATE 
	) loop
		if lc != r.crd then
			lcid:=r.CHANGED_AGENT_ID;
			lcd:=r.CHANGEDATE;
		end if;
		lc:=r.crd;
	end loop;
	if lcid is not null then
		select getPreferredAgentName(lcid) into lc from dual;
		ss:=lc || ' @ ' || lcd;
	end if;
	return ss;	
end;
/
sho err;


CREATE or replace PUBLIC SYNONYM getLastCoordsEdit FOR getLastCoordsEdit;
GRANT EXECUTE ON getLastCoordsEdit TO PUBLIC;



