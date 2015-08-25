CREATE OR REPLACE PROCEDURE MAKE_PART (
    collection_object_id IN number ,
	part_name IN varchar,
	part_modifier IN varchar,
	preserve_method IN varchar,
	condition IN varchar,
	coll_obj_disposition IN VARCHAR,
	lot_count IN number,
	is_tissue IN number,
	coll_object_remarks in VARCHAR )
is
    enteredbyid number;
	partID number;
	label varchar2(255);
	institution_acronym collection.institution_acronym%TYPE;
BEGIN
	SELECT distinct(agent_id) into enteredbyid 
	FROM agent_name 
	WHERE agent_name = user;
	
	dbms_output.put_line('enteredbyid: ' || enteredbyid);
	dbms_output.put_line('user: ' || user);
	dbms_output.put_line('collection_object_id: ' || collection_object_id);
	dbms_output.put_line('coll_obj_disposition: ' || coll_obj_disposition);
END;
/

--  exec make_part(12,'skull','partial',NULL,'ratty','IN COLLECTION',1,0,NULL);
