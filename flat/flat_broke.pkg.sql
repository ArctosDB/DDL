/* 
	This package runs against table FLAT as defined on 17-OCT-2007.	
	
	Requirements:
	
	CREATE TABLE flat_is_broken (
    	broke_date DATE,
    	collection_object_id NUMBER,
    	problem VARCHAR2(255),
    	fixed NUMBER
    );
    
    OBJECTIVE: 
    	periodically check everything in flat against real data
    	record things that are or potentially are broken in table flat_is_broken
    	provide tools to fix said broken things
    	
    	Flat columnlist: delete from here as tools to find and deal with
    	the issues pop up here
    	
 COLLECTION_OBJECT_ID                      NOT NULL NUMBER
 CAT_NUM                                   NOT NULL NUMBER
 ACCN_ID                                   NOT NULL NUMBER
 COLLECTION_ID                             NOT NULL NUMBER
 INSTITUTION_ACRONYM                                VARCHAR2(20)
 COLLECTION_CDE                                     VARCHAR2(5)
 COLLECTION                                         VARCHAR2(50)
 COLLECTING_EVENT_ID                                NUMBER
 BEGAN_DATE                                         DATE
 ENDED_DATE                                         DATE
 VERBATIM_DATE                                      VARCHAR2(60)
 LAST_EDIT_DATE                                     DATE
 INDIVIDUALCOUNT                                    NUMBER
 COLL_OBJ_DISPOSITION                               VARCHAR2(20)
 COLLECTORS                                         VARCHAR2(4000)
 FIELD_NUM                                          VARCHAR2(4000)
 OTHERCATALOGNUMBERS                                VARCHAR2(4000)
 GENBANKNUM                                         VARCHAR2(4000)
 RELATEDCATALOGEDITEMS                              VARCHAR2(4000)
 TYPESTATUS                                         VARCHAR2(4000)
 SEX                                                VARCHAR2(4000)
 PARTS                                              VARCHAR2(4000)
 ENCUMBRANCES                                       VARCHAR2(4000)
 ACCESSION                                          VARCHAR2(81)
 GEOG_AUTH_REC_ID                                   NUMBER
 HIGHER_GEOG                                        VARCHAR2(255)
 CONTINENT_OCEAN                                    VARCHAR2(50)
 COUNTRY                                            VARCHAR2(50)
 STATE_PROV                                         VARCHAR2(75)
 COUNTY                                             VARCHAR2(50)
 FEATURE                                            VARCHAR2(50)
 ISLAND                                             VARCHAR2(50)
 ISLAND_GROUP                                       VARCHAR2(50)
 QUAD                                               VARCHAR2(30)
 SEA                                                VARCHAR2(50)
 LOCALITY_ID                                        NUMBER
 SPEC_LOCALITY                                      VARCHAR2(255)
 MINIMUM_ELEVATION                                  NUMBER
 MAXIMUM_ELEVATION                                  NUMBER
 ORIG_ELEV_UNITS                                    VARCHAR2(2)
 MIN_ELEV_IN_M                                      NUMBER
 MAX_ELEV_IN_M                                      NUMBER
 DEC_LAT                                            NUMBER(12,10)
 DEC_LONG                                           NUMBER(13,10)
 DATUM                                              VARCHAR2(55)
 ORIG_LAT_LONG_UNITS                                VARCHAR2(25)
 VERBATIMLATITUDE                                   VARCHAR2(127)
 VERBATIMLONGITUDE                                  VARCHAR2(127)
 LAT_LONG_REF_SOURCE                                VARCHAR2(255)
 COORDINATEUNCERTAINTYINMETERS                      NUMBER
 GEOREFMETHOD                                       VARCHAR2(255)
 LAT_LONG_REMARKS                                   VARCHAR2(4000)
 LAT_LONG_DETERMINER                                VARCHAR2(184)
 IDENTIFICATION_ID                                  NUMBER
 SCIENTIFIC_NAME                                    VARCHAR2(255)
 IDENTIFIEDBY                                       VARCHAR2(184)
 MADE_DATE                                          DATE
 REMARKS                                            VARCHAR2(4000)
 HABITAT                                            VARCHAR2(4000)
 ASSOCIATED_SPECIES                                 VARCHAR2(4000)
 TAXA_FORMULA                                       VARCHAR2(25)
 FULL_TAXON_NAME                                    VARCHAR2(4000)
 PHYLCLASS                                          VARCHAR2(4000)
 KINGDOM                                            VARCHAR2(4000)
 PHYLUM                                             VARCHAR2(4000)
 PHYLORDER                                          VARCHAR2(4000)
 FAMILY                                             VARCHAR2(4000)
 GENUS                                              VARCHAR2(4000)
 SPECIES                                            VARCHAR2(4000)
 SUBSPECIES                                         VARCHAR2(4000)
 AUTHOR_TEXT                                        VARCHAR2(4000)
 NOMENCLATURAL_CODE                                 VARCHAR2(4000)
 INFRASPECIFIC_RANK                                 VARCHAR2(4000)
 IDENTIFICATIONMODIFIER                             CHAR(1)
 GUID                                               VARCHAR2(67)
 BASISOFRECORD                                      VARCHAR2(17)
 DEPTH_UNITS                                        VARCHAR2(20)
 MIN_DEPTH                                          NUMBER
 MAX_DEPTH                                          NUMBER
 MIN_DEPTH_IN_M                                     NUMBER
 MAX_DEPTH_IN_M                                     NUMBER
 COLLECTING_METHOD                                  VARCHAR2(255)
 COLLECTING_SOURCE                                  VARCHAR2(15)
 DAYOFYEAR                                          NUMBER
 AGE_CLASS                                          VARCHAR2(4000)
 ATTRIBUTES                                         VARCHAR2(4000)
 VERIFICATIONSTATUS                                 VARCHAR2(40)
 SPECIMENDETAILURL                                  VARCHAR2(255)
 IMAGEURL                                           VARCHAR2(121)
 FIELDNOTESURL                                      VARCHAR2(121)
 CATALOGNUMBERTEXT                                  VARCHAR2(40)
 COLLECTORNUMBER                                    VARCHAR2(4000)
 VERBATIMELEVATION                                  VARCHAR2(84)
 YEAR                                               NUMBER
 MONTH                                              NUMBER
 DAY                                                NUMBER
 STALE_FLAG                                         NUMBER

*/
CREATE OR REPLACE PACKAGE flat_broke AS
	/* show grouped problems */
	PROCEDURE show_stats;
	/* checks that flat and cataloged_item have the same number of records */
	PROCEDURE whurz_my_stuff;
	PROCEDURE fix_whurz_my_stuff;
	/* checks that flat taxonomy matches taxonomy for current identifications */
	PROCEDURE taxonomy_is_evil;
	PROCEDURE fix_taxonomy_is_evil;
	PROCEDURE no_loc_in_flat;
	PROCEDURE fix_no_loc_in_flat;
	PROCEDURE changed_collection;
	PROCEDURE fix_changed_collection;
	PROCEDURE show_sql;
	PROCEDURE fix_all;
