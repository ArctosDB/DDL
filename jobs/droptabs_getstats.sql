/*	daily job to execute sp_drop_oldjobs and sp_get_querystats,
    owned by sys
    modified to be owned by sys. 
    search tables are now created in the user's schema,
    so must run as sys to access dba_recyclebin
    
    2009 Sep 24. LKV.
    	removed username from query_stats_coll table.
    	added primary keys and indexes.
    
*/

-- create in uam_query schema

CREATE TABLE UAM_QUERY.QUERY_STATS (
    QUERY_ID NUMBER,
    QUERY_TYPE VARCHAR2(10),
    CREATE_DATE DATE,
    SUM_COUNT NUMBER,
    USERNAME VARCHAR2(30)
) TABLESPACE UAM_DAT_1;

ALTER TABLE QUERY_STATS
    ADD CONSTRAINT PK_QUERY_STATS 
    PRIMARY KEY (QUERY_ID)
    USING INDEX TABLESPACE UAM_IDX_1;

CREATE TABLE UAM_QUERY.QUERY_STATS_COLL (
    QUERY_ID NUMBER,
    REC_COUNT NUMBER,
    COLLECTION_ID NUMBER
) TABLESPACE UAM_DAT_1;

ALTER TABLE QUERY_STATS_COLL
    ADD CONSTRAINT PK_QUERY_STATS_COLL 
    PRIMARY KEY (QUERY_ID, COLLECTION_ID)
    USING INDEX TABLESPACE UAM_IDX_1;

CREATE INDEX IX_QUERYSTATS_CRDATE 
ON UAM_QUERY.QUERY_STATS (CREATE_DATE) 
TABLESPACE UAM_IDX_1;

CREATE INDEX IX_QUERYSTATSCOLL_QID 
ON UAM_QUERY.QUERY_STATS_COLL (QUERY_ID)
TABLESPACE UAM_IDX_1;

CREATE INDEX IX_QUERYSTATSCOLL_COLLID 
ON UAM_QUERY.QUERY_STATS_COLL (COLLECTION_ID)
TABLESPACE UAM_IDX_1;

ANALYZE TABLE UAM_QUERY.QUERY_STATS COMPUTE STATISTICS;
ANALYZE TABLE UAM_QUERY.QUERY_STATS_COLL COMPUTE STATISTICS;

CREATE SEQUENCE SQ_QUERY_ID INCREMENT BY 1 START WITH 1 NOCACHE;
 
-- create as sys
CREATE OR REPLACE PROCEDURE SP_DROP_OLDTABS
IS
	CURSOR oldtabs IS
		SELECT owner, object_name, to_char(created, 'DD-MON-YYYY HH24:MI') crdate
		FROM dba_objects
		WHERE object_type = 'TABLE'
		AND created < (SYSDATE - 1)
		AND (object_name LIKE 'SPECSRCH%' OR object_name LIKE 'TAXSRCH%')
    AND rownum <= 10000
		ORDER BY created;
BEGIN
	FOR ot in oldtabs
	LOOP
		EXECUTE IMMEDIATE 'DROP TABLE ' || ot.owner || '.' || ot.object_name;
		-- dbms_output.put_line('Dropping old table: ' || ot.owner || '.' || ot.object_name || ' created ' || ot.crdate);
	END LOOP;
EXCEPTION
	WHEN OTHERS THEN
		raise_application_error(-20001,'An error was encountered: '
			|| SQLCODE || '-ERROR-' || SQLERRM);
END;
/

-- create as sys
CREATE OR REPLACE PROCEDURE SP_GET_QUERYSTATS
IS
	CURSOR rbintabs IS
		SELECT owner, '"' || owner || '"."' || object_name || '"' tabname, original_name, createtime
		FROM dba_recyclebin
		WHERE (original_name LIKE 'SPECSRCH%' OR original_name LIKE 'TAXSRCH%')
    AND rownum <= 10000
		ORDER BY createtime;
	qid NUMBER;
	c NUMBER;
	sqltxt VARCHAR2(4000);
