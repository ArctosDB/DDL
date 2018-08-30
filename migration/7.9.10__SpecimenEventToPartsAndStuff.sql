







-- specimen event links: https://github.com/ArctosDB/arctos/issues/1545

create table specimen_event_links (
	specimen_event_link_id number not null,
	specimen_event_id number not null,
	part_id number
);
delete from specimen_event_links;

alter table specimen_event_links add collection_object_id number not null;

CREATE SEQUENCE sq_specimen_event_link_id;
CREATE public SYNONYM sq_specimen_event_link_id FOR sq_specimen_event_link_id;
GRANT SELECT ON sq_specimen_event_link_id TO PUBLIC;


CREATE OR REPLACE TRIGGER trg_specimen_event_links_BI
    BEFORE INSERT ON specimen_event_links
    FOR EACH ROW
    BEGIN
        if :new.specimen_event_link_id is null then
        	select sq_specimen_event_link_id.nextval into :new.specimen_event_link_id from dual;
        end if;
    end;
/

alter table specimen_event_links add constraint PK_specimen_event_link_id PRIMARY KEY (specimen_event_link_id) using index TABLESPACE UAM_IDX_1;
ALTER TABLE specimen_event_links ADD CONSTRAINT pk_spec_evt_lnk_seid FOREIGN KEY (specimen_event_id) REFERENCES specimen_event(specimen_event_id);
ALTER TABLE specimen_event_links ADD CONSTRAINT pk_spec_evt_lnk_pid FOREIGN KEY (part_id) REFERENCES specimen_part(collection_object_id);
ALTER TABLE specimen_event_links ADD CONSTRAINT pk_spec_evt_lnk_cid FOREIGN KEY (collection_object_id) REFERENCES cataloged_item(collection_object_id);


create public synonym specimen_event_links for specimen_event_links;
grant select on specimen_event_links to public;
grant all on specimen_event_links to manage_specimens;



insert into cf_form_permissions (FORM_PATH,ROLE_NAME) values ('/picks/linkSpecimenEvent.cfm','manage_specimens');

-- see if we can find some stuff
-- only care about things with multiple not-unaccpeted events
create table temp_mevt as select collection_object_id from specimen_event where verificationstatus!='unaccepted' having count(*) > 1 group by collection_object_id

select count(*) from temp_mevt;

>40306

-- can only deal with parts, so...
drop table temp_mevt_pt;
create table temp_mevt_pt as select
specimen_part.collection_object_id partID,
temp_mevt.collection_object_id,
COLL_OBJECT_REMARKS from
coll_object_remark,specimen_part,temp_mevt 
where temp_mevt.collection_object_id=specimen_part.DERIVED_FROM_CAT_ITEM and 
specimen_part.collection_object_id=coll_object_remark.collection_object_id and
COLL_OBJECT_REMARKS is not null
;
select count(*) from temp_mevt_pt;


UAM@ARCTOSTE> select count(*) from temp_mevt_pt;

  COUNT(*)
