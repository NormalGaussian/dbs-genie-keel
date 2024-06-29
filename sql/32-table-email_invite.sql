CREATE TABLE email_invite (
  -- Each row is a User who has been added to the system by an email address,
  --  but does not yet have an account.
  --  * Any created account should be checked for valid pending invites
  --  * Two invites can overlap, but only the latest one should be considered valid

  -- START basic_fields(email_invite)
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- END basic_fields(email_invite)

  -- The email address to watch out for
  email TEXT NOT NULL,

  -- The user to bind the account to
  user_id INTEGER,
  FOREIGN KEY (user_id) REFERENCES "user"(id)

  -- The user who created the invite
  creator_id INTEGER,
  FOREIGN KEY (creator_id) REFERENCES "user"(id),
  
  -- The expiry date of the invite
  expires_at TIMESTAMP DEFAULT NOW() + INTERVAL '1 day' CHECK (expires_at > created_at)
);
-- START basic_triggers(email_invite)
CREATE TRIGGER update_email_invite_modified_at BEFORE UPDATE ON email_invite FOR EACH ROW EXECUTE FUNCTION update_modified_at_column();
-- END basic_triggers(email_invite)

-- TODO: domain invites
