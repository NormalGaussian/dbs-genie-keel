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
