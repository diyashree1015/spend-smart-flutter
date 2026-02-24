-- SpendSmart Database Schema
-- Run this SQL in your Supabase SQL Editor

-- Create expenses table
CREATE TABLE expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  amount NUMERIC NOT NULL CHECK (amount > 0),
  category TEXT NOT NULL CHECK (category IN ('Food', 'Shopping', 'Healthcare', 'Travel', 'Other')),
  date DATE NOT NULL,
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations (for demo purposes)
-- In production, you should restrict this based on user authentication
CREATE POLICY "Allow all operations" ON expenses
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Create indexes for better query performance
CREATE INDEX idx_expenses_date ON expenses(date DESC);
CREATE INDEX idx_expenses_category ON expenses(category);
CREATE INDEX idx_expenses_created_at ON expenses(created_at DESC);

-- Insert sample data (optional - for testing)
INSERT INTO expenses (title, amount, category, date, note) VALUES
  ('Lunch at Restaurant', 450.00, 'Food', CURRENT_DATE - INTERVAL '1 day', 'Team lunch with colleagues'),
  ('Grocery Shopping', 2500.00, 'Shopping', CURRENT_DATE - INTERVAL '2 days', 'Weekly groceries from supermarket'),
  ('Doctor Visit', 800.00, 'Healthcare', CURRENT_DATE - INTERVAL '3 days', 'Regular health checkup'),
  ('Uber to Airport', 350.00, 'Travel', CURRENT_DATE - INTERVAL '4 days', 'Business trip transportation'),
  ('Coffee Shop', 150.00, 'Food', CURRENT_DATE - INTERVAL '5 days', 'Morning coffee'),
  ('Online Shopping', 1200.00, 'Shopping', CURRENT_DATE - INTERVAL '6 days', 'Electronics purchase'),
  ('Pharmacy', 300.00, 'Healthcare', CURRENT_DATE - INTERVAL '7 days', 'Monthly medicines'),
  ('Dinner', 800.00, 'Food', CURRENT_DATE - INTERVAL '8 days', 'Family dinner'),
  ('Flight Tickets', 5500.00, 'Travel', CURRENT_DATE - INTERVAL '9 days', 'Vacation booking'),
  ('Clothing', 1800.00, 'Shopping', CURRENT_DATE - INTERVAL '10 days', 'New wardrobe'),
  ('Breakfast', 200.00, 'Food', CURRENT_DATE - INTERVAL '11 days', 'Weekend brunch'),
  ('Medical Test', 1500.00, 'Healthcare', CURRENT_DATE - INTERVAL '12 days', 'Blood test'),
  ('Taxi', 180.00, 'Travel', CURRENT_DATE - INTERVAL '13 days', 'City commute'),
  ('Snacks', 120.00, 'Food', CURRENT_DATE - INTERVAL '14 days', 'Evening snacks'),
  ('Books', 600.00, 'Other', CURRENT_DATE - INTERVAL '15 days', 'Educational books');

-- Verify the data
SELECT 
  category,
  COUNT(*) as transaction_count,
  SUM(amount) as total_amount
FROM expenses
GROUP BY category
ORDER BY total_amount DESC;

-- View recent expenses
SELECT * FROM expenses ORDER BY date DESC LIMIT 10;
