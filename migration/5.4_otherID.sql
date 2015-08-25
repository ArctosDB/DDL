f/*
	
	THINGS TO TEST
		everything involving otherIDs or formerly involving relationships
		-data entry
		-bulkloading
		-cloning
		
	AFTER MIGRATION
		clean up pending relationships, then remove that functionality in another release
			- email notifications
			- bulkloading
			- form and table(s)
			
			
			
	set other ID up as relationships - that is, IDs of related specimens - along with being "self" IDs.
	
	
	need to cache some stuff (when available) about related specimens (=non-self-IDs). No such thing outside Arctos, or course, but set up mechanism to get 
	that sort of info via RDF or whatever
	
	here's where we're coming from
	
	
	uam@ARCTOSPROD> desc coll_obj_other_id_num;
	 Name								   Null?    Type
	 ----------------------------------------------------------------- -------- --------------------------------------------
	 COLLECTION_OBJECT_ID						   NOT NULL NUMBER
	 OTHER_ID_TYPE							   NOT NULL VARCHAR2(75)
	 OTHER_ID_PREFIX							    VARCHAR2(60)
	 OTHER_ID_NUMBER							    NUMBER
	 OTHER_ID_SUFFIX							    VARCHAR2(60)
	 DISPLAY_VALUE							   NOT NULL VARCHAR2(255)
	 COLL_OBJ_OTHER_ID_NUM_ID					   NOT NULL NUMBER
 
  	
 	
*/

create table ctid_references (
	id_references varchar2(60) not null ,
	description varchar2(4000) not null
);

ALTER TABLE ctid_references ADD CONSTRAINT pk_ctid_references PRIMARY KEY (id_references) USING INDEX TABLESPACE UAM_IDX_1;


create or replace public synonym ctid_references for ctid_references;
grant select on ctid_references to public;

-- don't want to do this twice, so lock the table for the duration of this update - make sure to unlock it way below
revoke update, insert, delete on ctBIOL_RELATIONS from manage_codetables;

-- now need to migrate from BIOL_RELATIONS


/*
	these will be displayed (tentatively) as
	
	({id_references}) [potential hyperlink {idtype}:{idnumber}] 
	

	
*/

-- reset
delete from ctid_references;




insert into ctid_references (id_references,description) values
	('self','An identifier associated primarily with this cataloged item. GenBank numbers referencing sequences of this individual or collector numbers referring to events leading to this specimen belong here. No reciprocal.');

insert into ctid_references (id_references,description) values
	('littermate or nestmate of','An identifier referencing a cataloged item that was a littermate or nestmate of this item. No indication of relatedness is intended; use "sibling" if that is known. This is suitable for all individuals found in a nest (including <i>e.g.</i>, nest parasites) or in an apparent but unconfirmed litter or family group. Reciprocal relationship is "littermate or nestmate of."');	

insert into ctid_references (id_references,description) values
	('mate of','An identifier referencing a cataloged item that was a mate of this item. Reproduction is implied. Reciprocal relationship is "mate of."');	

insert into ctid_references (id_references,description) values
	('same individual as','An identifier referencing a cataloged item that is the same individual as this item. Use when <i>e.g.</i>, parts and tissues are retained by different institutions. Reciprocal relationship is "same individual as."');	
	
insert into ctid_references (id_references,description) values
	('sibling of','An identifier referencing a cataloged item that is the biological sibling of this item. Reciprocal relationship is "sibling of."');
	
insert into ctid_references (id_references,description) values
	('in amplexus with','An identifier referencing a cataloged item that was (presumably found at time of collection) in amplexus with this item. No implications of reproduction are intended. Reciprocal relationship is "in amplexus with."');
	
insert into ctid_references (id_references,description) values
	('collected with','An identifier referencing a cataloged item that was collected in the field with another cataloged item, but the relationship between individuals is unclear. Do not use if the relationship (e.g., mate of, littermate of, offspring of, parasite of, etc.) is known. Reciprocal relationship is "collected with."');

