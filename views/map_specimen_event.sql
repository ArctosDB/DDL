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





drop view mse_nua_coord;
drop view mse_nua_nocoord;
drop view mse_therest;


-- not-unaccepted with coordinates
create or replace view mse_nua_coord as  SELECT 
    min(specimen_event_id)  specimen_event_id ,
    COLLECTION_OBJECT_ID 
FROM 
     specimen_event ,
     collecting_event,
     locality
WHERE
    specimen_event.collecting_event_id=collecting_event.collecting_event_id and
    collecting_event.locality_id=locality.locality_id and
    locality.dec_lat is not null and
    specimen_event_type != 'unaccepted place of collection'
group by 
    COLLECTION_OBJECT_ID
;

--  for specimens not in that, not-unaccepted without coordinats

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
    COLLECTION_OBJECT_ID not in (select COLLECTION_OBJECT_ID from mse_nua_coord) and
    specimen_event_type != 'unaccepted place of collection'
group by 
    COLLECTION_OBJECT_ID
;
--   for specimens not in those two, whatever's left

create or replace view mse_therest as  SELECT 
    min(specimen_event_id)  specimen_event_id ,
    COLLECTION_OBJECT_ID 
FROM 
     specimen_event
WHERE
    COLLECTION_OBJECT_ID not in (
        select COLLECTION_OBJECT_ID from mse_nua_coord
        union
        select COLLECTION_OBJECT_ID from mse_nua_nocoord
     )
group by 
    COLLECTION_OBJECT_ID
  ;
  
 create or replace view map_specimen_event as select 
  specimen_event_id,
  COLLECTION_OBJECT_ID
 from 
  mse_nua_coord
 union select 
  specimen_event_id,
  COLLECTION_OBJECT_ID
 from 
  mse_nua_nocoord
 union select 
  specimen_event_id,
  COLLECTION_OBJECT_ID
 from 
  mse_therest
 ;
  
 -- test
 -- select dec_lat ,stale_flag from flat where guid='UAMb:Herb:30408';
 -- nada
 -- update flat set stale_flag=1 where guid='UAMb:Herb:30408';
 -- select stale_flag,count(*) from flat group by stale_flag;