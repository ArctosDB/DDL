#!/bin/bash
# switcharoo for test/prod

#test environment
LOGDIR=/usr/local/httpd/htdocs/wwwarctos/log
# just some junk folder - we don't really log anything on test
ARCHIVEDIR=/usr/local/httpd/htdocs/notversioned

#production environment

ls $LDIR | while read FILE
	do
		#NAME=`echo $FILE`
		echo $FILE
	done

compress

 /usr/local/httpd/htdocs/wwwarctos/log* {
       monthly
       olddir /usr/local/httpd/htdocs/notversioned
       missingok
   }