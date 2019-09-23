-- ref https://github.com/ArctosDB/arctos/issues/745
-- ref https://docs.google.com/spreadsheets/d/180hSdIahLgP-wIhaxyhlBehk4lrPnsymlMLhkYwhmak/edit#gid=0


alter table cf_ctuser_roles add user_type varchar2(4000);
alter table cf_ctuser_roles add shared varchar2(4000);
-- def is dynamic
alter table cf_ctuser_roles add text_documentation varchar2(4000);
alter table cf_ctuser_roles add av_documentation varchar2(4000);

