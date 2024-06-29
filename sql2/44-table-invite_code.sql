CREATE TABLE invite_code (
  -- START basic_fields(invite_code)
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- END basic_fields(invite_code)

  -- The code that should be checked
  code TEXT CHECK (LENGTH(code) >= 6),

  -- The type of invite the code was created for
  -- note - this does not prevent users from copying the code and using it for a different purpose
  type TEXT CHECK (type IN ('email', 'link')),

  -- The user to bind the account to
  user_id INTEGER,
  FOREIGN KEY (user_id) REFERENCES "user"(id),

  -- The user who created the code
  creator_id INTEGER,
  FOREIGN KEY (creator_id) REFERENCES "user"(id),

  -- The expiry date of the code
  expires_at TIMESTAMP DEFAULT NOW() + INTERVAL '1 day' CHECK (expires_at > created_at),

);
-- START basic_triggers(invite_code)
CREATE TRIGGER update_invite_code_modified_at BEFORE UPDATE ON invite_code FOR EACH ROW EXECUTE FUNCTION update_modified_at_column();
-- END basic_triggers(invite_code)

-- Ensure that the code is unique whilst it is issued
CREATE UNIQUE INDEX invite_code_code_idx ON invite_code(code) WHERE expires_at > CURRENT_TIMESTAMP;
