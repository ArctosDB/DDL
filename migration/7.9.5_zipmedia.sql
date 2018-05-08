	--https://github.com/ArctosDB/arctos/issues/1446
	--1) make this asynchronous
	--2) move Media to s3/corral

	create table cf_temp_zipload (
		zid number not null,
		username varchar2(255) not null,
		email  varchar2(255) not null,
		jobname  varchar2(255) not null,
		status  varchar2(255) not null
	);

	alter table cf_temp_zipload add submitted_date date;


	create public synonym cf_temp_zipload for cf_temp_zipload;

	grant insert,select on cf_temp_zipload to manage_media;


	-- processing table
	-- only UAM will interact; no synonyms necessary
	create table cf_temp_zipfiles (
		zid number not null,
		filename varchar2(255),
		new_filename varchar2(255),
		preview_filename varchar2(255),
		localpath varchar2(255),
		remotepath varchar2(255),
		status varchar2(255)
	);

	alter table cf_temp_zipfiles add new_filename varchar2(255);
	alter table cf_temp_zipfiles add preview_filename varchar2(255);
	alter table cf_temp_zipfiles add md5 varchar2(255);
	alter table cf_temp_zipfiles add mime_type varchar2(255);
	alter table cf_temp_zipfiles add media_type varchar2(255);
	alter table cf_temp_zipfiles add remote_preview varchar2(255);


	-- schedule



insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'mediazip_zip_unzip',
	'BulkloadMedia.cfm?action=zip_unzip',
	'600',
	'ZIP Media Loader: unzip the loaded archive',
	'every half-hour',
	'0',
	'7,37',
	'*',
	'*',
	'*',
	'?'
);

insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'mediazip_zip_rename',
	'BulkloadMedia.cfm?action=zip_rename',
	'600',
	'ZIP Media Loader: rename images from a recently-unzipped archives',
	'every half-hour',
	'0',
	'17,47',
	'*',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'mediazip_zip_rename_confirm',
	'BulkloadMedia.cfm?action=zip_rename_confirm',
	'600',
	'ZIP Media Loader: confirm renameprocess from mediazip_zip_rename',
	'every half-hour',
	'0',
	'27,57',
	'*',
	'*',
	'*',
	'?'
);

insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'mediazip_zip_makepreview',
	'BulkloadMedia.cfm?action=zip_makepreview',
	'600',
	'ZIP Media Loader: create thumbnails',
	'every half-hour',
	'0',
	'8,28',
	'*',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'mediazip_zip_makepreview_confirm',
	'BulkloadMedia.cfm?action=zip_makepreview_confirm',
	'600',
	'ZIP Media Loader: confirm creation of thumbnails',
	'every half-hour',
	'0',
	'18,38',
	'*',
	'*',
	'*',
	'?'
);

insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'mediazip_zip_s3ify',
	'BulkloadMedia.cfm?action=zip_s3ify',
	'600',
	'ZIP Media Loader: load to server via S3',
	'every half-hour',
	'0',
	'28,48',
	'*',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'mediazip_zip_s3ify_confirm',
	'BulkloadMedia.cfm?action=zip_s3ify_confirm',
	'600',
	'ZIP Media Loader: confirm load to server via S3',
	'every half-hour',
	'0',
	'9,29',
	'*',
	'*',
	'*',
	'?'
);



insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'mediazip_zip_notify_done',
	'BulkloadMedia.cfm?action=zip_notify_done',
	'600',
	'ZIP Media Loader: Notify user of results',
	'every half-hour',
	'0',
	'19,39',
	'*',
	'*',
	'*',
	'?'
);
