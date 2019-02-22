

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
                                '<a target="_blank" class="external" href="'||uri||'">'||display||'</a>')
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

set escape "\"








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


alter table media_flat add alt_text varchar2(255);
alter table media_flat add descr varchar2(4000);
alter table media_flat drop column media_title varchar2(4000);
alter table media_flat drop column media_title;
alter table media_flat add LATEST_DATE varchar2(255);
alter table media_flat add EARLIEST_DATE varchar2(255);
set escape "\";













set define off;

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
    lv  VARCHAR2(4000);
    tn number;
    ct varchar2(4000);
    coords varchar2(4000);
    numtags NUMBER;
    mindate varchar2(30);
    maxdate varchar2(30);
    minmindate varchar2(30);
    maxmaxdate varchar2(30);
    tloc varchar2(4000);
    clocation varchar2(4000);
    wtf varchar2(4000);
    losep  VARCHAR2(4);    
    dsr varchar2(4000);
    -- some stuff for ALT tags
    -- pre-build them in here, since they take a bit of processing
    a_descr varchar2(4000);
    a_title varchar2(4000);
    a_locality varchar2(4000);
    a_geog varchar2(4000);
    a_guid varchar2(4000);
    a_sciname  varchar2(4000);
    a_plainsciname  varchar2(4000);
    a_agent varchar2(4000);
    a_proj varchar2(4000);
    a_accn varchar2(4000);    
    a_alt varchar2(4000);