----------
     17486

     select COLL_OBJECT_REMARKS from temp_mevt_pt order by COLL_OBJECT_REMARKS;
     
      select COLL_OBJECT_REMARKS from temp_mevt_pt where COLL_OBJECT_REMARKS not like '%Coll:%' and 
      COLL_OBJECT_REMARKS not like '%Prep:%' order by COLL_OBJECT_REMARKS ;
      
      -- pretty close, I think
      
      alter table temp_mevt_pt add rawdate varchar2(255);
      
      
      update temp_mevt_pt set rawdate= substr(COLL_OBJECT_REMARKS,instr(COLL_OBJECT_REMARKS,'Coll:')) where COLL_OBJECT_REMARKS like '%Coll:%';
      
        update temp_mevt_pt set rawdate= substr(COLL_OBJECT_REMARKS,instr(COLL_OBJECT_REMARKS,'Prep:')) where COLL_OBJECT_REMARKS like '%Prep:%';

      update temp_mevt_pt set rawdate=replace(rawdate,'Prep:');
            update temp_mevt_pt set rawdate=replace(rawdate,'Coll:');

      
      select COLL_OBJECT_REMARKS,
      substr(COLL_OBJECT_REMARKS,instr(COLL_OBJECT_REMARKS,'Coll:'))
      from temp_mevt_pt where COLL_OBJECT_REMARKS like '%Coll:%'
       order by COLL_OBJECT_REMARKS ;
       
    select distinct rawdate,
        SUBSTR(rawdate, 0,INSTR(rawdate, ';') -1)
        from temp_mevt_pt order by rawdate;

       update temp_mevt_pt set rawdate= SUBSTR(rawdate, 0,INSTR(rawdate, ';') -1) where rawdate like '%;%';
       
       update temp_mevt_pt set rawdate=trim(rawdate);
       
              update temp_mevt_pt set rawdate=replace(rawdate,'.');

   
       CREATE OR REPLACE FUNCTION temp_funky_isdate
( p_string in varchar2)
return integer
as
l_date date;
begin
l_date := to_date(p_string,'DD MON YYYY');
   return 1;
exception
when others then
return 0;
end;


       
         select distinct rawdate || '::' || temp_funky_isdate(rawdate)
        from temp_mevt_pt ;
        
        'DD MON YYYY')
        
        update temp_mevt_pt set thedate=to_date(rawdate,'DD MON YYYY') where  temp_funky_isdate(rawdate)=1;
        
        
        alter table temp_mevt_pt add specimen_event_id number;
        alter table temp_mevt_pt add status varchar2(255);
        
        -- pulls multiples, of course
        update temp_mevt_pt set specimen_event_id=(
        select specimen_event_id
        from specimen_event,collecting_event where
        temp_mevt_pt.collection_object_id=specimen_event.collection_object_id and
        specimen_event.collecting_event_id=collecting_event.collecting_event_id and
        collecting_event.began_date=to_char(temp_mevt_pt.thedate,'YYYY-MM-DD')
        );
        
        declare
        	c number;
        	seid number;
        begin
	        for r in (select * from temp_mevt_pt where thedate is not null) loop
		        select count(*) into c from specimen_event,collecting_event where
	        		specimen_event.collection_object_id=r.collection_object_id and
	        		specimen_event.collecting_event_id=collecting_event.collecting_event_id and
	        		collecting_event.began_date=to_char(r.thedate,'YYYY-MM-DD')
	        		;
	        	if c=1 then
	        	 select specimen_event.specimen_event_id into seid from specimen_event,collecting_event where
	        		specimen_event.collection_object_id=r.collection_object_id and
	        		specimen_event.collecting_event_id=collecting_event.collecting_event_id and
	        		collecting_event.began_date=to_char(r.thedate,'YYYY-MM-DD')
	        		;
	        		        	update temp_mevt_pt set specimen_event_id=seid where partid=r.partid;
	
	        	else
	        	
	        	update temp_mevt_pt set status='evtct: ' || c where partid=r.partid;
	        	end if;
	        end loop;
        end ;
        /
        
        select count(*) from temp_mevt_pt where specimen_event_id is not null;
        
        
        
        select status,rawdate from temp_mevt_pt where status is not null;
    
        
  delete from     specimen_event_links;  
  
  insert into specimen_event_links (collection_object_id,specimen_event_id,part_id) (select collection_object_id,specimen_event_id,partid from temp_mevt_pt where specimen_event_id is not null);
  
  
  select guid from flat where collection_object_id in (select collection_object_id from specimen_event_links) group by guid order by guid;
        
  

  
  
  
 -- specimens with multiple not-unaccepted events
