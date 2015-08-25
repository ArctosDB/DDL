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
    
    DROP TABLE t_media_flat;
    
    CREATE TABLE t_media_flat (
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
       
     
       
       
       
       
       create or replace public synonym t_media_flat for t_media_flat;
       grant select on t_media_flat to public;
       
               
*/
/* 

-- these allow selecting a list
    CREATE OR REPLACE TYPE ntt_varchar2 AS TABLE OF VARCHAR2(4000);
    /
    
	CREATE OR REPLACE FUNCTION to_string (
        nt_in        IN ntt_varchar2,
        delimiter_in IN VARCHAR2 DEFAULT '|'
        ) RETURN VARCHAR2 IS
        v_idx PLS_INTEGER;
        v_str VARCHAR2(32767);
        v_dlm VARCHAR2(10);
     BEGIN  
      v_idx := nt_in.FIRST;
      WHILE v_idx IS NOT NULL LOOP
        v_str := v_str || v_dlm || nt_in(v_idx);
        v_dlm := delimiter_in;
        v_idx := nt_in.NEXT(v_idx);
     END LOOP;
  
     RETURN v_str;
  
  END to_string;
  /	                    



*/


/*
    Need a primer AND TRIGGER here
    
    
    DELETE FROM t_media_flat;
    
    
    create unique index iu_t_m_f_mid on t_media_flat (media_id) tablespace uam_idx_1;
    
    INSERT INTO t_media_flat (
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
        FROM media,media_relations,ctmedia_license WHERE
        media.media_id=media_relations.media_id AND
       --  media.media_id=122681 and
        media.MEDIA_LICENSE_ID=ctmedia_license.MEDIA_LICENSE_ID(+)
        and media.media_id NOT IN (SELECT media_id FROM t_media_flat)
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
		INSERT INTO t_media_flat (
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
            FROM media,media_relations,ctmedia_license WHERE
            media.media_id=media_relations.media_id AND
           	media.media_id=:NEW.media_id and
            media.MEDIA_LICENSE_ID=ctmedia_license.MEDIA_LICENSE_ID (+)
            and media.media_id NOT IN (SELECT media_id FROM t_media_flat)
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
	elsif deleting then
		delete from t_media_flat where media_id=:OLD.media_id;
	elsif updating then
		update t_media_flat set lastdate=NULL where media_id=:OLD.media_id;
	end if;
	
END;



*/



/*
	Updating 20 records in test takes from essentially zero up to about
	30 seconds. Schedule at least 1.5s/record
*/

BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'test_media_flat',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'test_set_media_flat',
		start_date		=> to_timestamp_tz('26-APR-2011 00:00:00', 'DD-MON-YYYY HH24:MI:SS'),
		repeat_interval	=> 'freq=MINUTELY;interval=1',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'create flattened media as test');
END;
/ 


/*
	This procedure pulls zero-or-one set of coordinates for each Media record.
	That's lame, but no better ideas for how to handle it. Please DO NOT remove
	the commented >1 coordinate code
*/

