-- Group Expense Sharing App - Database Schema
-- Run this in Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (handled by Supabase Auth)
-- We'll reference auth.users

-- Groups table
CREATE TABLE IF NOT EXISTS groups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Group members table
CREATE TABLE IF NOT EXISTS group_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(group_id, user_id)
);

-- Expenses table (updated for groups)
CREATE TABLE IF NOT EXISTS expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  amount NUMERIC NOT NULL CHECK (amount > 0),
  category TEXT NOT NULL,
  paid_by UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User profiles table (for display names)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  display_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies for groups
CREATE POLICY "Users can view groups they are members of"
  ON groups FOR SELECT
  USING (
    id IN (
      SELECT group_id FROM group_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create groups"
  ON groups FOR INSERT
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Group creators can update their groups"
  ON groups FOR UPDATE
  USING (auth.uid() = created_by);

CREATE POLICY "Group creators can delete their groups"
  ON groups FOR DELETE
  USING (auth.uid() = created_by);

-- RLS Policies for group_members
CREATE POLICY "Users can view members of their groups"
  ON group_members FOR SELECT
  USING (
    group_id IN (
      SELECT group_id FROM group_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Group creators can add members"
  ON group_members FOR INSERT
  WITH CHECK (
    group_id IN (
      SELECT id FROM groups WHERE created_by = auth.uid()
    )
  );

CREATE POLICY "Users can leave groups"
  ON group_members FOR DELETE
  USING (user_id = auth.uid());

-- RLS Policies for expenses
CREATE POLICY "Users can view expenses in their groups"
  ON expenses FOR SELECT
  USING (
    group_id IN (
      SELECT group_id FROM group_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Group members can add expenses"
  ON expenses FOR INSERT
  WITH CHECK (
    group_id IN (
      SELECT group_id FROM group_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Expense creators can update their expenses"
  ON expenses FOR UPDATE
  USING (paid_by = auth.uid());

CREATE POLICY "Expense creators can delete their expenses"
  ON expenses FOR DELETE
  USING (paid_by = auth.uid());

-- RLS Policies for profiles
CREATE POLICY "Profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Indexes for performance
CREATE INDEX idx_groups_created_by ON groups(created_by);
CREATE INDEX idx_group_members_group_id ON group_members(group_id);
CREATE INDEX idx_group_members_user_id ON group_members(user_id);
CREATE INDEX idx_expenses_group_id ON expenses(group_id);
CREATE INDEX idx_expenses_paid_by ON expenses(paid_by);
CREATE INDEX idx_expenses_date ON expenses(date DESC);

-- Function to auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name)
  VALUES (NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Sample data (optional)
-- Insert after creating your first user via signup
