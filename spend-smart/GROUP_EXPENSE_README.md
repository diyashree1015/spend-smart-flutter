# 🎉 Group Expense Splitter - Production Ready

A modern, production-level group expense sharing application built with Flutter and Supabase.

## ✨ What's New

This app has been upgraded from a personal expense tracker to a **full-featured group expense splitter** with:

- ✅ **Authentication System** (Email/Password)
- ✅ **Group Management** (Create, Join, View)
- ✅ **Smart Split Calculation** (Automatic balance calculation)
- ✅ **Real-time Updates** (Supabase real-time subscriptions)
- ✅ **Modern Material 3 UI** (Clean, responsive design)
- ✅ **Multi-user Support** (Track who paid what)

## 🚀 Features

### 1. Authentication
- Email/Password signup and login
- Automatic session management
- Secure logout
- Profile creation on signup

### 2. Group Management
- Create unlimited groups
- Add members to groups
- View all your groups
- Group descriptions

### 3. Expense Tracking
- Add expenses to groups
- Track who paid
- Categorize expenses (Food, Shopping, Healthcare, Travel, Other)
- Add notes to expenses
- Date tracking

### 4. Smart Split Calculation
The app automatically calculates:
- Total group expense
- Share per person (equal split)
- How much each person paid
- Who owes whom
- Settlement summary

**Example:**
- Total expense: ₹3000
- 3 members
- Share per person: ₹1000
- Person A paid ₹1500 → Gets back ₹500
- Person B paid ₹800 → Owes ₹200
- Person C paid ₹700 → Owes ₹300

### 5. Modern UI/UX
- Material 3 design
- Gradient cards
- Responsive layout (max-width 900px for web)
- Loading states
- Empty states
- Success/Error feedback
- Floating action buttons
- Pull-to-refresh

## 📁 New Project Structure

```
lib/
├── auth/
│   ├── login_screen.dart          # Login page
│   ├── signup_screen.dart         # Signup page
│   └── auth_wrapper.dart          # Auth state management
├── models/
│   ├── expense.dart               # Updated for groups
│   ├── group.dart                 # Group model
│   ├── group_member.dart          # Member model
│   └── user_profile.dart          # User profile model
├── screens/
│   ├── group_list_screen.dart     # List all groups
│   ├── group_detail_screen.dart   # Group expenses & balances
│   └── group_add_expense_screen.dart # Add expense to group
├── services/
│   ├── group_service.dart         # Group & expense operations
│   └── supabase_service.dart      # Legacy service
├── utils/
│   └── category_icons.dart        # Category icons & colors
└── main.dart                      # App entry point
```

## 🗄️ Database Schema

### New Tables

**groups**
- id (uuid)
- name (text)
- description (text)
- created_by (uuid → auth.users)
- created_at (timestamp)

**group_members**
- id (uuid)
- group_id (uuid → groups)
- user_id (uuid → auth.users)
- joined_at (timestamp)

**profiles**
- id (uuid → auth.users)
- email (text)
- display_name (text)
- avatar_url (text)
- created_at (timestamp)

**expenses** (updated)
- id (uuid)
- group_id (uuid → groups)
- title (text)
- amount (numeric)
- category (text)
- paid_by (uuid → auth.users)
- date (date)
- note (text)
- created_at (timestamp)

## 🔒 Security

- Row Level Security (RLS) enabled on all tables
- Users can only view groups they're members of
- Users can only add expenses to their groups
- Secure authentication via Supabase Auth
- Profile auto-creation on signup

## 🚀 Setup Instructions

### 1. Run Database Schema

In Supabase SQL Editor, run:
```sql
-- Copy and paste contents of supabase_group_schema.sql
```

### 2. Enable Email Auth

In Supabase Dashboard:
1. Go to Authentication → Providers
2. Enable Email provider
3. Configure email templates (optional)

### 3. Run the App

```bash
flutter clean
flutter pub get
flutter run -d edge
```

## 📱 User Flow

### First Time User
1. Open app → See login screen
2. Click "Sign Up"
3. Enter name, email, password
4. Account created → Auto login
5. See empty groups list
6. Click "Create Group"
7. Enter group name
8. Add expenses
9. View split calculation

