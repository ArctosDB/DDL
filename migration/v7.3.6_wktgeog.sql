alter table geog_auth_rec add wkt_polygon clob;


download https://www.google.com/fusiontables/data?docid=1xdysxZ94uUFIit9eXmnw1fYc6VcQiXhceFd_CVKa#rows:id=3


drop table temp_geocounty;

create table temp_geocounty (
	CountyName varchar2(4000),
	StateCounty varchar2(4000),
	stateabbr varchar2(4000),
	StateAbbrToo varchar2(4000),
	geometry clob,
	value varchar2(4000),
	GEO_ID varchar2(4000),
	GEO_ID2 varchar2(4000),
	GeographicName varchar2(4000),
	STATEnum varchar2(4000),
	COUNTYnum varchar2(4000),
	FIPSformula varchar2(4000),
	Haserror varchar2(4000)
);

-- use /fix/a.cfm to populate

select count(*) from temp_geocounty;


drop table temp_geocounty_bak;
create table temp_geocounty_bak as select * from temp_geocounty;

--create table temp_geocounty as select * from temp_geocounty_bak;

select distinct GeographicName from temp_geocounty order by GeographicName;

alter table temp_geocounty add state varchar2(255);
alter table temp_geocounty add county varchar2(255);


declare
	c varchar2(4000);
	s  varchar2(4000);
begin
	for r in (select distinct  GeographicName from temp_geocounty) loop
		dbms_output.put_line(r.GeographicName);
		c:=trim(SUBSTR(r.GeographicName, 1 ,INSTR(r.GeographicName, ',', 1, 1)-1));
		dbms_output.put_line('county: ' || c);
		s:=trim(SUBSTR(r.GeographicName, INSTR(r.GeographicName,',', -1, 1)+1));
		dbms_output.put_line('state: ' || s);
		update temp_geocounty set state=s,county=c where GeographicName=r.GeographicName;
	end loop;
end;
/

select distinct state from temp_geocounty order by state;

update temp_geocounty set county=trim(replace(county,'Municipio')) where state='Puerto Rico';

alter table temp_geocounty add geog_auth_rec_id number;

declare 
	c number;
	gid number;
begin
	for r in (select distinct  state,county from temp_geocounty) loop
		--dbms_output.put_line(r.state || ', ' || r.county);

		select count(*) into c from geog_auth_rec where state_prov=r.state and county=r.county and feature is null and island is null and 
		island_group is null and
		 quad is null;

		if c = 1 then
			dbms_output.put_line(r.state || ', ' || r.county || ' @ ' || c);
			select geog_auth_rec_id into gid from geog_auth_rec where state_prov=r.state and county=r.county and feature is null and island is null and 
				island_group is null and
				 quad is null;
			update temp_geocounty set geog_auth_rec_id=gid where state=r.state and county=r.county;
		end if;

	end loop;
end;
/


declare 
	c number;
	gid number;
begin
	for r in (select distinct  state,county from temp_geocounty where  geog_auth_rec_id is null and state='Puerto Rico') loop
		--dbms_output.put_line(r.state || ', ' || r.county);

		select count(*) into c from geog_auth_rec where state_prov=r.state and county=r.county and feature is null and island is null and 
		 quad is null;
		if c = 1 then
				 dbms_output.put_line(r.state || ', ' || r.county || ' @ ' || c);

			--dbms_output.put_line(r.state || ', ' || r.county || ' @ ' || c);
			select geog_auth_rec_id into gid from geog_auth_rec where  state_prov=r.state and county=r.county and feature is null and island is null and 
		 quad is null;
			update temp_geocounty set geog_auth_rec_id=gid where state=r.state and county=r.county;
		end if;
	end loop;
end;
/


declare 
	c number;
	gid number;
begin
	for r in (select distinct  state,county from temp_geocounty where  geog_auth_rec_id is null and county like '%St.%') loop
		--dbms_output.put_line(r.state || ', ' || r.county);

		select count(*) into c from geog_auth_rec where state_prov=r.state and county=replace(r.county,'St.','Saint') and feature is null and island is null and 
		 quad is null;
		 if c = 1 then
		 			select geog_auth_rec_id into gid from geog_auth_rec where  state_prov=r.state and county=replace(r.county,'St.','Saint') and feature is null and island is null and 
		 			quad is null;
		 			update temp_geocounty set geog_auth_rec_id=gid where state=r.state and county=r.county;
		end if;
	end loop;