insert into ctid_references (id_references,description) values
	('collected on','An identifier referencing a cataloged item which this item was collected on. This is more specific than "collected with" and less specific than "parasite of." Reciprocal relationship is "collected from."');	
	
insert into ctid_references (id_references,description) values
	('collected from','An identifier referencing a cataloged item that was collected on this item. This is more specific than "collected with" and less specific than "parasite of."  Reciprocal relationship is "collected on."');

insert into ctid_references (id_references,description) values
	('parasite of','An identifier referencing a cataloged item that was a host of this item. Reciprocal relationship is "host of."');	
	
insert into ctid_references (id_references,description) values
	('host of','A number referring to a cataloged item that was a parasite of this item; this item is a parasite. Reciprocal relationship is "parasite of."');	

insert into ctid_references (id_references,description) values
	('ate','A number referring to a cataloged item that was eaten by this item. Reciprocal relationship is "eaten by."');	

insert into ctid_references (id_references,description) values
	('eaten by','A number referring to a cataloged item that ate this item. Reciprocal relationship is "ate."');	

insert into ctid_references (id_references,description) values
	('offspring of','A number referring to a cataloged item that is the biological parent of this item. Reciprocal relationship is "parent of."');
	
insert into ctid_references (id_references,description) values
	('parent of','A number referring to a cataloged item that is the biological child of this item;. Reciprocal relationship is "offspring of."');

	
	
/*
 	END things that we've done in prod already - the rest is for migration
 */
grant all on ctid_references to manage_codetables;

LOCK TABLE coll_obj_other_id_num IN EXCLUSIVE MODE NOWAIT; 

alter table coll_obj_other_id_num add id_references varchar2(60) default 'self' not null;

ALTER TABLE coll_obj_other_id_num add CONSTRAINT fk_id_references FOREIGN KEY (id_references) REFERENCES ctid_references (id_references);


-- create other ID types for each collection that doesn't already have them

declare
 c NUMBER;
begin
	for r in (select * from collection) loop
		select count(*) into c from CTCOLL_OTHER_ID_TYPE where replace(OTHER_ID_TYPE,':')=replace(r.guid_prefix,':');
		dbms_output.put_line('found ' || c || ' records for ' || r.guid_prefix);
		if c=0 then
			insert into CTCOLL_OTHER_ID_TYPE (OTHER_ID_TYPE,DESCRIPTION,BASE_URL) values (r.guid_prefix, r.collection || ' catalog number','http://arctos.database.museum/guid/' || r.guid_prefix || ':');
		end if;
	end loop;
end;
/

-- move all relationships into other IDs

drop trigger TR_BIOLINDIVRELN_AIUD_FLAT;

create table biol_indiv_relations20130218 as select * from biol_indiv_relations;
create table coll_obj_other_id_num20130218 as select * from coll_obj_other_id_num;


alter table biol_indiv_relations add idt varchar2(255);

update biol_indiv_relations set idt=(select guid_prefix from collection,cataloged_item where collection.collection_id=cataloged_item.collection_id and 
cataloged_item.collection_object_id=biol_indiv_relations.collection_object_id);

select idt from biol_indiv_relations where idt not in (select OTHER_ID_TYPE from CTCOLL_OTHER_ID_TYPE);
select count(*) from biol_indiv_relations where idt is null;


alter table biol_indiv_relations add r_idt varchar2(255);

update biol_indiv_relations set r_idt=(select guid_prefix from collection,cataloged_item where collection.collection_id=cataloged_item.collection_id and 
cataloged_item.collection_object_id=biol_indiv_relations.RELATED_COLL_OBJECT_ID);

select r_idt from biol_indiv_relations where r_idt not in (select OTHER_ID_TYPE from CTCOLL_OTHER_ID_TYPE);
select count(*) from biol_indiv_relations where r_idt is null;


