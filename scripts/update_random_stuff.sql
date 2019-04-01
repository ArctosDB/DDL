------------------ update locality


exec pause_maintanance('off');

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


exec pause_maintanance('on');


----------------- END update locality


------------------ update collecting_event
exec pause_maintanance('off');

lock table collecting_event in exclusive mode nowait;

alter trigger  TR_COLLECTINGEVENT_BUID disable;
alter trigger  TR_COLLEVENT_AU_FLAT disable;

update collecting_event set VERBATIM_COORDINATES=null where VERBATIM_COORDINATES='/';


alter trigger  TR_COLLECTINGEVENT_BUID enable;
alter trigger  TR_COLLEVENT_AU_FLAT enable;

exec pause_maintanance('on');


commit;

------------------ END update collecting_event



