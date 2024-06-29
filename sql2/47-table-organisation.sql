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
