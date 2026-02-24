-- Add invite_code column to groups table
ALTER TABLE groups ADD COLUMN IF NOT EXISTS invite_code TEXT UNIQUE;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_groups_invite_code ON groups(invite_code);

-- Function to generate random invite code
CREATE OR REPLACE FUNCTION generate_invite_code()
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  result TEXT := '';
  i INTEGER;
BEGIN
  FOR i IN 1..8 LOOP
    result := result || substr(chars, floor(random() * length(chars) + 1)::int, 1);
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-generate invite code on group creation
CREATE OR REPLACE FUNCTION set_invite_code()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.invite_code IS NULL THEN
    NEW.invite_code := generate_invite_code();
    -- Ensure uniqueness
    WHILE EXISTS (SELECT 1 FROM groups WHERE invite_code = NEW.invite_code) LOOP
      NEW.invite_code := generate_invite_code();
    END LOOP;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_set_invite_code ON groups;
CREATE TRIGGER trigger_set_invite_code
  BEFORE INSERT ON groups
  FOR EACH ROW
  EXECUTE FUNCTION set_invite_code();

-- Update existing groups with invite codes
UPDATE groups SET invite_code = generate_invite_code() WHERE invite_code IS NULL;
