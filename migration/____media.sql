alter table cf_global_settings add s3_endpoint varchar2(4000);
alter table cf_global_settings add s3_accesskey varchar2(4000);
alter table cf_global_settings add s3_secretkey varchar2(4000);

 Endpoint:  http://129.114.52.101:9003 
AccessKey: 0PGHFJSQI321FVMDKSDV 
SecretKey: 7l0r7OzgQgbs8ATtCoNVna+G/ppci7j+JYZ7Oip3 

update cf_global_settings set 
	s3_endpoint='xxx',
	s3_accesskey='xxx',
	s3_secretkey='xxx'
;