alter table biol_indiv_relations add cn varchar2(255);

update biol_indiv_relations set cn=(select cat_num from collection,cataloged_item where collection.collection_id=cataloged_item.collection_id and 
cataloged_item.collection_object_id=biol_indiv_relations.collection_object_id);

select count(*) from biol_indiv_relations where cn is null;

alter table biol_indiv_relations add r_cn varchar2(255);

update biol_indiv_relations set r_cn=(select cat_num from collection,cataloged_item where collection.collection_id=cataloged_item.collection_id and 
cataloged_item.collection_object_id=biol_indiv_relations.RELATED_COLL_OBJECT_ID);

select count(*) from biol_indiv_relations where r_cn is null;



alter table biol_indiv_relations add refs varchar2(255);
alter table biol_indiv_relations add r_refs varchar2(255);

drop index IU_COLLOBJOIDN_COID_TYPE_DISP;

CREATE UNIQUE INDEX IU_OIDNUM_ID_TYP_DISP_refs
	ON COLL_OBJ_OTHER_ID_NUM (COLLECTION_OBJECT_ID, OTHER_ID_TYPE, DISPLAY_VALUE,ID_REFERENCES)
	TABLESPACE UAM_IDX_1;



update biol_indiv_relations set
	refs='eaten by',
	r_refs='ate'
where BIOL_INDIV_RELATIONSHIP='eaten by';
	
update biol_indiv_relations set
	refs='ate',
	r_refs='eaten by'
where BIOL_INDIV_RELATIONSHIP='ate';

update biol_indiv_relations set
	refs='parent of',
	r_refs='offspring of'
where BIOL_INDIV_RELATIONSHIP='parent of';

update biol_indiv_relations set
	refs='offspring of',
	r_refs='parent of'
where BIOL_INDIV_RELATIONSHIP='offspring of';
	
	
update biol_indiv_relations set
	refs='parasite of',
	r_refs='host of'
where BIOL_INDIV_RELATIONSHIP='parasite of';

update biol_indiv_relations set
	refs='host of',
	r_refs='parasite of'
where BIOL_INDIV_RELATIONSHIP='host of';
	
update biol_indiv_relations set
	refs='collected on',
	r_refs='collected from'
where BIOL_INDIV_RELATIONSHIP='collected on';
	
update biol_indiv_relations set
	refs='in amplexus with',
	r_refs='in amplexus with'
where BIOL_INDIV_RELATIONSHIP='in amplexus with';
	
update biol_indiv_relations set
	refs='littermate or nestmate',
	r_refs='littermate or nestmate'
where BIOL_INDIV_RELATIONSHIP='littermate of';
	
update biol_indiv_relations set
	refs='littermate or nestmate',
	r_refs='littermate or nestmate'
where BIOL_INDIV_RELATIONSHIP='nestmate of';
	
update biol_indiv_relations set
	refs='mate of',
	r_refs='mate of'
where BIOL_INDIV_RELATIONSHIP='mate of';
	
update biol_indiv_relations set
	refs='collected with',
	r_refs='collected with'
where BIOL_INDIV_RELATIONSHIP='collected with';
	
update biol_indiv_relations set
	refs='sibling of',
	r_refs='sibling of'
where BIOL_INDIV_RELATIONSHIP='sibling of';
	
update biol_indiv_relations set
	refs='same individual as',
	r_refs='same individual as'
where BIOL_INDIV_RELATIONSHIP='same individual as';
	
select count(*) from biol_indiv_relations where refs is null;
select count(*) from biol_indiv_relations where r_refs is null;

	-- some of the stuff we just created is crazy duplicates, so....
	
	-- need to rebuild flat before we're done - in the meantime...
	drop trigger UAM.TR_COLLOBJOIDNUM_AIUD_FLAT;

