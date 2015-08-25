alter table cf_dataentry_settings add sort_leftcolumn varchar2(255);
alter table cf_dataentry_settings add sort_rightcolumn varchar2(255);
alter table cf_dataentry_settings add show_calendars number(1) default 1 check ( show_calendars in (0,1));
-- catch up some old stuff
 alter table cf_dataentry_settings add RELPICK_EVENT number(1);
alter table cf_dataentry_settings add RELPICK_LOCALITY number(1);
alter table cf_dataentry_settings add RELPICK_COLLECTOR number(1);

