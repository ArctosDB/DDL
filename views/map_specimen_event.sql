--- old and busted

/*
CREATE OR REPLACE VIEW 
    map_specimen_event 
AS SELECT 
     min(specimen_event_id) specimen_event_id,
     COLLECTION_OBJECT_ID FROM 
     specimen_event 
WHERE
    specimen_event_type != 'unaccepted place of collection'
GROUP BY
    COLLECTION_OBJECT_ID
;

*/

-- want
-- not-unaccepted with coordinates
--  for specimens not in that, not-unaccepted without coordinats
--   for specimens not in that, whatever's left




-----------

-- performance impact as of 2015-05-06: .02s --> .06s at one record, but crazy-slow in practice.
-- revisit ASAP - for now, live with the old-n-busted, but prefer the latest event_id, which is generally the
-- one with the best coordinates

CREATE OR REPLACE VIEW 
    map_specimen_event 
AS SELECT 
     max(specimen_event_id) specimen_event_id,
     COLLECTION_OBJECT_ID FROM 
     specimen_event 
WHERE
    specimen_event_type != 'unaccepted place of collection'
GROUP BY
    COLLECTION_OBJECT_ID
;


select flat.collection_object_id,specimen_event_id from flat,specimen_event where flat.collection_object_id=specimen_event.collection_object_id and
guid like 'UAMb:Herb%' having count(*) > 1 group by flat.collection_object_id,specimen_event_id;













/*


ORDERING:

1) place of manufacture (https://github.com/ArctosDB/arctos/issues/862)
2) not-unaccepted with coordinates
3) not-unaccepted without coordiantes
4) whatever's left


*/


drop view mse_pom;
drop view mse_nua_coord;
drop view mse_nua_nocoord;
drop view mse_therest;



-- 1: place of manufacture 
create or replace view mse_pom as SELECT 
    min(specimen_event_id) specimen_event_id ,
    COLLECTION_OBJECT_ID 
FROM 
     specimen_event
WHERE
    specimen_event_type = 'place of manufacture'
group by 
    COLLECTION_OBJECT_ID
;




-- 2: not-unaccepted with coordinates
create or replace view mse_nua_coord as  SELECT 
    min(specimen_event_id) specimen_event_id ,
    COLLECTION_OBJECT_ID 
FROM 
     specimen_event ,
     collecting_event,
     locality
WHERE
    specimen_event.collecting_event_id=collecting_event.collecting_event_id and
    collecting_event.locality_id=locality.locality_id and
    locality.dec_lat is not null and
    specimen_event_type != 'unaccepted place of collection' and
    COLLECTION_OBJECT_ID not in (select COLLECTION_OBJECT_ID from mse_pom)
group by 
    COLLECTION_OBJECT_ID
;
/*
performance sucks, try a different join
	select * from ( select * from mse_nua_coord order by dbms_random.value ) where rownum <= 100;
     	select * from ( select * from mse_nua_nocoord order by dbms_random.value ) where rownum <= 100;
     	select * from ( select * from map_specimen_event order by dbms_random.value ) where rownum <= 100;
     	select * from ( select * from specimen_event order by dbms_random.value ) where rownum <= 100;
     
select count(*) from mse_nua_coord;

  COUNT(*)
----------
   1566007

1 row selected.

Elapsed: 00:00:04.70


create or replace view mse_nua_coord as  SELECT 
    min(specimen_event.specimen_event_id) specimen_event_id ,
    specimen_event.COLLECTION_OBJECT_ID 
FROM 
     specimen_event ,
     collecting_event,
     locality,
     mse_pom
WHERE
    specimen_event.collecting_event_id=collecting_event.collecting_event_id and
    collecting_event.locality_id=locality.locality_id and
    locality.dec_lat is not null and
    specimen_event.specimen_event_type != 'unaccepted place of collection' and
    specimen_event.COLLECTION_OBJECT_ID=mse_pom.COLLECTION_OBJECT_ID (+) and
    mse_pom.COLLECTION_OBJECT_ID is null
group by 
    specimen_event.COLLECTION_OBJECT_ID
;

00:00:17.33

bah nevermind....

 */

-- 3: not-unaccepted withOUT coordinates
create or replace view mse_nua_nocoord as  SELECT 
    min(specimen_event_id)  specimen_event_id ,
    COLLECTION_OBJECT_ID 
FROM 
     specimen_event ,
     collecting_event,
     locality
WHERE
    specimen_event.collecting_event_id=collecting_event.collecting_event_id and
    collecting_event.locality_id=locality.locality_id and
    locality.dec_lat is null and
    COLLECTION_OBJECT_ID not in (
    	select COLLECTION_OBJECT_ID from mse_pom
    	UNION
    	select COLLECTION_OBJECT_ID from mse_nua_coord
    ) and
    specimen_event_type != 'unaccepted place of collection'
group by 
    COLLECTION_OBJECT_ID
;

-- 4: leftovers, everything with not-unaccepted events that we haven't found yet
create or replace view mse_nua_nounaccd as  SELECT 
    min(specimen_event_id)  specimen_event_id ,
    COLLECTION_OBJECT_ID 
FROM 
     specimen_event ,
     collecting_event,
     locality
WHERE
    specimen_event.collecting_event_id=collecting_event.collecting_event_id and
    collecting_event.locality_id=locality.locality_id and
    locality.dec_lat is null and
    COLLECTION_OBJECT_ID not in (
    	select COLLECTION_OBJECT_ID from mse_pom
    	UNION
    	select COLLECTION_OBJECT_ID from mse_nua_coord
    	UNION
    	select COLLECTION_OBJECT_ID from mse_nua_nocoord
    ) and
    specimen_event_type != 'unaccepted place of collection'
group by 
    COLLECTION_OBJECT_ID
;



create or replace view map_specimen_event as 
	select specimen_event_id, COLLECTION_OBJECT_ID from mse_pom
	UNION
	select specimen_event_id, COLLECTION_OBJECT_ID from mse_nua_coord
	UNION
	select specimen_event_id, COLLECTION_OBJECT_ID from mse_nua_nocoord
	UNION
	select specimen_event_id, COLLECTION_OBJECT_ID from mse_therest
 ;
  
 
 
 ----- test
 
 select stale_flag,count(*) from flat group by stale_flag;
 
 update flat set stale_flag=1 where collection_object_id=12;
 
 exec is_flat_stale;
 
 -- old model: 00:00:00.76
 -- new model: 00:00:01.06
 
  update flat set stale_flag=1 where rownum < 500;
  
  -- old: 00:00:24.33
  -- new: 00:07:23.58
  -- GASP! Turn off schedule, try again
  -- new2: 00:07:15.88
  
  
  

 
 -- test
 -- select dec_lat ,stale_flag from flat where guid='UAMb:Herb:30408';
 -- nada
 -- update flat set stale_flag=1 where guid='UAMb:Herb:30408';
 -- select stale_flag,count(*) from flat group by stale_flag;