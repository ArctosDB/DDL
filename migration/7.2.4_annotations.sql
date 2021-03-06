-- re: https://github.com/ArctosDB/arctos/issues/704
/*
 	Da Plan:
 	
 		-- add annotation_group_id to annotations
 		-- rebuild service to accept multi-record annotations (eg, COLLECTION_OBJECT_ID LIST)
 		-- rebuild management forms to display/manage annotations as groups
 			-- explicit error if >1000 records - seems unnecessary anyway??
 		-- continue to store annotation with specimens, etc.
 			-- indicate the annotation was part of a group eg, annotator wasn't looking at individual specimens
 			
 		
 */

CREATE SEQUENCE sq_annotation_group_id;
-- do NOT autoinsert this; force the forms/apps to deal with it.
alter table annotations add annotation_group_id number;
-- all existing are single
update annotations set annotation_group_id=sq_annotation_group_id.nextval;

alter table annotations modify annotation_group_id not null;

-- insert is likely to require lotsa connections/be slow, so push it off to a procedure

CREATE OR REPLACE PROCEDURE add_annotation (
	v_username in VARCHAR2,
	v_annotation_text in VARCHAR2,
	v_annotation_type in VARCHAR2,
	v_keys in VARCHAR2
)
AS
	v_tab parse_list.varchar2_table;
	v_nfields integer;
	v_keyfield varchar2(255);
	ssmt varchar2(400);
	gid number;
BEGIN
	-- Advisory Committee has stated that username is optional, no checks needed
	
	-- sanitize annotation_text
	
	-- ensure annotation_text meets minimum length requirements
	if length(v_annotation_text) < 20 then
		  raise_application_error(-20000, 'Annotations must be at least 20 characters.');
	end if;
	 
	-- sanitize v_annotation_type
	if v_annotation_type = 'specimen' then
		v_keyfield:='collection_object_id';
	elsif v_annotation_type = 'taxon' then
		v_keyfield:='taxon_name_id';
	elsif v_annotation_type = 'project' then
		v_keyfield:='project_id';
	elsif v_annotation_type = 'publication' then
		v_keyfield:='publication_id';
	else
		raise_application_error(-20000, 'Invalid annotation type.');
	end if;
	
	select sq_annotation_group_id.nextval into gid from dual;
	
	parse_list.delimstring_to_table (v_keys, v_tab, v_nfields);
	for i in 1..v_nfields loop
    	-- each child is the PARENT of the collection_object_id passed in
		dbms_output.put_line(v_tab(i));
		ssmt:='insert into annotations (ANNOTATION_ID,annotation_group_id,ANNOTATE_DATE,CF_USERNAME,' || v_keyfield || ',ANNOTATION ) values (';
		ssmt:=ssmt || 'sq_annotation_id.nextval,' || gid || ',sysdate,''' || v_username ||''',' || v_tab(i) || ',''' || v_annotation_text || ''')';
    	dbms_output.put_line(ssmt);
		execute immediate(ssmt);
	end loop;
END;
/
sho err;


create public synonym add_annotation for add_annotation;

grant execute on add_annotation to coldfusion_user;


exec add_annotation('','tooshort','bad','99999999999999');
exec add_annotation('','tooshort tooshort tooshort tooshort tooshort tooshort','bad','99999999999999');

exec add_annotation('','tooshort tooshort tooshort tooshort tooshort tooshort','specimen','99999999999999');


exec add_annotation('','tooshort tooshort tooshort tooshort tooshort tooshort','specimen','12');

exec add_annotation('','test2: tooshort tooshort tooshort tooshort tooshort tooshort','specimen','12,13,14');

-- rebuild on-page annotation popup; add "details" link to group annotations

select 
	ANNOTATION_ID,
	ANNOTATE_DATE,
	CF_USERNAME,
	COLLECTION_OBJECT_ID,
	ANNOTATION,
	REVIEWER_AGENT_ID,
	REVIEWED_FG,
	REVIEWER_COMMENT,
	ANNOTATION_GROUP_ID
from annotations where collection_object_id=12;



select * from annotations where ANNOTATION_GROUP_ID=398;




-- make annotation page public; limit tools by roles

UAM@ARCTOS> desc annotations
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 ANNOTATION_ID							   NOT NULL NUMBER
 ANNOTATE_DATE							   NOT NULL DATE
 CF_USERNAME								    VARCHAR2(255)
 COLLECTION_OBJECT_ID							    NUMBER
 TAXON_NAME_ID								    NUMBER
 PROJECT_ID								    NUMBER
 PUBLICATION_ID 							    NUMBER
 ANNOTATION							   NOT NULL VARCHAR2(4000)
 REVIEWER_AGENT_ID							    NUMBER
 REVIEWED_FG							   NOT NULL NUMBER(1)
 REVIEWER_COMMENT							    VARCHAR2(255)

 
 