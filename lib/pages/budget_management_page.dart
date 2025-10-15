// lib/pages/budget_management_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../services/validation_service.dart';

class BudgetManagementPage extends StatefulWidget {
  const BudgetManagementPage({super.key});

  @override
  _BudgetManagementPageState createState() => _BudgetManagementPageState();
}

class _BudgetManagementPageState extends State<BudgetManagementPage>
    with TickerProviderStateMixin {
  // Database service instance
  final DatabaseService _dbService = DatabaseService();

  // Loading state
  bool _isLoading = true;

  // Budget plans - loaded from database
  Map<String, Map<String, dynamic>> _budgetPlans = {};

  // Selected budget type
  String _selectedBudgetType = 'monthly';

  // Animation controllers
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadBudgetData();
  }

  void _initializeAnimations() {
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeOutBack,
      ),
    );
    _progressAnimationController.forward();
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    super.dispose();
  }

  /// Load budget data from database
  Future<void> _loadBudgetData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load budgets from database
      final budgets = await _dbService.getAllBudgets();
      
      // Initialize budget plans from database
      _budgetPlans = {};
      
      // If no budgets exist, create default ones
      if (budgets.isEmpty) {
        print('No budgets found, creating default budgets...');
        await _createDefaultBudgets();
        // Reload budgets after creating defaults
        final newBudgets = await _dbService.getAllBudgets();
        budgets.addAll(newBudgets);
      }
      
      // Load spending data for the selected period
      await _updateBudgetPlansForPeriod(budgets);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading budget data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Update budget plans based on selected period
  Future<void> _updateBudgetPlansForPeriod(List<Map<String, dynamic>> budgets) async {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    // Calculate date range based on selected period
    if (_selectedBudgetType == 'weekly') {
      startDate = now.subtract(Duration(days: now.weekday - 1)); // Start of current week
    } else if (_selectedBudgetType == 'monthly') {
      startDate = DateTime(now.year, now.month, 1); // Start of current month
    } else {
      startDate = DateTime(now.year, 1, 1); // Start of current year
    }

    // Get spending data for the selected period
    final transactions = await _dbService.getTransactionsByDateRange(startDate, endDate);
    final spendingByCategory = <String, double>{};

    // Calculate spending by category for the selected period
    for (var transaction in transactions) {
      if (transaction['amount'] < 0) {
        // Only consider expenses
        final category = transaction['category'] as String;
        final amount = (transaction['amount'] as double).abs();
        spendingByCategory.update(category, (value) => value + amount, ifAbsent: () => amount);
      }
    }

    // Update budget plans with period-specific data
    for (final budget in budgets) {
      final type = budget['type'] as String;
      final amount = budget['amount'] as double;
      final spent = budget['spent'] as double;
      
      // Calculate category breakdown based on actual spending for this period
      final categories = <String, Map<String, dynamic>>{};
      for (final entry in spendingByCategory.entries) {
        final category = entry.key;
        final categorySpent = entry.value;
        
        // Estimate budget for each category based on spending patterns
        final estimatedBudget = categorySpent * 1.5; // 1.5x spending as budget
        
        categories[category] = {
          'budget': estimatedBudget,
          'spent': categorySpent,
        };
      }
      
      _budgetPlans[type] = {
        'amount': amount,
        'spent': spent,
        'categories': categories,
      };
    }
  }

  /// Create default budgets if none exist
  Future<void> _createDefaultBudgets() async {
    final spendingByCategory = await _dbService.getSpendingByCategory();
    final totalMonthlySpending = spendingByCategory.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );

    final defaultBudgets = [
      {
        'type': 'weekly',
        'amount': (totalMonthlySpending / 4.3).clamp(1000.0, 10000.0),
        'spent': 0.0,
        'category': null,
      },
      {
        'type': 'monthly',
        'amount': totalMonthlySpending.clamp(5000.0, 50000.0),
        'spent': 0.0,
        'category': null,
      },
      {
        'type': 'yearly',
        'amount': (totalMonthlySpending * 12).clamp(60000.0, 600000.0),
        'spent': 0.0,
        'category': null,
      },
    ];

    for (final budget in defaultBudgets) {
      await _dbService.insertBudget(budget);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Budget Management"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add),
            onPressed: () => _bookmarkBudget(),
            tooltip: "Bookmark Budget Management",
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBudgetDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Budget Type Selector
                  _buildBudgetTypeSelector(),
                  const SizedBox(height: 20),

                  // Budget Overview Card
                  _buildBudgetOverviewCard(),
                  const SizedBox(height: 20),

                  // Budget Progress Chart
                  _buildBudgetProgressChart(),
                  const SizedBox(height: 20),

                  // Category Breakdown
                  _buildCategoryBreakdown(),
                  const SizedBox(height: 20),

                  // Budget Alerts
                  _buildBudgetAlerts(),
                ],
              ),
            ),
    );
  }

  Widget _buildBudgetTypeSelector() {
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
          Expanded(
            child: _buildBudgetTypeButton(
              'weekly',
              'Weekly',
              Icons.calendar_view_week,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildBudgetTypeButton(
              'monthly',
              'Monthly',
              Icons.calendar_view_month,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildBudgetTypeButton(
              'yearly',
              'Yearly',
              Icons.calendar_today,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetTypeButton(String type, String label, IconData icon) {
    final isSelected = _selectedBudgetType == type;
    return GestureDetector(
      onTap: () async {
        setState(() {
          _selectedBudgetType = type;
        });
        // Reload data for the new period
        await _loadBudgetData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetOverviewCard() {
    final plan = _budgetPlans[_selectedBudgetType];
    if (plan == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No budget data available',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    final spent = plan['spent'] as double;
    final budget = plan['amount'] as double;
    final remaining = budget - spent;
    final percentage = budget > 0 ? (spent / budget) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            percentage > 0.8 ? Colors.red : Colors.blue,
            percentage > 0.8 ? Colors.orange : Colors.purple,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedBudgetType.toUpperCase()} BUDGET',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(percentage * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Budget',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '฿${budget.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Spent',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '฿${spent.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Remaining',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '฿${remaining.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: remaining < 0 ? Colors.red[200] : Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: (percentage * _progressAnimation.value).clamp(0.0, 1.0),
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage > 0.8 ? Colors.red[200]! : Colors.white,
                ),
                minHeight: 8,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetProgressChart() {
    final plan = _budgetPlans[_selectedBudgetType];
    if (plan == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No budget data available',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    final categories = plan['categories'] as Map<String, dynamic>;

    return Container(
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
            'Category Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: categories.entries.map((entry) {
                  final categoryData = entry.value as Map<String, dynamic>;
                  final budget = categoryData['budget'] as double;
                  final spent = categoryData['spent'] as double;
                  final percentage = budget > 0 ? (spent / budget) : 0.0;

                  return PieChartSectionData(
                    color: _getCategoryColor(entry.key),
                    value: spent,
                    title: percentage > 0.1
                        ? '${(percentage * 100).toStringAsFixed(0)}%'
                        : '',
                    radius: 60,
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
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: categories.entries.map((entry) {
              final categoryData = entry.value as Map<String, dynamic>;
              final budget = categoryData['budget'] as double;
              final spent = categoryData['spent'] as double;
              final percentage = budget > 0 ? (spent / budget) : 0.0;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(entry.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(entry.key, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    '฿${spent.toStringAsFixed(0)}/฿${budget.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: percentage > 0.8 ? Colors.red : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    final plan = _budgetPlans[_selectedBudgetType];
    if (plan == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No budget data available',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    final categories = plan['categories'] as Map<String, dynamic>;

    return Container(
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
            'Category Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...categories.entries.map((entry) {
            final categoryData = entry.value as Map<String, dynamic>;
            final budget = categoryData['budget'] as double;
            final spent = categoryData['spent'] as double;
            final percentage = budget > 0 ? (spent / budget) : 0.0;
            final remaining = budget - spent;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '฿${spent.toStringAsFixed(0)} / ฿${budget.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: percentage > 0.8
                              ? Colors.red
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percentage.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage > 0.8 ? Colors.red : Colors.blue,
                    ),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(percentage * 100).toStringAsFixed(0)}% used',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                      Text(
                        remaining < 0
                            ? 'Over by ฿${(-remaining).toStringAsFixed(0)}'
                            : '฿${remaining.toStringAsFixed(0)} left',
                        style: TextStyle(
                          fontSize: 10,
                          color: remaining < 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBudgetAlerts() {
    final plan = _budgetPlans[_selectedBudgetType];
    if (plan == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No budget data available',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    final categories = plan['categories'] as Map<String, dynamic>;

    // Find categories that are over budget
    final overBudgetCategories = categories.entries.where((entry) {
      final categoryData = entry.value as Map<String, dynamic>;
      final budget = categoryData['budget'] as double;
      final spent = categoryData['spent'] as double;
      return spent > budget;
    }).toList();

    if (overBudgetCategories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Great job! You\'re staying within your ${_selectedBudgetType} budget.',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red[600]),
              const SizedBox(width: 12),
              Text(
                'Budget Alert',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'You\'re over budget in ${overBudgetCategories.length} category(ies):',
            style: TextStyle(
              color: Colors.red[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...overBudgetCategories.map((entry) {
            final categoryData = entry.value as Map<String, dynamic>;
            final budget = categoryData['budget'] as double;
            final spent = categoryData['spent'] as double;
            final overAmount = spent - budget;

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${entry.key}: Over by ฿${overAmount.toStringAsFixed(0)}',
                style: TextStyle(color: Colors.red[600], fontSize: 14),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '🍕 Food & Dining':
        return Colors.orange;
      case '🚗 Transportation':
        return Colors.blue;
      case '🛍️ Shopping':
        return Colors.purple;
      case '🏠 Housing':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showAddBudgetDialog() {
    final TextEditingController amountController = TextEditingController();
    String selectedCategory = '🍕 Food & Dining';
    String selectedPeriod = _selectedBudgetType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add Budget"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category Selection
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '🍕 Food & Dining',
                      child: Text('🍕 Food & Dining'),
                    ),
                    DropdownMenuItem(
                      value: '🚗 Transportation',
                      child: Text('🚗 Transportation'),
                    ),
                    DropdownMenuItem(
                      value: '🛍️ Shopping',
                      child: Text('🛍️ Shopping'),
                    ),
                    DropdownMenuItem(
                      value: '🏠 Housing',
                      child: Text('🏠 Housing'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => selectedCategory = value!),
                ),
                const SizedBox(height: 16),

                // Period Selection
                DropdownButtonFormField<String>(
                  value: selectedPeriod,
                  decoration: const InputDecoration(
                    labelText: "Period",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                    DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                  ],
                  onChanged: (value) => setState(() => selectedPeriod = value!),
                ),
                const SizedBox(height: 16),

                // Amount
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Budget Amount",
                    border: OutlineInputBorder(),
                    prefixText: "฿",
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
                if (amountController.text.isEmpty) {
                  ValidationService.showValidationError(
                    context,
                    'Please enter an amount',
                  );
                  return;
                }

                try {
                  final amount = double.parse(amountController.text);

                  // Update budget in database
                  final existingBudget = await _dbService.getBudgetByType(
                    selectedPeriod,
                  );
                  if (existingBudget != null) {
                    // Update existing budget
                    await _dbService.updateBudget(existingBudget['id'] as int, {
                      'type': selectedPeriod,
                      'amount': amount,
                      'spent': existingBudget['spent'] ?? 0.0,
                      'category': selectedCategory,
                    });
                  } else {
                    // Create new budget
                    await _dbService.insertBudget({
                      'type': selectedPeriod,
                      'amount': amount,
                      'spent': 0.0,
                      'category': selectedCategory,
                    });
                  }

                  Navigator.of(context).pop();
                  ValidationService.showSuccessMessage(
                    context,
                    'Budget updated: ฿${amount.toStringAsFixed(0)} for $selectedCategory',
                  );

                  // Reload data
                  await _loadBudgetData();
                } catch (e) {
                  ValidationService.showValidationError(
                    context,
                    'Invalid amount. Please enter a valid number.',
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Bookmark Method
  void _bookmarkBudget() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Budget Management bookmarked! Check Bookmarks page in Settings."),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
