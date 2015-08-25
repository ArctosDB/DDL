-- create deterministic functions to approximate pi
CREATE OR REPLACE FUNCTION toRad (n  in number) return number DETERMINISTIC as
begin
   return n * 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067982148086513282306647093844609550582231725359408128481117450284102701938521105559644622948954930381964428810975665933446128475648233786783165271201909145648566923460348610454326648213393607260249141273724587006606315588174881520920962829254091715364367892590360011330530548820466521384146951941511609 / 180;
end;
/

CREATE OR REPLACE FUNCTION toDeg (n  in number) return number DETERMINISTIC as
begin
   return n * 180 / 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067982148086513282306647093844609550582231725359408128481117450284102701938521105559644622948954930381964428810975665933446128475648233786783165271201909145648566923460348610454326648213393607260249141273724587006606315588174881520920962829254091715364367892590360011330530548820466521384146951941511609;  
end;
/

create table fake_coordinate_error (
  locality_id number,
  swlat number,
  swlong number,
  nelat number,
  nelong number,
  stale_fg number
);

--alter table fake_coordinate_error add stale_fg number;

create or replace public synonym fake_coordinate_error for fake_coordinate_error;
grant select on fake_coordinate_error to public;

CREATE OR REPLACE PROCEDURE getFakeError ( locid in number) is
  lat number;
  lng number;
  dist number;
  lat1 number;
  lat2 number;
  lon1 number;
  lon2 number;
  brng2 number;
  swlat number;
  swlong number;
  nelat number;
  nelong number;
begin
  select dec_lat,dec_long, to_meters(max_error_distance, locality.max_error_units) into lat, lng, dist from locality where locality_id=locid;
  if lat is null or lng is null then
    return;
  end if;
  if dist is null then
     nelat:=lat;
     swlat:=lat;
     nelong:=lng;
     swlong:=lng;
  else
    dist := (dist / 6371)/1000;
    brng2 := toRad(0);  
    lat1 := toRad(lat);
    lat2 := asin(sin(lat1) * cos(dist) + cos(lat1) * sin(dist) * cos(brng2));
    nelat:=toDeg(lat2);
    brng2 := toRad(180);  
    lat1 := toRad(lat);
    lat2 := asin(sin(lat1) * cos(dist) + cos(lat1) * sin(dist) * cos(brng2));
    swlat:=toDeg(lat2);
    brng2 := toRad(90);  
    lon1 := toRad(lng);
    lon2 := lon1 + atan2(sin(brng2) * sin(dist) * cos(lat1), cos(dist) - sin(lat1) * sin(lat2));
    nelong:=toDeg(lon2);
    brng2 := toRad(270);  
    lon1 := toRad(lng);
    lon2 := lon1 + atan2(sin(brng2) * sin(dist) * cos(lat1), cos(dist) - sin(lat1) * sin(lat2));
    swlong:=toDeg(lon2);
  end if;
  
  if (nelong < -180) then
  	nelong := nelong + 360;
  end if;
  if (swlong < -180) then
  	swlong := swlong + 360;
  end if;
  
  if (nelong > 180) then
  	nelong := nelong - 360;
  end if;
  if (swlong > 180) then
  	swlong := swlong - 360;
  end if;
  
  
  --dbms_output.put_line('nelong: ' || nelong);
  ---dbms_output.put_line('swlong: ' || swlong);
  
  delete from fake_coordinate_error  where locality_id=locid;
  
  if (swlong >0 and nelong < 0) then
  	-- error spans 180/-180
  	-- can't write to that, so....just make two errors that butt up to each other
  	insert into fake_coordinate_error (
	    locality_id,
	    swlat,
	    swlong,
	    nelat,
	    nelong
	  ) values (
	    locid,
	    swlat,
	    swlong,
	    nelat,
	    180
	  );
	  insert into fake_coordinate_error (
	    locality_id,
	    swlat,
	    swlong,
	    nelat,
	    nelong
	  ) values (
	    locid,
	    swlat,
	    -180,
	    nelat,
	    nelong
	  );
  else
	  insert into fake_coordinate_error (
	    locality_id,
	    swlat,
	    swlong,
	    nelat,
	    nelong
	  ) values (
	    locid,
	    swlat,
	    swlong,
	    nelat,
	    nelong
	  );
	end if;
end;
/
sho err;


exec getfakeerror(1116568);
select * from fake_coordinate_error where locality_id=1116568;



---- init
begin
  for r in (select locality_id from locality where dec_lat is not null) loop
    getFakeError(r.locality_id);
  end loop;
end;
/

CREATE OR REPLACE TRIGGER TR_LOCALITY_FAKEERR_AID
AFTER INSERT OR DELETE OR UPDATE ON LOCALITY
FOR EACH ROW
BEGIN
	--
    IF inserting or updating THEN
    	update fake_coordinate_error set stale_fg=1 where locality_id=:NEW.locality_id;
    ELSIF deleting THEN
    	DELETE FROM fake_coordinate_error 
    	WHERE locality_id = :OLD.locality_id;
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE fake_coordinate_error_stale IS 
BEGIN
	FOR r IN (SELECT locality_id from fake_coordinate_error where stale_fg=1) loop
		  getfakeerror(r.locality_id);
	END LOOP;
END;
/
sho err;

BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name           =>  'j_fake_coordinate_error_stale',
    job_type           =>  'STORED_PROCEDURE',
	job_action         =>  'fake_coordinate_error_stale',
	start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=minutely; interval=1',
	enabled            =>  TRUE,
	end_date           =>  NULL,
	comments           =>  'check fake_coordinate_error for records marked as stale and update them');
END;
/

delete from cf_spec_res_cols where COLUMN_NAME='cat_num';
delete from cf_spec_res_cols where COLUMN_NAME='collection_cde';

select * from cf_spec_res_cols where COLUMN_NAME='collection';


insert into cf_spec_res_cols (COLUMN_NAME,SQL_ELEMENT,CATEGORY,DISP_ORDER) values ('guid','flatTableName.guid','required',1);

update cf_spec_res_cols set CATEGORY='specimen',DISP_ORDER=2 where COLUMN_NAME='collection';

-- test only
--insert into cf_spec_res_cols (COLUMN_NAME,SQL_ELEMENT,CATEGORY,DISP_ORDER) values ('collection','flatTableName.collection','specimen',2);


-- get rid of collection_cde, cat_num - both are deprecated
-- prepend guid

update cf_users set resultcolumnlist=replace(resultcolumnlist,'collection_cde,');
update cf_users set resultcolumnlist=replace(resultcolumnlist,'cat_num,');
update cf_users set resultcolumnlist=replace(resultcolumnlist,'guid,');
update cf_users set resultcolumnlist=replace(resultcolumnlist,'collection,');
update cf_users set resultcolumnlist=replace(resultcolumnlist,'collection_cde');



update cf_users set resultcolumnlist='guid,' || resultcolumnlist;

select resultcolumnlist from cf_users where (
	lower(resultcolumnlist) like '%collection_cde%' or
	lower(resultcolumnlist) like '%cat_num%'
);

-- BOUNCE CF!! 	to reset sessions

collection,cat_num,
