-- START Standard functions
CREATE OR REPLACE FUNCTION update_modified_at_column() RETURNS TRIGGER AS $$
BEGIN
  NEW.modified_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
-- END Standard functions
