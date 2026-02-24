# SpendSmart - Application Flow Diagram

## 🗺️ Navigation Structure

```
┌─────────────────────────────────────────────────────────────┐
│                     SpendSmart App                          │
│                   (Bottom Navigation)                        │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
   ┌────────┐           ┌──────────┐         ┌──────────┐
   │  Home  │           │ Expenses │         │   Add    │
   │   🏠   │           │    💰    │         │    ➕    │
   └────────┘           └──────────┘         └──────────┘
        │                     │                     │
        │                     ▼                     │
        │            ┌─────────────────┐           │
        │            │   Analytics     │           │
        │            │      📊         │           │
        │            └─────────────────┘           │
        │                                          │
        ▼                                          ▼
   ┌──────────┐                            ┌──────────┐
   │ Calendar │                            │ Profile  │
   │    📅    │                            │    👤    │
   └──────────┘                            └──────────┘
```

## 📱 Screen Flow Details

### 1. Home Screen Flow
```
Home Screen
    │
    ├─→ View Balance Card
    │   └─→ Shows total expenses
    │
    ├─→ Select Year (Dropdown)
    │   └─→ Updates bar chart
    │
    ├─→ View Bar Chart
    │   └─→ Shows monthly expenses
    │
    ├─→ View Recent Transactions
    │   └─→ Last 5 expenses
    │
    └─→ Pull to Refresh
        └─→ Reloads all data
```

### 2. Expenses Screen Flow
```
Expenses Screen
    │
    ├─→ Change Month (◀ ▶)
    │   └─→ Updates all data
    │
    ├─→ View Calendar Strip
    │   └─→ Shows days of month
    │
    ├─→ View Summary Cards
    │   ├─→ Total Salary (static)
    │   └─→ Total Expense (tap)
    │       └─→ Opens Analytics Screen
    │
    └─→ View Category List
        └─→ Shows breakdown with progress
```

### 3. Analytics Screen Flow
```
Total Expense Analytics Screen
    │
    ├─→ View Month Display
    │
    ├─→ View Spending Summary
    │   └─→ "You have spent ₹X"
    │
    ├─→ View Budget Progress
    │   └─→ Progress bar with %
    │
    ├─→ View Pie Chart
    │   └─→ Category breakdown
    │
    ├─→ View Legend
    │   └─→ Category amounts
    │
    └─→ Back Button
        └─→ Returns to Expenses
```

### 4. Add Expense Screen Flow
```
Add Expense Screen
    │
    ├─→ Enter Title
    │   └─→ Optional: Voice Input 🎤
    │
    ├─→ Enter Amount
    │   └─→ Validates > 0
    │
    ├─→ Select Category
    │   └─→ Dropdown with icons
    │
    ├─→ Select Date
    │   └─→ Opens date picker
    │
    ├─→ Enter Note (optional)
    │
    └─→ Save Button
        ├─→ Validates form
        ├─→ Saves to Supabase
        ├─→ Shows success message
        └─→ Clears form
```

### 5. Calendar Screen Flow
```
Calendar Screen
    │
    ├─→ Change Month (◀ ▶)
    │   └─→ Updates calendar
    │
    ├─→ View Calendar Grid
    │   ├─→ Shows all days
    │   └─→ Highlights expense days
    │
    ├─→ Select Date
    │   └─→ Shows expenses for that day
    │
    └─→ View Expense List
        └─→ Filtered by selected date
```

### 6. Profile Screen Flow
```
Profile Screen
    │
    ├─→ View Profile Card
    │   ├─→ Avatar
    │   ├─→ Name
    │   └─→ Email
    │
    ├─→ View Statistics
    │   ├─→ Total Expenses
    │   ├─→ Transaction Count
    │   └─→ Member Since
    │
    └─→ View Options
        ├─→ Settings
        ├─→ Help & Support
        └─→ About (tap)
            └─→ Shows app info dialog
```

## 🔄 Data Flow

### Adding an Expense
```
User Input
    │
    ▼
Form Validation
    │
    ▼
Supabase Service
    │
    ▼
Supabase Database
    │
    ▼
Success Response
    │
    ▼
UI Update
    │
    ▼
Success Message
```

### Loading Data
```
Screen Loads
    │
    ▼
Show Loading Indicator
    │
    ▼
Supabase Service
    │
    ▼
Fetch from Database
    │
    ▼
Process Data
    │
    ▼
Update State
    │
    ▼
Hide Loading Indicator
    │
    ▼
Display Data
```

### Error Handling
```
Operation Starts
    │
    ▼
Try Block
    │
    ├─→ Success
    │   └─→ Update UI
    │
    └─→ Error
        └─→ Catch Block
            └─→ Show Error Message
```

