CREATE OR REPLACE FUNCTION getMonthCollected(b IN varchar,e IN varchar)
RETURN varchar
AS
    rby varchar(4);
    rey  varchar(4);
   BEGIN
    if length(b) < 7 OR length(e) < 7 then
    	return '';
    end if;
    rby:=substr( b, 6, 2 );
    rey:=substr( e, 6, 2 );
	if (rby!=rey) then
		return '';
	end if;
	return rby;
end;
    /
    sho err;


CREATE OR REPLACE PUBLIC SYNONYM getMonthCollected FOR getMonthCollected;
GRANT EXECUTE ON getMonthCollected TO PUBLIC;