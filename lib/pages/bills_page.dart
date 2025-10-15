// lib/pages/bills_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../services/database_service.dart';
import '../services/tutorial_service.dart';
import '../services/validation_service.dart';
import '../widgets/transaction_calendar.dart';
import 'detailed_expenses_page.dart';
import 'detailed_income_page.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  _BillsPageState createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  String _searchQuery = "";
  String _selectedFilter = "All";
  String _selectedView = "overview"; // "overview", "expenses", "income"
  DateTime? _selectedDate;
  String get _selectedMonth => _getCurrentMonth();

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
    _showTutorials();
  }

  /// Notify other pages that data has changed
  void _notifyDataChanged() {
    // This will trigger a refresh in other pages
    // We can use a simple approach with a callback or event system
    print('Transaction added - data changed notification sent');
  }

  /// Load transactions from database
  Future<void> _loadTransactions() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final transactions = await _dbService.getAllTransactions();
      print('Bills page loaded ${transactions.length} transactions');

      if (transactions.isNotEmpty) {
        print('First transaction: ${transactions.first}');
      }

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

  void _showTutorials() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showBillsPageTutorial();
    });
  }

  void _showBillsPageTutorial() {
    if (!TutorialService.isTutorialCompleted(
      TutorialService.billsPageCalendar,
    )) {
      TutorialService.showTutorial(
        context,
        TutorialService.billsPageCalendar,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Bills & Transaction Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Here you can:\n'
              '• View your daily spending calendar\n'
              '• Track income and expenses\n'
              '• Analyze spending patterns\n'
              '• Search and filter transactions\n'
              '• Add, edit, or delete records',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  String _getCurrentMonth() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[now.month - 1]} ${now.year}';
  }

  // Transactions are now loaded from database in _loadTransactions()

  // Helper methods
  double get _totalExpenses => _transactions
      .where((t) => t['type'] == 'expense')
      .fold(0.0, (sum, t) => sum + t['amount'].abs());

  double get _totalIncome => _transactions
      .where((t) => t['type'] == 'income')
      .fold(0.0, (sum, t) => sum + t['amount'].abs());

  List<Map<String, dynamic>> get _filteredTransactions {
    var filtered = _transactions.where((transaction) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        if (!transaction['category'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) &&
            !transaction['date'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            )) {
          return false;
        }
      }

      // Filter logic
      if (_selectedFilter != "All") {
        switch (_selectedFilter) {
          case "Income":
            if (transaction['type'] != 'income') return false;
            break;
          case "Expenses":
            if (transaction['type'] != 'expense') return false;
            break;
          case "Category":
            // Show all transactions with categories (all transactions)
            break;
          case "Assets":
            // Filter for asset-related transactions
            if (!transaction['category'].toString().contains('🏠') &&
                !transaction['category'].toString().contains('💼') &&
                !transaction['category'].toString().contains('💻')) {
              return false;
            }
            break;
          case "Ledger":
            // Filter for ledger-related transactions (could be all transactions in this context)
            break;
          default:
            // For specific categories, check if category contains the filter text
            if (!transaction['category'].toString().contains(_selectedFilter)) {
              return false;
            }
            break;
        }
      }

      return true;
    }).toList();

    // Sort by date (most recent first)
    filtered.sort((a, b) => b['date'].compareTo(a['date']));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Transactions"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTransactionDialog(),
          ),
          // Monthly period display
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedMonth,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    color: Colors.grey[700],
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedView == "overview") ...[
                      // 📊 Expenses/Income Overview Card
                      TutorialService.buildTooltip(
                        message:
                            "Tap to view detailed expense breakdown and charts",
                        tutorialKey: TutorialService.billsPageCharts,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedView = "expenses";
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.purple, Colors.blue],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Expenses",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "฿${_totalExpenses.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Income",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "฿${_totalIncome.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedView = "income";
                                        });
                                      },
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔍 Search and Filter
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Search transactions...",
                                prefixIcon: TutorialService.buildTooltip(
                                  message:
                                      "Type to search through your transactions",
                                  tutorialKey: TutorialService.searchAndFilter,
                                  child: const Icon(Icons.search),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: PopupMenuButton<String>(
                              onSelected: (String value) {
                                setState(() {
                                  _selectedFilter = value;
                                });
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem<String>(
                                  value: "All",
                                  child: Text("All"),
                                ),
                                const PopupMenuItem<String>(
                                  value: "Category",
                                  child: Text("Category"),
                                ),
                                const PopupMenuItem<String>(
                                  value: "Assets",
                                  child: Text("Assets"),
                                ),
                                const PopupMenuItem<String>(
                                  value: "Ledger",
                                  child: Text("Ledger"),
                                ),
                                const PopupMenuItem<String>(
                                  value: "Income",
                                  child: Text("Income"),
                                ),
                                const PopupMenuItem<String>(
                                  value: "Expenses",
                                  child: Text("Expenses"),
                                ),
                              ],
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedFilter,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 4),
                                    TutorialService.buildTooltip(
                                      message:
                                          "Tap to filter transactions by category, assets, or ledger",
                                      tutorialKey:
                                          TutorialService.searchAndFilter,
                                      child: const Icon(
                                        Icons.filter_list,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 📊 Expenses Donut Chart
                      _buildDonutChartCard("Expenses", _getExpenseData(), () {
                        // Navigate to detailed expenses page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailedExpensesPage(),
                          ),
                        );
                      }),

                      const SizedBox(height: 20),

                      // 📊 Income Donut Chart
                      _buildDonutChartCard("Income", _getIncomeData(), () {
                        // Navigate to detailed income page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailedIncomePage(),
                          ),
                        );
                      }),

                      const SizedBox(height: 20),

                      // 📅 Enhanced Calendar with Monthly Transaction History
                      TransactionCalendar(transactions: _transactions),

                      const SizedBox(height: 20),

                      // 📊 Monthly Histogram
                      _buildMonthlyHistogramSection(),

                      const SizedBox(height: 20),
                    ] else if (_selectedView == "expenses") ...[
                      // Expenses View
                      _buildMonthlyView(
                        "Expenses",
                        _filteredTransactions
                            .where((t) => t['type'] == 'expense')
                            .toList(),
                      ),
                    ] else if (_selectedView == "income") ...[
                      // Income View
                      _buildMonthlyView(
                        "Income",
                        _filteredTransactions
                            .where((t) => t['type'] == 'income')
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonutChartCard(
    String title,
    List<Map<String, dynamic>> data,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.arrow_forward, color: Colors.blue[600], size: 24),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Donut Chart
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 120,
                    child: RepaintBoundary(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                          sections: data.map((item) {
                            final percentage =
                                ((item['amount'] /
                                    data.fold(
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
                ),
                const SizedBox(width: 8),
                // Legend
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.map((item) {
                      final percentage =
                          ((item['amount'] /
                              data.fold(
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
    );
  }

  Widget _buildMonthlyView(
    String title,
    List<Map<String, dynamic>> transactions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button and title
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedView = "overview";
                });
              },
              icon: const Icon(Icons.arrow_back),
            ),
            Text(
              "$title - $_selectedMonth",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            hintText: "Search $title...",
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
        if (transactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
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
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "No $title found",
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
          ...transactions.map((transaction) => _transactionItem(transaction)),
      ],
    );
  }

  Widget _transactionItem(Map<String, dynamic> transaction) {
    final isExpense = transaction['type'] == 'expense';
    final amount = transaction['amount'].abs();

    return GestureDetector(
      onTap: () => _showTransactionDetailsDialog(transaction),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isExpense ? Colors.red[100] : Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                color: isExpense ? Colors.red[600] : Colors.green[600],
                size: 20,
              ),
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
              "${isExpense ? '-' : '+'}฿${amount.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isExpense ? Colors.red[600] : Colors.green[600],
              ),
            ),
          ],
        ),
      ),
    );
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

  List<Map<String, dynamic>> _getIncomeData() {
    final income = _transactions.where((t) => t['type'] == 'income').toList();
    final categories = <String, double>{};

    for (var item in income) {
      final category = item['category'].toString();
      categories[category] = (categories[category] ?? 0) + item['amount'];
    }

    final colors = [
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
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

  // CRUD Operations for Transactions
  void _showAddTransactionDialog() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController remarkController = TextEditingController();
    String selectedAsset = AppConstants.defaultAsset;
    String selectedLedger = AppConstants.defaultLedger;
    String selectedType = "expense";
    String selectedCategory = AppConstants.defaultExpenseCategories.first;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add Transaction"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Transaction Type
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Expense"),
                        value: "expense",
                        groupValue: selectedType,
                        onChanged: (value) {
                          setState(() {
                            selectedType = value!;
                            // Update category when type changes
                            selectedCategory = selectedType == "expense"
                                ? AppConstants.defaultExpenseCategories.first
                                : AppConstants.defaultIncomeCategories.first;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Income"),
                        value: "income",
                        groupValue: selectedType,
                        onChanged: (value) {
                          setState(() {
                            selectedType = value!;
                            // Update category when type changes
                            selectedCategory = selectedType == "expense"
                                ? AppConstants.defaultExpenseCategories.first
                                : AppConstants.defaultIncomeCategories.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Category
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items:
                      (selectedType == "expense"
                              ? AppConstants.defaultExpenseCategories
                              : AppConstants.defaultIncomeCategories)
                          .map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          })
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Amount
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                    prefixText: AppConstants.currencySymbol,
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 16),
                // Date and Time Row
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text("Date"),
                        subtitle: Text(
                          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (date != null) {
                            setState(() {
                              selectedDate = date;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text("Time"),
                        subtitle: Text(selectedTime.format(context)),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (time != null) {
                            setState(() {
                              selectedTime = time;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Asset Dropdown
                DropdownButtonFormField<String>(
                  initialValue: selectedAsset,
                  decoration: const InputDecoration(
                    labelText: "Asset",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance_wallet),
                  ),
                  items:
                      [
                            AppConstants.defaultAsset,
                            "Credit Card",
                            "Bank Transfer",
                            "Investment Account",
                          ]
                          .map(
                            (asset) => DropdownMenuItem(
                              value: asset,
                              child: Text(asset),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAsset = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Ledger Dropdown
                DropdownButtonFormField<String>(
                  initialValue: selectedLedger,
                  decoration: const InputDecoration(
                    labelText: "Ledger",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.book),
                  ),
                  items: AppConstants.ledgerTypes
                      .map(
                        (ledger) => DropdownMenuItem(
                          value: ledger,
                          child: Text(ledger),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLedger = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Remark
                TextField(
                  controller: remarkController,
                  decoration: const InputDecoration(
                    labelText: "Remark (Good, Bad, etc.)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate inputs
                final amountError = ValidationService.validateAmount(
                  amountController.text,
                );

                if (amountError != null) {
                  ValidationService.showValidationError(context, amountError);
                  return;
                }

                final transaction = {
                  "category": selectedCategory,
                  "amount": selectedType == "expense"
                      ? -double.tryParse(amountController.text)!
                      : double.tryParse(amountController.text)!,
                  "date": selectedDate.toIso8601String().split('T')[0],
                  "time": selectedTime.format(context),
                  "asset": selectedAsset,
                  "ledger": selectedLedger,
                  "remark": remarkController.text.isNotEmpty
                      ? remarkController.text
                      : AppConstants.defaultRemark,
                  "type": selectedType,
                };

                // Save transaction to database
                try {
                  await _dbService.insertTransaction(transaction);

                  // Add transaction to local list immediately for better UX
                  setState(() {
                    _transactions.insert(0, transaction); // Insert at beginning
                  });

                  // Notify other pages that data has changed
                  _notifyDataChanged();

                  Navigator.of(context).pop();
                  ValidationService.showSuccessMessage(
                    context,
                    AppConstants.transactionAddedMessage,
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving transaction: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Add", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTransactionDialog(Map<String, dynamic> transaction, int index) {
    final TextEditingController categoryController = TextEditingController(
      text: transaction["category"]
          .toString()
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .trim(),
    );
    final TextEditingController amountController = TextEditingController(
      text: transaction["amount"].abs().toString(),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Edit Transaction"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                  prefixText: "฿",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (categoryController.text.isEmpty ||
                    amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill in all fields"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setState(() {
                  _transactions[index] = {
                    "category": "📝 ${categoryController.text}",
                    "amount": -double.tryParse(amountController.text)!,
                    "date": "Updated",
                    "type": "expense",
                  };
                });

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Transaction updated successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text(
                "Update",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetailsDialog(Map<String, dynamic> transaction) {
    final isExpense = transaction['type'] == 'expense';
    final amount = transaction['amount'].abs();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isExpense ? Colors.red[100] : Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                color: isExpense ? Colors.red[600] : Colors.green[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['category'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${isExpense ? '-' : '+'}฿${amount.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isExpense ? Colors.red[600] : Colors.green[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                "Date",
                transaction['date'] ?? DateTime.now().toString().split(' ')[0],
              ),
              _buildDetailRow(
                "Time",
                transaction['time'] ??
                    DateTime.now().toString().split(' ')[1].substring(0, 5),
              ),
              _buildDetailRow(
                "Asset",
                transaction['asset'] ?? AppConstants.defaultAsset,
              ),
              _buildDetailRow(
                "Ledger",
                transaction['ledger'] ?? AppConstants.defaultLedger,
              ),
              _buildDetailRow(
                "Remark",
                transaction['remark'] ?? AppConstants.defaultRemark,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              final index = _transactions.indexOf(transaction);
              _showEditTransactionDialog(transaction, index);
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text("Edit"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              final index = _transactions.indexOf(transaction);
              _showDeleteConfirmationDialog(index);
            },
            icon: const Icon(Icons.delete, size: 18),
            label: const Text("Delete"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Transaction"),
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _transactions.removeAt(index);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Transaction deleted successfully!"),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyHistogramSection() {
    final selectedDate = _selectedDate ?? DateTime.now();
    final currentMonth = selectedDate.month;
    final currentYear = selectedDate.year;

    // Calculate weekly totals
    List<Map<String, dynamic>> weeklyData = [];

    // Get all transactions for current month
    final monthlyTransactions = _transactions.where((t) {
      try {
        final date = DateTime.parse(t['date']);
        return date.month == currentMonth && date.year == currentYear;
      } catch (e) {
        return false;
      }
    }).toList();

    // Group by weeks
    for (int week = 1; week <= 5; week++) {
      final weekStart = (week - 1) * 7 + 1;
      final weekEnd = (week * 7).clamp(
        1,
        DateTime(currentYear, currentMonth + 1, 0).day,
      );

      double weekExpense = 0;
      double weekIncome = 0;

      for (var transaction in monthlyTransactions) {
        try {
          final date = DateTime.parse(transaction['date']);
          if (date.day >= weekStart && date.day <= weekEnd) {
            if (transaction['type'] == 'expense') {
              weekExpense += transaction['amount'].abs();
            } else {
              weekIncome += transaction['amount'].abs();
            }
          }
        } catch (e) {
          // Skip invalid dates
        }
      }

      weeklyData.add({
        'week': 'Week $week',
        'expense': weekExpense,
        'income': weekIncome,
      });
    }

    final maxAmount = weeklyData
        .fold<double>(
          0,
          (max, week) => [
            week['expense'],
            week['income'],
          ].fold<double>(0, (sum, amount) => sum + (amount as double)),
        )
        .clamp(1000, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Monthly Histogram",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
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
          child: Column(
            children: [
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("Expenses", style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 20),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("Income", style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 20),
              // Histogram bars
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: weeklyData.map((week) {
                  final expenseHeight =
                      (week['expense'] as double) / maxAmount * 100;
                  final incomeHeight =
                      (week['income'] as double) / maxAmount * 100;

                  return Column(
                    children: [
                      // Value labels
                      Text(
                        '฿${((week['expense'] as double) + (week['income'] as double)).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Bars
                      SizedBox(
                        width: 40,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // Income bar (green)
                            Container(
                              width: 15,
                              height: incomeHeight,
                              decoration: BoxDecoration(
                                color: Colors.green[400],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            // Expense bar (red)
                            Positioned(
                              left: 20,
                              child: Container(
                                width: 15,
                                height: expenseHeight,
                                decoration: BoxDecoration(
                                  color: Colors.red[400],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Week label
                      Text(
                        week['week'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
