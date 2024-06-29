CREATE TABLE organisation_member (
  -- START basic_fields(organisation_member)
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- END basic_fields(organisation_member)

  user INTEGER,
  FOREIGN KEY (user) REFERENCES "user"(id),
  
  organisation INTEGER,
  FOREIGN KEY (organisation) REFERENCES organisation(id)
  
  permissions TEXT[],
);
-- START basic_triggers(organisation_member)
CREATE TRIGGER update_organisation_member_modified_at BEFORE UPDATE ON organisation_member FOR EACH ROW EXECUTE FUNCTION update_modified_at_column();
-- END basic_triggers(organisation_member)
-- Enforce that a user can only be in an organisation once
CREATE UNIQUE INDEX organisation_member_user_organisation_idx ON organisation_member(user, organisation);
