-- START basic ownership
-- END basic ownership


-- System user roles and users

-- This user can do anything. Ideally it will be disabled
-- This can create databases etc.
CREATE ROLE superuser WITH PASSWORD ?

-- This user can create and delete tables
CREATE ROLE system_migration WITH PASSWORD ?

-- This user can create, view, and edit all data in all tables, including deleting it
CREATE ROLE system_data_administrator WITH PASSWORD ?

-- This user can create, view, and edit all data in all tables, but not delete it
CREATE ROLE system_data_editor WITH PASSWORD ?

-- This user can create data and view all data in all tables, but not edit or delete it
CREATE ROLE system_data_creator WITH PASSWORD ?

-- This user can view all data in all tables, but not edit or delete it
CREATE ROLE system_data_viewer WITH PASSWORD ?

-- This user can imporsonate system users
CREATE ROLE system_webgui WITH PASSWORD ?

-- End user roles and users

-- This user can impersonate end users
CREATE ROLE client_webgui WITH PASSWORD ?

CREATE ROLE end_user;

--  TODO: creating policies
-- 
-- This policy uses the current postgres user
-- CREATE POLICY end_user_policy ON "user" FOR all TO public USING (id = current_user);
-- 
-- This policy uses a setting rather than the current user
-- CREATE POLICY end_user_policy ON "user" FOR all TO public USING (id = current_setting('jwt.claims.user_id')::INTEGER);
--
-- We can try and use a policy to map a session variable against another table; e.g.
-- use a USING policy when using SELECT and DELETE, but a CHECK policy when using INSERT and UPDATE
-- CREATE POLICY end_user_policy ON "team_member" FOR all TO end_user USING (
--   SELECT
--      true
--   FROM user_tokens
--   JOIN team_member
--     ON team_member.user = user_tokens.user
--   WHERE user_tokens.user = current_setting('editing_user')::INTEGER
--     AND user_tokens.token = current_setting('editing_user_token')::TEXT
--     AND team_member.team = NEW.team
--     AND team_member.team = OLD.team -- implicit OLD.team = NEW.team; this could be split allowing for change of team?
--     AND Permission.ManageTeam IN team_member.permissions
-- )
--
-- CREATE POLICY end_user_policy ON "team_member" FOR all TO end_user USING (
--   valid_user(current_setting('editing_user')::INTEGER, current_setting('editing_user_token')::TEXT)
--   AND (
--      permission_check_user_on_team(current_setting('editing_user')::INTEGER, NEW.team, Permission.ManageTeam)
--      OR
--      permission_check_user_on_organisation(
--          current_setting('editing_user')::INTEGER,
--          organisation_from_team(NEW.team),
--          Permission.ManageTeam
--      )
--   )
-- );

CREATE OR REPLACE FUNCTION organisation_from_team(INTEGER team_id) RETURN INTEGER AS $$
    SELECT
        team.organisation
    FROM team
    WHERE team.id = team_id;
$$;

CREATE OR REPLACE FUNCTION valid_user(INTEGER user_id, TEXT token) RETURN BOOLEAN AS $$
    SELECT
        true
    FROM user_tokens
    WHERE user_tokens.user = user_id
        AND user_tokens.token = token;
$$;

CREATE OR REPLACE FUNCTION permission_check_user_on_team(INTEGER user_id, INTEGER team_id, Permission permission) RETURN BOOLEAN AS $$
    SELECT
        true
    FROM team_member
    WHERE team_member.user = user_id
        AND team_member.team = team_id
        AND permission IN team_member.permissions;
$$;

CREATE OR REPLACE FUNCTION permission_check_user_on_organisation(INTEGER user_id, INTEGER organisation_id, Permission permission) RETURN BOOLEAN AS $$
    SELECT
        true
    FROM organisation_member
    WHERE organisation_member.user = user_id
        AND organisation_member.organisation = organisation_id
        AND permission IN organisation_member.permissions;
$$;