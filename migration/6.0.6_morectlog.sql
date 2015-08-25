<!-----------------------



CFML to build code to build tables and triggers.

run, copy into file, exec.







<cfquery name="d" datasource="uam_god">
	select * from user_tab_cols where table_name like 'CT%'
</cfquery>
<cfquery name="tabl" dbtype="query">
	select table_name from d group by table_name
</cfquery>

<cfoutput>
	<cfloop query="tabl">
		<cfquery name="cols" dbtype="query">
			select * from d where table_name='#table_name#'
		</cfquery>
		
		<!----
		<cfset thisSQL="drop table log_#tabl.table_name#">
		<cftry>
			<cfquery name="drop" datasource="uam_god">
				#thisSQL#
			</cfquery>
			<br>#thisSQL#
		<cfcatch>
			<br>FAIL: could not #thisSQL#
			<!----
			<cfdump var=#cfcatch#>
			------>
		</cfcatch>
		</cftry>
		
		<cfset thisSQL="create table log_#tabl.table_name# ( 
		username varchar2(60),	
		when date default sysdate,">
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "n_#COLUMN_NAME# #DATA_TYPE#(#DATA_LENGTH#),">
		</cfloop>
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "o_#COLUMN_NAME# #DATA_TYPE#(#DATA_LENGTH#),">
		</cfloop>
		<cfset thisSQL=thisSQL & ")">
		<cfset thisSQL=replace(thisSQL,',)',')')>
		#thisSQL#
		<cfquery name="buildtable" datasource="uam_god">
			#thisSQL#
		</cfquery>
		<cfquery name="buildps" datasource="uam_god">
			create or replace public synonym log_#tabl.table_name# for log_#tabl.table_name#
		</cfquery>
		<cfquery name="grantps" datasource="uam_god">
			grant select on log_#tabl.table_name# to coldfusion_user
		</cfquery>

		<cfset thisSQL="CREATE OR REPLACE TRIGGER TR_log_#table_name# AFTER INSERT or update or delete ON #table_name# FOR EACH ROW BEGIN insert into log_#table_name# ( username, when,">
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "n_#COLUMN_NAME#,">
		</cfloop>
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "o_#COLUMN_NAME#,">
		</cfloop>
		<cfset thisSQL=thisSQL & ") values ( SYS_CONTEXT('USERENV','SESSION_USER'),	sysdate,">
		<cfset thisSQL=replace(thisSQL,',)',')','all')>

		<cfloop query="cols">
			<cfset thisSQL=thisSQL & ":NEW.#COLUMN_NAME#,">
		</cfloop>
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & ":OLD.#COLUMN_NAME#,">
		</cfloop>
		<cfset thisSQL=thisSQL & ");">
	
		<cfset thisSQL=replace(thisSQL,',);',');','all')>

		<cfset thisSQL=thisSQL & "  END;">
		<p>
			#thisSQL#
		</p>
		<cfquery name="buildtr" datasource="uam_god">#thisSQL#</cfquery>
		
		
		---->
		<p>
			drop table log_#tabl.table_name#;
		</p>
		<cfset thisSQL="create table log_#tabl.table_name# ( 
		<br>username varchar2(60),	
		<br>when date default sysdate,">
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "<br>n_#COLUMN_NAME# #DATA_TYPE#(#DATA_LENGTH#),">
		</cfloop>
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "<br>o_#COLUMN_NAME# #DATA_TYPE#(#DATA_LENGTH#),">
		</cfloop>
		<cfset thisSQL=thisSQL & "<br>);">
		<cfset thisSQL=replace(thisSQL,',<br>);','<br>);')>
		<p>
			#thisSQL#
		</p>
		<p>
			create or replace public synonym log_#tabl.table_name# for log_#tabl.table_name#;
		</p>
		<p>
			grant select on log_#tabl.table_name# to coldfusion_user;
		</p>
		
		<cfset thisSQL="CREATE OR REPLACE TRIGGER TR_log_#table_name# AFTER INSERT or update or delete ON #table_name#
			<br>FOR EACH ROW
			<br>BEGIN
    		<br>  insert into log_#table_name# (
			<br>username,
			<br>when,">
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "<br>n_#COLUMN_NAME#,">
		</cfloop>
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "<br>o_#COLUMN_NAME#,">
		</cfloop>
		<cfset thisSQL=thisSQL & "<br>) values ( 
			<br>SYS_CONTEXT('USERENV','SESSION_USER'),
			<br>sysdate,">
		<cfset thisSQL=replace(thisSQL,',<br>)','<br>)','all')>

		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "<br>:NEW.#COLUMN_NAME#,">
		</cfloop>
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "<br>:OLD.#COLUMN_NAME#,">
		</cfloop>
		<cfset thisSQL=thisSQL & "<br>);">
	
		<cfset thisSQL=replace(thisSQL,',<br>);','<br>);','all')>

		<cfset thisSQL=thisSQL & "  <br>END;<br>
			/">
		<p>
			#thisSQL#
		</p>



-- cleanup, copypasta, exec....
	
	