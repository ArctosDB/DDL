-- create a script

set feedback off
set pagesize 0
set termout off
set echo off
set timing off
spool cf_log.csv
select '"LOG_ID","USERNAME","TEMPLATE","ACCESS_DATE","QUERY_STRING","REPORTED_COUNT","REFERRING_URL"' text from dual;
select
'"' || LOG_ID || '","' || USERNAME || '","' || TEMPLATE || '","' || ACCESS_DATE || '","' || QUERY_STRING || '","' || REPORTED_COUNT || '","' || REFERRING_URL || '"'  as text
from cf_log ;
spool off

-- then @scriptname

-- then smoosh

zip cf_log.csv.20170607.zip cf_log.csv

-- and move to archive space

-- waiting on reply from CJ - can't see that from test server