create table temp_multi_evt as select collection_object_id from specimen_event where verificationstatus!='unaccepted' having count(*) > 1 group by collection_object_id;
alter table temp_multi_evt add num_parts number;
update temp_multi_evt set num_parts=(select count(*) from specimen_part where specimen_part.derived_from_cat_item=temp_multi_evt.collection_object_id);
alter table temp_multi_evt add num_linked_parts number;
update temp_multi_evt set num_linked_parts=(select count(*) from specimen_event_links where specimen_event_links.collection_object_id=temp_multi_evt.collection_object_id);
alter table temp_multi_evt add guid varchar2(255);
update temp_multi_evt set guid=(select guid from flat where flat.collection_object_id=temp_multi_evt.collection_object_id);
-- get rid of some stuff we know 
delete from temp_multi_evt where guid like 'UAM:EH%';
delete from temp_multi_evt where guid like 'UAMb:Herb:%';
select substr(guid,1,instr(guid,':',1,2)) || ' @ ' || count(*) from temp_multi_evt group by  substr(guid,1,instr(guid,':',1,2));


--- get NK-links

create table temp_mevt_nk_p as select 
specimen_part.collection_object_id partID,
temp_mevt.collection_object_id,
COLL_OBJECT_REMARKS 
from
coll_object_remark,
specimen_part,
temp_mevt 
where 
temp_mevt.collection_object_id=specimen_part.DERIVED_FROM_CAT_ITEM and 
specimen_part.collection_object_id=coll_object_remark.collection_object_id and
COLL_OBJECT_REMARKS is not null
;


create table temp_mevt_nk_se as select 
specimen_event.collection_object_id CID,
specimen_event.specimen_event_id,
SPECIMEN_EVENT_REMARK
from
specimen_event,
temp_mevt 
where 
temp_mevt.collection_object_id=specimen_event.collection_object_id and
SPECIMEN_EVENT_REMARK is not null
;

alter table temp_mevt_nk_se add nk varchar2(255);

alter table temp_mevt_nk_p add nk varchar2(255);

update temp_mevt_nk_se set nk=regexp_replace(SPECIMEN_EVENT_REMARK,'^.*NK([^0-9]*)([0-9]*)(.*)$','\2') where SPECIMEN_EVENT_REMARK like '%NK%';


update temp_mevt_nk_p set nk=regexp_replace(COLL_OBJECT_REMARKS,'^.*NK([^0-9]*)([0-9]*)(.*)$','\2') where COLL_OBJECT_REMARKS like '%NK%';

create table temp_multi_link (
	pid number,
	eid1 number,
	eid2 number
);


declare
	c number;
begin
	for r in (
		select temp_mevt_nk_se.CID,temp_mevt_nk_se.NK,temp_mevt_nk_se.specimen_event_id,temp_mevt_nk_p.partID from 
		temp_mevt_nk_se,temp_mevt_nk_p
		where
		temp_mevt_nk_se.nk is not null and
		temp_mevt_nk_p.nk is not null and
		temp_mevt_nk_se.nk=temp_mevt_nk_p.nk
		) loop
			dbms_output.put_line(r.nk);
			select count(*) into c from specimen_event_links where part_id=r.partID;
			if c>0 then
				dbms_output.put_line('part is linked....');
				select count(*) into c from specimen_event_links where part_id=r.partID and specimen_event_id=r.specimen_event_id;
				if c=0 then
					dbms_output.put_line('...to a DIFFERENT event!!');
					dbms_output.put_line('PartID:' || r.partID);
					dbms_output.put_line('proposedEventID:' || r.specimen_event_id);
					insert into temp_multi_link (pid, eid1,eid2) values (
					r.partID,
					(select specimen_event_id from specimen_event_links where part_id=r.partID),
					r.specimen_event_id);
					
				end if;
			else
				insert into specimen_event_links (collection_object_id,specimen_event_id,part_id) values (r.CID,r.specimen_event_id,r.partID);
			end if;
				
		end loop;
end ;
/

create table temp_multi_link (
	pid number,
	eid1 number,
	eid2 number
);