--.back out - DO NOT DO THIS IN PROD - DON'T SCREW IT UP THERE!!!
--  delete from COLL_OBJ_OTHER_ID_NUM where OTHER_ID_TYPE in (select guid_prefix from collection);
	
	
	select refs from biol_indiv_relations where refs not in (select id_references from ctid_references) group by refs;
		select r_refs from biol_indiv_relations where r_refs not in (select id_references from ctid_references) group by r_refs;

		update biol_indiv_relations set refs='littermate or nestmate of' where refs='littermate or nestmate';
		update biol_indiv_relations set r_refs='littermate or nestmate of' where r_refs='littermate or nestmate';
		
		
	insert into coll_obj_other_id_num (
		 COLLECTION_OBJECT_ID,
		 OTHER_ID_TYPE,
		 OTHER_ID_NUMBER,
		 ID_REFERENCES
	) (
		select 
			RELATED_COLL_OBJECT_ID, -- this item
			IDT, -- related item
			CN, -- related item
			REFS -- what happened to the related item
		from
			biol_indiv_relations
		group by
			RELATED_COLL_OBJECT_ID,
			IDT,
			CN,
			REFS
	);

	
	
	-- DAMMIT!!!!!!!
	
	
	LOCK TABLE coll_obj_other_id_num IN EXCLUSIVE MODE NOWAIT; 

	alter trigger UAM.COLL_OBJ_DATA_CHECK disable;
	alter trigger UAM.COLL_OBJ_DISP_VAL disable;
	alter trigger UAM.TR_COLLOBJOIDNUM_AIUD_FLAT disable;
	
	
	
	
	
	alter table coll_obj_other_id_num add tempref varchar2(255);
	update coll_obj_other_id_num set tempref=id_references;
	
	
	UPDATE coll_obj_other_id_num SET id_references='eaten by' WHERE tempref='ate';
	UPDATE coll_obj_other_id_num SET id_references='ate' WHERE tempref='eaten by';
	UPDATE coll_obj_other_id_num SET id_references='parent of' WHERE tempref='offspring of';
	UPDATE coll_obj_other_id_num SET id_references='offspring of' WHERE tempref='parent of';
	UPDATE coll_obj_other_id_num SET id_references='parasite of' WHERE tempref='host of';
	UPDATE coll_obj_other_id_num SET id_references='host of' WHERE tempref='parasite of';
	UPDATE coll_obj_other_id_num SET id_references='collected on' WHERE tempref='collected from';
	UPDATE coll_obj_other_id_num SET id_references='collected from' WHERE tempref='collected on';
	
	
	
	-----IU_OIDNUM_ID_TYP_DISP_REFS
	


	CREATE OR REPLACE TRIGGER TR_COLLOBJOIDNUM_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON coll_obj_other_id_num
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
	IF deleting 
	    THEN id := :OLD.collection_object_id;
	    ELSE id := :NEW.collection_object_id;
	END IF;
	    
	UPDATE flat
	SET stale_flag = 1,
	lastuser=sys_context('USERENV', 'SESSION_USER'),
	lastdate=SYSDATE
    WHERE collection_object_id = id;
END;
/


