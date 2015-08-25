CREATE OR REPLACE FUNCTION getYearCollected(b IN varchar,e IN varchar)
RETURN varchar
AS
   rby varchar(4);
    rey  varchar(4);
BEGIN
    if length(b) < 4 OR length(e) < 4 then
    	return '';
    end if;
    rby:=substr( b, 1, 4 );
    rey:=substr( e, 1, 4 );
	if (rby!=rey) then
		return '';
	end if;
	return rby;
end;
    /
    sho err;


CREATE  OR REPLACE PUBLIC SYNONYM getYearCollected FOR getYearCollected;
GRANT EXECUTE ON getYearCollected TO PUBLIC;