end;
/



declare 
	c number;
	gid number;
begin
	for r in (select distinct  state,county from temp_geocounty where  geog_auth_rec_id is null ) loop
		--dbms_output.put_line(r.state || ', ' || r.county);

		select count(*) into c from geog_auth_rec where state_prov=r.state and county=replace(r.county,'St.','Saint') and feature is null and island is null and 
		 quad is null;
		
			dbms_output.put_line(r.state || ', ' || r.county || ' @ ' || c);
	end loop;
end;
/

	




-- download https://www.google.com/fusiontables/data?docid=17aT9Ud-YnGiXdXEJUyycH2ocUqreOeKGbzCkUw#rows:id=1
drop table temp_geostate;

create table temp_geostate (
	name varchar2(4000),
	id varchar2(4000),
	geometry clob
	);
	
	
		use fix/a.cfm

	select count(*) from temp_geostate;
		
	create table temp_geostate_bak as select * from temp_geostate;
	

begin
	for r in (select * from temp_geostate_bak where NAME='California') loop
		dbms_output.put_line(r.GEOMETRY);
	end loop;
end;
/

-- try this again...

drop table temp_geostate;
create table temp_geostate as select * from temp_geostate_bak;

alter table temp_geostate add geog_auth_rec_id number;


-- end reset rock on


declare 
	c number;
	gid number;
begin
	for r in (select distinct name from temp_geostate where geog_auth_rec_id is null) loop
		--dbms_output.put_line(r.state || ', ' || r.county);

		select count(*) into c from geog_auth_rec where state_prov=r.name  and feature is null and island is null and 
		island_group is null and
		 quad is null and county is null and sea is null;

		if c = 1 then
			dbms_output.put_line(r.name ||  ' @ ' || c);
			select geog_auth_rec_id into gid from geog_auth_rec where state_prov=r.name  and feature is null and island is null and 
		island_group is null and
		 quad is null and county is null  and sea is null;
			update temp_geostate set geog_auth_rec_id=gid where name=r.name;
		else
			dbms_output.put_line(r.name || ' @ ' || c);
		end if;

	end loop;
end;
/





-------

----working area...
drop table temp_geo_wkt;

create table temp_geo_wkt as select geog_auth_rec_id,GEOMETRY from temp_geostate where geog_auth_rec_id is not null;
insert into temp_geo_wkt (geog_auth_rec_id,GEOMETRY) (select geog_auth_rec_id,GEOMETRY from temp_geocounty where geog_auth_rec_id is not null);

-- and because
create table temp_geo_wkt_bak as select * from temp_geo_wkt;
create table temp_geo_wkt_bak2 as select * from temp_geo_wkt;


-- now defuckify the KML
-- check it


begin
	for r in (select * from temp_geo_wkt where geog_auth_rec_id=969) loop
		dbms_output.put_line('---------------------------------------');
		dbms_output.put_line(r.geog_auth_rec_id);
		dbms_output.put_line(r.GEOMETRY);
	end loop;
end;
/

begin
	for r in (select * from temp_geo_wkt where geog_auth_rec_id=121) loop
		dbms_output.put_line('---------------------------------------');
		dbms_output.put_line(r.geog_auth_rec_id);
		dbms_output.put_line(r.GEOMETRY);
	end loop;
end;
/




-- commas are IN coordiante pairs, need to be BETWEEN
update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,',','|') ;
update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,' ','!') ;

-- | --> comma
-- ! --> space

update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'|',' ') ;
update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'!',',') ;


-- in multipolygons, deal with middle shit
update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'</coordinates></LinearRing></outerBoundaryIs></Polygon><Polygon><outerBoundaryIs><LinearRing><coordinates>',')),((') ;

-- start, end
update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'<Polygon><outerBoundaryIs><LinearRing><coordinates>','POLYGON((') ;
update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'</coordinates></LinearRing></outerBoundaryIs></Polygon>','))') ;
--update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'POLYGON ((','POLYGON((') ;


-- and multi


