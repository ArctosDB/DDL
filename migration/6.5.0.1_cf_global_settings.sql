
alter table cf_global_settings add log_email varchar2(4000);
update cf_global_settings set log_email='arctos.database@gmail.com';

alter table cf_global_settings add protected_ip_list varchar2(4000);
update cf_global_settings set protected_ip_list='127.0.0.1,129.114.52.171,66.249.65.44';