-- CREATE TABLE media_keywords AS SELECT media_id FROM media;
-- ALTER TABLE media_keywords ADD keywords varchar2(4000);
-- ALTER TABLE media_keywords ADD lastdate DATE;
-- create index ix_media_keyword on media_keywords(keywords) tablespace uam_idx_1;
-- create unique index ix_media_id_keyword on media_keywords(media_id) tablespace uam_idx_1;
-- create public synonym media_keywords for media_keywords;
-- grant select on media_keywords to public;

-- mia_media_keywords_job is scheduled to run daily at 3:00 AM;
-- see DDL/dbms_scheduler/mia_media_keywords_job.sql.
CREATE OR REPLACE PROCEDURE mia_media_keywords
IS
BEGIN
    INSERT INTO media_keywords (media_id) 
    SELECT media_id 
    FROM media 
    WHERE media_id NOT IN (SELECT media_id FROM media_keywords));
END;
/
-- set_media_keywords_job is scheduled to every five minutes.
-- see DDL/dbms_scheduler/set_media_keywords_job.sql.
CREATE OR REPLACE PROCEDURE set_media_keywords 
IS
    tabl VARCHAR2(255);
    kw VARCHAR2(4000);
    temp VARCHAR2(4000);
    sep VARCHAR2(4);
BEGIN
    FOR m IN (
        SELECT media_id 
        FROM media_keywords 
        WHERE (lastdate IS NULL OR ((SYSDATE - lastdate) > 1)) 
        AND ROWNUM <= 2000
    ) LOOP
        kw := ' ';
        temp := ' ';
        sep:= ' ';  
        
        FOR r IN (
            SELECT media_relationship, related_primary_key 
            FROM media_relations 
            WHERE media_id = m.media_id 
            AND media_relationship NOT IN (
                'original created by agent',
                'created by agent')
        ) LOOP
            tabl := SUBSTR(r.media_relationship, INSTR(r.media_relationship, ' ', -1) + 1);
            
            --dbms_output.put_line('mid: ' || m.media_id);
            --dbms_output.put_line('mr: ' || r.media_relationship || chr(9) || r.related_primary_key);
            --dbms_output.put_line('tabl : ' || tabl);
            
            CASE tabl
                WHEN 'locality' THEN
                    SELECT spec_locality || '; ' || higher_geog into temp 
                    FROM locality,geog_auth_rec
                    WHERE locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id 
                    AND locality.locality_id = r.related_primary_key;
                WHEN 'collecting_event' THEN
                    SELECT 
                        DECODE(
                              verbatim_locality,
                              spec_locality,'',
                              verbatim_locality || '; ')  || 
                         verbatim_date || '; ' || 
                        spec_locality || '; ' || higher_geog INTO temp 
                    FROM collecting_event, locality, geog_auth_rec 
                    WHERE collecting_event.locality_id = locality.locality_id 
                    AND locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id 
                    AND collecting_event.collecting_event_id = r.related_primary_key;
                WHEN 'agent' THEN
                    SELECT agent_name INTO temp 
                    FROM preferred_agent_name 
                    WHERE agent_id = r.related_primary_key;
                WHEN 'media' THEN
                    SELECT media_uri INTO temp 
                    FROM media 
                    WHERE media_id = r.related_primary_key;
                WHEN 'cataloged_item' THEN
                    SELECT 
                        collection || ' ' || cat_num || '; ' || 
                        GUID_PREFIX || ':' || cat_num  || '; ' ||
                        concatOtherId(cataloged_item.collection_object_id) || '; ' ||
                        get_taxonomy(cataloged_item.collection_object_id, 'scientific_name')  || '; ' ||
                        DECODE(regexp_replace(get_taxonomy(cataloged_item.collection_object_id, 'display_name'), '<[^<]+>', ''),
                            get_taxonomy(cataloged_item.collection_object_id, 'scientific_name'),'',
                            regexp_replace(get_taxonomy(cataloged_item.collection_object_id, 'display_name'), '<[^<]+>', '')  || '; ') ||
                        DECODE(
                              verbatim_locality,
                              spec_locality,'',
                              verbatim_locality || '; ')  ||  
                        verbatim_date || '; ' || 
                        spec_locality || '; ' || 
                        higher_geog
                    INTO temp 
                    FROM cataloged_item,collection,collecting_event,locality,geog_auth_rec
                    WHERE cataloged_item.collection_id = collection.collection_id 
                    AND cataloged_item.collecting_event_id = collecting_event.collecting_event_id 
                    AND collecting_event.locality_id = locality.locality_id 
                    AND locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id 
                    AND cataloged_item.collection_object_id = r.related_primary_key;
                WHEN 'project' THEN
                    SELECT project_name INTO temp 
                    FROM project 
                    WHERE project_id = r.related_primary_key;
                WHEN 'accn' THEN
                    SELECT collection || ' ' || accn_number INTO temp 
                    FROM accn, trans, collection
                    WHERE accn.transaction_id = trans.transaction_id 
                    AND trans.collection_id = collection.collection_id 
                    AND accn.transaction_id = r.related_primary_key;
                WHEN 'taxonomy' THEN
                    SELECT full_taxon_name || ' ' || display_name INTO temp 
                    FROM taxonomy 
                    WHERE  taxonomy.taxon_name_id = r.related_primary_key;
                 WHEN 'publication' THEN
                     SELECT regexp_replace(formatted_publication, '<[^<]+>', '') INTO temp
                     FROM formatted_publication WHERE
                     format_style='long' AND
                     formatted_publication.publication_id=r.related_primary_key;
                ELSE
                    NULL;
            END CASE;
                
            IF length(kw) + length(temp) + 20 < 4000 THEN
                kw := kw || sep || temp;
                sep := '; ';
            END IF;
        END LOOP;
        
        FOR l IN (
            SELECT label_value 
            FROM media_labels 
            WHERE media_id = m.media_id 
            AND media_label NOT IN (
                'audio recording channels',
				'audio sample frequency',
				'audio bit rate',
				'audio vocal type',
				'audio individual identifier',
				'page',
				'audio cues count',
				'usage',
				'aspect',
				'use policy',
				'MD5 checksum',
				'audio original source')
        ) LOOP
            IF length(kw) + length(l.label_value) + 20 < 4000 THEN
                kw := kw || sep || regexp_replace(l.label_value, '<[^<]+>', '');
                sep := '; ';
            END IF;
        END LOOP;
        
        UPDATE media_keywords 
        SET keywords = trim(kw), lastdate = SYSDATE 
        WHERE media_id = m.media_id;
    END LOOP;
END;
/
sho err;
 
-- exec set_media_keywords;

-- select media_id,lastdate,keywords from media_keywords where keywords is not null;

-- UPDATE media_keywords SET keywords=NULL,lastdate=NULL WHERE keywords IS NOT NULL;