alter trigger UAM.COLL_OBJ_DATA_CHECK ENABLE;
	alter trigger UAM.COLL_OBJ_DISP_VAL ENable;

	
	
	--- END DAMMIT
	-- have to deal with duplicates (from unnecessarily explicit recursion in related data) now
	declare
		c number;
	begin
		for r in (select 
			COLLECTION_OBJECT_ID, -- this item, from this perspective
			r_IDT, -- related item
			r_CN,
			r_REFS -- what happened to the related item
		from
			biol_indiv_relations
		group by
			COLLECTION_OBJECT_ID, -- this item, from this perspective
			r_IDT,
			r_CN,
			r_REFS) loop
			select count(*) into c from coll_obj_other_id_num where 
				COLLECTION_OBJECT_ID=r.COLLECTION_OBJECT_ID and
				OTHER_ID_TYPE=r.r_IDT and
				OTHER_ID_NUMBER=r.r_CN and
				ID_REFERENCES=r.r_REFS;
			if c=0 then
				--dbms_output.put_line(r.r_IDT || ':' || r.r_cn || ' ' || r.r_REFS || '; INSERTING-------');
				insert into coll_obj_other_id_num (
					 COLLECTION_OBJECT_ID,
					 OTHER_ID_TYPE,
					 OTHER_ID_NUMBER,
					 ID_REFERENCES
				) values (
					r.COLLECTION_OBJECT_ID,
					r.r_IDT,
					r.r_CN,
					r.r_REFS
				);
			
			end if;
		
		end loop;
	end ;
	/
	
	alter table bulkloader add OTHER_ID_REFERENCES_1 VARCHAR2(255);
	alter table bulkloader add OTHER_ID_REFERENCES_2 VARCHAR2(255);
	alter table bulkloader add OTHER_ID_REFERENCES_3 VARCHAR2(255);
	alter table bulkloader add OTHER_ID_REFERENCES_4 VARCHAR2(255);
	alter table bulkloader add OTHER_ID_REFERENCES_5 VARCHAR2(255);
	
	
	alter table bulkloader_stage add OTHER_ID_REFERENCES_1 VARCHAR2(255);
	alter table bulkloader_stage add OTHER_ID_REFERENCES_2 VARCHAR2(255);
	alter table bulkloader_stage add OTHER_ID_REFERENCES_3 VARCHAR2(255);
	alter table bulkloader_stage add OTHER_ID_REFERENCES_4 VARCHAR2(255);
	alter table bulkloader_stage add OTHER_ID_REFERENCES_5 VARCHAR2(255);
	
	
	alter table bulkloader_deletes add OTHER_ID_REFERENCES_1 VARCHAR2(255);
	alter table bulkloader_deletes add OTHER_ID_REFERENCES_2 VARCHAR2(255);
	alter table bulkloader_deletes add OTHER_ID_REFERENCES_3 VARCHAR2(255);
	alter table bulkloader_deletes add OTHER_ID_REFERENCES_4 VARCHAR2(255);
	alter table bulkloader_deletes add OTHER_ID_REFERENCES_5 VARCHAR2(255);
	
	
drop trigger OTHER_ID_CT_CHECK;

CREATE OR REPLACE TRIGGER COLL_OBJ_DISP_VAL
BEFORE INSERT or UPDATE ON COLL_OBJ_OTHER_ID_NUm
FOR EACH ROW
BEGIN
    :NEW.display_value := 
        :NEW.OTHER_ID_PREFIX || 
        :NEW.OTHER_ID_NUMBER || 
        :NEW.OTHER_ID_SUFFIX;
    if :new.ID_REFERENCES is null then
    	:new.ID_REFERENCES:='self';
    end if;
END;

-- push this back to DDL folder
CREATE OR REPLACE FUNCTION concatRelations (p_key_val IN VARCHAR2)
RETURN VARCHAR2
AS
    TYPE RC IS REF CURSOR;
    l_str    VARCHAR2(4000);
    l_sep    VARCHAR2(30);
    l_val    VARCHAR2(4000);
    l_cur    RC;
BEGIN
    OPEN l_cur FOR '
        select 
            ''('' || coll_obj_other_id_num.ID_REFERENCES || '') '' ||  coll_obj_other_id_num.other_id_type || '' '' || ctcoll_other_id_type.base_url || coll_obj_other_id_num.display_value
            FROM
					coll_obj_other_id_num,
					ctcoll_other_id_type
				where
					collection_object_id=:x and
					coll_obj_other_id_num.ID_REFERENCES != ''self'' and
					coll_obj_other_id_num.other_id_type=ctcoll_other_id_type.other_id_type (+)
				ORDER BY
					coll_obj_other_id_num.id_references,
					coll_obj_other_id_num.other_id_type,
					coll_obj_other_id_num.display_value'
        USING p_key_val;
    LOOP
        FETCH l_cur INTO l_val;
        EXIT WHEN l_cur%notfound;
        if length(l_str) + length(l_sep) + length(l_val) > 3500 then
        	l_str := l_str || ' - truncated....';
        	exit;
        else
        	l_str := l_str || l_sep || l_val;
        	l_sep := '; ';
        end if;
    END LOOP;
    CLOSE l_cur;
    RETURN l_str;
