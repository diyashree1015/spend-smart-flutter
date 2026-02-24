# 📝 Personal Expenses Feature - Complete Guide

## ✨ Overview

The Personal Expenses feature allows users to track their individual expenses separately from group expenses. This is perfect for tracking daily personal spending like coffee, transport, groceries, etc.

## 🎯 Features Implemented

### 1. Personal Expense Model
- **File:** `lib/models/personal_expense.dart`
- **Fields:**
  - `id` - Unique identifier (UUID)
  - `title` - Expense name
  - `amount` - Expense amount (double)
  - `category` - Optional category (String?)
  - `createdAt` - Timestamp

### 2. Service Methods
- **File:** `lib/services/supabase_service.dart`
- **Methods:**
  - `addPersonalExpense()` - Add new expense
  - `getPersonalExpenses()` - Fetch all user expenses
  - `deletePersonalExpense()` - Delete expense by ID
  - `getTotalPersonalExpenses()` - Calculate total

### 3. Personal Expense Screen
- **File:** `lib/screens/personal_expense_screen.dart`
- **Features:**
  - Total spent card (gradient)
  - Expense list with cards
  - Add expense dialog
  - Delete confirmation
  - Empty state
  - Pull-to-refresh
  - Loading states

### 4. Navigation
- Added "Personal Expenses" button in Group List Screen AppBar
- Icon: Person icon
- Opens Personal Expense Screen

## 🗄️ Database Schema

### Table: `personal_expenses`

```sql
CREATE TABLE personal_expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  amount NUMERIC NOT NULL CHECK (amount > 0),
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Row Level Security (RLS)

✅ **Enabled** - Users can only access their own expenses

**Policies:**
- SELECT: Users can view own expenses
- INSERT: Users can add own expenses
- UPDATE: Users can update own expenses
- DELETE: Users can delete own expenses

### Indexes

```sql
CREATE INDEX idx_personal_expenses_user_id ON personal_expenses(user_id);
CREATE INDEX idx_personal_expenses_created_at ON personal_expenses(created_at DESC);
```

## 📱 User Interface

### Total Card
- **Gradient background** (primary → secondary)
- **Large amount display** (₹ format)
- **Expense count** below amount
- **Rounded corners** (16px)
- **Elevation** (4)

### Expense Cards
- **Title** (bold, 16px)
- **Category** (if provided)
- **Timestamp** (formatted: MMM dd, yyyy - hh:mm a)
- **Amount** (red, bold, 18px)
- **Delete button** (icon)
- **Rounded corners** (16px)
- **Elevation** (2)

### Add Expense Dialog
- **Title field** (required)
- **Amount field** (required, numeric)
- **Category field** (optional)
- **Cancel button**
- **Add button** (with loading state)
- **Validation** (title & amount required)
- **Rounded corners** (16px)

### Empty State
- **Large icon** (receipt_long_outlined, 80px)
- **Message:** "No personal expenses yet"
- **Subtitle:** "Tap the + button to add your first expense"
- **Gray colors** for subtle appearance

## 🔄 User Flow

### Adding an Expense

1. User clicks "Personal Expenses" icon in AppBar
2. Screen loads with existing expenses
3. User clicks FAB "Add Expense"
4. Dialog appears with form
5. User enters:
   - Title (e.g., "Coffee")
   - Amount (e.g., "150")
   - Category (optional, e.g., "Food")
6. User clicks "Add"
7. Button shows loading spinner
8. Expense saved to Supabase
9. Dialog closes
10. Success SnackBar appears
11. List refreshes automatically
12. New expense appears at top

### Deleting an Expense

1. User clicks delete icon on expense card
2. Confirmation dialog appears
3. User confirms deletion
4. Expense deleted from Supabase
5. Success SnackBar appears
6. List refreshes automatically
7. Expense removed from view
8. Total recalculated

### Viewing Expenses

1. User opens Personal Expense Screen
2. Loading indicator shown
3. Expenses fetched from Supabase
4. Total calculated
5. UI updates with data
6. User can scroll through list
7. Pull down to refresh

## 🎨 Design Highlights

### Colors
- **Total Card:** Gradient (primary → secondary)
- **Expense Amount:** Red (#D32F2F)
- **Delete Icon:** Red
- **Success SnackBar:** Green
- **Error SnackBar:** Red
- **Empty State:** Gray

### Typography
- **Total Amount:** 36px, bold, white
- **Expense Title:** 16px, bold
- **Expense Amount:** 18px, bold, red
- **Category:** 12px, gray
- **Timestamp:** 12px, light gray

### Spacing
- **Screen Padding:** 16px
- **Card Margin:** 12px bottom
- **Card Padding:** 16px
- **Dialog Padding:** 16px between fields

### Borders
- **Cards:** 16px radius
- **Dialog:** 16px radius
- **SnackBar:** 12px radius
- **Input Fields:** 12px radius

## 🔧 Technical Implementation

### State Management
```dart
List<PersonalExpense> _expenses = [];
bool _isLoading = true;
double _totalExpense = 0.0;
```

### Loading Data
```dart
Future<void> _loadExpenses() async {
  final expenses = await _supabaseService.getPersonalExpenses();
  final total = expenses.fold<double>(
    0.0,
    (sum, expense) => sum + expense.amount,
  );
  setState(() {
    _expenses = expenses;
    _totalExpense = total;
    _isLoading = false;
  });
}
```

### Adding Expense
```dart
await _supabaseService.addPersonalExpense(
  title,
  amount,
  category,
);
```

### Deleting Expense
```dart
await _supabaseService.deletePersonalExpense(expense.id);
```

## 📊 Data Flow

```
User Action
    ↓
