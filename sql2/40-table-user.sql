CREATE TABLE "user" (
  -- Don't create a user directly
  -- Either:
  -- * Create an account, with a tied user
  -- * Create an email invite, with a tied user
  -- * Create a TeamMember, with a tied user

  -- START basic_fields(user)
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- END basic_fields(user)

  legal_forename TEXT,
  legal_surname TEXT,
  display_name TEXT
);
-- START basic_triggers(user)
CREATE TRIGGER update_user_modified_at BEFORE UPDATE ON "user" FOR EACH ROW EXECUTE FUNCTION update_modified_at_column();
-- END basic_triggers(user)
