create table ctyes_no (yes_or_no varchar2(3));
create public synonym ctyes_no for ctyes_no;
grant all on ctyes_no to manage_codetables;
grant select on ctyes_no to public;
