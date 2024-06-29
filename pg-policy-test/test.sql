CREATE TABLE user_tokens (
    user INTEGER,
    FOREIGN KEY (user) REFERENCES "user"(id),
    token TEXT
);

CREATE TABLE user (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    display_name TEXT NOT NULL,
    email TEXT NOT NULL,
    password TEXT NOT NULL
);

CREATE TABLE organisation (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    display_name TEXT NOT NULL,
    active BOOLEAN
);

CREATE TABLE team (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    display_name TEXT,
    organisation INTEGER,
    FOREIGN KEY (organisation) REFERENCES organisation(id)
);


CREATE ROLE end_user;

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