alter table temp_multi_link add se_remark1 varchar2(4000);
alter table temp_multi_link add se_remark2 varchar2(4000);
alter table temp_multi_link add part_remark varchar2(4000);
alter table temp_multi_link add bd1 varchar2(4000);
alter table temp_multi_link add bd2 varchar2(4000);
alter table temp_multi_link add barcode varchar2(4000);

update temp_multi_link set se_remark1=(select SPECIMEN_EVENT_REMARK from specimen_event where specimen_event_id=eid1);
update temp_multi_link set se_remark2=(select SPECIMEN_EVENT_REMARK from specimen_event where specimen_event_id=eid2);

update temp_multi_link set part_remark=(select COLL_OBJECT_REMARKS from COLL_OBJECT_REMARK where collection_object_id=pid);

update temp_multi_link set bd1=(select began_date from specimen_event,collecting_event where specimen_event.collecting_event_id=collecting_event.collecting_event_id and  specimen_event_id=eid1);
update temp_multi_link set bd2=(select began_date from specimen_event,collecting_event where specimen_event.collecting_event_id=collecting_event.collecting_event_id and  specimen_event_id=eid2);

update temp_multi_link set barcode=(
	select c.barcode from 
	coll_obj_cont_hist,container s,container c where 
	coll_obj_cont_hist.container_id=s.container_id and
	s.parent_container_id=c.container_id and
	coll_obj_cont_hist.collection_object_id=pid
);


	
	specimen_event,collecting_event where specimen_event.collecting_event_id=collecting_event.collecting_event_id and  specimen_event_id=eid2);


226775
part is linked....
...to a DIFFERENT event!!
PartID:27923980
proposedEventID:3177392





create table specimen_event_links (
	specimen_event_link_id number not null,
	specimen_event_id number not null,
	part_id number
);


select distinct
regexp_replace(SPECIMEN_EVENT_REMARK,'^.*NK([^0-9]*)([0-9]*)(.*)$','\2')
from temp_mevt_nk_se where SPECIMEN_EVENT_REMARK like '%NK%';

select COLL_OBJECT_REMARKS from temp_mevt_nk_p where COLL_OBJECT_REMARKS like '%NK%' order by COLL_OBJECT_REMARKS;


select COLL_OBJECT_REMARKS,
regexp_replace(COLL_OBJECT_REMARKS,'^.*NK(.).*$',\1)
from temp_mevt_nk_p where COLL_OBJECT_REMARKS like '%NK%' order by COLL_OBJECT_REMARKS;


select distinct
regexp_replace(COLL_OBJECT_REMARKS,'^.*NK(.).*$','\1')
from temp_mevt_nk_p where COLL_OBJECT_REMARKS like '%NK%';



select distinct
regexp_replace(SPECIMEN_EVENT_REMARK,'^.*NK(.).*$','\1')
from temp_mevt_nk_se where SPECIMEN_EVENT_REMARK like '%NK%';



select distinct
regexp_replace(SPECIMEN_EVENT_REMARK,'^.*NK([^0-9]*)([0-9]*)(.*)$','\2')
from temp_mevt_nk_se where SPECIMEN_EVENT_REMARK like '%NK%';



order by COLL_OBJECT_REMARKS;



select SPECIMEN_EVENT_REMARK from temp_mevt_nk_se where SPECIMEN_EVENT_REMARK like '%NK%' order by SPECIMEN_EVENT_REMARK;




drop table temp_mevt_pt;
create table temp_mevt_pt as select
specimen_part.collection_object_id partID,
temp_mevt.collection_object_id,
COLL_OBJECT_REMARKS from
coll_object_remark,specimen_part,temp_mevt 
where temp_mevt.collection_object_id=specimen_part.DERIVED_FROM_CAT_ITEM and 
specimen_part.collection_object_id=coll_object_remark.collection_object_id and
COLL_OBJECT_REMARKS is not null
;



