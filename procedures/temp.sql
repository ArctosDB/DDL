
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
    a_alt varchar2(255);
BEGIN
    FOR m IN (
        SELECT media_id
        FROM media_flat
        WHERE 
       -- media_id=19771
        (lastdate IS NULL OR ((SYSDATE - lastdate) > 1))
        AND ROWNUM <= 10000
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
            
           --dbms_output.put_line(m.media_id);
             
             
            FOR r IN (
                SELECT media_relationship, related_primary_key
                from media_relations
                where media_id = m.media_id
            ) LOOP
                tabl := SUBSTR(r.media_relationship, instr(r.media_relationship, ' ', -1) + 1);
                --dbms_output.put_line('table ' || tabl);
               
                case tabl
                    when 'locality' then
                        select 
                            r.media_relationship || '==<a href="/showLocality.cfm?action=srch\&locality_id=' || locality.locality_id || '">' || state_prov || ': ' || spec_locality || '</a>',
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
                            r.media_relationship || '==<a href="/showLocality.cfm?action=srch\&collecting_event_id=' || collecting_event.collecting_event_id || '">' || state_prov || ': ' || spec_locality || ' (' || verbatim_date || ')</a>',
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
                    when 'taxonomy' then
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
                --dbms_output.put_line('minmindate: ' ||minmindate) ;
                --dbms_output.put_line('mindate: ' ||mindate) ;
                --dbms_output.put_line('maxmaxdate: ' || maxmaxdate) ;
                --dbms_output.put_line('maxdate: ' || maxdate) ;
                
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
            
            
            
           --  dbms_output.put_line('HI THERE: ' ) ;
                   
                    
                    
            if a_descr is not null and  length(a_descr) < 250 then
                a_alt:=a_descr;
                dsr:=a_descr;
                
               -- dbms_output.put_line('a_descr: ' || a_descr) ;
            end if;
            if a_descr is null and a_title is not null and length(a_title) < 250 then
                
                a_alt:=a_title;
                dsr:=a_title;
                
                
              --  dbms_output.put_line('a_title: ' || a_title) ;
                
                
            end if;
            
          --  dbms_output.put_line('a_alt: ' || a_alt) ;
            -- go through the list of potential things to add to the alt tag
            -- in order of priority
            -- if they don't already exist in whatever' there
            -- AND if adding them won't make the alt too long
            -- append them
            --dbms_output.put_line('a_sciname: ' || a_sciname) ;
           
            --dbms_output.put_line('nvl(length(a_alt),0): ' ||   nvl(length(a_alt),0) );
            --dbms_output.put_line(' nvl(instr(lower(a_alt),lower(a_sciname)),0) ' ||   nvl(instr(lower(a_alt),lower(a_sciname)),0) );
            
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
           -- dbms_output.put_line('a_geog: ' || a_geog) ;
            
          --   dbms_output.put_line('nvl(instr(lower(a_alt),lower(a_geog)),0): ' || nvl(instr(lower(a_alt),lower(a_geog)),0)) ;
             
             
            --dbms_output.put_line('length(a_alt) ' || length(a_alt)) ;
           -- dbms_output.put_line('length(a_geog) ' || length(a_geog)) ;
            if a_geog is not null and 
                nvl(instr(lower(a_alt),lower(a_geog)),0) = 0 and 
                nvl(length(a_alt) + length(a_geog),0) < 250 then
              --  dbms_output.put_line('adding a_geog to a_alt');
                a_alt:=a_alt || chr(7) || a_geog;
            end if;
            dbms_output.put_line('a_locality' || a_locality) ;
            if a_locality is not null and 
                nvl(instr(lower(a_alt),lower(a_locality)),0) = 0 and 
                nvl(length(a_alt) + length(a_locality),0) < 250 then
            --    dbms_output.put_line('adding a_locality to a_alt');
                a_alt:=a_alt || chr(7) || a_locality;
            end if;
            --dbms_output.put_line('a_agent' || a_agent) ;
            if a_agent is not null and 
                nvl(instr(lower(a_alt),lower(a_agent)),0) = 0 and 
                nvl(length(a_alt) + length(a_agent),0) < 250 then
                --dbms_output.put_line('adding a_agent to a_alt');
                a_alt:=a_alt || chr(7) || a_agent;
            end if;
            --dbms_output.put_line('a_proj' || a_proj) ;
            if a_proj is not null and 
                nvl(instr(lower(a_alt),lower(a_proj)),0) = 0 and 
                nvl(length(a_alt) + length(a_proj),0) < 250 then
                --dbms_output.put_line('adding a_proj to a_alt');
                a_alt:=a_alt || chr(7) || a_proj;
            end if;
            --dbms_output.put_line('a_accn' || a_accn) ;
            if a_accn is not null and 
                nvl(instr(lower(a_alt),lower(a_accn)),0) = 0 and 
                nvl(length(a_alt) + length(a_accn),0) < 250 then
                --dbms_output.put_line('adding a_accn to a_alt');
                a_alt:=a_alt || chr(7) || a_accn;
            end if;
           
            --dbms_output.put_line('a_alt: ' || a_alt) ;
             
            -- nobody cares
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
            
            ---dbms_output.put_line('final a_alt: ' || a_alt) ;
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
                 --dbms_output.put_line('problem with ' || m.media_id);
                 -- these are usually encumbered specimens, update flat so we can ignore them for a while....
                  UPDATE media_flat SET lastdate = SYSDATE WHERE media_id=m.media_id;   
        end;
    END LOOP;   
END;
/
sho err;



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
  
  
