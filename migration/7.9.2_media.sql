alter table cf_global_settings add s3_endpoint varchar2(4000);
alter table cf_global_settings add s3_accesskey varchar2(4000);
alter table cf_global_settings add s3_secretkey varchar2(4000);


update cf_global_settings set 
	s3_endpoint='xxx',
	s3_accesskey='xxx',
	s3_secretkey='xxx'
;

