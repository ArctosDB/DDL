/*
    latest attempt at flattened media
    Da Idea:
    
    on insert into media
    	prime media_flat with 1:1 stuff
    	NULL lastdate
    on update to media
    	if 1:1 stuff changes
    		NULL lastdate
    		
    periodically run procedure to update media_flat with lastdate old or NULL
    
    For things with one obvious coordinate set, use it
    For others, no coordinates - it's not clear WTF people are trying to do or why anyone might care anyway.
*/    
    DROP TABLE media_flat;
    
    CREATE TABLE media_flat (
        media_id NUMBER NOT NULL,
        media_type VARCHAR2(255),
        media_uri VARCHAR2(255),
        preview_uri VARCHAR2(255),
        mime_type VARCHAR2(255),
        relationships VARCHAR2(4000),
        license VARCHAR2(255),
        labels VARCHAR2(4000),
        keywords VARCHAR2(4000),
        coordinates varchar2(4000),
        hastags number default 0,
        lastdate DATE
       );
    
    
     INSERT INTO media_flat (
        media_id,
        media_type,
        media_uri,
        preview_uri,
        mime_type,
        license
    )  (
        SELECT 
            media.media_id,
            media_type,
            media_uri,
            preview_uri,
            mime_type,
            decode(uri,
    			null,'unlicensed',
    			'<a href="'||uri||'">'||display||'</a>'
    		)
        FROM 
            media,
            ctmedia_license 
        WHERE
            media.MEDIA_LICENSE_ID=ctmedia_license.MEDIA_LICENSE_ID (+)
       );
       
       
       create or replace public synonym media_flat for media_flat;
       grant select on media_flat to public;
       
    
               

    create unique index iu_medflt_mid on media_flat (media_id) tablespace uam_idx_1;
    
    
    INSERT INTO media_flat (
        media_id,
        media_type,
        media_uri,
        preview_uri,
        mime_type,
        license
    )  (
        SELECT 
            media.media_id,
            media_type,
            media_uri,
            preview_uri,
            mime_type,
            decode(uri,
    			null,'unlicensed',
    			'<a href="'||uri||'">'||display||'</a>'
    		)
        FROM 
            media,
            media_relations,
            ctmedia_license 
        WHERE
            media.media_id=media_relations.media_id AND
            media_relations.media_relationship LIKE '% media' AND
            media.MEDIA_LICENSE_ID=ctmedia_license.MEDIA_LICENSE_ID (+) and 
            media.media_id NOT IN (SELECT media_id FROM media_flat)
        group by
            media.media_id,
            media_type,
            media_uri,
            preview_uri,
            mime_type,
            decode(uri,
    			null,'unlicensed',
    			'<a href="'||uri||'">'||display||'</a>'
    		)
       );
       
       
CREATE OR REPLACE TRIGGER TR_ins_media_FLAT
AFTER INSERT or update or delete ON media
FOR EACH ROW
BEGIN
        IF inserting then
                INSERT INTO media_flat (
            media_id,
           media_type,
            media_uri,
            preview_uri,
            mime_type,
            license
        ) VALUES (
                :NEW.media_id,
                :NEW.media_type,
                :NEW.media_uri,
                :NEW.preview_uri,
                :NEW.mime_type,
                (SELECT decode(uri,
                                null,'unlicensed',
                                '<a target="_blank" class="external" href="'||uri||'">'||display||'</a>')
                 FROM ctmedia_license WHERE MEDIA_LICENSE_ID=:NEW.MEDIA_LICENSE_ID
               )
         );
                
        end if;
        if deleting then
                delete from media_flat where media_id=:OLD.media_id;
        end if;
       
        if  updating then
                UPDATE media_flat SET
            media_type=:NEW.media_type,
            media_uri=:NEW.media_uri,
            preview_uri=:NEW.preview_uri,
            mime_type=:NEW.mime_type,
            lastdate=NULL,
            license=(
                    SELECT decode(uri,
                                null,'unlicensed',
                                '<a  target="_blank" class="external" href="'||uri||'">'||display||'</a>')
                                FROM ctmedia_license WHERE MEDIA_LICENSE_ID=:NEW.MEDIA_LICENSE_ID
                )
           WHERE media_id=:NEW.media_id;
        end if;
END;
/


sho err