## 🎨 UI Component Hierarchy

### Home Screen Components
```
HomeScreen
├── AppBar
│   ├── Avatar (left)
│   └── Notification Icon (right)
├── ScrollView
│   ├── Balance Card
│   │   ├── Title
│   │   └── Amount
│   ├── Analytics Section
│   │   ├── Header Row
│   │   │   ├── "Analytics" Text
│   │   │   └── Year Dropdown
│   │   └── Bar Chart Card
│   └── Transactions Section
│       ├── Header Row
│       │   ├── "Recent Transactions" Text
│       │   └── "View All" Button
│       └── Transaction List
│           └── Transaction Cards
└── Bottom Navigation
```

### Add Expense Components
```
AddExpenseScreen
├── AppBar
│   └── Title
├── ScrollView
│   └── Form Card
│       ├── Title Field
│       │   └── Voice Button
│       ├── Amount Field
│       ├── Category Dropdown
│       ├── Date Picker
│       ├── Note Field
│       └── Save Button
└── Bottom Navigation
```

## 🗄️ Database Operations

### CRUD Operations Flow
```
CREATE (Add Expense)
    User → Form → Validation → Service → Database → Success

READ (Get Expenses)
    Screen → Service → Database → Transform → State → UI

UPDATE (Future Feature)
    User → Form → Validation → Service → Database → Success

DELETE (Future Feature)
    User → Confirm → Service → Database → Success
```

## 📊 Chart Data Flow

### Bar Chart
```
Select Year
    │
    ▼
Fetch Monthly Data
    │
    ▼
Calculate Totals per Month
    │
    ▼
Format for Chart
    │
    ▼
Render Bar Chart
```

### Pie Chart
```
Select Month
    │
    ▼
Fetch Category Data
    │
    ▼
Calculate Category Totals
    │
    ▼
Calculate Percentages
    │
    ▼
Format for Chart
    │
    ▼
Render Pie Chart
```

## 🔐 Security Flow

### RLS (Row Level Security)
```
Client Request
    │
    ▼
Supabase API
    │
    ▼
RLS Policy Check
    │
    ├─→ Allowed
    │   └─→ Execute Query
    │
    └─→ Denied
        └─→ Return Error
```

## 🎯 User Journey

### First Time User
```
1. Open App
    ↓
2. See Empty State
    ↓
3. Click "Add" Tab
    ↓
4. Fill Expense Form
    ↓
5. Save Expense
    ↓
6. See Success Message
    ↓
7. View in Home Screen
    ↓
8. Explore Charts
```

### Returning User
```
1. Open App
    ↓
2. View Dashboard
    ↓
3. Check Balance
    ↓
4. View Charts
    ↓
5. Add New Expense
    ↓
6. View Analytics
    ↓
7. Check Calendar
```

## 🔄 State Management Flow

### Screen State Lifecycle
```
initState()
    │
    ▼
Load Data
    │
    ▼
setState() - Loading
    │
    ▼
Fetch from Database
    │
    ▼
setState() - Data Loaded
    │
    ▼
Build UI
    │
    ▼
User Interaction
    │
    ▼
setState() - Update
    │
    ▼
Rebuild UI
```

## 📱 Platform-Specific Flow

### Web
```
Browser → Flutter Web → Supabase → Response → Update UI
```

### Android
```
Android App → Flutter Engine → Supabase → Response → Update UI
```

### iOS
```
iOS App → Flutter Engine → Supabase → Response → Update UI
```

## 🎨 Theme Flow

### Light/Dark Mode
```
System Theme
    │
    ▼
App Theme Mode
    │
    ├─→ Light Theme
    │   └─→ Light Colors
    │
    └─→ Dark Theme
        └─→ Dark Colors
```

## 🔍 Search & Filter Flow (Future)

### Potential Enhancement
```
Search Input
    │
    ▼
Filter Expenses
    │
    ├─→ By Title
    ├─→ By Category
    ├─→ By Date Range
    └─→ By Amount Range
    │
    ▼
Display Filtered Results
```

## 📈 Analytics Calculation Flow

### Monthly Total
```
Select Month
    │
    ▼
Get Start Date (1st of month)
    │
    ▼
Get End Date (last day of month)
    │
    ▼
Query Database (date range)
    │
    ▼
Sum All Amounts
    │
    ▼
Display Total
```

### Category Breakdown
```
Select Month
    │
    ▼
Fetch All Expenses
    │
    ▼
Group by Category
    │
    ▼
Sum Each Category
    │
    ▼
Calculate Percentages
    │
    ▼
Display Breakdown
```

---

**This flow diagram helps visualize how SpendSmart works! 🗺️**