END;
/
sho err;

-- and update flat

update flat set RELATEDCATALOGEDITEMS=concatRelations(collection_object_id) where 
RELATEDCATALOGEDITEMS is not null or
collection_object_id in (select collection_object_id from coll_obj_other_id_num)
;



update coll_obj_other_id_num set other_id_type='UAM:Ento' where other_id_type='UAM:ENTO';

delete from CTCOLL_OTHER_ID_TYPE where  other_id_type='UAM:ENTO';




-- push this back to DDL folder
CREATE OR REPLACE function ConcatOtherId(p_key_val  in number)
    return varchar2
    as
        type rc is ref cursor;
        l_str    varchar2(4000);
       l_sep    varchar2(2);
       l_val    varchar2(4000);
   		l_cur    rc;
   begin

       open l_cur for 'select other_id_type || ''=''|| display_value
                         from coll_obj_other_id_num
                        where coll_obj_other_id_num.ID_REFERENCES = ''self'' and collection_object_id = :x
                        order by other_id_type, display_value'
                   using p_key_val;

       loop
           fetch l_cur into l_val;
           exit when l_cur%notfound;
           l_str := l_str || l_sep || l_val;
           l_sep := '; ';
       end loop;
       close l_cur;

       return l_str;
   end;
/


-- rebuild  Procedure parse_other_id
-- rebuild CREATE OR REPLACE FUNCTION bulk_check_one (colobjid  in NUMBER)
-- rebuild CREATE OR REPLACE FUNCTION bulk_stage_check_one (colobjid  in NUMBER)
-- rebuild bulkloader table


drop table cf_temp_oids;
drop public synonym cf_temp_oids;

create table cf_temp_oids (
	key number,
	collection_object_id number,
	guid_prefix varchar2(20) not null,
	existing_other_id_type varchar2(60) not null,
	existing_other_id_number varchar2(60) not null,
	new_other_id_type varchar2(60) not null,
	new_other_id_number varchar2(60) not null,
	new_other_id_references varchar2(60),
	status varchar2(4000)
);

	create public synonym cf_temp_oids for cf_temp_oids;
	grant select,insert,update,delete on cf_temp_oids to manage_specimens;

	 CREATE OR REPLACE TRIGGER cf_temp_oids_key
 before insert  ON cf_temp_oids
 for each row
    begin
    	if :NEW.key is null then
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;
    end;
/
sho err



	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	



------------------------------------ cleanup/to-do ------------------------------------
-- delete or unlock ctBIOL_RELATIONS 
-- pending relations + link in header

-- other randomness
alter table collection add use_license_id number;
ALTER TABLE collection add CONSTRAINT fk_use_license_id FOREIGN KEY (use_license_id) REFERENCES CTMEDIA_LICENSE (MEDIA_LICENSE_ID);


CREATE OR REPLACE TRIGGER TR_COLLECTION_AU_FLAT
	AFTER UPDATE ON collection FOR EACH ROW
	BEGIN
		if (:NEW.COLLECTION != :OLD.collection) OR (:new.guid_prefix != :old.guid_prefix) then
			UPDATE flat SET stale_flag = 1 WHERE collection_id = :OLD.collection_id;
		end if;
	END;
/
sho err;
alter table collection add citation varchar2(255);

-- set privs for info/ipt.cfm
 