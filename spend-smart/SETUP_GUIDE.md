# SpendSmart - Complete Setup Guide

This guide will walk you through setting up SpendSmart from scratch.

## 📋 Prerequisites

Before you begin, ensure you have:

1. **Flutter SDK** installed (version 3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`

2. **Code Editor**
   - VS Code (recommended) with Flutter extension
   - OR Android Studio with Flutter plugin

3. **Supabase Account**
   - Sign up at: https://supabase.com

## 🚀 Step-by-Step Setup

### Step 1: Install Flutter (if not already installed)

**Windows:**
```bash
# Download Flutter SDK from flutter.dev
# Extract to C:\src\flutter
# Add to PATH: C:\src\flutter\bin
flutter doctor
```

**macOS/Linux:**
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
```

### Step 2: Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in
2. Click "New Project"
3. Fill in:
   - Project Name: `spendsmart`
   - Database Password: (create a strong password)
   - Region: (choose closest to you)
4. Click "Create new project" and wait for setup to complete

### Step 3: Setup Database

1. In your Supabase project, go to **SQL Editor**
2. Click "New Query"
3. Copy and paste this SQL:

```sql
-- Create expenses table
CREATE TABLE expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('Food', 'Shopping', 'Healthcare', 'Travel', 'Other')),
  date DATE NOT NULL,
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations (for demo purposes)
CREATE POLICY "Allow all operations" ON expenses
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Create indexes for better performance
CREATE INDEX idx_expenses_date ON expenses(date DESC);
CREATE INDEX idx_expenses_category ON expenses(category);

-- Insert sample data (optional)
INSERT INTO expenses (title, amount, category, date, note) VALUES
  ('Lunch at Restaurant', 450, 'Food', '2024-02-15', 'Team lunch'),
  ('Grocery Shopping', 2500, 'Shopping', '2024-02-14', 'Weekly groceries'),
  ('Doctor Visit', 800, 'Healthcare', '2024-02-13', 'Regular checkup'),
  ('Uber to Airport', 350, 'Travel', '2024-02-12', 'Business trip'),
  ('Coffee', 150, 'Food', '2024-02-11', 'Morning coffee');
```

4. Click "Run" to execute the SQL

### Step 4: Get Supabase Credentials

1. In Supabase, go to **Project Settings** (gear icon)
2. Click on **API** in the left sidebar
3. Copy these two values:
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon public** key (under "Project API keys")

### Step 5: Setup Flutter Project

1. **Navigate to project directory:**
   ```bash
   cd spend_smart
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase credentials:**
   
   Open `lib/main.dart` and find this section (around line 10):
   ```dart
   await Supabase.initialize(
     url: 'YOUR_SUPABASE_URL',
     anonKey: 'YOUR_SUPABASE_ANON_KEY',
   );
   ```

   Replace with your actual credentials:
   ```dart
   await Supabase.initialize(
     url: 'https://xxxxx.supabase.co',
     anonKey: 'your-actual-anon-key-here',
   );
   ```

### Step 6: Run the App

**For Web:**
```bash
flutter run -d chrome
```

**For Android:**
```bash
# Connect your Android device or start emulator
flutter run
```

**For iOS (macOS only):**
```bash
# Start iOS simulator
open -a Simulator
flutter run
```

## ✅ Verification

After running the app, you should see:

1. ✅ Home screen with balance card
2. ✅ Sample expenses (if you inserted sample data)
3. ✅ Working navigation bar
4. ✅ Ability to add new expenses
5. ✅ Charts displaying data

## 🧪 Testing the App

### Test 1: Add an Expense
1. Click on "Add" tab (+ icon)
2. Fill in:
   - Title: "Test Expense"
   - Amount: 100
   - Category: Food
   - Date: Today
3. Click "Save Expense"
4. You should see a success message

### Test 2: View Analytics
1. Go to "Home" tab
2. Check if the bar chart shows data
3. Verify total balance is displayed

### Test 3: View Expenses
1. Go to "Expenses" tab
2. Check category breakdown
3. Click on "Total Expense" card to see pie chart

## 🐛 Common Issues & Solutions

### Issue 1: "flutter: command not found"
**Solution:** Flutter is not in your PATH. Add Flutter to your system PATH.

### Issue 2: Supabase connection error
**Solution:** 
- Verify URL and anon key are correct
- Check internet connection
- Ensure Supabase project is active

### Issue 3: "Failed to fetch expenses"
**Solution:**
- Check if RLS policies are created
- Verify table name is exactly "expenses"
- Check Supabase project logs

### Issue 4: Charts not displaying
**Solution:**
- Add some expenses first
- Check if data is in the database (Supabase Table Editor)
- Refresh the app

### Issue 5: Voice input not working
**Solution:**
- Grant microphone permissions
- Voice input is optional - app works without it

## 📱 Platform-Specific Setup

### Android
No additional setup required. Just run `flutter run`.

### iOS (macOS only)
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select a development team
3. Run from Xcode or use `flutter run`

### Web
Works out of the box. Use `flutter run -d chrome`.

## 🔧 Development Tips

### Hot Reload
Press `r` in terminal while app is running to hot reload changes.

### Debug Mode
The app runs in debug mode by default. For production:
```bash
flutter build apk --release  # Android
flutter build web --release  # Web
```

### View Logs
```bash
flutter logs
```

### Clear Cache
```bash
flutter clean
flutter pub get
```

## 📊 Supabase Dashboard

Access your data anytime:
1. Go to Supabase project
2. Click "Table Editor"
3. Select "expenses" table
4. View, edit, or delete records

## 🎯 Next Steps

1. ✅ Customize categories in `lib/utils/category_icons.dart`
2. ✅ Adjust budget values in screens
3. ✅ Add authentication (optional)
4. ✅ Deploy to production
5. ✅ Add more features

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [fl_chart Documentation](https://pub.dev/packages/fl_chart)
- [Material 3 Design](https://m3.material.io/)

## 🆘 Need Help?

If you encounter issues:
1. Check the error message carefully
2. Run `flutter doctor` to check your setup
3. Verify Supabase credentials
4. Check Supabase project logs
5. Ensure all dependencies are installed

---

**You're all set! Happy coding! 🎉**