BEGIN
	FOR rt IN rbintabs
	LOOP
		SELECT uam_query.sq_query_id.nextval INTO qid FROM dual;
        -- dbms_output.put_line (qid || ': ' || rt.tabname );
        
		IF rt.original_name LIKE 'SPECSRCH%' THEN
            EXECUTE IMMEDIATE 'select COUNT(*) ' ||
			    'from ' || rt.tabname || ' rbt, uam.cataloged_item ci ' ||
			    'where rbt.collection_object_id = ci.collection_object_id '
			    INTO c;
			
            -- dbms_output.put_line (chr(9) || 'specsrch count: ' || c);
            
            INSERT INTO uam_query.query_stats (query_id, query_type, create_date, sum_count, username)
            VALUES(qid, 'specimen', to_date(rt.createtime,'YYYY-MM-DD:HH24:MI:SS'), c, rt.owner);
            
            sqltxt := 'insert into uam_query.query_stats_coll (
					query_id,
					rec_count,
					collection_id) (
				select ' ||
					qid || ',
					count(*),
					ci.collection_id 
				from ' || rt.tabname || ' rbt, uam.cataloged_item ci
				where rbt.collection_object_id = ci.collection_object_id
				group by ci.collection_id)';
				
			EXECUTE IMMEDIATE  sqltxt;
		ELSIF rt.original_name LIKE 'TAXSRCH%' THEN
            EXECUTE IMMEDIATE 'select COUNT(*) ' ||
			    'from ' || rt.tabname || ' rbt, uam.taxonomy t ' ||
			    'where rbt.taxon_name_id = t.taxon_name_id '
			    INTO c;
			
            -- dbms_output.put_line (chr(9) || 'taxsrch count: ' || c);
            
            INSERT INTO uam_query.query_stats (query_id, query_type, create_date, sum_count, username)
            VALUES(qid, 'taxa', to_date(rt.createtime,'YYYY-MM-DD:HH24:MI:SS'), c, rt.owner);
		END IF;
		-- dbms_output.put_line (chr(9) || 'purged table ' || rt.tabname || chr(10) || chr(9) ||'original table name: ' || rt.original_name);
		EXECUTE IMMEDIATE 'purge table ' || rt.tabname;
	END LOOP;
EXCEPTION
	WHEN OTHERS THEN
		raise_application_error(-20001,'An error was encountered: '
			|| SQLCODE || '-ERROR-' || SQLERRM);
END;
/

-- create as sys
CREATE OR REPLACE PROCEDURE SP_DROPTABS_GETSTATS
IS
BEGIN
    EXECUTE IMMEDIATE 'begin sp_drop_oldtabs; end;';
    dbms_output.put_line('executed sys.sp_drop_oldtabs....');
    EXECUTE IMMEDIATE 'begin sp_get_querystats; end;';
    dbms_output.put_line('executed sys.sp_get_querystats....');
END;
/

--exec sp_drop_oldtabs;
--exec sp_get_querystats;
--exec sp_droptabs_getstats;

-- create as sys
BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'droptabs_getstats_job',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'sp_droptabs_getstats',
		start_date		=> SYSDATE,
		repeat_interval	=> 'freq=daily; byhour=1;byminute=1',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'drop %SRCH% tables when > 24 hrs and get stats');
END;
/

/*
--exec DBMS_SCHEDULER.DISABLE('DROPTABS_GETSTATS_JOB');
--exec DBMS_SCHEDULER.ENABLE('DROPTABS_GETSTATS_JOB');
--exec DBMS_SCHEDULER.DROP_JOB('DROPTABS_GETSTATS_JOB');

BEGIN
DBMS_SCHEDULER.SET_ATTRIBUTE (
   name           =>   'droptabs_getstats_job',
   attribute      =>   'repeat_interval',
   value          =>   'freq=daily; byhour=1; byminute=1');
END;
*/
