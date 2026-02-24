import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../models/expense.dart';
import '../utils/category_icons.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  DateTime _selectedDate = DateTime.now();
  List<Expense> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final expenses = await _supabaseService.getExpensesByMonth(
        _selectedDate.year,
        _selectedDate.month,
      );
      
      if (mounted) {
        setState(() {
          _expenses = expenses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Expense> _getExpensesForDate(DateTime date) {
    return _expenses.where((expense) {
      return expense.date.year == date.year &&
          expense.date.month == date.month &&
          expense.date.day == date.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCalendar(),
                const Divider(),
                Expanded(
                  child: _buildExpenseList(),
                ),
              ],
            ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month - 1,
                      );
                      _isLoading = true;
                    });
                    _loadExpenses();
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month + 1,
                      );
                      _isLoading = true;
                    });
                    _loadExpenses();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCalendarGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateUtils.getDaysInMonth(
      _selectedDate.year,
      _selectedDate.month,
    );
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map((day) => SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        ...List.generate((daysInMonth + startingWeekday) ~/ 7 + 1, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - startingWeekday + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox(width: 40, height: 40);
                }

                final date = DateTime(_selectedDate.year, _selectedDate.month, dayNumber);
                final hasExpenses = _getExpensesForDate(date).isNotEmpty;
                final isToday = date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : hasExpenses
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        dayNumber.toString(),
                        style: TextStyle(
                          color: isToday
                              ? Colors.white
                              : hasExpenses
                                  ? Theme.of(context).colorScheme.onPrimaryContainer
                                  : null,
                          fontWeight: hasExpenses ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildExpenseList() {
    final dayExpenses = _getExpensesForDate(_selectedDate);

    if (dayExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses on ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dayExpenses.length,
      itemBuilder: (context, index) {
        final expense = dayExpenses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: CategoryIcons.getColor(expense.category)
                  .withOpacity(0.2),
              child: Icon(
                CategoryIcons.getIcon(expense.category),
                color: CategoryIcons.getColor(expense.category),
              ),
            ),
            title: Text(expense.title),
            subtitle: expense.note != null ? Text(expense.note!) : null,
            trailing: Text(
              '₹${NumberFormat('#,##,###.##').format(expense.amount)}',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