END;
/
sho err

CREATE OR REPLACE PACKAGE BODY flat_broke AS
    error_msg VARCHAR2(255);
	some_number NUMBER;
	some_other_number NUMBER;
	some_varchar VARCHAR2(4000);
PROCEDURE show_sql IS
BEGIN
    dbms_output.put_line('exec flat_broke.show_stats;');
    dbms_output.put_line('exec flat_broke.fix_all;');
    dbms_output.put_line('exec flat_broke.whurz_my_stuff;');
    dbms_output.put_line('exec flat_broke.fix_whurz_my_stuff;');
    dbms_output.put_line('exec flat_broke.taxonomy_is_evil;');
    dbms_output.put_line('exec flat_broke.fix_taxonomy_is_evil;');
    dbms_output.put_line('exec flat_broke.no_loc_in_flat;');
    dbms_output.put_line('exec flat_broke.fix_no_loc_in_flat;');
    dbms_output.put_line('exec flat_broke.changed_collection;');
    dbms_output.put_line('exec flat_broke.fix_changed_collection;');
END;
------------------------

PROCEDURE fix_all IS
BEGIN
	whurz_my_stuff;
	fix_whurz_my_stuff;
	taxonomy_is_evil;
	fix_taxonomy_is_evil;
	no_loc_in_flat;
	fix_no_loc_in_flat;
	changed_collection;
	fix_changed_collection;
	show_stats;
END;
------------------------

PROCEDURE changed_collection IS
BEGIN
	FOR m IN (
        SELECT cataloged_item.collection_object_id              
        FROM flat, cataloged_item 
        WHERE flat.collection_object_id = cataloged_item.collection_object_id 
        AND flat.collection_id != cataloged_item.collection_id
    ) LOOP
        INSERT INTO flat_is_broken (
            broke_date,
            problem,
            collection_object_id
        ) VALUES (
            sysdate,
            'collection changed',
            m.collection_object_id
        );
    END LOOP;
END;
-------------------------

