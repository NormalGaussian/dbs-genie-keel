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
