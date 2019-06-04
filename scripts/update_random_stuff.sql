------------------ update locality


exec pause_maintenance('off');

lock table locality in exclusive mode nowait;

alter trigger TRG_LOCALITY_BIU disable;
alter trigger TR_LOCALITY_BUD disable;
alter trigger TR_LOCALITY_AU_FLAT disable;
alter trigger TR_LOCALITY_FAKEERR_AID disable;


--update LOCALITY set locality_name=NULL where  locality_name like 'TEMP::%';
update locality set bla='bla' where blaugh='blah';


alter trigger TR_LOCALITY_FAKEERR_AID enable;
alter trigger TR_LOCALITY_AU_FLAT enable;
alter trigger TRG_LOCALITY_BIU enable;
alter trigger TR_LOCALITY_BUD enable;


exec pause_maintenance('on');


----------------- END update locality


------------------ update collecting_event
exec pause_maintenance('off');

lock table collecting_event in exclusive mode nowait;

alter trigger  TR_COLLECTINGEVENT_BUID disable;
alter trigger  TR_COLLEVENT_AU_FLAT disable;

update collecting_event set VERBATIM_COORDINATES=null where VERBATIM_COORDINATES='/';


alter trigger  TR_COLLECTINGEVENT_BUID enable;
alter trigger  TR_COLLEVENT_AU_FLAT enable;

exec pause_maintenance('on');


commit;

------------------ END update collecting_event











-- need to update some specimens using these localities to a new geography
-- new geog ID is 10005036 for all
-- first make a clone of all of the localities
alter table temp_ds_lswp add cloned_loc_id number;

begin
  for r in (select distinct LOCALITY_ID from temp_ds_lswp) loop
    insert into locality (
      LOCALITY_ID,
      GEOG_AUTH_REC_ID,
      SPEC_LOCALITY,
      DEC_LAT,
      DEC_LONG,
      MINIMUM_ELEVATION,
      MAXIMUM_ELEVATION,
      ORIG_ELEV_UNITS,
      MIN_DEPTH,
      MAX_DEPTH,
      DEPTH_UNITS,
      MAX_ERROR_DISTANCE,
      MAX_ERROR_UNITS,
      DATUM,
      LOCALITY_REMARKS,
      GEOREFERENCE_SOURCE,
      GEOREFERENCE_PROTOCOL,
      LOCALITY_NAME,
      WKT_MEDIA_ID
    ) (select
        sq_locality_id.nextval,
        10005036,
        SPEC_LOCALITY,
        DEC_LAT,
        DEC_LONG,
        MINIMUM_ELEVATION,
        MAXIMUM_ELEVATION,
        ORIG_ELEV_UNITS,
        MIN_DEPTH,
        MAX_DEPTH,
        DEPTH_UNITS,
        MAX_ERROR_DISTANCE,
        MAX_ERROR_UNITS,
        DATUM,
        LOCALITY_REMARKS,
        GEOREFERENCE_SOURCE,
        GEOREFERENCE_PROTOCOL,
        LOCALITY_NAME,
        WKT_MEDIA_ID
      from
        locality
      where
        LOCALITY_ID=r.locality_id
    );
    update temp_ds_lswp set cloned_loc_id=sq_locality_id.currval where LOCALITY_ID=r.locality_id;
  end loop;
end;
/

--check
select LOCALITY_ID,cloned_loc_id from temp_ds_lswp;
-- spiffy
-- now get collecting_event_id for specimens we care about
-- might as well get specimen_event_id and collection_object_id while we're here
-- new table for this
create table temp_ds_ls_two (
  LOCALITY_ID number,
  cloned_loc_id number,
  specimen_event_id number,
  collecting_event_id number)
  ;

begin
  for r in (select distinct LOCALITY_ID,cloned_loc_id from temp_ds_lswp) loop
    for s in (
      select 
        specimen_event_id,
        specimen_event.collecting_event_id
      from
        collection,
        cataloged_item,
        specimen_event,
        collecting_event
      where
        collection.collection_id=cataloged_item.collection_id and
        cataloged_item.collection_object_id=specimen_event.collection_object_id and
        specimen_event.collecting_event_id=collecting_event.collecting_event_id and
        collection.guid_prefix in ('KWP:Ento','UAM:Ento','UAMObs:Ento') and
        collecting_event.locality_id=r.LOCALITY_ID
    ) loop
      insert into temp_ds_ls_two (
        LOCALITY_ID,
        cloned_loc_id,
        specimen_event_id,
        collecting_event_id
      ) values (
        r.LOCALITY_ID,
        r.cloned_loc_id,
        s.specimen_event_id,
        s.collecting_event_id
      );
    end loop;
  end loop;
end;
/

-- check
select * from temp_ds_ls_two;
-- bueno

-- now just make new collecting events to avoid any possible issues with sharing
alter table temp_ds_ls_two add cloned_event_id number;

begin
  for r in (select distinct collecting_event_id,cloned_loc_id from temp_ds_ls_two) loop
    insert into collecting_event (
      COLLECTING_EVENT_ID,
      LOCALITY_ID,
      VERBATIM_DATE,
      VERBATIM_LOCALITY,
      COLL_EVENT_REMARKS,
      BEGAN_DATE,
      ENDED_DATE,
      VERBATIM_COORDINATES,
      DATUM,
      ORIG_LAT_LONG_UNITS
    ) (
      select
        sq_COLLECTING_EVENT_ID.nextval,
        r.cloned_loc_id,
        VERBATIM_DATE,
        VERBATIM_LOCALITY,
        COLL_EVENT_REMARKS,
        BEGAN_DATE,
        ENDED_DATE,
        VERBATIM_COORDINATES,
        DATUM,
        ORIG_LAT_LONG_UNITS
      from
        collecting_event
      where
        collecting_event_id=r.collecting_event_id
    );

    update temp_ds_ls_two set cloned_event_id=sq_COLLECTING_EVENT_ID.currval where collecting_event_id=r.collecting_event_id;

  end loop;
end;
/

-- check
select * from temp_ds_ls_two;
--bueno

-- backups of backups...

create table bak_locality20190529 as select * from locality;
create table bak_collecting_event20190529 as select * from collecting_event;
create table bak_specimen_event20190529 as select * from specimen_event;

  -- double-extra-triple check
begin
  for r in (select specimen_event_id from temp_ds_ls_two ) loop
    for s in (
       select 
          guid_prefix || ':'||cat_num guid,
          higher_geog
        from
          collection,
          cataloged_item,
          specimen_event,
          collecting_event,
          locality,
          geog_auth_rec
        where
          collection.collection_id=cataloged_item.collection_id and
          cataloged_item.collection_object_id=specimen_event.collection_object_id and
          specimen_event.collecting_event_id=collecting_event.collecting_event_id and
          collecting_event.locality_id=locality.LOCALITY_ID and
          locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
          specimen_event.specimen_event_id=r.specimen_event_id
      ) loop
        dbms_output.put_line(s.guid || '-->' || s.higher_geog);
      end loop;
     end loop;
  end;
  /

  -- OK, lets do it....

exec pause_maintenance('off');

begin
  for r in (select specimen_event_id,cloned_event_id from temp_ds_ls_two ) loop
    update specimen_event set collecting_event_id=r.cloned_event_id where specimen_event_id=r.specimen_event_id;
  end loop;
end;
/

exec pause_maintenance('on');

-- END::need to update some specimens using these localities to a new geography