PROCEDURE fix_changed_collection IS
BEGIN
	FOR r IN (
        SELECT 
            cataloged_item.collection_object_id,
            cataloged_item.cat_num,
            cataloged_item.accn_id,
            cataloged_item.collecting_event_id,
            cataloged_item.collection_cde,
            cataloged_item.collection_id
        FROM
            flat_is_broken,
            cataloged_item
	    WHERE problem = 'collection changed' 
	    AND fixed IS NULL 
	    AND flat_is_broken.collection_object_id = cataloged_item.collection_object_id
    ) LOOP
        UPDATE flat 
        SET 
            cat_num = r.cat_num,
            accn_id = r.accn_id,
            collecting_event_id = r.collecting_event_id,
            collection_cde = r.collection_cde,
            collection_id = r.collection_id,
            catalognumbertext = to_char(r.cat_num)
        WHERE flat.collection_object_id = r.collection_object_id;
        update_flat(r.collection_object_id);
	    UPDATE flat_is_broken 
	    SET fixed = 1 
	    WHERE problem = 'collection changed' 
	    AND collection_object_id = r.collection_object_id;
	    -- likely to die many times; commit after every fix
	    COMMIT;
	END LOOP;
END;
-------------------------

PROCEDURE whurz_my_stuff IS
BEGIN
	SELECT count(*) INTO some_number FROM flat;
	SELECT count(*) INTO some_other_number FROM cataloged_item;
	
	IF some_number != some_other_number THEN
		FOR m IN (
            SELECT collection_object_id 
            FROM flat 
            WHERE collection_object_id NOT IN (
                SELECT collection_object_id FROM cataloged_item)
        ) LOOP
            INSERT INTO flat_is_broken (
                broke_date,
                problem,
                collection_object_id
            ) VALUES (
                sysdate,
                'cataloged item not in cataloged_item',
                m.collection_object_id
            );
        END LOOP;
		FOR m IN (
            SELECT collection_object_id 
            FROM cataloged_item 
            WHERE collection_object_id NOT IN (
                SELECT collection_object_id FROM flat)
        ) LOOP
            INSERT INTO flat_is_broken (
                broke_date,
                problem,
                collection_object_id
            ) VALUES (
                sysdate,
                'cataloged item not in flat',
                m.collection_object_id
            );
        END LOOP;
    END IF;
END;
-------------------------

PROCEDURE fix_whurz_my_stuff IS
BEGIN
    DELETE FROM flat
    WHERE collection_object_id IN (
        SELECT collection_object_id 
        FROM flat_is_broken
        WHERE problem = 'cataloged item not in cataloged_item'
        AND fixed IS NULL
    );
    UPDATE flat_is_broken 
    SET fixed = 1
    WHERE problem = 'cataloged item not in cataloged_item';

	INSERT INTO flat (
		collection_object_id,
		cat_num,
		accn_id,
		collection_id,
		collection_cde,
		catalognumbertext
	)(
	    SELECT
			cataloged_item.collection_object_id,
			cat_num,
			accn_id,
			collection_id,
			collection_cde,
			to_char(cat_num)	
	    FROM 
			cataloged_item,
			flat_is_broken
		WHERE cataloged_item.collection_object_id = flat_is_broken.collection_object_id 
		AND problem = 'cataloged item not in flat'
	);
	UPDATE flat_is_broken 
	SET fixed = 1
    WHERE problem = 'cataloged item not in flat';
END;
-------------------------

