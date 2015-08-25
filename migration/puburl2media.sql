 select max(media_id) from media;

MAX(MEDIA_ID)
-------------
     10090220



DECLARE mtype varchar2(20);
BEGIN
    FOR r IN (SELECT * FROM publication_url) LOOP
       BEGIN
           IF r.link LIKE '%.pdf' THEN
               mtype:='application/pdf';
           ELSE
               mtype:='text/html';
           END IF;
               
           insert into media (
                media_id,
                media_uri,
                mime_type,
                media_type)
    	    values (
    	        sq_media_id.nextval,
    	        r.link,
    	        mtype,
    	        'text'
    	    );
    	    insert into media_relations (
    		    media_id,
    			media_relationship,
    			related_primary_key,
    			created_by_agent_id
    		) values (
    			sq_media_id.currval,
    			'shows publication',
    			r.publication_id,
    			0
    		);
    		insert into media_labels (
    			media_id,
    			media_label,
    			label_value,
    			ASSIGNED_BY_AGENT_ID)
    		values (
    		    sq_media_id.currval,
    		    'description',
    		    r.description,
    		    0
    		 );
       EXCEPTION WHEN OTHERS THEN
           dbms_output.put_line(r.link);
        END;	    
    END LOOP;
END;