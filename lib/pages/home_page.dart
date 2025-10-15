import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../services/database_service.dart';
import '../services/hybrid_data_service.dart';
import '../services/tutorial_service.dart';
import '../services/unified_data_service.dart';
import '../services/validation_service.dart';
import '../utils/page_transitions.dart';
import 'budget_management_page.dart';
import 'digital_wallet_page.dart';
import 'financial_goals_page.dart';
import 'quick_calculator_page.dart';
import 'reports_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  double _currentBalance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double _emergencyFund = 0.0;
  List<Map<String, dynamic>> _investments = [];
  bool _isLoading = true; // Add loading state
  late AnimationController _balanceAnimationController;
  late AnimationController _tabAnimationController;
  late Animation<double> _balanceAnimation;

  // Unified data service instance
  final UnifiedDataService _unifiedDataService = UnifiedDataService();

  final List<String> _tabs = ["Overview", "Emergency", "Investment", "Recent"];

  @override
  void initState() {
    super.initState();
    _loadData();
    _initializeAnimations();
    _showTutorials();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning to this page
    _loadData();
  }

  /// Refresh data manually - can be called from other pages
  Future<void> refreshData() async {
    await _loadData();
  }

  void _showTutorials() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showHomePageTutorial();
    });
  }

  void _showHomePageTutorial() {
    if (!TutorialService.isTutorialCompleted(
      TutorialService.homePageOverview,
    )) {
      TutorialService.showTutorial(
        context,
        TutorialService.homePageOverview,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Welcome to Your Financial Dashboard!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'This is your home page where you can:\n'
              '• View your current balance\n'
              '• Manage emergency funds\n'
              '• Track investments\n'
              '• See recent transactions\n'
              '• Access quick features',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _balanceAnimationController.dispose();
    _tabAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _balanceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _balanceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _balanceAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _balanceAnimationController.forward();
    _tabAnimationController.forward();
  }

  Future<void> _loadData() async {
    try {
      // Load all data in parallel to avoid blocking UI
      final futures = await Future.wait([
        _unifiedDataService.getCurrentBalance(),
        _unifiedDataService.getEmergencyBalance(),
        _unifiedDataService.getTotalIncome(),
        _unifiedDataService.getTotalExpenses(),
        _unifiedDataService.getInvestments(),
      ]);

      if (mounted) {
        setState(() {
          _currentBalance = futures[0] as double;
          _emergencyFund = futures[1] as double;
          _totalIncome = futures[2] as double;
          _totalExpenses = futures[3] as double;
          _investments = futures[4] as List<Map<String, dynamic>>;
          _isLoading = false; // Set loading to false when data is loaded
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      // Fallback to HybridDataService if database fails
      try {
        final financialData = await HybridDataService.getFinancialData();
        final emergencyFund = await HybridDataService.getEmergencyFund();
        final investments = await HybridDataService.getInvestments();

        if (mounted) {
          setState(() {
            _currentBalance = financialData['currentBalance'] ?? 0.0;
            _totalIncome = financialData['totalIncome'] ?? 0.0;
            _totalExpenses = financialData['totalExpenses'] ?? 0.0;
            _emergencyFund = emergencyFund;
            _investments = investments;
            _isLoading =
                false; // Set loading to false when fallback data is loaded
          });
        }
      } catch (fallbackError) {
        debugPrint('Fallback data loading failed: $fallbackError');
      }
    }
  }

  double _getTotalInvestmentValue() {
    return _investments.fold(
      0.0,
      (sum, investment) => sum + (investment['amount'] as double),
    );
  }

  // Weekly transaction methods
  Future<double> _getWeeklyIncome() async {
    try {
      final transactions = await _unifiedDataService.getAllTransactions();
      double totalIncome = 0.0;
      for (final t in transactions) {
        if (t['type'] == 'income') {
          totalIncome += (t['amount'] as double);
        }
      }
      return totalIncome;
    } catch (e) {
      print('Error getting weekly income: $e');
      return 0.0;
    }
  }

  Future<double> _getWeeklyExpenses() async {
    try {
      final transactions = await _unifiedDataService.getAllTransactions();
      double totalExpenses = 0.0;
      for (final t in transactions) {
        if (t['type'] == 'expense') {
          totalExpenses += (t['amount'] as double).abs();
        }
      }
      return totalExpenses;
    } catch (e) {
      print('Error getting weekly expenses: $e');
      return 0.0;
    }
  }

  Future<List<Map<String, dynamic>>> _getWeeklyTransactions() async {
    try {
      // Get ALL transactions from database (same as bills page)
      final allTransactions = await _unifiedDataService.getAllTransactions();

      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      print(
        'Weekly transaction range: ${weekStart.toIso8601String().split('T')[0]} to ${weekEnd.toIso8601String().split('T')[0]}',
      );

      // Filter transactions for this week (same logic as TransactionCalendar)
      final weeklyTransactions = allTransactions.where((transaction) {
        try {
          final transactionDate = DateTime.parse(transaction['date'] as String);
          return transactionDate.isAfter(
                weekStart.subtract(const Duration(days: 1)),
              ) &&
              transactionDate.isBefore(weekEnd.add(const Duration(days: 1)));
        } catch (e) {
          print('Error parsing date: ${transaction['date']}');
          return false;
        }
      }).toList();

      print('Found ${weeklyTransactions.length} transactions for this week');

      // Sort by date descending (most recent first)
      weeklyTransactions.sort((a, b) {
        try {
          final dateA = DateTime.parse(a['date'] as String);
          final dateB = DateTime.parse(b['date'] as String);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      return weeklyTransactions;
    } catch (e) {
      print('Error getting weekly transactions: $e');
      return [];
    }
  }

  Widget _buildWeeklyTransactionsSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getWeeklyTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Column(
            children: [
              Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                "No transactions this week",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          );
        }

        final transactions = snapshot.data!;
        return Column(
          children: transactions.map((transaction) {
            final amount = transaction['amount'] as double;
            final isExpense = amount < 0;
            final category = transaction['category'] ?? 'Unknown';
            final date = transaction['date'] ?? '';
            final time = transaction['time'] ?? '';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildWeeklyTransactionItem(
                category,
                '฿${amount.abs().toStringAsFixed(2)}',
                _formatTransactionDate(date, time),
                isExpense,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _formatTransactionDate(String date, String time) {
    try {
      final transactionDate = DateTime.parse(date);
      final now = DateTime.now();
      final difference = now.difference(transactionDate).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return '$difference days ago';
      } else {
        return '${transactionDate.day}/${transactionDate.month}';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getEmergencyStatus(double minAmount, double maxAmount) {
    if (_emergencyFund >= maxAmount) {
      return "FULLY COVERED";
    } else if (_emergencyFund >= minAmount) {
      return "PARTIALLY COVERED";
    } else {
      return "INSUFFICIENT";
    }
  }

  Color _getEmergencyStatusColor(double minAmount, double maxAmount) {
    if (_emergencyFund >= maxAmount) {
      return Colors.green;
    } else if (_emergencyFund >= minAmount) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  double _getInvestmentAmountByCategory(String category) {
    return _investments
        .where(
          (investment) => investment['name'].toString().toLowerCase().contains(
            category.toLowerCase(),
          ),
        )
        .fold(0.0, (sum, investment) => sum + (investment['amount'] as double));
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while data is loading
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👋 Greeting Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, Student!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Welcome back to your expense tracker",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 💰 Balance Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedBuilder(
                  animation: _balanceAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _balanceAnimation.value,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[400]!, Colors.blue[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Current Balance",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "฿${_currentBalance.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                TutorialService.buildTooltip(
                                  message: "Tap to add money to your balance",
                                  tutorialKey:
                                      TutorialService.balanceManagement,
                                  child: GestureDetector(
                                    onTap: _showAddBalanceDialog,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                TutorialService.buildTooltip(
                                  message:
                                      "Tap to subtract money from your balance",
                                  tutorialKey:
                                      TutorialService.balanceManagement,
                                  child: GestureDetector(
                                    onTap: _showSubtractBalanceDialog,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.remove,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // 📊 Quick Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _statCard(
                      Icons.arrow_upward,
                      "Income",
                      "฿${_totalIncome.toStringAsFixed(2)}",
                      Colors.white,
                      Colors.green,
                    ),
                    _statCard(
                      Icons.arrow_downward,
                      "Expenses",
                      "฿${_totalExpenses.toStringAsFixed(2)}",
                      Colors.white,
                      Colors.orange[600]!,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 🧭 Tab Navigation
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tabs.length,
                  itemBuilder: (context, index) {
                    final active = _selectedTabIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                        _tabAnimationController.reset();
                        _tabAnimationController.forward();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: active ? Colors.blue : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          _tabs[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.blue : Colors.black54,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 📂 Tab Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildTabContent(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: TutorialService.buildTooltip(
        message:
            "Tap to open the quick calculator for adding expenses or income",
        tutorialKey: TutorialService.quickCalculator,
        child: FloatingActionButton(
          heroTag: "main_fab",
          onPressed: () {
            AnimatedNavigation.slideFromBottom(context, QuickCalculatorPage());
          },
          backgroundColor: Colors.blue[600],
          tooltip: 'Quick Calculator',
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // 📂 Tab Content Builder
  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0: // Overview
        return _buildOverviewTab();
      case 1: // Emergency
        return _buildEmergencyTab();
      case 2: // Investment
        return _buildInvestmentTab();
      case 3: // Recent
        return _buildRecentTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return Column(
      children: [
        // Overview section with feature cards
        Row(
          children: [
            Expanded(
              child: TutorialService.buildTooltip(
                message: "Tap to set and track your financial goals",
                tutorialKey: TutorialService.balanceManagement,
                child: _clickableFeatureCard(
                  Icons.flag,
                  "Goals",
                  "Track your savings",
                  () {
                    AnimatedNavigation.slideFromRight(
                      context,
                      FinancialGoalsPage(),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TutorialService.buildTooltip(
                message: "Tap to view detailed financial reports",
                tutorialKey: TutorialService.balanceManagement,
                child: _clickableFeatureCard(
                  Icons.analytics,
                  "Reports",
                  "View analytics",
                  () {
                    AnimatedNavigation.slideFromRight(context, ReportsPage());
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TutorialService.buildTooltip(
                message: "Tap to manage your budget and spending limits",
                tutorialKey: TutorialService.balanceManagement,
                child: _clickableFeatureCard(
                  Icons.account_balance_wallet,
                  "Budget",
                  "Manage spending",
                  () {
                    AnimatedNavigation.slideFromRight(
                      context,
                      BudgetManagementPage(),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TutorialService.buildTooltip(
                message: "Tap to manage your digital wallet and accounts",
                tutorialKey: TutorialService.balanceManagement,
                child: _clickableFeatureCard(
                  Icons.account_balance,
                  "Wallet",
                  "Your accounts",
                  () {
                    AnimatedNavigation.slideFromRight(
                      context,
                      DigitalWalletPage(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmergencyTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Emergency Fund",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => _bookmarkEmergencyFund(),
                  icon: const Icon(Icons.bookmark_add, color: Colors.purple),
                  tooltip: "Bookmark Emergency Fund",
                ),
                TutorialService.buildTooltip(
                  message: "Tap to add money to your emergency fund",
                  tutorialKey: TutorialService.emergencyFund,
                  child: FloatingActionButton(
                    heroTag: "emergency_fab",
                    mini: true,
                    onPressed: () => _showAddEmergencyDialog(),
                    backgroundColor: Colors.purple,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
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
              Text(
                "฿${_emergencyFund.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Target: ฿50,000",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: (_emergencyFund / 50000).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Emergency Scenarios",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildEmergencyScenarioCard(
                "Medical",
                Icons.favorite,
                Colors.orange,
                "฿5,000 - ฿15,000\nAvailable: ฿${_emergencyFund.toStringAsFixed(0)}",
                _getEmergencyStatus(5000, 15000),
                _getEmergencyStatusColor(5000, 15000),
                () => _showMedicalEmergencyDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEmergencyScenarioCard(
                "Education",
                Icons.school,
                Colors.blue,
                "฿2,000 - ฿8,000\nAvailable: ฿${_emergencyFund.toStringAsFixed(0)}",
                _getEmergencyStatus(2000, 8000),
                _getEmergencyStatusColor(2000, 8000),
                () => _showEducationEmergencyDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInvestmentTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Investment Portfolio",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => _bookmarkInvestment(),
                  icon: const Icon(Icons.bookmark_add, color: Colors.blue),
                  tooltip: "Bookmark Investment",
                ),
                FloatingActionButton(
                  heroTag: "investment_fab",
                  mini: true,
                  onPressed: () => _showAddInvestmentDialog(),
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
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
                "Portfolio Value",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                "฿${_getTotalInvestmentValue().toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Performance",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  Text(
                    "+5.2%",
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Investment Categories",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInvestmentCategoryCard(
                "Stocks",
                Icons.trending_up,
                Colors.blue,
                "฿${_getInvestmentAmountByCategory('stock').toStringAsFixed(0)}",
                () => _showStocksDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInvestmentCategoryCard(
                "Bonds",
                Icons.shield,
                Colors.green,
                "฿${_getInvestmentAmountByCategory('bond').toStringAsFixed(0)}",
                () => _showBondsDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "This Week's Transactions",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Week Summary Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[400]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "This Week's Activity",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Week of ${_getWeekStartDate()}",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FutureBuilder<double>(
                      future: _getWeeklyIncome(),
                      builder: (context, snapshot) {
                        final income = snapshot.data ?? 0.0;
                        return Column(
                          children: [
                            Text(
                              "฿${income.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Income",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  Expanded(
                    child: FutureBuilder<double>(
                      future: _getWeeklyExpenses(),
                      builder: (context, snapshot) {
                        final expenses = snapshot.data ?? 0.0;
                        return Column(
                          children: [
                            Text(
                              "฿${expenses.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Expenses",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Recent Transactions List (This Week)
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Transactions",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "This Week",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Weekly transactions from database
              _buildWeeklyTransactionsSection(),
            ],
          ),
        ),
      ],
    );
  }

  String _getWeekStartDate() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return "${startOfWeek.day}/${startOfWeek.month}";
  }

  Widget _buildWeeklyTransactionItem(
    String category,
    String amount,
    String date,
    bool isExpense,
  ) {
    return GestureDetector(
      onTap: () => _showTransactionDetailsDialog({
        'category': category,
        'amount': isExpense
            ? -double.parse(amount.replaceAll('฿', '').replaceAll(',', ''))
            : double.parse(amount.replaceAll('฿', '').replaceAll(',', '')),
        'date': date,
        'time': '12:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Weekly transaction',
        'type': isExpense ? 'expense' : 'income',
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
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
                    category,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  "${isExpense ? '-' : '+'}$amount",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isExpense ? Colors.red[600] : Colors.green[600],
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditTransactionDialog({
                        'category': category,
                        'amount': isExpense
                            ? -double.parse(
                                amount.replaceAll('฿', '').replaceAll(',', ''),
                              )
                            : double.parse(
                                amount.replaceAll('฿', '').replaceAll(',', ''),
                              ),
                        'date': date,
                        'time': '12:00',
                        'asset': 'Cash',
                        'ledger': 'Personal',
                        'remark': 'Weekly transaction',
                        'type': isExpense ? 'expense' : 'income',
                      });
                    } else if (value == 'delete') {
                      _showDeleteConfirmationDialog({
                        'category': category,
                        'amount': isExpense
                            ? -double.parse(
                                amount.replaceAll('฿', '').replaceAll(',', ''),
                              )
                            : double.parse(
                                amount.replaceAll('฿', '').replaceAll(',', ''),
                              ),
                        'date': date,
                        'time': '12:00',
                        'asset': 'Cash',
                        'ledger': 'Personal',
                        'remark': 'Weekly transaction',
                        'type': isExpense ? 'expense' : 'income',
                      });
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionCard(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 📊 Quick Stat Widget
  Widget _statCard(
    IconData icon,
    String title,
    String value,
    Color color,
    Color bgColor,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
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
            // Icon container with rounded square background
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📦 Clickable Feature Card Widget
  Widget _clickableFeatureCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.blue[600], size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBalanceDialog() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController sourceController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    String selectedCategory = '💼 Salary';
    String selectedPaymentMethod = 'Cash';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add to Balance"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Add money to your balance"),
                const SizedBox(height: 16),

                // Amount
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                    prefixText: AppConstants.currencySymbol,
                  ),
                ),
                const SizedBox(height: 16),

                // Source/Category
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "Source",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '💼 Salary',
                      child: Text('💼 Salary'),
                    ),
                    DropdownMenuItem(
                      value: '💳 Freelance',
                      child: Text('💳 Freelance'),
                    ),
                    DropdownMenuItem(
                      value: '🎁 Allowance',
                      child: Text('🎁 Allowance'),
                    ),
                    DropdownMenuItem(
                      value: '📈 Investment Return',
                      child: Text('📈 Investment Return'),
                    ),
                    DropdownMenuItem(
                      value: '🎯 Bonus',
                      child: Text('🎯 Bonus'),
                    ),
                    DropdownMenuItem(value: '💰 Gift', child: Text('💰 Gift')),
                    DropdownMenuItem(
                      value: '🏪 Business',
                      child: Text('🏪 Business'),
                    ),
                    DropdownMenuItem(
                      value: '💸 Refund',
                      child: Text('💸 Refund'),
                    ),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) =>
                      setState(() => selectedCategory = value!),
                ),
                const SizedBox(height: 16),

                // Payment Method
                DropdownButtonFormField<String>(
                  initialValue: selectedPaymentMethod,
                  decoration: const InputDecoration(
                    labelText: "Payment Method",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Cash', child: Text('💵 Cash')),
                    DropdownMenuItem(
                      value: 'Bank Transfer',
                      child: Text('🏦 Bank Transfer'),
                    ),
                    DropdownMenuItem(
                      value: 'Credit Card',
                      child: Text('💳 Credit Card'),
                    ),
                    DropdownMenuItem(
                      value: 'Digital Wallet',
                      child: Text('📱 Digital Wallet'),
                    ),
                    DropdownMenuItem(value: 'Check', child: Text('📄 Check')),
                  ],
                  onChanged: (value) =>
                      setState(() => selectedPaymentMethod = value!),
                ),
                const SizedBox(height: 16),

                // Source Details
                TextField(
                  controller: sourceController,
                  decoration: const InputDecoration(
                    labelText: "Source Details",
                    border: OutlineInputBorder(),
                    hintText: "e.g., Company name, client name",
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                    hintText: "Optional: Additional details",
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

                final amountError = ValidationService.validateAmount(
                  amountController.text,
                );
                if (amountError != null) {
                  ValidationService.showValidationError(context, amountError);
                  return;
                }

                final amount = double.parse(amountController.text);

                // Create transaction record
                final transaction = {
                  'category': selectedCategory,
                  'amount': amount,
                  'date': DateTime.now().toIso8601String().split('T')[0],
                  'time': DateTime.now()
                      .toString()
                      .split(' ')[1]
                      .substring(0, 5),
                  'asset': selectedPaymentMethod,
                  'ledger': 'Personal',
                  'remark': descriptionController.text.isNotEmpty
                      ? '${sourceController.text} - ${descriptionController.text}'
                      : sourceController.text.isNotEmpty
                      ? sourceController.text
                      : 'Balance addition',
                  'type': 'income',
                };

                // Save transaction to database
                await _unifiedDataService.insertTransaction(transaction);

                setState(() {
                  _currentBalance += amount;
                });
                await _unifiedDataService.updateBalance(
                  'current',
                  _currentBalance,
                );
                await HybridDataService.saveCurrentBalance(_currentBalance);

                // Refresh all data to update income/expense totals
                await _loadData();

                Navigator.of(context).pop();
                ValidationService.showSuccessMessage(
                  context,
                  'Added ฿${amount.toStringAsFixed(2)} from $selectedCategory',
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Add", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubtractBalanceDialog() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    String selectedCategory = '🍕 Food & Dining';
    String selectedPaymentMethod = 'Cash';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Subtract from Balance"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Subtract money from your balance"),
                const SizedBox(height: 16),

                // Amount
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                    prefixText: AppConstants.currencySymbol,
                  ),
                ),
                const SizedBox(height: 16),

                // Category
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
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
                    DropdownMenuItem(
                      value: '💊 Healthcare',
                      child: Text('💊 Healthcare'),
                    ),
                    DropdownMenuItem(
                      value: '🎮 Entertainment',
                      child: Text('🎮 Entertainment'),
                    ),
                    DropdownMenuItem(
                      value: '📚 Education',
                      child: Text('📚 Education'),
                    ),
                    DropdownMenuItem(
                      value: '⚡ Utilities',
                      child: Text('⚡ Utilities'),
                    ),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) =>
                      setState(() => selectedCategory = value!),
                ),
                const SizedBox(height: 16),

                // Payment Method
                DropdownButtonFormField<String>(
                  initialValue: selectedPaymentMethod,
                  decoration: const InputDecoration(
                    labelText: "Payment Method",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Cash', child: Text('💵 Cash')),
                    DropdownMenuItem(
                      value: 'Bank Transfer',
                      child: Text('🏦 Bank Transfer'),
                    ),
                    DropdownMenuItem(
                      value: 'Credit Card',
                      child: Text('💳 Credit Card'),
                    ),
                    DropdownMenuItem(
                      value: 'Digital Wallet',
                      child: Text('📱 Digital Wallet'),
                    ),
                    DropdownMenuItem(value: 'Check', child: Text('📄 Check')),
                  ],
                  onChanged: (value) =>
                      setState(() => selectedPaymentMethod = value!),
                ),
                const SizedBox(height: 16),

                // Description
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                    hintText: "Optional: What was this expense for?",
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

                final amountError = ValidationService.validateAmount(
                  amountController.text,
                );
                if (amountError != null) {
                  ValidationService.showValidationError(context, amountError);
                  return;
                }

                final amount = double.parse(amountController.text);
                if (_currentBalance < amount) {
                  ValidationService.showValidationError(
                    context,
                    'Insufficient balance',
                  );
                  return;
                }

                // Create transaction record
                final transaction = {
                  'category': selectedCategory,
                  'amount': -amount, // Negative for expense
                  'date': DateTime.now().toIso8601String().split('T')[0],
                  'time': DateTime.now()
                      .toString()
                      .split(' ')[1]
                      .substring(0, 5),
                  'asset': selectedPaymentMethod,
                  'ledger': 'Personal',
                  'remark': descriptionController.text.isNotEmpty
                      ? descriptionController.text
                      : 'Balance deduction',
                  'type': 'expense',
                };

                // Save transaction to database
                await _unifiedDataService.insertTransaction(transaction);

                setState(() {
                  _currentBalance -= amount;
                });
                await _unifiedDataService.updateBalance(
                  'current',
                  _currentBalance,
                );
                await HybridDataService.saveCurrentBalance(_currentBalance);

                // Refresh all data to update income/expense totals
                await _loadData();

                Navigator.of(context).pop();
                ValidationService.showSuccessMessage(
                  context,
                  'Subtracted ฿${amount.toStringAsFixed(2)} for $selectedCategory',
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                "Subtract",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEmergencyDialog() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController targetController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    String selectedCategory = 'Medical';
    String selectedPriority = 'High';
    DateTime selectedTargetDate = DateTime.now().add(const Duration(days: 365));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add Emergency Fund"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fund Name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Fund Name",
                    border: OutlineInputBorder(),
                    hintText: "e.g., Medical Emergency, Car Repair",
                  ),
                ),
                const SizedBox(height: 16),

                // Category Selection
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Medical',
                      child: Text('🏥 Medical'),
                    ),
                    DropdownMenuItem(
                      value: 'Vehicle',
                      child: Text('🚗 Vehicle'),
                    ),
                    DropdownMenuItem(value: 'Home', child: Text('🏠 Home')),
                    DropdownMenuItem(
                      value: 'Job Loss',
                      child: Text('💼 Job Loss'),
                    ),
                    DropdownMenuItem(value: 'Other', child: Text('⚠️ Other')),
                  ],
                  onChanged: (value) =>
                      setState(() => selectedCategory = value!),
                ),
                const SizedBox(height: 16),

                // Priority Selection
                DropdownButtonFormField<String>(
                  initialValue: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: "Priority",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'High',
                      child: Text('🔴 High Priority'),
                    ),
                    DropdownMenuItem(
                      value: 'Medium',
                      child: Text('🟡 Medium Priority'),
                    ),
                    DropdownMenuItem(
                      value: 'Low',
                      child: Text('🟢 Low Priority'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => selectedPriority = value!),
                ),
                const SizedBox(height: 16),

                // Current Amount
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Current Amount",
                    border: OutlineInputBorder(),
                    prefixText: AppConstants.currencySymbol,
                    hintText: "Amount to add now",
                  ),
                ),
                const SizedBox(height: 16),

                // Target Amount
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Target Amount",
                    border: OutlineInputBorder(),
                    prefixText: AppConstants.currencySymbol,
                    hintText: "Goal amount for this fund",
                  ),
                ),
                const SizedBox(height: 16),

                // Target Date
                ListTile(
                  title: const Text("Target Date"),
                  subtitle: Text(
                    "${selectedTargetDate.day}/${selectedTargetDate.month}/${selectedTargetDate.year}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedTargetDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 5),
                      ),
                    );
                    if (date != null) {
                      setState(() {
                        selectedTargetDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                    hintText:
                        "Optional: Describe the purpose of this emergency fund",
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
                if (amountController.text.isEmpty ||
                    nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill in required fields"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  // Add to emergency fund
                  final newAmount = _emergencyFund + amount;
                  await HybridDataService.saveEmergencyFund(newAmount);

                  // Save emergency fund details to database
                  final emergencyFundData = {
                    'name': nameController.text,
                    'current_amount': amount,
                    'target_amount': targetController.text.isNotEmpty
                        ? double.tryParse(targetController.text) ?? 0.0
                        : 0.0,
                    'priority': selectedPriority,
                  };

                  // Save to database using DatabaseService
                  final dbService = DatabaseService();
                  await dbService.insertEmergencyFund(emergencyFundData);

                  // Update UI
                  setState(() {
                    _emergencyFund = newAmount;
                  });

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "฿${amount.toStringAsFixed(2)} added to ${nameController.text} (${selectedCategory})!",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid amount"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text(
                "Add Fund",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddInvestmentDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController targetAmountController =
        TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    String selectedType = 'Stocks';
    String selectedRiskLevel = 'Medium';
    DateTime selectedTargetDate = DateTime.now().add(const Duration(days: 365));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add Investment"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Investment Name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Investment Name",
                    border: OutlineInputBorder(),
                    hintText: "e.g., Apple Stock, Government Bond",
                  ),
                ),
                const SizedBox(height: 16),

                // Investment Type
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: "Investment Type",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Stocks', child: Text('📈 Stocks')),
                    DropdownMenuItem(value: 'Bonds', child: Text('🏛️ Bonds')),
                    DropdownMenuItem(
                      value: 'Mutual Fund',
                      child: Text('💰 Mutual Fund'),
                    ),
                    DropdownMenuItem(value: 'ETF', child: Text('📊 ETF')),
                    DropdownMenuItem(
                      value: 'Crypto',
                      child: Text('₿ Cryptocurrency'),
                    ),
                    DropdownMenuItem(
                      value: 'Real Estate',
                      child: Text('🏠 Real Estate'),
                    ),
                    DropdownMenuItem(value: 'Other', child: Text('💼 Other')),
                  ],
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
                const SizedBox(height: 16),

                // Risk Level
                DropdownButtonFormField<String>(
                  initialValue: selectedRiskLevel,
                  decoration: const InputDecoration(
                    labelText: "Risk Level",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('🟢 Low Risk')),
                    DropdownMenuItem(
                      value: 'Medium',
                      child: Text('🟡 Medium Risk'),
                    ),
                    DropdownMenuItem(
                      value: 'High',
                      child: Text('🔴 High Risk'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => selectedRiskLevel = value!),
                ),
                const SizedBox(height: 16),

                // Current Amount
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Current Amount",
                    border: OutlineInputBorder(),
                    prefixText: AppConstants.currencySymbol,
                    hintText: "Amount to invest now",
                  ),
                ),
                const SizedBox(height: 16),

                // Target Amount
                TextField(
                  controller: targetAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Target Amount",
                    border: OutlineInputBorder(),
                    prefixText: AppConstants.currencySymbol,
                    hintText: "Goal amount for this investment",
                  ),
                ),
                const SizedBox(height: 16),

                // Target Date
                ListTile(
                  title: const Text("Target Date"),
                  subtitle: Text(
                    "${selectedTargetDate.day}/${selectedTargetDate.month}/${selectedTargetDate.year}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedTargetDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 10),
                      ),
                    );
                    if (date != null) {
                      setState(() {
                        selectedTargetDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                    hintText: "Optional: Describe your investment strategy",
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
                if (nameController.text.isEmpty ||
                    amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill in required fields"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  // Add investment
                  final newInvestment = {
                    'name': nameController.text,
                    'type': selectedType,
                    'symbol': nameController.text, // Use name as symbol for now
                    'quantity': 1.0, // Default quantity
                    'purchase_price': amount,
                    'current_price': amount,
                    'purchase_date': DateTime.now().toIso8601String(),
                  };

                  final updatedInvestments = List<Map<String, dynamic>>.from(
                    _investments,
                  );
                  updatedInvestments.add(newInvestment);

                  // Save to database using DatabaseService
                  final dbService = DatabaseService();
                  await dbService.insertInvestment(newInvestment);

                  await HybridDataService.saveInvestments(updatedInvestments);

                  // Update UI
                  setState(() {
                    _investments = updatedInvestments;
                  });

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "฿${amount.toStringAsFixed(2)} invested in ${nameController.text}!",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid amount"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                "Add Investment",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyScenarioCard(
    String title,
    IconData icon,
    Color iconColor,
    String range,
    String status,
    Color statusColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              range,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentCategoryCard(
    String title,
    IconData icon,
    Color iconColor,
    String value,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMedicalEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Medical Emergency"),
        content: const Text(
          "Medical emergency fund covers unexpected medical expenses ranging from ฿5,000 to ฿15,000. This includes hospital visits, emergency treatments, and medical procedures.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showAddEmergencyDialog();
            },
            child: const Text("Add Funds"),
          ),
        ],
      ),
    );
  }

  void _showEducationEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Education Emergency"),
        content: const Text(
          "Education emergency fund covers unexpected educational expenses ranging from ฿2,000 to ฿8,000. This includes school fees, books, supplies, and other educational needs.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showAddEmergencyDialog();
            },
            child: const Text("Add Funds"),
          ),
        ],
      ),
    );
  }

  void _showStocksDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Stocks Portfolio"),
        content: const Text(
          "Your stocks portfolio is currently valued at ฿1,200. This includes various stock investments across different sectors.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showAddInvestmentDialog();
            },
            child: const Text("Add Investment"),
          ),
        ],
      ),
    );
  }

  void _showBondsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Bonds Portfolio"),
        content: const Text(
          "Your bonds portfolio is currently valued at ฿950. This includes government and corporate bonds for stable returns.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showAddInvestmentDialog();
            },
            child: const Text("Add Investment"),
          ),
        ],
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
              _showEditTransactionDialog(transaction);
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text("Edit"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _showDeleteConfirmationDialog(transaction);
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

  void _showEditTransactionDialog(Map<String, dynamic> transaction) {
    final TextEditingController categoryController = TextEditingController(
      text: transaction['category'],
    );
    final TextEditingController amountController = TextEditingController(
      text: transaction['amount'].abs().toString(),
    );
    final TextEditingController remarkController = TextEditingController(
      text: transaction['remark'] ?? '',
    );
    String selectedType = transaction['type'];
    String selectedLedger = transaction['ledger'] ?? 'Personal';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Transaction"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Type Selection
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: "Type",
                  border: OutlineInputBorder(),
                ),
                items: ['expense', 'income'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedType = value!;
                },
              ),
              const SizedBox(height: 16),

              // Category
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Amount
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Asset (fixed to Cash for weekly transactions)
              TextField(
                controller: TextEditingController(
                  text: AppConstants.defaultAsset,
                ),
                decoration: const InputDecoration(
                  labelText: "Asset",
                  border: OutlineInputBorder(),
                ),
                enabled: false,
              ),
              const SizedBox(height: 16),

              // Ledger
              DropdownButtonFormField<String>(
                initialValue: selectedLedger,
                decoration: const InputDecoration(
                  labelText: "Ledger",
                  border: OutlineInputBorder(),
                ),
                items: ['Personal', 'Work', 'Business', 'Family'].map((ledger) {
                  return DropdownMenuItem(value: ledger, child: Text(ledger));
                }).toList(),
                onChanged: (value) {
                  selectedLedger = value!;
                },
              ),
              const SizedBox(height: 16),

              // Remark
              TextField(
                controller: remarkController,
                decoration: const InputDecoration(
                  labelText: "Remark",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
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
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null &&
                  amount > 0 &&
                  categoryController.text.isNotEmpty) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Transaction updated successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please fill in all required fields!"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Transaction"),
        content: Text(
          "Are you sure you want to delete this ${transaction['type']} transaction for ฿${transaction['amount'].abs().toStringAsFixed(2)}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
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

  // Bookmark Methods
  void _bookmarkEmergencyFund() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Emergency Fund bookmarked! Check Bookmarks page in Settings.",
        ),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _bookmarkInvestment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Investment Portfolio bookmarked! Check Bookmarks page in Settings.",
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
