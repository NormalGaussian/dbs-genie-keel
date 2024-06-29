
CREATE TABLE account (
  -- An account is something that can be logged into
  -- Each account is tied to a user, a user may not have an account
  --  where a user doesn't have an account - they are considered to be a pending user

  -- START basic_fields(account)
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- END basic_fields(account)

  -- The identity of the account, TODO: tie it into some form of login mechanism
  identity UUID NOT NULL, -- TODO: identity doesn't exist here

  -- The user that the account is tied to
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES "user"(id),
  
  -- Allow disabling of accounts, seperately to users
  active BOOLEAN NOT NULL DEFAULT TRUE
);
-- START basic_triggers(account)
CREATE TRIGGER update_account_modified_at BEFORE UPDATE ON account FOR EACH ROW EXECUTE FUNCTION update_modified_at_column();
-- END basic_triggers(account)

