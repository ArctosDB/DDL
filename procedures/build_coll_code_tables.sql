CREATE OR REPLACE PROCEDURE build_coll_code_tables IS
	thisTableName varchar2(38);
	n number;
	s varchar2(4000);
BEGIN
/*
	creates cct tables to use in institution-specific searches
*/
    FOR c IN (SELECT * FROM collection) LOOP
		thisTableName := 'cctattribute_type' || c.collection_id;
		SELECT count(*) INTO n FROM user_tables WHERE upper(table_name) = upper(thisTableName);
		IF n = 0 THEN
			s := 'CREATE TABLE ' || thisTableName || ' AS';
    		s := s || ' SELECT attributes.attribute_type, collection.collection_cde';
    		s := s || ' FROM attributes, cataloged_item, collection';
    		s := s || ' WHERE attributes.collection_object_id = cataloged_item.collection_object_id';
    		s := s || ' AND cataloged_item.collection_id = collection.collection_id';
    		s := s || ' AND collection.collection_id = ' || c.collection_id;
    		s := s || ' GROUP BY attributes.attribute_type, collection.collection_cde';
			EXECUTE IMMEDIATE s;
			s := 'CREATE OR REPLACE PUBLIC SYNONYM ' || thisTableName || ' FOR ' || thisTableName;
			EXECUTE IMMEDIATE s;
		    s := 'GRANT SELECT ON ' || thisTableName || ' TO public';
			EXECUTE IMMEDIATE s;
		ELSE
		    s:='truncate table ' || thisTableName;
			EXECUTE IMMEDIATE s;
			s := 'insert into ' || thisTableName || ' (';
            s := s || 'attribute_type,collection_cde) (';
            s := s || ' SELECT attributes.attribute_type, collection.collection_cde';
    		s := s || ' FROM attributes, cataloged_item, collection';
    		s := s || ' WHERE attributes.collection_object_id = cataloged_item.collection_object_id';
    		s := s || ' AND cataloged_item.collection_id = collection.collection_id';
    		s := s || ' AND collection.collection_id = ' || c.collection_id;
    		s := s || ' GROUP BY attributes.attribute_type, collection.collection_cde)';
			EXECUTE IMMEDIATE s;
		END IF;
		    
		thisTableName := 'cctSpecimen_Part_Name' || c.collection_id;
		SELECT count(*) INTO n FROM user_tables WHERE upper(table_name) = upper(thisTableName);
		IF n = 0 THEN
			s := 'CREATE TABLE ' || thisTableName || ' AS';
    		s := s || ' SELECT specimen_part.part_name, collection.collection_cde';
    		s := s || ' FROM specimen_part, cataloged_item, collection';
    		s := s || ' WHERE specimen_part.derived_from_cat_item = cataloged_item.collection_object_id';
    		s := s || ' AND cataloged_item.collection_id = collection.collection_id';
    		s := s || ' AND collection.collection_id = ' || c.collection_id;
    		s := s || ' GROUP BY specimen_part.part_name, collection.collection_cde';
			EXECUTE IMMEDIATE s;
			s := 'CREATE OR REPLACE PUBLIC SYNONYM ' || thisTableName || ' FOR ' || thisTableName;
			EXECUTE IMMEDIATE s;
		    s := 'GRANT SELECT ON ' || thisTableName || ' TO public';
			EXECUTE IMMEDIATE s;
		ELSE
		    s:='truncate table ' || thisTableName;
			EXECUTE IMMEDIATE s;
			s := 'insert into ' || thisTableName || ' (';
            s := s || 'part_name,collection_cde) (';
            s := s || ' SELECT specimen_part.part_name, collection.collection_cde';
    		s := s || ' FROM specimen_part, cataloged_item, collection';
    		s := s || ' WHERE specimen_part.derived_from_cat_item = cataloged_item.collection_object_id';
    		s := s || ' AND cataloged_item.collection_id = collection.collection_id';
    		s := s || ' AND collection.collection_id = ' || c.collection_id;
    		s := s || ' GROUP BY specimen_part.part_name, collection.collection_cde)';
			EXECUTE IMMEDIATE s;
		END IF;
		
		thisTableName := 'cctColl_Other_Id_Type' || c.collection_id;
		SELECT count(*) INTO n FROM user_tables WHERE upper(table_name) = upper(thisTableName);
		IF n = 0 THEN
			s := 'CREATE TABLE ' || thisTableName || ' AS';
    		s := s || ' SELECT coll_obj_other_id_num.other_id_type, collection.collection_cde';
    		s := s || ' FROM coll_obj_other_id_num, cataloged_item, collection';
    		s := s || ' WHERE coll_obj_other_id_num.collection_object_id = cataloged_item.collection_object_id';
    		s := s || ' AND cataloged_item.collection_id = collection.collection_id';
    		s := s || ' AND collection.collection_id = ' || c.collection_id;
    		s := s || ' GROUP BY coll_obj_other_id_num.other_id_type, collection.collection_cde';
			EXECUTE IMMEDIATE s;
			s := 'CREATE OR REPLACE PUBLIC SYNONYM ' || thisTableName || ' FOR ' || thisTableName;
    		EXECUTE IMMEDIATE s;
    		s := 'GRANT SELECT ON ' || thisTableName || ' TO public';
    		EXECUTE IMMEDIATE s;
		ELSE
		    s:='truncate table ' || thisTableName;
			EXECUTE IMMEDIATE s;
			s := 'insert into ' || thisTableName || ' (';
            s := s || 'other_id_type,collection_cde) (';
            s := s || ' SELECT coll_obj_other_id_num.other_id_type, collection.collection_cde';
    		s := s || ' FROM coll_obj_other_id_num, cataloged_item, collection';
    		s := s || ' WHERE coll_obj_other_id_num.collection_object_id = cataloged_item.collection_object_id';
    		s := s || ' AND cataloged_item.collection_id = collection.collection_id';
    		s := s || ' AND collection.collection_id = ' || c.collection_id;
    		s := s || ' GROUP BY coll_obj_other_id_num.other_id_type, collection.collection_cde)';
    		EXECUTE IMMEDIATE s;
		END IF;
		
		EXECUTE IMMEDIATE s;
		
	END LOOP; 
END;
/
sho err;
-- exec build_coll_code_tables;