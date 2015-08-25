All pages should have SOME role assigned to them.

Add "public" as a valid role.

Next step will be to alter CustomTags/rolecheck.cfm to disallow access to any form that has no roles
and delete forms that aren't used anywhere.

insert into cf_ctuser_roles (ROLE_NAME,DESCRIPTION) values ('public','allow access by any user');

Make sure cfadmin is pointing to /errors/404.cfm and not /404.cfm

