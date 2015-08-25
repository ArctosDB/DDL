CREATE OR REPLACE function to_grams(meas IN number, unit in varchar2 )
    return number DETERMINISTIC
    as
        g  number;
	begin
	if meas is null or unit is null then
		g := null;
	else	
		if upper(unit) = 'G' OR upper(unit) = 'GRAMS' OR upper(unit) = 'GRAM' then
			g := meas;
		elsif upper(unit) = 'KG' OR upper(unit) = 'KILOGRAM' OR upper(unit) = 'KILOGRAMS' then
			g := meas * 1000;
		elsif upper(unit) = 'LB' OR upper(unit) = 'POUND' OR upper(unit) = 'POUNDS' then
			g := meas * 0.0022046;
		elsif upper(unit) = 'OZ' OR upper(unit) = 'OUNCE' OR upper(unit) = 'OUNCES' then
			g := meas * 0.035274;
		else
			g := null;
		end if;
	end if;
	
	return g;
  end;
  /
sho err;


  
  create or replace public synonym to_grams for to_grams;
  grant execute on to_grams to public;