CREATE OR REPLACE PROCEDURE test_set_media_flat
is
    tabl varchar2(255);
    kw VARCHAR2(4000);
    kwt VARCHAR2(4000);
    lbl VARCHAR2(4000);
    lblt VARCHAR2(4000);
    rel VARCHAR2(4000);
    relt VARCHAR2(4000);
    temp VARCHAR2(4000);
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
        FROM t_media_flat
        WHERE (lastdate IS NULL OR ((SYSDATE - lastdate) > 1))
        AND ROWNUM <= 20
        --AND media_id IN (5414,10001194,23535)
    ) LOOP
        -- starting with a fresh record
        --dbms_output.put_line('=========================================' || m.media_id);
        kw := '';
        temp := ' ';
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
        temp := '';
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
            --dbms_output.put_line('mid: ' || m.media_id);
            --dbms_output.put_line('mr: ' || r.media_relationship || chr(9) || r.related_primary_key);
            --dbms_output.put_line('tabl : ' || tabl);
            
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
                    /*
                    BEGIN
                        SELECT
                            TO_STRING(CAST(COLLECT(d) AS ntt_varchar2)) 
                        into 
                            ct
                        FROM (
                        	select -- specimen loans used by project
                        		dec_lat || ',' || dec_long d
                        	from
                        		flat,project_trans,loan_item,specimen_part
                        	where
    		                    flat.collection_object_id=specimen_part.derived_from_cat_item and
    		                    specimen_part.collection_object_id=loan_item.collection_object_id and
    		                    loan_item.transaction_id=project_trans.transaction_id and
    		                    dec_lat is not null and dec_long is not null and 
    		                    project_trans.project_id=r.related_primary_key
    		                    group by dec_lat || ',' || dec_long
    		                 union -- data loans used by project
    		                 select 
                        		dec_lat || ',' || dec_long d
                        	from
                        		flat,project_trans,loan_item
                        	where
    		                    flat.collection_object_id=loan_item.collection_object_id and
    		                    loan_item.transaction_id=project_trans.transaction_id and
    		                    dec_lat is not null and dec_long is not null and 
    		                    project_trans.project_id=r.related_primary_key
    		                group by 
    		                    dec_lat || ',' || dec_long
    		                union -- specimens accessioned by project
    		                select 
                        		dec_lat || ',' || dec_long d
                        	from
                        		flat,project_trans
                        	where
    		                    flat.accn_id=project_trans.transaction_id and
    		                    dec_lat is not null and dec_long is not null and 
    		                    project_trans.project_id=r.related_primary_key
    		                group 
    		                    by dec_lat || ',' || dec_long
    		              );
                    EXCEPTION WHEN OTHERS THEN
                        -- too many ROWS overflows THE 4k CHARACTER LIMIT buffer - just ignore it FOR now?
                        
                        dbms_output.put_line('fail: ' || SQLERRM);
                    END;
		        dbms_output.put_line('<<<<<<<<<<<<<<<<<<<<<<<<<<<ct== ' || ct);
                */
            
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
                    /*
                    SELECT
                        TO_STRING(CAST(COLLECT(d) AS ntt_varchar2)) 
                    into 
                        ct
                    FROM (
                    	select
                    		dec_lat || ',' || dec_long d
                    	from
                    		flat
                    	where
		                    flat.accn_id=r.related_primary_key
		                group by 
		                    dec_lat || ',' || dec_long
		            );
		            dbms_output.put_line('<<<<<<<<<<<<<<<<<<<<<<<<<<<ct: ' || ct);   
		            */   
                when 'taxonomy' then
                    select 
                        r.media_relationship || '==<a href="/name/' || scientific_name || '">' || display_name  || '</a>',
                        full_taxon_name || ' ' || display_name 
                    into 
                        relt,
                        kwt
                    from taxonomy
                    where  taxonomy.taxon_name_id=r.related_primary_key;
                    /*
                    SELECT
                        TO_STRING(CAST(COLLECT(d) AS ntt_varchar2))into ct
                    FROM   (
                    	select
                    		dec_lat || ',' || dec_long d
                    	from
                    		flat,identification_taxonomy
                    	where
		                    flat.identification_id=identification_taxonomy.identification_id and
		                    identification_taxonomy.taxon_name_id=r.related_primary_key
		                group by 
		                    dec_lat || ',' || dec_long
		            );
		           */
                ELSE
                    NULL;
            end case;
            
          --dbms_output.put_line('------one inner loop ------------');
          
          
          --dbms_output.put_line('tabl: ' || tabl);
          --dbms_output.put_line('ct: ' || ct);
          
          --dbms_output.put_line('------if just comma DIE..... ------------');
          IF ct=',' THEN
              ct:='';
                        --dbms_output.put_line('------IS just comma DIE..... ------------');
              
          END IF;
              
          --dbms_output.put_line('ct: ' || ct);
          
          --dbms_output.put_line('coords: ' || coords);
          --dbms_output.put_line('csep: ' || csep);
          --dbms_output.put_line('------appending..... ------------');
          
          tn:=nvl(length(coords),0) + nvl(length(ct),0) + 20;
          IF length(ct) > 0 AND tn < 4000 THEN
               coords := coords || csep || ct;
               csep := '|';
            END IF;
           ct:='';
           --dbms_output.put_line('coords: ' || coords);
                   
          --dbms_output.put_line('csep: ' || csep);
                         
          --  dbms_output.put_line('--------------------------------------'||tn);
           -- dbms_output.put_line('relt: ' || relt);
            
           -- dbms_output.put_line('kwt: ' || kwt);
            
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
             
             --dbms_output.put_line('////////////////////ct: ' || ct);

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
              dbms_output.put_line(' added inverse relations----------now : rel==' || rel);
                
        END LOOP;
        
        
        
        FOR l IN (
            SELECT media_label || '==' || label_value label_value
            FROM media_labels
            WHERE media_id=m.media_id
        ) LOOP
             tn:=nvl(length(kw),0) + nvl(length(kwt),0) + 20;

            IF tn < 4000 THEN
                kw := kw || ksep || regexp_replace(l.label_value, '<[^<]+>', '');
                ksep := '|';
            END IF;
            tn:=nvl(length(lbl),0) + nvl(length(l.label_value),0) + 20;

            IF tn < 4000 THEN
                lbl := lbl || lsep || regexp_replace(l.label_value, '<[^<]+>', '');
                lsep := '|';
            END IF;
                
                
        END LOOP;
        
        dbms_output.put_line('-----------------------------------------------------------------------');
        
            --dbms_output.put_line('rel:' || rel);
            --dbms_output.put_line('kw:' || kw);
           --dbms_output.put_line('lbl:' || lbl);
         
        SELECT COUNT(*) INTO hastags FROM tag WHERE media_id=m.media_id;
        
        UPDATE t_media_flat SET
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
    
    ----------- exec test_set_media_flat;
   ---- 10001194
   ----select coordinates from t_media_flat where MEDIA_ID=10001194;
   
END;
/
sho err

-- DO this FIRST - it's down here to unretard the retarded comment detector thingee
set escape '\';