update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'<MultiGeometry>POLYGON((','MULTIPOLYGON(((') ;
-- crap/patch: update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'POLYGON(((','MULTIPOLYGON(((') ;


update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'))</MultiGeometry>',')))') ;


--update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'))POLYGON((',')),((') ;


-- idkwtf but get rid of the 0.0 "coordinates"...
update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,',0.0 ',' ') ;
update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,',0.0))','))') ;
update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,' 0.0,',',') ;
update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,' 0.0))','))') ;







update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,')) ((',')),((') ;

update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'POLYGON((','MULTIPOLYGON(((') where geometry like '%</coordinates></LinearRing></outerBoundaryIs><innerBoundaryIs><LinearRing><coordinates>%';

update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'</coordinates></LinearRing></outerBoundaryIs><innerBoundaryIs><LinearRing><coordinates>','))((') ;
update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'</coordinates></LinearRing></innerBoundaryIs></Polygon></MultiGeometry>',')))') ;


</coordinates></LinearRing></innerBoundaryIs></Polygon></MultiGeometry>
</coordinates></LinearRing></innerBoundaryIs></Polygon></MultiGeometry>


--- push to geog


lock table geog_auth_rec in exclusive mode nowait;

alter trigger TRG_HIGHER_GEOG_MAGICDUPS disable;
alter trigger  TR_GEOGAUTHREC_AU_FLAT disable;

begin
	for r in (select * from temp_geo_wkt ) loop
		update geog_auth_rec set wkt_polygon=r.GEOMETRY where geog_auth_rec_id=r.geog_auth_rec_id;
	end loop;
end;
/


update geog_auth_rec set wkt_polygon='MEDIA::10497397' where geog_auth_rec_id=1137;
update geog_auth_rec set wkt_polygon='MEDIA::10497395' where geog_auth_rec_id=121;
update geog_auth_rec set wkt_polygon='MEDIA::10497396' where geog_auth_rec_id=1328;

alter trigger TRG_HIGHER_GEOG_MAGICDUPS enable;
alter trigger  TR_GEOGAUTHREC_AU_FLAT enable;

commit;








vi ak.wkt

# copypasta

:%s/,/|/g
:%s/ /!/g
:%s/<Polygon><outerBoundaryIs><LinearRing><coordinates>/POLYGON((/g
:%s/<\/coordinates><\/LinearRing><\/outerBoundaryIs><\/Polygon>/))/g
:%s/<MultiGeometry>POLYGON((/POLYGON(((/g
:%s/))<\/MultiGeometry>/)))/g


:%s/|/ /g
:%s/!/,/g


:%s/,0.0 / /g
:%s/,0.0))/))/g
:%s/ 0.0,/,/g
:%s/ 0.0))/))/g
:%s/replacethis/withthis/g



-- start, end


-- idkwtf but get rid of the 0.0 "coordinates"...
update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'',' ') ;
update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'','') ;
update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'',',') ;
update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'','))') ;







update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,')) ((',')),((') ;

update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'POLYGON((','MULTIPOLYGON(((') where geometry like '%</coordinates></LinearRing></outerBoundaryIs><innerBoundaryIs><LinearRing><coordinates>%';

update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'</coordinates></LinearRing></outerBoundaryIs><innerBoundaryIs><LinearRing><coordinates>','))((') ;
update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,'</coordinates></LinearRing></innerBoundaryIs></Polygon></MultiGeometry>',')))') ;




update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,',','|') ;
update temp_geo_wkt set GEOMETRY=replace(GEOMETRY,' ','!') ;



http://arctos-test.tacc.utexas.edu/editLocality.cfm?locality_id=10043723






alter trigger TRG_HIGHER_GEOG_MAGICDUPS enable;
alter trigger  TR_GEOGAUTHREC_AU_FLAT enable;


commit;



select
  state_prov || ': ' || county
from
  geog_auth_rec
where
  state_prov is not null and
  county is not null and
  WKT_POLYGON is null and
  country='United States' and
  sea is null and
  island_group is null and
  island is null and
  quad is null and
  feature is null;
  
  
   


   

select distinct name from temp_geostate where geog_auth_rec_id is null;


MEDIA::

- alaska
- minnesota
- wi