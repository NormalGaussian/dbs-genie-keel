-- START Standard functions
CREATE OR REPLACE FUNCTION update_modified_at_column() RETURNS TRIGGER AS $$
BEGIN
  NEW.modified_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
-- END Standard functions

-- START basic ownership
-- END basic ownership

CREATE TYPE Permission AS ENUM (
  -- Unused permissions
  'ViewUsers',
  'ViewTeams',
  'ManageUsers',
  'ManageTeams',
  'ViewAuditHistory',
  'ViewBillingInvoices',
  'ViewBillingSummary',
  'ViewPaymentMethods',
  'ManageBilling'
);

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

CREATE TABLE team (
  -- START basic_fields(team)
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- END basic_fields(team)

  display_name TEXT,
  organisation INTEGER,
  FOREIGN KEY (organisation) REFERENCES organisation(id)
);
-- START basic_triggers(team)
CREATE TRIGGER update_team_modified_at BEFORE UPDATE ON team FOR EACH ROW EXECUTE FUNCTION update_modified_at_column();
-- END basic_triggers(team)

CREATE TABLE invoice (
  -- An invoice is a record of a demand for payment
  -- TODO: split out actual payments into a separate table

  -- START basic_fields(invoice)
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- END basic_fields(invoice)
  
  -- Organisation that the invoice is for
  organisation INTEGER NOT NULL,
  FOREIGN KEY (organisation) REFERENCES organisation(id),

  -- Invoice information
  period_start TIMESTAMP,
  period_end TIMESTAMP,
  invoice_id TEXT NOT NULL,
  
  -- Payment information
  paid BOOLEAN,
  stripe_subscription_id INTEGER,
  payment_id TEXT,
  payment_at TIMESTAMP,
);

CREATE TABLE organisation (
  -- START basic_fields(organisation)
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- END basic_fields(organisation)

  display_name TEXT NOT NULL,
  active BOOLEAN,
);
-- START basic_triggers(organisation)
CREATE TRIGGER update_organisation_modified_at BEFORE UPDATE ON organisation FOR EACH ROW EXECUTE FUNCTION update_modified_at_column();
-- END basic_triggers(organisation)

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

CREATE TABLE team_member (
  -- START basic_fields(team_member)
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- END basic_fields(team_member)

  user INTEGER,
  FOREIGN KEY (user) REFERENCES "user"(id),
  
  team INTEGER,
  FOREIGN KEY (team) REFERENCES team(id)
  
  permissions TEXT[],
);
-- START basic_triggers(team_member)
CREATE TRIGGER update_team_member_modified_at BEFORE UPDATE ON team_member FOR EACH ROW EXECUTE FUNCTION update_modified_at_column();
-- END basic_triggers(team_member)
-- Enforce that a user can only be in a team once
CREATE UNIQUE INDEX team_member_user_team_idx ON team_member(user, team);

CREATE TABLE stripe_subscription (
  -- A subscription to a Stripe plan
  -- This is a record of a subscription, not the subscription itself
  --  * The subscription itself is managed by Stripe
  --  * This record is used to track the subscription and link it to the organisation

  -- START basic_fields(stripe_subscription)
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- END basic_fields(stripe_subscription)

  -- The organisation that the subscription is for
  organisation INTEGER,
  FOREIGN KEY (organisation) REFERENCES organisation(id),

  active BOOLEAN DEFAULT FALSE,
  plan_id TEXT,
  stripe_customer_id TEXT,
  plan_name TEXT,
);
-- START basic_triggers(stripe_subscription)
CREATE TRIGGER update_stripe_subscription_modified_at BEFORE UPDATE ON stripe_subscription FOR EACH ROW EXECUTE FUNCTION update_modified_at_column();
-- END basic_triggers(stripe_subscription)
