import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/personal_expense.dart';
import '../services/supabase_service.dart';
import '../widgets/summary_card.dart';
import '../widgets/section_header.dart';

class PersonalAnalyticsScreen extends StatefulWidget {
  const PersonalAnalyticsScreen({super.key});

  @override
  State<PersonalAnalyticsScreen> createState() => _PersonalAnalyticsScreenState();
}

class _PersonalAnalyticsScreenState extends State<PersonalAnalyticsScreen> {
  final SupabaseService _service = SupabaseService();
  List<PersonalExpense> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    try {
      final expenses = await _service.getPersonalExpenses();
      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading expenses: $e')),
        );
      }
    }
  }

  Map<String, double> _getCategoryTotals() {
    final Map<String, double> totals = {};
    for (var expense in _expenses) {
      final category = expense.category ?? 'Other';
      totals[category] = (totals[category] ?? 0) + expense.amount;
    }
    return totals;
  }

  Map<String, double> _getWeeklyTotals() {
    final Map<String, double> totals = {};
    final now = DateTime.now();
    
    for (var expense in _expenses) {
      final daysAgo = now.difference(expense.createdAt).inDays;
      if (daysAgo <= 30) {
        final weekKey = 'Week ${(daysAgo / 7).floor() + 1}';
        totals[weekKey] = (totals[weekKey] ?? 0) + expense.amount;
      }
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final total = _expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final categoryTotals = _getCategoryTotals();
    final weeklyTotals = _getWeeklyTotals();
    final topCategory = categoryTotals.entries.isEmpty
        ? null
        : categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Analytics'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Total Spent',
                        value: '₹${total.toStringAsFixed(0)}',
                        icon: Icons.account_balance_wallet,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SummaryCard(
                        title: 'Transactions',
                        value: _expenses.length.toString(),
                        icon: Icons.receipt_long,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SummaryCard(
                        title: 'Top Category',
                        value: topCategory?.key ?? 'N/A',
                        icon: Icons.trending_up,
                        color: Colors.green,
                        subtitle: topCategory != null
                            ? '₹${topCategory.value.toStringAsFixed(0)}'
                            : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Category Breakdown
                if (categoryTotals.isNotEmpty) ...[
                  const SectionHeader(
                    title: 'Category Breakdown',
                    subtitle: 'Your spending by category',
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        height: 300,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 60,
                                  sections: _buildPieChartSections(categoryTotals),
                                ),
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: _buildLegend(categoryTotals),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Weekly Trend
                if (weeklyTotals.isNotEmpty) ...[
                  const SectionHeader(
                    title: 'Weekly Trend',
                    subtitle: 'Last 4 weeks spending',
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        height: 300,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: weeklyTotals.values.reduce((a, b) => a > b ? a : b) * 1.2,
                            barGroups: _buildBarGroups(weeklyTotals),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '₹${value.toInt()}',
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final keys = weeklyTotals.keys.toList();
                                    if (value.toInt() < keys.length) {
                                      return Text(
                                        keys[value.toInt()],
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                            ),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                if (_expenses.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48.0),
                      child: Column(
                        children: [
                          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No data to analyze yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Start adding expenses to see analytics',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> data) {
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    int index = 0;
    return data.entries.map((entry) {
      final color = colors[index % colors.length];
      index++;
      return PieChartSectionData(
        value: entry.value,
        title: '${((entry.value / data.values.reduce((a, b) => a + b)) * 100).toStringAsFixed(0)}%',
        color: color,
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(Map<String, double> data) {
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    int index = 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((entry) {
        final color = colors[index % colors.length];
        index++;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Text(
                '₹${entry.value.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, double> data) {
    int index = 0;
    return data.entries.map((entry) {
      final group = BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.purple,
            width: 32,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ],
      );
      index++;
      return group;
    }).toList();
  }
}
