create profile arctos_user 
limit
    COMPOSITE_LIMIT                  UNLIMITED
	SESSIONS_PER_USER                UNLIMITED
	CPU_PER_SESSION                  UNLIMITED
	CPU_PER_CALL                     UNLIMITED
	LOGICAL_READS_PER_SESSION        UNLIMITED
	LOGICAL_READS_PER_CALL           UNLIMITED
	IDLE_TIME                        UNLIMITED
	CONNECT_TIME                     UNLIMITED
	PRIVATE_SGA                      UNLIMITED
	FAILED_LOGIN_ATTEMPTS            3
	PASSWORD_LIFE_TIME               UNLIMITED
	PASSWORD_REUSE_TIME              UNLIMITED
	PASSWORD_REUSE_MAX               UNLIMITED
	PASSWORD_VERIFY_FUNCTION         VERIFY_FUNCTION
	PASSWORD_LOCK_TIME               1/48
	PASSWORD_GRACE_TIME              UNLIMITED;
	
--alter profile arctos_user LIMIT FAILED_LOGIN_ATTEMPTS 3;
--alter profile arctos_user LIMIT PASSWORD_LOCK_TIME 1/48;
	
begin
    for uname in (
        select d.username from dba_users d, cf_users c
        where d.username = upper(c.username)
    ) loop
        execute immediate 'alter user ' || uname.username ||
            ' profile arctos_user';
    end loop;
end;

-- scott is oracle system user
alter user scott profile default;

alter user DIGIR_QUERY profile arctos_user;
alter user UAM profile arctos_user;
alter user UAM_QUERY profile arctos_user;
alter user UAM_UPDATE profile arctos_user;
alter user VPD_TEST profile arctos_user;
/* only at test
alter user EIGHTY profile arctos_user;
alter user PUB_USR_ALL_ALL profile arctos_user;
alter user PUB_USR_CRCM_BIRD profile arctos_user;
alter user PUB_USR_DGR_BIRD profile arctos_user;
alter user PUB_USR_DGR_ENTO profile arctos_user;
alter user PUB_USR_DGR_FISH profile arctos_user;
alter user PUB_USR_DGR_HERP profile arctos_user;
alter user PUB_USR_DGR_MAMM profile arctos_user;
alter user PUB_USR_GOD_HERB profile arctos_user;
alter user PUB_USR_KWP_ENTO profile arctos_user;
alter user PUB_USR_MSB_BIRD profile arctos_user;
alter user PUB_USR_MSB_MAMM profile arctos_user;
alter user PUB_USR_NBSB_BIRD profile arctos_user;
alter user PUB_USR_PSU_MAMM profile arctos_user;
alter user PUB_USR_UAMOBS_MAMM profile arctos_user;
alter user PUB_USR_UAM_BIRD profile arctos_user;
alter user PUB_USR_UAM_BRYO profile arctos_user;
alter user PUB_USR_UAM_CRUS profile arctos_user;
alter user PUB_USR_UAM_ENTO profile arctos_user;
alter user PUB_USR_UAM_FISH profile arctos_user;
alter user PUB_USR_UAM_HERB profile arctos_user;
alter user PUB_USR_UAM_HERP profile arctos_user;
alter user PUB_USR_UAM_MAMM profile arctos_user;
alter user PUB_USR_UAM_MOLL profile arctos_user;
alter user PUB_USR_UAM_VPAL profile arctos_user;
alter user PUB_USR_WNMU_BIRD profile arctos_user;
alter user PUB_USR_WNMU_FISH profile arctos_user;
alter user PUB_USR_WNMU_MAMM profile arctos_user;
*/
