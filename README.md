SpendSmart - Hybrid Expense Tracker & Group Splitter
A comprehensive full-stack expense tracking SaaS application featuring both personal expense management and group expense splitting with advanced analytics. Built with Flutter and Supabase for modern, scalable expense management.

✨ Features
🏠 Personal Expenses
Modern Dashboard: Finance app-inspired UI with gradient cards and interactive charts
Monthly Analytics: Bar charts showing spending trends with pull-to-refresh
Category Breakdown: Pie charts with progress bars and budget utilization
Calendar View: Visual expense tracking with date-wise listings
Smart Categories: Food, Shopping, Healthcare, Travel, and Other with icons
👥 Group Expenses & Splitting
Group Creation: Create shared expense groups with multiple members
Member Management: Add members by email with automatic profile validation
Expense Splitting: Automatic equal-share calculations with balance tracking
Real-time Updates: Live synchronization of group expenses and balances
Settlement Tracking: Clear visibility of who owes what to whom
🔐 Authentication & Security
Supabase Auth: Secure user authentication with email/password
Profile Management: Automatic profile creation and management
Row Level Security: Database-level security policies
Input Validation: Comprehensive form validation and error handling
🛠️ Tech Stack
Frontend
Flutter - Cross-platform framework (Web + Mobile + Desktop)
Material 3 - Modern design system with adaptive theming
fl_chart - Interactive charts and data visualizations
intl - Internationalization and date formatting
speech_to_text - Optional voice input for expenses
Backend & Database
Supabase - PostgreSQL with real-time subscriptions
Row Level Security (RLS) - Database security policies
Real-time Streams - Live data synchronization
RESTful APIs - Clean API design with proper error handling
📊 Database Schema
Core Tables
profiles
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT UNIQUE NOT NULL,
  display_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
expenses (Personal)
CREATE TABLE expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  title TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  category TEXT NOT NULL,
  date DATE NOT NULL,
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
groups
CREATE TABLE groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  created_by UUID REFERENCES profiles(id) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
group_members
CREATE TABLE group_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID REFERENCES groups(id) NOT NULL,
  user_id UUID REFERENCES profiles(id) NOT NULL,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(group_id, user_id)
);
group_expenses
CREATE TABLE group_expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID REFERENCES groups(id) NOT NULL,
  paid_by UUID REFERENCES profiles(id) NOT NULL,
  title TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  category TEXT NOT NULL,
  date DATE NOT NULL,
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
🔄 Split Algorithm
The application implements an equal-share splitting algorithm for group expenses:

How It Works
Total Calculation: Sum all group expenses
Member Count: Count active group members
Equal Share: total_expenses / member_count
Individual Balance: amount_paid - equal_share
Balance States
Positive Balance: User gets money back (overpaid)
Negative Balance: User owes money (underpaid)
Zero Balance: User is settled (paid exact share)
Example
Group Members: Alice, Bob, Charlie (3 members)
Expenses:
- Alice paid $30 for dinner
- Bob paid $20 for movie tickets
- Charlie paid $10 for drinks

Total: $60
Share per person: $60 / 3 = $20

Balances:
- Alice: $30 - $20 = +$10 (gets $10)
- Bob: $20 - $20 = $0 (settled)
- Charlie: $10 - $20 = -$10 (owes $10)
🚀 Setup Instructions
Prerequisites
Flutter SDK (3.0.0+)
Dart SDK
Supabase account
Git
1. Clone Repository
git clone <repository-url>
cd spend-smart
2. Install Dependencies
flutter pub get
3. Setup Supabase
Create new project at supabase.com
Go to SQL Editor and run the schema files in order:
supabase_schema.sql (base schema)
supabase_group_schema.sql (group features)
personal_expenses_schema.sql (personal expenses)
4. Configure Environment
Update lib/main.dart with your Supabase credentials:

await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
5. Run Application
# Web
flutter run -d chrome

# Mobile
flutter run

# Desktop
flutter run -d windows
🎯 Key Features Implementation
Authentication Flow
Signup: Creates user account + profile record automatically
Login: Secure authentication with session management
Profile Sync: Real-time profile updates across app
Group Management
Create Groups: Instant group creation with creator as first member
Add Members: Email-based member addition with profile validation
Member Queries: Efficient joins for member lists with profile data
Expense Splitting Logic
Real-time Calculation: Automatic balance computation on expense changes
Equal Distribution: Fair splitting algorithm for all group expenses
Balance Tracking: Clear debt/credit visibility for settlements
🔒 Security Features
Row Level Security: Database policies prevent unauthorized access
Input Sanitization: All user inputs validated and sanitized
Error Boundaries: Comprehensive error handling with user feedback
Session Management: Secure token handling and automatic refresh
📱 UI/UX Highlights
Material 3 Design: Modern, adaptive interface
Responsive Layout: Optimized for mobile, tablet, and web
Dark Mode: Automatic theme switching
Smooth Animations: Polished micro-interactions
Loading States: Clear feedback during operations
Empty States: Helpful guidance when no data exists
🧪 Testing & Validation
Form Validation: Real-time input validation
Error Handling: Graceful failure recovery
Data Integrity: Database constraints and foreign keys
Performance: Optimized queries and efficient state management
🚀 Production Ready
✅ No Error Screens: Comprehensive error boundaries ✅ Clean Architecture: Modular, maintainable code structure ✅ Database Security: RLS policies and input validation ✅ Real-time Sync: Live updates across all features ✅ Cross-platform: Web, mobile, and desktop support ✅ Scalable Design: Ready for multiple users and groups

📈 Analytics & Insights
Personal Spending: Monthly trends and category analysis
Group Balances: Real-time settlement tracking
Budget Monitoring: Progress indicators and alerts
Visual Charts: Interactive bar and pie charts
🎤 Optional Features
Voice Input: Speech-to-text for expense titles
Calendar Integration: Date picker with visual indicators
Category Icons: Intuitive expense categorization
🐛 Troubleshooting
Common Issues
Supabase Connection Failed

Verify URL and anon key are correct
Check network connectivity
Ensure Supabase project is active
Group Member Not Found

User must sign up first before being added to groups
Check email address spelling
Verify profile was created during signup
Balance Calculations Wrong

Ensure all group expenses are properly recorded
Check member count is accurate
Verify expense amounts are correct
Build Errors

flutter clean
flutter pub get
flutter upgrade
📝 API Reference
Authentication
POST /auth/signup - Create new account
POST /auth/login - User login
POST /auth/logout - User logout
Profiles
GET /profiles/me - Get current user profile
PUT /profiles/me - Update user profile
Groups
POST /groups - Create new group
GET /groups - List user groups
POST /groups/{id}/members - Add group member
GET /groups/{id}/members - List group members
Expenses
POST /expenses - Create personal expense
GET /expenses - List personal expenses
POST /groups/{id}/expenses - Create group expense
GET /groups/{id}/expenses - List group expenses
GET /groups/{id}/balances - Calculate group balances
👨‍💻 Author
Diya Shree L

Built as a comprehensive expense management solution combining personal finance tracking with social expense splitting capabilities.

🙏 Acknowledgments
Flutter Team - Amazing cross-platform framework
Supabase Team - Powerful backend infrastructure
Material Design - Beautiful design system
fl_chart - Excellent charting library
Ready for production deployment and scalable expense management! 🎉