PROCEDURE taxonomy_is_evil IS
BEGIN
	INSERT INTO flat_is_broken (
	    broke_date,
	    problem,
	    collection_object_id
    )(
        SELECT 
            sysdate,
            'bad taxonomy',
            flat.collection_object_id
	    FROM
		    flat,
			identification,
			identification_taxonomy,
			taxonomy
		WHERE flat.collection_object_id = identification.collection_object_id 
        AND identification.identification_id = identification_taxonomy.identification_id 
        AND identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id 
        AND identification.accepted_id_fg = 1 
        AND variable='A'
        AND (
            flat.full_taxon_name IS NULL 
            OR flat.full_taxon_name != 
				CASE
				    WHEN identification.taxa_formula LIKE '%B'
                    THEN get_taxonomy(flat.collection_object_id,'full_taxon_name')
                    ELSE taxonomy.full_taxon_name
                END
		   	OR flat.phylclass != 
				CASE 
				    WHEN identification.taxa_formula like '%B' 
				    THEN get_taxonomy(flat.collection_object_id,'phylclass')
		    	    ELSE taxonomy.phylclass
		    	END
		   	OR flat.Kingdom != 
				CASE 
				    WHEN identification.taxa_formula like '%B'
				    THEN get_taxonomy(flat.collection_object_id,'Kingdom')
		    		ELSE taxonomy.Kingdom
		    	END
		    OR flat.Phylum != 
				CASE 
				    WHEN identification.taxa_formula like '%B'
				    THEN get_taxonomy(flat.collection_object_id,'Phylum')
		    		ELSE taxonomy.Phylum
		    	END
		    OR flat.phylOrder != 
				CASE 
				    WHEN identification.taxa_formula like '%B'
				    THEN get_taxonomy(flat.collection_object_id,'phylOrder')
		    		ELSE taxonomy.phylOrder
		    	END
    		OR flat.Family != 
				CASE 
				    WHEN identification.taxa_formula like '%B'
				    THEN get_taxonomy(flat.collection_object_id,'Family')
		    		ELSE taxonomy.Family
		    	END
		    OR flat.Genus != 
				CASE 
				    WHEN identification.taxa_formula like '%B'
				    THEN get_taxonomy(flat.collection_object_id,'Genus')
		    		ELSE taxonomy.Genus
		    	END
		     OR flat.Species != 
				CASE 
				    WHEN identification.taxa_formula like '%B'
				    THEN get_taxonomy(flat.collection_object_id,'Species')
		    		ELSE taxonomy.Species
		    	END
		     OR flat.Subspecies != 
				CASE 
				    WHEN identification.taxa_formula like '%B'
				    THEN get_taxonomy(flat.collection_object_id,'Subspecies')
		    		ELSE taxonomy.Subspecies
		    	END
		    OR flat.author_text != 
				CASE 
				    WHEN identification.taxa_formula like '%B'
				    THEN get_taxonomy(flat.collection_object_id,'author_text')
		    		ELSE taxonomy.author_text
		    	END
		    OR flat.nomenclatural_code != 
				CASE 
				    WHEN identification.taxa_formula like '%B'
				    THEN get_taxonomy(flat.collection_object_id,'nomenclatural_code')
		    		ELSE taxonomy.nomenclatural_code
		    	END
		    OR flat.infraspecific_rank != 
				CASE 
				    WHEN identification.taxa_formula like '%B'
				    THEN get_taxonomy(flat.collection_object_id,'infraspecific_rank')
		    		ELSE taxonomy.infraspecific_rank
		    	END
        )
    );
END;
-------------------------

PROCEDURE fix_taxonomy_is_evil IS
BEGIN
	FOR r IN (
        SELECT collection_object_id 
        FROM flat_is_broken
	    WHERE problem = 'bad taxonomy' 
	    AND fixed IS NULL
    ) LOOP
	    -- probably should have something more specific, but for now
	    -- just update the whole damned thing
        update_flat(r.collection_object_id);
        UPDATE flat_is_broken 
        SET fixed = 1 WHERE problem = 'bad taxonomy' 
        AND collection_object_id = r.collection_object_id;
	    -- likely to die many times; commit after every fix
	    COMMIT;
	END LOOP;
END;
--------------------------

PROCEDURE show_stats IS
BEGIN
	FOR r IN (
	    SELECT
	        problem,
	        decode(fixed, null,'pending', 'complete') fixed,
		    count(*) c 
        FROM flat_is_broken
        GROUP BY problem, fixed
        ORDER BY problem, fixed
    ) LOOP
        dbms_output.put_line('Status: ' ||  r.fixed || 
            '; Problem: ' || r.problem || 
            '; count: ' || r.c);
    END LOOP;
END;
--------------------------

PROCEDURE no_loc_in_flat IS
BEGIN
	INSERT INTO flat_is_broken (
	    broke_date,
	    problem,
	    collection_object_id
    )(
        SELECT 
	        sysdate,
	        'missing locality stuff',
	        flat.collection_object_id
		FROM flat
		WHERE flat.higher_geog IS NULL
    );
END;
--------------------------

PROCEDURE fix_no_loc_in_flat IS
BEGIN
	FOR r IN (
        SELECT collection_object_id 
        FROM flat_is_broken
	    WHERE problem = 'missing locality stuff' 
	    AND fixed IS NULL
    ) LOOP
	    -- probably should have something more specific, but for now
	    -- just update the whole damned thing
        update_flat(r.collection_object_id);
	    UPDATE flat_is_broken 
	    SET fixed = 1 
	    WHERE problem = 'missing locality stuff' 
	    AND collection_object_id = r.collection_object_id;
	    -- likely to die many times; commit after every fix
	    COMMIT;
	END LOOP;
END;
--------------------------
END;
/
sho err
--------------------------

--  exec flat_broke.whurz_my_stuff;
--  exec flat_broke.fix_whurz_my_stuff;
--  exec flat_broke.taxonomy_is_evil;
--  exec flat_broke.fix_taxonomy_is_evil;
--  exec flat_broke.no_loc_in_flat;
--  exec flat_broke.fix_no_loc_in_flat;
--  exec flat_broke.changed_collection;
--  exec flat_broke.fix_changed_collection;
--  exec flat_broke.show_stats;