CREATE OR REPLACE TRIGGER TR_mediareln_FLAT
AFTER INSERT or update or delete ON media_relations
FOR EACH ROW
BEGIN
    IF inserting OR updating THEN
        UPDATE media_flat SET lastdate=NULL WHERE media_id=:NEW.media_id;
    END IF;
    IF deleting THEN
        UPDATE media_flat SET lastdate=NULL WHERE media_id=:OLD.media_id;
    END IF;
END;
/


sho err


CREATE OR REPLACE TRIGGER TR_medialbl_FLAT
AFTER INSERT or update or delete ON media_labels
FOR EACH ROW
BEGIN
    IF inserting OR updating THEN
        UPDATE media_flat SET lastdate=NULL WHERE media_id=:NEW.media_id;
    END IF;
    IF deleting THEN
        UPDATE media_flat SET lastdate=NULL WHERE media_id=:OLD.media_id;
    END IF;
END;
/


sho err

-- test exec times:
-- 2,000 ROWS: 12s
-- 20,000 rows: 67s

CREATE OR REPLACE PROCEDURE set_media_flat
is
    tabl varchar2(255);
    kw VARCHAR2(4000);
    kwt VARCHAR2(4000);
    lbl VARCHAR2(4000);
    lblt VARCHAR2(4000);
    rel VARCHAR2(4000);
    relt VARCHAR2(4000);
    rsep VARCHAR2(4);
    ksep VARCHAR2(4);
    lsep VARCHAR2(4);
    csep varchar2(4);
    tn number;
    ct varchar2(4000);
    coords varchar2(4000);
    hastags NUMBER;