BEGIN
	FOR m IN (
        SELECT media_id from (
      		SELECT media_id,lastdate
          	FROM media_flat
           	WHERE
           	(lastdate IS NULL OR ((SYSDATE - lastdate) > 1))
          	order by lastdate desc
        ) where ROWNUM <= 10000
    ) LOOP
        begin
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
            lv := NULL;
            tn := NULL;
            ct  := '';
            coords  := '';
            numtags := NULL;
            mindate := NULL;
            maxdate := NULL;
            tloc := null;
            dsr:=null;
            a_descr := '';
            a_locality := '';
            a_geog := '';
            a_guid := '';
            a_plainsciname := '';
            a_sciname := '';
            a_alt := '';
            a_agent :='';
            a_proj :='';
            a_accn :='';
            a_title := '';
            wtf := '';
            clocation := '';
            minmindate := '';
            maxmaxdate := '';
            losep := '';
            FOR r IN (
                SELECT media_relationship, related_primary_key
                from media_relations
                where media_id = m.media_id
            ) LOOP
                tabl := SUBSTR(r.media_relationship, instr(r.media_relationship, ' ', -1) + 1);
                case tabl
                    when 'locality' then
                        select 
                            r.media_relationship || '==<a href="/showLocality.cfm?action=srch&locality_id=' || locality.locality_id || '">' || state_prov || ': ' || spec_locality || '</a>',
                            spec_locality || ';' || higher_geog,
                            dec_lat || ',' || dec_long,
                            spec_locality || ';' || higher_geog,
                            spec_locality,
                            higher_geog
                        into 
                            relt,
                            kwt,
                            ct,
                            tloc,
                            a_locality,
                            a_geog
                        from 
                            locality,geog_auth_rec
                        where 
                            locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and 
                            locality.locality_id=r.related_primary_key;
                    when 'collecting_event' then
                        select
                            r.media_relationship || '==<a href="/showLocality.cfm?action=srch&showDetail=event&collecting_event_id=' || collecting_event.collecting_event_id || '">' || state_prov || ': ' || spec_locality || ' (' || verbatim_date || ')</a>',
                            verbatim_locality || '; ' || verbatim_date || '; ' ||
                            locality.spec_locality || '; ' || higher_geog,
                            locality.dec_lat || ',' || locality.dec_long,
                            BEGAN_DATE,
                            ended_date,
                            locality.spec_locality || '; ' || higher_geog,
                            spec_locality,
                            higher_geog
                        into
                            relt,
                            kwt,
                            ct,
                            mindate,
                            maxdate,
                            tloc,
                            a_locality,
                            a_geog
                        from
                            collecting_event, locality, geog_auth_rec
                        WHERE 
                            collecting_event.locality_id = locality.locality_id and 
                            locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
                            collecting_event.collecting_event_id = r.related_primary_key;
                    when 'agent' then
                        select 
                            r.media_relationship || '==' || agent_name,
                            agent_name,
                            NULL,
                            decode(r.media_relationship,'shows agent',agent_name,NULL)
                        into
                            relt,
                            kwt,
                            ct,
                            a_agent
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
                             regexp_replace(get_taxonomy(filtered_flat.collection_object_id,'display_name'),'<[^<]+>','')  || '; ' ||
                             verbatim_date || '; ' ||
                             spec_locality || '; ' ||
                             higher_geog,
                             dec_lat || ',' || dec_long,
                             BEGAN_DATE,
                             ended_date,
                            spec_locality || '; ' || higher_geog,
                            higher_geog,
                            spec_locality,
                            guid,
                            regexp_replace(get_taxonomy(filtered_flat.collection_object_id,'display_name'),'<[^<]+>',''),
                            scientific_name
                         into
                             relt,
                             kwt,
                             ct,
                            mindate,
                            maxdate,
                            tloc,
                            a_geog,
                            a_locality,
                            a_guid,
                            a_sciname,
                            a_plainsciname
                         from  
                             filtered_flat
                         where 
                             filtered_flat.collection_object_id=r.related_primary_key;
                    when 'project' then
                        select 
                            r.media_relationship || '==<a href="/project/' || niceURL(project_name) || '">' || project_name  || '</a>',
                            project_name,
                            project_name
                        into
                            relt,
                            kwt,
                            a_proj
                        from 
                            project
                        where project_id=r.related_primary_key;
                    when 'accn' then
                        select 
                            r.media_relationship || '==<a href="/viewAccn.cfm?transaction_id=' || accn.transaction_id  || '">' || collection || ' ' || accn_number || '</a>',
                            collection || ' ' || accn_number,
                            collection || ' ' || accn_number
                        into 
                            relt,
                            kwt,
                            a_accn
                        from 
                            accn,trans,collection
                        where
                            accn.transaction_id=trans.transaction_id AND
                            trans.collection_id=collection.collection_id AND
                            accn.transaction_id=r.related_primary_key;
                     when 'loan' then
                        select 
                            r.media_relationship  || '==' || collection  || ' ' || loan_number,
                            collection || ' ' || loan_number
                        into 
                            relt,
                            kwt
                        from 
                            loan,trans,collection
                        where
                            loan.transaction_id=trans.transaction_id AND
                            trans.collection_id=collection.collection_id AND
                            loan.transaction_id=r.related_primary_key;
                    when 'taxon_name' then
                        select 
                            r.media_relationship || '==<a href="/name/' || scientific_name || '">' || scientific_name  || '</a>',
                            scientific_name,
                            scientific_name
                        into 
                            relt,
                            kwt,
                            a_sciname
                        from taxon_name
                        where  taxon_name.taxon_name_id=r.related_primary_key;
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
                 if minmindate is null or mindate < minmindate then
                    minmindate:=mindate;
                end if; 
                if maxmaxdate is null or maxdate > maxmaxdate then
                      maxmaxdate:=maxdate;
                end if;
                tn:=nvl(length(clocation),0) + nvl(length(tloc),0) + 20;
                IF tn < 4000 THEN
                    clocation := clocation || ksep || tloc;
                    losep := '|';
                END IF;
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
                SELECT 
                    media_label,
                    label_value 
                FROM 
                    media_labels
                WHERE 
                    media_id=m.media_id
            ) LOOP
                lv:=l.media_label || '==' || l.label_value;
                kwt:=regexp_replace(lv, '<[^<]+>', '');
                tn:=nvl(length(kw),0) + nvl(length(kwt),0) + 20;
                if (l.media_label='description') then
                    a_descr:= regexp_replace(l.label_value,'<[^<]+>','');
                end if;
                if (l.media_label='title') then
                    a_title:= regexp_replace(l.label_value,'<[^<]+>','');
                end if;
                IF tn < 4000 THEN
                    kw := kw || ksep || kwt;
                    ksep := '|';
                END IF;
                tn:=nvl(length(lbl),0) + nvl(length(lv),0) + 20;
                IF tn < 4000 THEN
                    lbl := lbl || lsep || regexp_replace(lv, '<[^<]+>', '');
                    lsep := '|';
                END IF;
            END LOOP;
            SELECT COUNT(*) INTO numtags FROM tag WHERE media_id=m.media_id;
            -- allow zero or one set of coordinates only
            IF instr(coords,'|') != 0 THEN
                coords:=NULL;
            END IF;
            if a_descr is not null and  length(a_descr) < 250 then
                a_alt:=a_descr;
                dsr:=a_descr;
            end if;
            if a_descr is null and a_title is not null and length(a_title) < 250 then
                a_alt:=a_title;
                dsr:=a_title;                
            end if;
            if a_sciname is not null and nvl(instr(lower(a_alt),lower(a_sciname)),0) = 0 and nvl(length(a_alt),0)+nvl(length(a_sciname),0) < 250 then
                -- don't add fancy scientific name if the plain one is already there either
                if a_plainsciname is not null and nvl(instr(lower(a_alt),lower(a_plainsciname)),0)=0 then
                    --dbms_output.put_line('adding a_sciname to a_alt');
                    a_alt:=a_alt || chr(7) || a_sciname;
                end if;
           end if;
            --dbms_output.put_line('a_plainsciname: ' || a_plainsciname) ;
            if a_plainsciname is not null and 
                nvl(instr(lower(a_alt),lower(a_plainsciname)),0) = 0 and 
                nvl(length(a_alt) + length(a_plainsciname),0) < 250 then
                --dbms_output.put_line('adding a_plainsciname to a_alt');
                a_alt:=a_alt || chr(7) || a_plainsciname;
            end if;
            --dbms_output.put_line('a_guid: ' || a_guid) ;
            if a_guid is not null and 
                nvl(instr(lower(a_alt),lower(a_guid)),0) = 0 and 
                nvl(length(a_alt) + length(a_guid),0) < 250 then
                --dbms_output.put_line('adding a_guid to a_alt: ' || a_guid);
                a_alt:=a_alt || chr(7) || a_guid;
            end if;
            if a_geog is not null and 
                nvl(instr(lower(a_alt),lower(a_geog)),0) = 0 and 
                nvl(length(a_alt) + length(a_geog),0) < 250 then
              --  dbms_output.put_line('adding a_geog to a_alt');
                a_alt:=a_alt || chr(7) || a_geog;
            end if;
            if a_locality is not null and 
                nvl(instr(lower(a_alt),lower(a_locality)),0) = 0 and 
                nvl(length(a_alt) + length(a_locality),0) < 250 then
                a_alt:=a_alt || chr(7) || a_locality;
            end if;
            if a_agent is not null and 
                nvl(instr(lower(a_alt),lower(a_agent)),0) = 0 and 
                nvl(length(a_alt) + length(a_agent),0) < 250 then
                --dbms_output.put_line('adding a_agent to a_alt');
                a_alt:=a_alt || chr(7) || a_agent;
            end if;
            if a_proj is not null and 
                nvl(instr(lower(a_alt),lower(a_proj)),0) = 0 and 
                nvl(length(a_alt) + length(a_proj),0) < 250 then
                --dbms_output.put_line('adding a_proj to a_alt');
                a_alt:=a_alt || chr(7) || a_proj;
            end if;
            if a_accn is not null and 
                nvl(instr(lower(a_alt),lower(a_accn)),0) = 0 and 
                nvl(length(a_alt) + length(a_accn),0) < 250 then
                --dbms_output.put_line('adding a_accn to a_alt');
                a_alt:=a_alt || chr(7) || a_accn;
            end if;
            a_alt:=replace(a_alt,'no higher geography recorded','');
            a_alt:=replace(a_alt,'no specific locality recorded','');
            a_alt:=replace(a_alt,'unidentifiable','');
            -- deal with some common formatting issues and any character that might break anything
            a_alt:=replace(a_alt,'''','');
            a_alt:=replace(a_alt,'"','');
            a_alt:=replace(a_alt,': ;','; ');
            a_alt:=replace(a_alt,'  ',' ');
            a_alt:=trim(both chr(7) from a_alt);
            a_alt:=replace(a_alt,chr(7) || chr(7),chr(7));
            a_alt:=replace(a_alt,chr(7),'; ');
            if length(a_alt) >200 then
                a_alt:=substr(a_alt,1,197) || '...';
            end if;
            UPDATE media_flat SET
                relationships=trim(rel),
                labels=trim(lbl),
                keywords=trim(kw),
                coordinates=trim(coords),
                hastags=numtags,
                lastdate = SYSDATE,
                earliest_date=minmindate,
                latest_date=maxmaxdate,
                location=clocation,
                alt_text=a_alt,
                descr=dsr
            WHERE 
                media_id=m.media_id;                      
            rel:='';
            kw:='';
            lbl:='';
        exception
            when no_data_found then
                  UPDATE media_flat SET lastdate = SYSDATE WHERE media_id=m.media_id;   
        end;
    END LOOP;   
END;
/
sho err;


exec set_media_flat;






 update media_flat set LASTDATE=null  where RELATIONSHIPS like '%collecting_event%';











exec set_media_flat;

exec set_media_flat;


 exec set_Media_flat;


--exec set_media_flat;


--select distinct alt_text from media_flat where alt_text is not null;

--update media_flat set lastdate=null where media_id in (Select media_id from media where media_uri like '%uam_ento%' );
--update media_flat set lastdate=null where media_id=10294787;


--   update media_flat set lastdate=null where media_id in (Select media_id from media where media_uri like '%ffdss%' );

--   exec set_media_flat;
--    select distinct alt_text from media_flat where alt_text is not null order by alt_text;





--   update media_flat set lastdate=null where media_id=10242633;
--   commit;
--  
--   select alt_text from media_flat  where media_id=10469642;
-- 
 
/*
 * 
 * 
  select media_id from media_flat where alt_text is null and mime_type not in ( 'image/dng','audio/x-wav')
and media_id not in (select media_id from media_relations where media_relationship in ('documents loan','shows publication'));



*/
-- update media_flat set lastdate = null where  alt_text is null and mime_type != 'image/dng';


--  select alt_text from media_flat where media_id=10373163;

--   select count(*) from media_flat where lastdate is null;


 --update media_flat set lastdate=null where media_id=10373163;
 --commit;
 -- exec set_media_flat;
  
 -- select alt_text from media_flat order by alt_text;
  
  
-- select lastdate from media_flat where media_id=10469716;






BEGIN
DBMS_SCHEDULER.DROP_JOB('J_SET_MEDIA_FLAT',true);
END;
/

BEGIN
DBMS_SCHEDULER.DROP_JOB('J_MEDIA_FLAT',true);
END;
/



BEGIN
DBMS_SCHEDULER.DROP_JOB('SET_MEDIA_KEYWORDS_JOB',true);
END;
/

BEGIN
DBMS_SCHEDULER.DROP_JOB('MIA_MEDIA_KEYWORDS_JOB',true);
END;
/







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


SELECT JOB_NAME, STATE,FAILURE_COUNT,LAST_START_DATE,NEXT_RUN_DATE FROM DBA_SCHEDULER_JOBS WHERE JOB_NAME = 'J_SET_MEDIA_FLAT';




-- DO this FIRST - it's down here to unretard the retarded comment detector thingee
set escape '\';