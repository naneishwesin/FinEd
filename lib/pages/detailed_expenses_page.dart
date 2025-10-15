// lib/pages/detailed_expenses_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/database_service.dart';

class DetailedExpensesPage extends StatefulWidget {
  const DetailedExpensesPage({super.key});

  @override
  _DetailedExpensesPageState createState() => _DetailedExpensesPageState();
}

class _DetailedExpensesPageState extends State<DetailedExpensesPage> {
  String _searchQuery = "";

  // Database service instance
  final DatabaseService _dbService = DatabaseService();

  // Transactions list - will be loaded from database
  List<Map<String, dynamic>> _transactions = [];

  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  /// Load transactions from database
  Future<void> _loadTransactions() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final transactions = await _dbService.getTransactionsByType('expense');
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading transactions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    return _transactions.where((transaction) {
      if (_searchQuery.isNotEmpty) {
        return transaction['category'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            transaction['date'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> _getExpenseData() {
    final expenses = _transactions
        .where((t) => t['type'] == 'expense')
        .toList();
    final categories = <String, double>{};

    for (var expense in expenses) {
      final category = expense['category'].toString();
      categories[category] =
          (categories[category] ?? 0) + expense['amount'].abs();
    }

    final colors = [
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.teal,
    ];
    int colorIndex = 0;

    return categories.entries.map((entry) {
      return {
        'category': entry.key,
        'amount': entry.value,
        'color': colors[colorIndex++ % colors.length],
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Detailed Expenses"),
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
            // Donut Chart Section
            Container(
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
                  Row(
                    children: [
                      // Donut Chart
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 120,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 30,
                              sections: _getExpenseData().map((item) {
                                final percentage =
                                    ((item['amount'] /
                                        _getExpenseData().fold(
                                          0.0,
                                          (sum, item) => sum + item['amount'],
                                        )) *
                                    100);
                                return PieChartSectionData(
                                  color: item['color'],
                                  value: item['amount'],
                                  title: percentage > 5
                                      ? '${percentage.toStringAsFixed(0)}%'
                                      : '',
                                  radius: 40,
                                  titleStyle: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Legend
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _getExpenseData().map((item) {
                            final percentage =
                                ((item['amount'] /
                                    _getExpenseData().fold(
                                      0.0,
                                      (sum, item) => sum + item['amount'],
                                    )) *
                                100);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: item['color'],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item['category'],
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Monthly Usage Section
            Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Monthly Usage",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.calendar_month,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search bar
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search expenses...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Transactions list
                  if (_filteredTransactions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No expenses found",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._filteredTransactions.map(
                      (transaction) => _transactionItem(transaction),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionItem(Map<String, dynamic> transaction) {
    final amount = transaction['amount'].abs();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_downward, color: Colors.red[600], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['category'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction['date'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "-฿${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }
}