BEGIN
    FOR m IN (
        SELECT media_id
        FROM media_flat
        WHERE (lastdate IS NULL OR ((SYSDATE - lastdate) > 1))
        AND ROWNUM <= 200
    ) LOOP
        kw := '';
        ksep:='';
        lsep:='';
        rsep:='';
        csep:='';
        tabl := '';
        kwt := '';
        lbl := '';
        lblt := '';
        rel := '';
        relt := '';
        rsep := '';
        ksep := '';
        lsep := '';
        csep := '';
        tn := NULL;
        ct  := '';
        coords  := '';
        hastags := NULL;
        FOR r IN (
            SELECT media_relationship, related_primary_key
            from media_relations
            where media_id = m.media_id
        ) LOOP
            tabl := SUBSTR(r.media_relationship, instr(r.media_relationship, ' ', -1) + 1);
            case tabl
                when 'locality' then
                    select 
                        r.media_relationship || '==<a href="/showLocality.cfm?action=srch\&locality_id=' || locality.locality_id || '">' || state_prov || ': ' || spec_locality || '</a>',
                        spec_locality || ';' || higher_geog,
                        dec_lat || ',' || dec_long
                    into 
                        relt,
                        kwt,
                        ct
                    from 
                        locality,geog_auth_rec,accepted_lat_long
                    where 
                        locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and 
                        locality.locality_id=accepted_lat_long.locality_id (+) AND 
                        locality.locality_id=r.related_primary_key;
                when 'collecting_event' then
                    select
                        r.media_relationship || '==<a href="/showLocality.cfm?action=srch\&collecting_event_id=' || collecting_event.collecting_event_id || '">' || state_prov || ': ' || spec_locality || '</a>',
                        verbatim_locality || '; ' || verbatim_date || '; ' ||
                        spec_locality || '; ' || higher_geog,
                        dec_lat || ',' || dec_long
                    into
                        relt,
                        kwt,
                        ct
                    from
                        collecting_event, locality, geog_auth_rec,accepted_lat_long
                    WHERE 
                        collecting_event.locality_id = locality.locality_id and 
                        locality.locality_id=accepted_lat_long.locality_id (+) AND
                        locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
                        collecting_event.collecting_event_id = r.related_primary_key;
                when 'agent' then
                    select 
                        r.media_relationship || '==' || agent_name,
                        agent_name,
                        NULL
                    into
                        relt,
                        kwt,
                        ct
                    from 
                        preferred_agent_name
                    where 
                        agent_id=r.related_primary_key;
                when 'media' then
                    select 
                        r.media_relationship || '==' || media_id,
                        NULL,
                        NULL
                    into
                        relt,
                        kwt,
                        ct
                    from 
                        media
                    where 
                        media_id=r.related_primary_key;
                when 'cataloged_item' then
                     select
                         r.media_relationship || '==<a href="/guid/' || guid || '">' || guid  || '</a>',
                         collection || ' ' || cat_num || '; ' ||
                         GUID || '; ' ||
                         OTHERCATALOGNUMBERS || '; ' ||
                         COLLECTORS || '; ' ||
                         scientific_name || '; ' ||
                         regexp_replace(get_taxonomy(flat.collection_object_id,'display_name'),'<[^<]+>','')  || '; ' ||
                         verbatim_date || '; ' ||
                         spec_locality || '; ' ||
                         higher_geog,
                         dec_lat || ',' || dec_long
                     into
                         relt,
                         kwt,
                         ct
                     from  
                         flat
                     where 
                         flat.collection_object_id=r.related_primary_key;
                when 'project' then
                    select 
                        r.media_relationship || '==<a href="/project/' || niceURL(project_name) || '">' || project_name  || '</a>',
                        project_name
                    into
                        relt,
                        kwt
                    from 
                        project
                    where project_id=r.related_primary_key;
                when 'accn' then
                    select 
                        r.media_relationship || '==<a href="/viewAccn.cfm?transaction_id=' || accn.transaction_id  || '">' || collection || ' ' || accn_number || '</a>',
                        collection || ' ' || accn_number
                    into 
                        relt,
                        kwt
                    from 
                        accn,trans,collection
                    where
                        accn.transaction_id=trans.transaction_id AND
                        trans.collection_id=collection.collection_id AND
                        accn.transaction_id=r.related_primary_key;
                when 'taxonomy' then
                    select 
                        r.media_relationship || '==<a href="/name/' || scientific_name || '">' || display_name  || '</a>',
                        full_taxon_name || ' ' || display_name 
                    into 
                        relt,
                        kwt
                    from taxonomy
                    where  taxonomy.taxon_name_id=r.related_primary_key;
                ELSE
                    NULL;
            end case;
          IF ct=',' THEN
              ct:='';
          END IF;
          tn:=nvl(length(coords),0) + nvl(length(ct),0) + 20;
          IF length(ct) > 0 AND tn < 4000 THEN
               coords := coords || csep || ct;
               csep := '|';
            END IF;
           ct:='';
            tn:=nvl(length(rel),0) + nvl(length(relt),0) + 20;
            IF tn < 4000 THEN
                rel := rel || rsep || relt;
               rsep := '|';
            END IF;
            tn:=nvl(length(kw),0) + nvl(length(kwt),0) + 20;
            IF tn < 4000 THEN
                kw := kw || ksep || kwt;
               ksep := '|';
            END IF;
             kwt:='';
        END LOOP;
        FOR rm IN (select 
                        media_relationship || '==' || media_id mrs
                    from 
                        media_relations
                    where 
                        media_relationship LIKE '% media' AND
                        related_primary_key=m.media_id) LOOP
             tn:=nvl(length(rel),0) + nvl(length(rm.mrs),0) + 20;
            IF tn < 4000 THEN
                rel := rel || rsep || rm.mrs;
               rsep := '|';
            END IF;
        END LOOP; 
        FOR l IN (
            SELECT media_label || '==' || label_value label_value
            FROM media_labels
            WHERE media_id=m.media_id
        ) LOOP
            kwt:=regexp_replace(l.label_value, '<[^<]+>', '');
            tn:=nvl(length(kw),0) + nvl(length(kwt),0) + 20;
            IF tn < 4000 THEN
                kw := kw || ksep || kwt;
                ksep := '|';
            END IF;
            tn:=nvl(length(lbl),0) + nvl(length(l.label_value),0) + 20;
            IF tn < 4000 THEN
                lbl := lbl || lsep || regexp_replace(l.label_value, '<[^<]+>', '');
                lsep := '|';
            END IF;
        END LOOP;
        SELECT COUNT(*) INTO hastags FROM tag WHERE media_id=m.media_id;
        -- allow zero or one set of coordinates only
        IF instr(coords,'|') != 0 THEN
            coords:=NULL;
        END IF;
        UPDATE media_flat SET
            relationships=trim(rel),
            labels=trim(lbl),
            keywords=trim(kw),
            coordinates=trim(coords),
            hastags=hastags,
            lastdate = SYSDATE
        WHERE 
            media_id=m.media_id;                         
        rel:='';
        kw:='';
        lbl:='';
    END LOOP;   
END;
/
sho err


BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'j_set_media_flat',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'set_media_flat',
		start_date		=> to_timestamp_tz('26-APR-2011 00:00:00', 'DD-MON-YYYY HH24:MI:SS'),
		repeat_interval	=> 'freq=MINUTELY;interval=1',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'update flattened media metadata');
END;
/ 



-- DO this FIRST - it's down here to unretard the retarded comment detector thingee
set escape '\';
