alter table cf_user_data add download_format varchar2(20);
alter table cf_user_data add ask_for_filename number(1) default 0;
update cf_user_data set ask_for_filename=0;
alter table cf_user_data modify ask_for_filename not null;
alter table cf_user_data add constraint bool_askfilename check (ask_for_filename in (0,1));