-- run AS sys

set echo on

drop role plustrace;
create role plustrace;

grant select on v_$sesstat to plustrace;
grant select on v_$statname to plustrace;
grant select on v_$mystat to plustrace;
grant plustrace to dba with admin option;

GRANT ALL ON plan_table TO PUBLIC;

grant plustrace to dlm;

set echo off
