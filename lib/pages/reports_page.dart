// lib/pages/reports_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/database_service.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedPeriod = 'Quarter';
  final List<String> _periods = ['Month', 'Quarter', 'Year'];

  // Database service instance
  final DatabaseService _dbService = DatabaseService();

  // Loading state
  bool _isLoading = true;

  // Dynamic data from database
  Map<String, double> _incomeData = {};
  Map<String, double> _expenseData = {};
  List<Map<String, dynamic>> _categoryData = [];

  @override
  void initState() {
    super.initState();
    _loadReportsData();
  }

  /// Load reports data from database
  Future<void> _loadReportsData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load income and expense data for different periods
      final totalIncome = await _dbService.getTotalIncome();
      final totalExpenses = await _dbService.getTotalExpenses();

      // Calculate data for different periods (simplified calculation)
      _incomeData = {
        'Month': totalIncome / 12,
        'Quarter': totalIncome / 4,
        'Year': totalIncome,
      };

      _expenseData = {
        'Month': totalExpenses / 12,
        'Quarter': totalExpenses / 4,
        'Year': totalExpenses,
      };

      // Load category spending data
      _categoryData = await _getCategorySpendingData();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reports data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Get category spending data from database
  Future<List<Map<String, dynamic>>> _getCategorySpendingData() async {
    try {
      final spendingByCategory = await _dbService.getSpendingByCategory();
      final colors = [
        Colors.red,
        Colors.blue,
        Colors.orange,
        Colors.purple,
        Colors.green,
        Colors.grey,
      ];

      // Debug logging
      final totalCategorySpending = spendingByCategory.values.fold(
        0.0,
        (sum, amount) => sum + amount,
      );
      print('Category spending data: $spendingByCategory');
      print('Total category spending: $totalCategorySpending');

      int colorIndex = 0;
      return spendingByCategory.entries.map((entry) {
        return {
          'category': entry.key,
          'amount': entry.value,
          'color': colors[colorIndex++ % colors.length],
        };
      }).toList();
    } catch (e) {
      print('Error getting category data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    double totalIncome = _incomeData[_selectedPeriod] ?? 0.0;
    double totalExpense = _expenseData[_selectedPeriod] ?? 0.0;
    double netSavings = totalIncome - totalExpense;

    // Debug logging for chart data validation
    final totalCategorySpending = _categoryData.fold(
      0.0,
      (sum, category) => sum + category['amount'],
    );
    print('Reports Debug - Period: $_selectedPeriod');
    print('Total Income: $totalIncome');
    print('Total Expense: $totalExpense');
    print('Total Category Spending: $totalCategorySpending');
    print('Category Data: $_categoryData');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Period Selection
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: _periods.map((period) {
                  final isSelected = period == _selectedPeriod;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPeriod = period;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: Colors.blue, width: 2)
                              : null,
                        ),
                        child: Text(
                          period,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.black87
                                : Colors.grey[600],
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Net Savings Card (Top Left)
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    "Net Savings",
                    Icons.savings,
                    netSavings,
                    [Colors.purple[300]!, Colors.blue[400]!],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    "Total Income",
                    Icons.arrow_upward,
                    totalIncome,
                    [Colors.green[400]!, Colors.green[600]!],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Total Expenses Card (Full Width)
            _buildSummaryCard(
              "Total Expenses",
              Icons.arrow_downward,
              totalExpense,
              [Colors.orange[400]!, Colors.red[400]!],
            ),

            const SizedBox(height: 20),

            // Income vs Expenses Chart
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Income vs Expenses",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (totalIncome * 1.2).roundToDouble(),
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 0:
                                    return const Text('Income');
                                  case 1:
                                    return const Text('Expenses');
                                  case 2:
                                    return const Text('Savings');
                                  default:
                                    return const Text('');
                                }
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '฿${(value / 1000).toStringAsFixed(0)}k',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: totalIncome,
                                color: Colors.green,
                                width: 40,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: totalExpense,
                                color: Colors.red,
                                width: 40,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: netSavings,
                                color: netSavings >= 0
                                    ? Colors.blue
                                    : Colors.orange,
                                width: 40,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Expense Categories Chart
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Expense Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    child: RepaintBoundary(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: _categoryData.map((category) {
                            // Ensure percentage doesn't exceed 100% due to data inconsistencies
                            final percentage = totalExpense > 0
                                ? ((category['amount'] / totalExpense) * 100)
                                      .clamp(0.0, 100.0)
                                : 0.0;
                            return PieChartSectionData(
                              color: category['color'],
                              value: category['amount'],
                              title: percentage > 5
                                  ? '${percentage.toStringAsFixed(0)}%'
                                  : '',
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Legend
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: _categoryData.map((category) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: category['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            category['category'],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Financial Insights Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple[300]!, Colors.blue[400]!],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Financial Insights",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInsightCard(
                    "Savings Rate",
                    "${((netSavings / totalIncome) * 100).toStringAsFixed(1)}%",
                    netSavings > 0
                        ? "Great job saving money!"
                        : "Consider reducing expenses",
                    netSavings > 0 ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildInsightCard(
                    "Top Expense",
                    _categoryData.isNotEmpty
                        ? _categoryData.first['category']
                        : "No expenses",
                    _categoryData.isNotEmpty
                        ? "฿${_categoryData.first['amount'].toStringAsFixed(0)} this ${_selectedPeriod.toLowerCase()}"
                        : "No data available",
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildInsightCard(
                    "Trend",
                    "Monthly Average",
                    "฿${(totalIncome / 6).toStringAsFixed(0)} income, ฿${(totalExpense / 6).toStringAsFixed(0)} expenses",
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    IconData icon,
    double amount,
    List<Color> colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  "฿${amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    String title,
    String value,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
