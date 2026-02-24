# SpendSmart - Project Structure

## 📁 Directory Structure

```
spend_smart/
├── lib/
│   ├── main.dart                 # App entry point & navigation
│   ├── models/
│   │   └── expense.dart          # Expense data model
│   ├── screens/
│   │   ├── home_screen.dart      # Dashboard with analytics
│   │   ├── expenses_screen.dart  # Monthly expense breakdown
│   │   ├── add_expense_screen.dart # Expense entry form
│   │   ├── calendar_screen.dart  # Date-wise expense view
│   │   ├── profile_screen.dart   # User profile & stats
│   │   └── total_expense_analytics_screen.dart # Detailed analytics
│   ├── services/
│   │   └── supabase_service.dart # Database operations
│   └── utils/
│       └── category_icons.dart   # Category icons & colors
├── android/                      # Android configuration
├── web/                          # Web configuration
├── pubspec.yaml                  # Dependencies
├── README.md                     # Main documentation
├── SETUP_GUIDE.md               # Detailed setup instructions
├── FEATURES.md                  # Feature documentation
├── QUICKSTART.md                # Quick start guide
├── supabase_schema.sql          # Database schema
└── analysis_options.yaml        # Linting rules
```

## 📄 File Descriptions

### Core Files

#### `lib/main.dart`
- App initialization
- Supabase configuration
- Main navigation setup
- Bottom navigation bar
- Theme configuration (light & dark)
- Material 3 design

#### `lib/models/expense.dart`
- Expense data model
- JSON serialization
- Type-safe data structure
- Fields:
  - id (UUID)
  - title (String)
  - amount (double)
  - category (String)
  - date (DateTime)
  - note (String?)
  - createdAt (DateTime)

#### `lib/services/supabase_service.dart`
- Database operations
- CRUD methods:
  - `getExpenses()` - Fetch all expenses
  - `getExpensesByMonth()` - Monthly expenses
  - `addExpense()` - Insert new expense
  - `getTotalExpenses()` - Calculate total
  - `getExpensesByCategory()` - Category breakdown
  - `getMonthlyExpenses()` - Year overview
- Error handling
- Data transformation

#### `lib/utils/category_icons.dart`
- Category icon mapping
- Color scheme definitions
- Category list
- Helper methods:
  - `getIcon(category)` - Returns IconData
  - `getColor(category)` - Returns Color
  - `categories` - List of all categories

### Screen Files

#### `lib/screens/home_screen.dart`
**Purpose:** Main dashboard

**Components:**
- Balance card with gradient
- Year selector
- Monthly bar chart (fl_chart)
- Recent transactions list
- Pull-to-refresh

**State:**
- `_recentExpenses` - Last 5 expenses
- `_totalBalance` - Sum of all expenses
- `_monthlyExpenses` - Map<month, amount>
- `_selectedYear` - Current year
- `_isLoading` - Loading state

**Methods:**
- `_loadData()` - Fetch all data
- `_buildBalanceCard()` - Gradient card
- `_buildAnalyticsSection()` - Chart section
- `_buildBarChart()` - Bar chart widget
- `_buildTransactionsSection()` - Transaction list

#### `lib/screens/expenses_screen.dart`
**Purpose:** Monthly expense breakdown

**Components:**
- Month selector
- Horizontal calendar strip
- Salary/Expense summary cards
- Category list with progress bars

**State:**
- `_selectedMonth` - Current month
- `_categoryExpenses` - Map<category, amount>
- `_totalExpense` - Monthly total
- `_totalSalary` - Demo value
- `_isLoading` - Loading state

**Methods:**
- `_loadData()` - Fetch monthly data
- `_changeMonth(delta)` - Navigate months
- `_buildMonthSelector()` - Month navigation
- `_buildCalendarStrip()` - Horizontal calendar
- `_buildSummaryCards()` - Salary/Expense cards
- `_buildCategoryList()` - Category breakdown

#### `lib/screens/add_expense_screen.dart`
**Purpose:** Expense entry form

**Components:**
- Title input (with voice)
- Amount input
- Category dropdown
- Date picker
- Note input
- Save button

**State:**
- Form controllers
- `_selectedCategory` - Current category
- `_selectedDate` - Selected date
- `_isLoading` - Save state
- `_speech` - Speech recognition
- `_isListening` - Voice input state

