
CREATE OR REPLACE FUNCTION degree2radian(pin_Degree IN NUMBER)
	RETURN NUMBER DETERMINISTIC IS BEGIN
    RETURN pin_Degree / 57.2957795; --1R = 180C
END degree2radian;
/
  


CREATE OR REPLACE PUBLIC SYNONYM degree2radian FOR degree2radian;
GRANT EXECUTE ON degree2radian TO PUBLIC;
  
CREATE or replace FUNCTION getHaversineDistance (la1 in number,lo1 in number,la2 in number,lo2 in number)
	return number deterministic
	as
		R number:=6371; --earth's mean radius in km
		dLat number;
		dLong number;
		a number;
		c number;
		d number;
	begin
		dLat := degree2radian(la2 - la1);
		dLong := degree2radian(lo2-lo1);
		a := sin(dLat/2) * sin(dLat/2) + cos(degree2radian(la1)) * cos(degree2radian(la2)) * sin(dLong/2) *sin(dLong/2);
		c := 2 * atan2(sqrt(a), sqrt(1-a));
		d := R * c;
		return d;
	end;
/
sho err;


CREATE OR REPLACE PUBLIC SYNONYM getHaversineDistance FOR getHaversineDistance;
GRANT EXECUTE ON getHaversineDistance TO PUBLIC;


-- just easy way to call it
CREATE or replace FUNCTION checkLocalityError (lid in number)
return number
as

d number;
begin
	select getHaversineDistance(dec_lat,dec_long,s$dec_lat,s$dec_long) into d from locality where locality_id=lid;
	return d;
end;
/
sho err;

CREATE OR REPLACE PUBLIC SYNONYM checkLocalityError FOR checkLocalityError;
GRANT EXECUTE ON checkLocalityError TO PUBLIC;



----

select getHaversineDistance(dec_lat,dec_long,s$dec_lat,s$dec_long) from locality where locality_id=92930;
 select checkLocalityError(92930) from dual;

 
 
 