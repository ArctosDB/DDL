CREATE OR REPLACE function to_days(meas IN number, unit in varchar2 )
    return number DETERMINISTIC
    as
        d  number;
	begin
	if meas is null or unit is null then
		d := null;
	else	
		if upper(unit) = 'D' OR upper(unit) = 'DAY' OR upper(unit) = 'DAYS' then
			d := meas;
		elsif upper(unit) = 'H' OR upper(unit) = 'HOUR' OR upper(unit) = 'HOURS' then
			d := meas / 24;
		elsif upper(unit) = 'M' OR upper(unit) = 'MONTH' OR upper(unit) = 'MONTHS' then
			d := meas * 30.4368;
		elsif upper(unit) = 'WEEK' OR upper(unit) = 'WEEKS' then
			d := meas * 7;
		elsif upper(unit) = 'YR' OR upper(unit) = 'Y' OR upper(unit) = 'YEAR' OR upper(unit) = 'YEARS' then
			d := meas * 365.242;
		else
			d := null;
		end if;
	end if;
	
	return d;
  end;
/

sho err;



 create or replace public synonym to_days for to_days;
 grant execute on to_days to public;




 