**Methods:**
- `_initSpeech()` - Initialize voice
- `_startListening()` - Start voice input
- `_stopListening()` - Stop voice input
- `_selectDate()` - Open date picker
- `_saveExpense()` - Submit form

**Validation:**
- Title: required, non-empty
- Amount: required, numeric, > 0
- Category: required (dropdown)
- Date: required (picker)
- Note: optional

#### `lib/screens/total_expense_analytics_screen.dart`
**Purpose:** Detailed expense analytics

**Components:**
- Month display
- Spending summary
- Budget progress bar
- Pie chart
- Category legend

**Props:**
- `month` - Selected month
- `totalExpense` - Total amount
- `categoryExpenses` - Category breakdown

**Methods:**
- `_buildPieChartSections()` - Pie chart data
- `_buildLegend()` - Color legend

**Calculations:**
- Budget percentage
- Remaining amount
- Category percentages

#### `lib/screens/calendar_screen.dart`
**Purpose:** Date-wise expense view

**Components:**
- Month navigation
- Calendar grid
- Expense list for selected date

**State:**
- `_selectedDate` - Current date
- `_expenses` - Monthly expenses
- `_isLoading` - Loading state

**Methods:**
- `_loadExpenses()` - Fetch monthly data
- `_getExpensesForDate()` - Filter by date
- `_buildCalendar()` - Month navigation
- `_buildCalendarGrid()` - Calendar layout
- `_buildExpenseList()` - Date expenses

#### `lib/screens/profile_screen.dart`
**Purpose:** User profile and stats

**Components:**
- Profile card
- Statistics card
- Settings options

**State:**
- `_totalExpenses` - Total amount
- `_transactionCount` - Total count
- `_isLoading` - Loading state

**Methods:**
- `_loadStats()` - Fetch statistics

## 🗄️ Database Schema

### Table: `expenses`

```sql
CREATE TABLE expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  amount NUMERIC NOT NULL CHECK (amount > 0),
  category TEXT NOT NULL CHECK (category IN ('Food', 'Shopping', 'Healthcare', 'Travel', 'Other')),
  date DATE NOT NULL,
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Indexes:**
- `idx_expenses_date` - Date descending
- `idx_expenses_category` - Category
- `idx_expenses_created_at` - Created date

**RLS Policies:**
- Allow all operations (demo mode)

## 🎨 Design Patterns

### State Management
- StatefulWidget for reactive UI
- Local state in each screen
- Service layer for data operations
- Separation of concerns

### Data Flow
```
UI → Service → Supabase → Service → UI
```

### Error Handling
```
try {
  // Operation
} catch (e) {
  if (mounted) {
    // Show error
  }
}
```

### Loading States
```
setState(() => _isLoading = true);
// Fetch data
setState(() => _isLoading = false);
```

## 📦 Dependencies

### Production
- `flutter` - Framework
- `supabase_flutter` - Backend
- `fl_chart` - Charts
- `intl` - Formatting
- `speech_to_text` - Voice input

### Development
- `flutter_test` - Testing
- `flutter_lints` - Linting

## 🔧 Configuration Files

### `pubspec.yaml`
- Package dependencies
- Asset configuration
- SDK constraints

### `analysis_options.yaml`
- Linting rules
- Code style enforcement

### `android/app/build.gradle`
- Android configuration
- Min SDK: 21
- Target SDK: 34

### `web/manifest.json`
- PWA configuration
- App metadata
- Icons

## 🎯 Code Organization

### Models
- Data structures
- JSON serialization
- Type safety

### Services
- Business logic
- API calls
- Data transformation

### Screens
- UI components
- User interactions
- State management

### Utils
- Helper functions
- Constants
- Shared utilities

## 🚀 Build Outputs

### Debug
- `build/app/outputs/flutter-apk/app-debug.apk`
- `build/web/`

### Release
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/web/` (optimized)

## 📝 Best Practices

1. **State Management**
   - Always check `mounted` before setState
   - Use const constructors
   - Minimize rebuilds

2. **Error Handling**
   - Try-catch all async operations
   - Show user-friendly messages
   - Log errors for debugging

3. **Performance**
   - Use ListView.builder for lists
   - Lazy load data
   - Cache when appropriate

4. **Code Quality**
   - Follow linting rules
   - Write readable code
   - Add comments for complex logic

5. **Security**
   - Validate all inputs
   - Use environment variables
   - Enable RLS in production

---

**Well-organized code = Happy developers! 🎉**