UI Event (FAB click, Delete click)
    ↓
Service Method Call
    ↓
Supabase API Request
    ↓
Database Operation (INSERT/SELECT/DELETE)
    ↓
RLS Policy Check
    ↓
Response
    ↓
Service Method Return
    ↓
UI Update (setState)
    ↓
User Feedback (SnackBar)
```

## 🔒 Security

### Authentication Required
- User must be logged in
- User ID from `Supabase.instance.client.auth.currentUser!.id`

### Row Level Security
- Users can only see their own expenses
- Users can only modify their own expenses
- Enforced at database level

### Validation
- Title: Required, non-empty
- Amount: Required, numeric, > 0
- Category: Optional

## 📱 Responsive Design

### Web (Desktop)
- Max width: 900px
- Centered layout
- Proper spacing

### Mobile
- Full width
- Touch-friendly buttons
- Scrollable lists

## 🎯 Use Cases

### Personal Tracking
- Daily coffee expenses
- Transport costs
- Grocery shopping
- Entertainment
- Utilities
- Subscriptions

### Separate from Groups
- Track personal expenses separately
- Don't mix with group expenses
- Clear distinction
- Independent totals

## 💡 Future Enhancements

Potential additions:
- [ ] Edit expense functionality
- [ ] Category filtering
- [ ] Date range filtering
- [ ] Export to CSV/PDF
- [ ] Charts and analytics
- [ ] Budget tracking
- [ ] Recurring expenses
- [ ] Receipt image upload
- [ ] Search functionality
- [ ] Sort options

## 🚀 Testing

### Manual Testing Steps

1. **Add Expense:**
   - Click Personal Expenses icon
   - Click FAB
   - Enter title, amount, category
   - Click Add
   - Verify expense appears
   - Verify total updates

2. **Delete Expense:**
   - Click delete icon
   - Confirm deletion
   - Verify expense removed
   - Verify total updates

3. **Empty State:**
   - Delete all expenses
   - Verify empty state shows
   - Verify message displays

4. **Validation:**
   - Try adding without title
   - Try adding without amount
   - Try adding negative amount
   - Verify error messages

5. **Refresh:**
   - Pull down to refresh
   - Verify loading indicator
   - Verify data reloads

## 📝 SQL Setup Instructions

### Step 1: Run Schema
```sql
-- Copy contents of personal_expenses_schema.sql
-- Paste in Supabase SQL Editor
-- Click Run
```

### Step 2: Verify Table
```sql
SELECT * FROM personal_expenses;
```

### Step 3: Check RLS
```sql
SELECT * FROM pg_policies WHERE tablename = 'personal_expenses';
```

### Step 4: Test Insert
```sql
-- Will fail if not authenticated
INSERT INTO personal_expenses (user_id, title, amount, category)
VALUES (auth.uid(), 'Test', 100, 'Test');
```

## 🎉 Success Criteria

The feature is complete when:
- ✅ Table created in Supabase
- ✅ RLS policies enabled
- ✅ Model created
- ✅ Service methods implemented
- ✅ Screen created
- ✅ Navigation added
- ✅ Add expense works
- ✅ Delete expense works
- ✅ Total calculation works
- ✅ Empty state shows
- ✅ Loading states work
- ✅ Error handling works
- ✅ UI is polished

## 📊 Statistics

**Files Created:** 3
- `lib/models/personal_expense.dart`
- `lib/screens/personal_expense_screen.dart`
- `personal_expenses_schema.sql`

**Files Modified:** 2
- `lib/services/supabase_service.dart`
- `lib/screens/group_list_screen.dart`

**Lines of Code:** ~500+

**Features:** 8
- Add expense
- View expenses
- Delete expense
- Calculate total
- Empty state
- Loading states
- Error handling
- Navigation

---

**Personal Expenses feature is complete and ready to use! 📝✨**
