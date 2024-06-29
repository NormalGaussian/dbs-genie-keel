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
-- START basic_triggers(invoice)
CREATE TRIGGER update_invoice_modified_at BEFORE UPDATE ON invoice FOR EACH ROW EXECUTE FUNCTION update_modified_at_column();
-- END basic_triggers(invoice)
