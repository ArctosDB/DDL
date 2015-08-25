-- create no synonyms or permissions for this
-- there is minimal debuggong and checking and it needs to run only as UAM
--
-- run the check agent web script BEFORE firing this off
-- be paranoid
-- make sure everything in the table is handled in here
CREATE OR REPLACE PROCEDURE bulkload_agents 
AS
	c number;
BEGIN

	for r in (select * from cf_temp_agent_sort) loop
		INSERT INTO agent (
			agent_id,
			agent_type,
			PREFERRED_AGENT_NAME,
			AGENT_REMARKS
		) VALUES (
			sq_agent_id.nextval,
			r.agent_type,
			trim(r.preferred_name),
			trim(r.agent_remark)
		);
		if r.other_name_type_1 is not null and r.other_name_1 is not null then
			INSERT INTO agent_name (
				agent_name_id,
				agent_id,
				agent_name_type,
				agent_name
			) VALUES (
				SQ_AGENT_NAME_ID.NEXTVAL,
				sq_agent_id.currval,
				r.other_name_type_1,
				trim(r.other_name_1)
			);
		end if;

		if r.other_name_type_2 is not null and r.other_name_2 is not null then
			INSERT INTO agent_name (
				agent_name_id,
				agent_id,
				agent_name_type,
				agent_name
			) VALUES (
				SQ_AGENT_NAME_ID.NEXTVAL,
				sq_agent_id.currval,
				r.other_name_type_2,
				trim(r.other_name_2)
			);
		end if;

		if r.other_name_type_3 is not null and r.other_name_3 is not null then
			INSERT INTO agent_name (
				agent_name_id,
				agent_id,
				agent_name_type,
				agent_name
			) VALUES (
				SQ_AGENT_NAME_ID.NEXTVAL,
				sq_agent_id.currval,
				r.other_name_type_3,
				trim(r.other_name_3)
			);
		end if;

		if r.other_name_type_4 is not null and r.other_name_4 is not null then
			INSERT INTO agent_name (
				agent_name_id,
				agent_id,
				agent_name_type,
				agent_name
			) VALUES (
				SQ_AGENT_NAME_ID.NEXTVAL,
				sq_agent_id.currval,
				r.other_name_type_4,
				trim(r.other_name_4)
			);
		end if;

		if r.other_name_type_5 is not null and r.other_name_5 is not null then
			INSERT INTO agent_name (
				agent_name_id,
				agent_id,
				agent_name_type,
				agent_name
			) VALUES (
				SQ_AGENT_NAME_ID.NEXTVAL,
				sq_agent_id.currval,
				r.other_name_type_5,
				trim(r.other_name_5)
			);
		end if;

		if r.other_name_type_6 is not null and r.other_name_6 is not null then
			INSERT INTO agent_name (
				agent_name_id,
				agent_id,
				agent_name_type,
				agent_name
			) VALUES (
				SQ_AGENT_NAME_ID.NEXTVAL,
				sq_agent_id.currval,
				r.other_name_type_6,
				trim(r.other_name_6)
			);
		end if;



		if r.agent_status_1 is not null and r.agent_status_date_1 is not null then
			INSERT INTO AGENT_STATUS (
				AGENT_STATUS_ID,
				agent_id,
				AGENT_STATUS,
				STATUS_DATE
			) VALUES (
				SQ_AGENT_STATUS_ID.NEXTVAL,
				sq_agent_id.currval,
				r.agent_status_1,
				r.agent_status_date_1
			);
		end if;

		if r.agent_status_2 is not null and r.agent_status_date_2 is not null then
			INSERT INTO AGENT_STATUS (
				AGENT_STATUS_ID,
				agent_id,
				AGENT_STATUS,
				STATUS_DATE
			) VALUES (
				SQ_AGENT_STATUS_ID.NEXTVAL,
				sq_agent_id.currval,
				r.agent_status_2,
				r.agent_status_date_2
			);
		end if;

	end loop;
END;
/