### Returning User
1. Open app → Auto login (session restored)
2. See list of groups
3. Click on a group
4. View expenses and balances
5. Add new expenses
6. See real-time updates

## 🎨 UI Highlights

### Login Screen
- Clean card-based design
- Email/Password fields
- Loading states
- Error handling
- Link to signup

### Group List Screen
- Floating "Create Group" button
- Card-based group list
- Empty state with icon
- Pull-to-refresh
- Logout button

### Group Detail Screen
- Gradient summary card (total expense)
- Your balance card (color-coded)
- Members list with balances
- Expenses list with paid-by info
- Floating "Add Expense" button

### Add Expense Screen
- Clean form layout
- Category dropdown with icons
- Date picker
- Amount validation
- Success feedback

## 💡 Smart Split Logic

```dart
// Calculate balances
totalExpense = sum of all expenses
sharePerPerson = totalExpense / memberCount

for each member:
  paidAmount = sum of expenses paid by member
  balance = paidAmount - sharePerPerson
  
  if balance > 0:
    member should receive money
  else if balance < 0:
    member should pay money
  else:
    member is settled up
```

## 🔄 Real-time Updates (Optional)

The app supports Supabase real-time subscriptions:

```dart
// Stream expenses
_groupService.streamGroupExpenses(groupId).listen((expenses) {
  // Update UI automatically
});
```

## 🎯 Use Cases

### Perfect For:
- ✅ Friends sharing trip expenses
- ✅ Roommates splitting bills
- ✅ Group dinners
- ✅ Shared household expenses
- ✅ Event planning
- ✅ Team outings

## 📊 Example Scenarios

### Scenario 1: Trip to Goa
- 4 friends
- Total expenses: ₹40,000
- Share per person: ₹10,000
- Friend A paid ₹15,000 → Gets back ₹5,000
- Friend B paid ₹12,000 → Gets back ₹2,000
- Friend C paid ₹8,000 → Owes ₹2,000
- Friend D paid ₹5,000 → Owes ₹5,000

### Scenario 2: Roommate Bills
- 3 roommates
- Monthly expenses: ₹15,000
- Share per person: ₹5,000
- Roommate A paid ₹9,000 (rent) → Gets back ₹4,000
- Roommate B paid ₹4,000 (groceries) → Owes ₹1,000
- Roommate C paid ₹2,000 (utilities) → Owes ₹3,000

## 🛠️ Technical Details

### State Management
- StatefulWidget with setState
- Async/await for API calls
- Mounted checks before setState
- Loading states

### API Integration
- Supabase client
- Auth methods (signUp, signIn, signOut)
- Database queries with RLS
- Real-time subscriptions (optional)

### Error Handling
- Try-catch blocks
- User-friendly error messages
- SnackBar notifications
- Validation on forms

### Responsive Design
- ConstrainedBox with maxWidth 900
- Center alignment for web
- Proper padding (16px)
- Card-based layout

## 🎓 Learning Outcomes

This project demonstrates:
- Authentication flows
- Multi-user systems
- Database relationships
- RLS policies
- Split calculation algorithms
- Modern UI/UX patterns
- State management
- Error handling
- Form validation

## 🚀 Future Enhancements

Potential additions:
- [ ] Unequal splits (custom percentages)
- [ ] Expense editing/deletion
- [ ] Group invitations via email
- [ ] Settlement tracking
- [ ] Export to PDF/CSV
- [ ] Push notifications
- [ ] Receipt image upload
- [ ] Multiple currencies
- [ ] Expense categories customization
- [ ] Group chat

## 📝 Notes

- This is a production-ready application
- All features are fully functional
- Database schema is complete
- RLS policies are configured
- UI is polished and responsive
- Code is clean and documented

## 🎉 Success!

You now have a complete group expense splitter app that:
- ✅ Handles authentication
- ✅ Manages groups and members
- ✅ Tracks expenses
- ✅ Calculates splits automatically
- ✅ Shows clear balances
- ✅ Has modern UI/UX
- ✅ Is production-ready

**Start splitting expenses smartly! 💰🎯**
