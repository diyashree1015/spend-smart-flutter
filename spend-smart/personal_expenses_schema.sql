-- Personal Expenses Table Schema
-- Run this in Supabase SQL Editor

-- Create personal_expenses table
CREATE TABLE IF NOT EXISTS personal_expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  amount NUMERIC NOT NULL CHECK (amount > 0),
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE personal_expenses ENABLE ROW LEVEL SECURITY;

-- RLS Policies for personal_expenses
CREATE POLICY "Users can view own personal expenses"
  ON personal_expenses FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own personal expenses"
  ON personal_expenses FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own personal expenses"
  ON personal_expenses FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own personal expenses"
  ON personal_expenses FOR DELETE
  USING (auth.uid() = user_id);

-- Create indexes for performance
CREATE INDEX idx_personal_expenses_user_id ON personal_expenses(user_id);
CREATE INDEX idx_personal_expenses_created_at ON personal_expenses(created_at DESC);

-- Sample data (optional - for testing)
-- Replace 'YOUR_USER_ID' with actual user ID from auth.users
/*
INSERT INTO personal_expenses (user_id, title, amount, category) VALUES
  ('YOUR_USER_ID', 'Morning Coffee', 150, 'Food'),
  ('YOUR_USER_ID', 'Uber Ride', 250, 'Transport'),
  ('YOUR_USER_ID', 'Grocery Shopping', 1200, 'Shopping'),
  ('YOUR_USER_ID', 'Movie Ticket', 300, 'Entertainment'),
  ('YOUR_USER_ID', 'Lunch', 400, 'Food');
*/
