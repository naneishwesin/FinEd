// lib/pages/assets_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../services/tutorial_service.dart';
import 'cash_records_page.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});

  @override
  _AssetsPageState createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  String _selectedChart = "Assets"; // "Assets" or "Liabilities"
  String _selectedTimePeriod = "All Time";

  // Database service instance
  final DatabaseService _dbService = DatabaseService();

  // Loading state
  bool _isLoading = true;

  // Dynamic data from database
  double _totalAssets = 0.0;
  double _totalLiabilities = 0.0;
  double _cashAmount = 0.0;
  List<Map<String, dynamic>> _cashTransactions = [];
  List<Map<String, dynamic>> _assets = [];
  List<Map<String, dynamic>> _liabilities = [];

  // Cached chart data for performance
  List<Map<String, dynamic>>? _cachedAssetsData;
  List<Map<String, dynamic>>? _cachedLiabilitiesData;

  @override
  void initState() {
    super.initState();
    _loadAssetsData();
    _showTutorials();
  }

  /// Load assets data from database
  Future<void> _loadAssetsData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load current balance as cash amount
      _cashAmount = await _dbService.getCurrentBalance();

      // Load emergency fund as part of assets
      final emergencyFund = await _dbService.getEmergencyBalance();

      // Load investment balance as part of assets
      final investmentBalance = await _dbService.getInvestmentBalance();

      // Load custom assets from database
      _assets = await _dbService.getAllAssets();
      final customAssetsTotal = _assets.fold(
        0.0,
        (sum, asset) => sum + (asset['amount'] as double),
      );

      // Calculate total assets (cash + emergency + investment + custom assets)
      _totalAssets =
          _cashAmount + emergencyFund + investmentBalance + customAssetsTotal;

      // Load liabilities from database
      _liabilities = await _dbService.getAllLiabilities();
      _totalLiabilities = _liabilities.fold(
        0.0,
        (sum, liability) => sum + (liability['amount'] as double),
      );

      // Load cash transactions
      _cashTransactions = await _dbService.getTransactionsByAsset('Cash');

      // Cache chart data for performance
      _cachedAssetsData = await _getAssetsData();
      _cachedLiabilitiesData = _getLiabilitiesData();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading assets data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showTutorials() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAssetsPageTutorial();
    });
  }

  void _showAssetsPageTutorial() {
    if (!TutorialService.isTutorialCompleted(
      TutorialService.assetsPageOverview,
    )) {
      TutorialService.showTutorial(
        context,
        TutorialService.assetsPageOverview,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Assets & Liabilities Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Here you can:\n'
              '• View your total assets and liabilities\n'
              '• Analyze trending charts over time\n'
              '• Filter data by time periods\n'
              '• Manage cash transactions\n'
              '• View asset/liability breakdowns',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Assets"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAssetDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Assets and Liabilities Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildAmountCard(
                            "Assets",
                            _totalAssets,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildAmountCard(
                            "Liabilities",
                            _totalLiabilities,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Section 2: Trending Chart
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
                                "Trending Chart",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  _buildChartButton(
                                    "Assets",
                                    _selectedChart == "Assets",
                                  ),
                                  const SizedBox(width: 8),
                                  _buildChartButton(
                                    "Liabilities",
                                    _selectedChart == "Liabilities",
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Time Period Filter
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedTimePeriod,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (String value) {
                                          setState(() {
                                            _selectedTimePeriod = value;
                                          });
                                        },
                                        itemBuilder: (BuildContext context) => [
                                          const PopupMenuItem<String>(
                                            value: "Last Month",
                                            child: Text("Last Month"),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: "Last Week",
                                            child: Text("Last Week"),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: "Last Quarter",
                                            child: Text("Last Quarter"),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: "Last Year",
                                            child: Text("Last Year"),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: "All Time",
                                            child: Text("All Time"),
                                          ),
                                        ],
                                        child: Icon(
                                          Icons.filter_list,
                                          color: Colors.grey[600],
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Chart
                          SizedBox(
                            height: 200,
                            child: FutureBuilder<List<FlSpot>>(
                              future: _getChartData(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final spots = snapshot.data ?? [];
                                return LineChart(
                                  LineChartData(
                                    gridData: FlGridData(show: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      rightTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            // Generate labels based on actual dates
                                            String label = '';
                                            final now = DateTime.now();

                                            if (_selectedTimePeriod ==
                                                "Last Week") {
                                              // Show actual dates for last week
                                              final date = now.subtract(
                                                Duration(
                                                  days: 6 - value.toInt(),
                                                ),
                                              );
                                              final weekdays = [
                                                'Mon',
                                                'Tue',
                                                'Wed',
                                                'Thu',
                                                'Fri',
                                                'Sat',
                                                'Sun',
                                              ];
                                              label =
                                                  weekdays[date.weekday - 1];
                                            } else if (_selectedTimePeriod ==
                                                "Last Month") {
                                              // Show day numbers for last month
                                              final dayNumber =
                                                  value.toInt() + 1;
                                              if (dayNumber <= 30) {
                                                label = '${dayNumber}';
                                              }
                                            } else if (_selectedTimePeriod ==
                                                "Last Year") {
                                              // Show actual month names for last year
                                              final monthIndex = value.toInt();
                                              final months = [
                                                'Jan',
                                                'Feb',
                                                'Mar',
                                                'Apr',
                                                'May',
                                                'Jun',
                                                'Jul',
                                                'Aug',
                                                'Sep',
                                                'Oct',
                                                'Nov',
                                                'Dec',
                                              ];
                                              if (monthIndex >= 0 &&
                                                  monthIndex < months.length) {
                                                label = months[monthIndex];
                                              }
                                            } else {
                                              // Default: Last 6 months - show actual months
                                              final monthIndex = value.toInt();
                                              final currentMonth = now.month;
                                              final months = [
                                                'Jan',
                                                'Feb',
                                                'Mar',
                                                'Apr',
                                                'May',
                                                'Jun',
                                                'Jul',
                                                'Aug',
                                                'Sep',
                                                'Oct',
                                                'Nov',
                                                'Dec',
                                              ];

                                              // Calculate which month to show (going backwards)
                                              int monthToShow =
                                                  currentMonth -
                                                  (5 - monthIndex);
                                              if (monthToShow <= 0)
                                                monthToShow += 12;

                                              if (monthIndex >= 0 &&
                                                  monthIndex < 6) {
                                                label = months[monthToShow - 1];
                                              }
                                            }

                                            return Text(label);
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: spots,
                                        isCurved: true,
                                        color: _selectedChart == "Assets"
                                            ? Colors.green
                                            : Colors.red,
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(show: false),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color:
                                              (_selectedChart == "Assets"
                                                      ? Colors.green
                                                      : Colors.red)
                                                  .withValues(alpha: 0.1),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section 3: Cash Card
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CashRecordsPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.purple],
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
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Liquid Cash",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "฿${_cashAmount.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Available Balance",
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section 4: Assets Donut Chart
                    _buildDonutChartCard(
                      "Assets",
                      _cachedAssetsData ?? [],
                      Colors.green,
                    ),

                    const SizedBox(height: 20),

                    // Section 5: Liabilities Donut Chart
                    _buildDonutChartCard(
                      "Liabilities",
                      _cachedLiabilitiesData ?? [],
                      Colors.red,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAmountCard(String title, double amount, Color color) {
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
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "฿${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartButton(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChart = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (title == "Assets" ? Colors.green : Colors.red)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDonutChartCard(
    String title,
    List<Map<String, dynamic>> data,
    Color primaryColor,
  ) {
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
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Donut Chart
              Expanded(
                flex: 2,
                child: RepaintBoundary(
                  child: SizedBox(
                    height: 120,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        sections: data.map((item) {
                          final totalAmount = data.fold(
                            0.0,
                            (sum, item) => sum + item['amount'],
                          );
                          // Ensure percentage doesn't exceed 100% due to data inconsistencies
                          final percentage = totalAmount > 0
                              ? ((item['amount'] / totalAmount) * 100).clamp(
                                  0.0,
                                  100.0,
                                )
                              : 0.0;
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
                    final totalAmount = data.fold(
                      0.0,
                      (sum, item) => sum + item['amount'],
                    );
                    // Ensure percentage doesn't exceed 100% due to data inconsistencies
                    final percentage = totalAmount > 0
                        ? ((item['amount'] / totalAmount) * 100).clamp(
                            0.0,
                            100.0,
                          )
                        : 0.0;
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
    );
  }

  Future<List<FlSpot>> _getChartData() async {
    // Get real historical data based on selected time period
    final now = DateTime.now();
    List<FlSpot> spots = [];

    if (_selectedTimePeriod == "Last Week") {
      // Last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final amount = await _getHistoricalAmount(date, _selectedChart);
        spots.add(FlSpot((6 - i).toDouble(), amount));
      }
    } else if (_selectedTimePeriod == "Last Month") {
      // Last 30 days
      for (int i = 29; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final amount = await _getHistoricalAmount(date, _selectedChart);
        spots.add(FlSpot((29 - i).toDouble(), amount));
      }
    } else if (_selectedTimePeriod == "Last Year") {
      // Last 12 months
      for (int i = 11; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        final amount = await _getHistoricalAmount(date, _selectedChart);
        spots.add(FlSpot((11 - i).toDouble(), amount));
      }
    } else {
      // Default: Last 6 months
      for (int i = 5; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        final amount = await _getHistoricalAmount(date, _selectedChart);
        spots.add(FlSpot((5 - i).toDouble(), amount));
      }
    }

    return spots;
  }

  Future<double> _getHistoricalAmount(DateTime date, String chartType) async {
    // Calculate historical amount based on transactions up to that date
    double amount = 0.0;

    // Get transactions from database
    final transactions = await _dbService.getAllTransactions();

    // Sort transactions by date to calculate running balance
    transactions.sort(
      (a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])),
    );

    for (var transaction in transactions) {
      try {
        final transactionDate = DateTime.parse(transaction['date']);
        if (transactionDate.isBefore(date) ||
            transactionDate.isAtSameMomentAs(date)) {
          if (chartType == "Assets") {
            // For assets, calculate running balance
            if (transaction['type'] == 'income') {
              amount += transaction['amount'].abs();
            } else if (transaction['type'] == 'expense') {
              amount -= transaction['amount'].abs();
            }
          } else {
            // For liabilities, calculate total expenses up to that date
            if (transaction['type'] == 'expense') {
              amount += transaction['amount'].abs();
            }
          }
        }
      } catch (e) {
        // Skip invalid dates
      }
    }

    // Ensure amount is not negative for display
    return amount.abs();
  }

  Future<List<Map<String, dynamic>>> _getAssetsData() async {
    final List<Map<String, dynamic>> assetsData = [];

    // Always show all categories, even if 0
    final categories = [
      {
        'category': '💰 Liquid Cash',
        'amount': _cashAmount,
        'color': Colors.blue,
        'icon': Icons.account_balance_wallet,
      },
      {
        'category': '🚨 Emergency Fund',
        'amount': await _dbService.getEmergencyBalance(),
        'color': Colors.green,
        'icon': Icons.emergency,
      },
      {
        'category': '📈 Investments',
        'amount': await _dbService.getInvestmentBalance(),
        'color': Colors.purple,
        'icon': Icons.trending_up,
      },
      {
        'category': '🏠 Real Estate',
        'amount': 0.0,
        'color': Colors.brown,
        'icon': Icons.home,
      },
      {
        'category': '🚗 Vehicles',
        'amount': 0.0,
        'color': Colors.orange,
        'icon': Icons.directions_car,
      },
      {
        'category': '💻 Electronics',
        'amount': 0.0,
        'color': Colors.cyan,
        'icon': Icons.computer,
      },
      {
        'category': '💎 Jewelry',
        'amount': 0.0,
        'color': Colors.pink,
        'icon': Icons.diamond,
      },
      {
        'category': '📱 Digital Assets',
        'amount': 0.0,
        'color': Colors.indigo,
        'icon': Icons.phone_android,
      },
    ];

    // Add predefined categories
    for (final category in categories) {
      assetsData.add({
        'category': category['category'],
        'amount': category['amount'] as double,
        'color': category['color'] as Color,
        'icon': category['icon'] as IconData,
      });
    }

    // Add custom assets from database
    for (final asset in _assets) {
      // Check if this asset category already exists
      final existingIndex = assetsData.indexWhere(
        (item) => item['category'] == asset['name'],
      );

      if (existingIndex != -1) {
        // Update existing category
        assetsData[existingIndex]['amount'] = asset['amount'] as double;
        assetsData[existingIndex]['color'] = Color(
          int.parse(asset['color'].toString().replaceAll('#', '0xff')),
        );
      } else {
        // Add new custom asset
        assetsData.add({
          'category': asset['name'],
          'amount': asset['amount'] as double,
          'color': Color(
            int.parse(asset['color'].toString().replaceAll('#', '0xff')),
          ),
          'icon': Icons.category,
        });
      }
    }

    // Filter out categories with 0 amount for better visualization
    // But keep at least 3 categories for a meaningful chart
    final nonZeroAssets = assetsData
        .where((item) => item['amount'] > 0)
        .toList();
    if (nonZeroAssets.length >= 3) {
      return nonZeroAssets;
    } else {
      // If less than 3 categories have values, show top 3 by amount
      assetsData.sort(
        (a, b) => (b['amount'] as double).compareTo(a['amount'] as double),
      );
      return assetsData.take(3).toList();
    }
  }

  List<Map<String, dynamic>> _getLiabilitiesData() {
    final List<Map<String, dynamic>> liabilitiesData = [];

    // Always show all liability categories, even if 0
    final categories = [
      {
        'category': '🏠 Mortgage',
        'amount': 0.0,
        'color': Colors.red,
        'icon': Icons.home,
      },
      {
        'category': '🚗 Car Loan',
        'amount': 0.0,
        'color': Colors.deepOrange,
        'icon': Icons.directions_car,
      },
      {
        'category': '💳 Credit Card',
        'amount': 0.0,
        'color': Colors.purple,
        'icon': Icons.credit_card,
      },
      {
        'category': '📚 Student Loan',
        'amount': 0.0,
        'color': Colors.blue,
        'icon': Icons.school,
      },
      {
        'category': '🏥 Medical Bills',
        'amount': 0.0,
        'color': Colors.pink,
        'icon': Icons.local_hospital,
      },
      {
        'category': '⚡ Utilities',
        'amount': 0.0,
        'color': Colors.yellow,
        'icon': Icons.electrical_services,
      },
      {
        'category': '📱 Phone Bill',
        'amount': 0.0,
        'color': Colors.cyan,
        'icon': Icons.phone,
      },
      {
        'category': '🌐 Internet',
        'amount': 0.0,
        'color': Colors.indigo,
        'icon': Icons.wifi,
      },
    ];

    // Add predefined categories
    for (final category in categories) {
      liabilitiesData.add({
        'category': category['category'],
        'amount': category['amount'] as double,
        'color': category['color'] as Color,
        'icon': category['icon'] as IconData,
      });
    }

    // Add custom liabilities from database
    for (final liability in _liabilities) {
      // Check if this liability category already exists
      final existingIndex = liabilitiesData.indexWhere(
        (item) => item['category'] == liability['name'],
      );

      if (existingIndex != -1) {
        // Update existing category
        liabilitiesData[existingIndex]['amount'] =
            liability['amount'] as double;
        liabilitiesData[existingIndex]['color'] = Color(
          int.parse(liability['color'].toString().replaceAll('#', '0xff')),
        );
      } else {
        // Add new custom liability
        liabilitiesData.add({
          'category': liability['name'],
          'amount': liability['amount'] as double,
          'color': Color(
            int.parse(liability['color'].toString().replaceAll('#', '0xff')),
          ),
          'icon': Icons.warning,
        });
      }
    }

    // Filter out categories with 0 amount for better visualization
    // But keep at least 3 categories for a meaningful chart
    final nonZeroLiabilities = liabilitiesData
        .where((item) => item['amount'] > 0)
        .toList();
    if (nonZeroLiabilities.length >= 3) {
      return nonZeroLiabilities;
    } else {
      // If less than 3 categories have values, show top 3 by amount
      liabilitiesData.sort(
        (a, b) => (b['amount'] as double).compareTo(a['amount'] as double),
      );
      return liabilitiesData.take(3).toList();
    }
  }

  // CRUD Operations for Assets
  void _showAddAssetDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    String selectedType = 'asset';
    String selectedCategory = 'General';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add Asset/Liability"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Type Selection
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Asset'),
                        value: 'asset',
                        groupValue: selectedType,
                        onChanged: (value) =>
                            setState(() => selectedType = value!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Liability'),
                        value: 'liability',
                        groupValue: selectedType,
                        onChanged: (value) =>
                            setState(() => selectedType = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                    hintText: "e.g., House, Car, Credit Card",
                  ),
                ),
                const SizedBox(height: 16),

                // Amount
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                    prefixText: "฿",
                  ),
                ),
                const SizedBox(height: 16),

                // Category Selection
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'General',
                      child: Text('🏠 General'),
                    ),
                    DropdownMenuItem(
                      value: 'Food',
                      child: Text('🍕 Food & Dining'),
                    ),
                    DropdownMenuItem(
                      value: 'Car',
                      child: Text('🚗 Transportation'),
                    ),
                    DropdownMenuItem(
                      value: 'Education',
                      child: Text('📚 Education'),
                    ),
                    DropdownMenuItem(
                      value: 'Healthcare',
                      child: Text('🏥 Healthcare'),
                    ),
                    DropdownMenuItem(
                      value: 'Entertainment',
                      child: Text('🎬 Entertainment'),
                    ),
                    DropdownMenuItem(
                      value: 'Shopping',
                      child: Text('🛒 Shopping'),
                    ),
                    DropdownMenuItem(
                      value: 'Utilities',
                      child: Text('💡 Utilities'),
                    ),
                    DropdownMenuItem(
                      value: 'Investment',
                      child: Text('📈 Investment'),
                    ),
                    DropdownMenuItem(value: 'Other', child: Text('💳 Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
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
                      content: Text("Please fill in all fields"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final amount = double.parse(amountController.text);
                  final item = {
                    'name': nameController.text,
                    'amount': amount,
                    'type': selectedType,
                    'category': selectedCategory,
                  };

                  if (selectedType == 'asset') {
                    await _dbService.insertAsset(item);
                  } else {
                    await _dbService.insertLiability(item);
                  }

                  // Reload data to reflect changes
                  await _loadAssetsData();

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${selectedType == 'asset' ? 'Asset' : 'Liability'} '${nameController.text}' added!",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error adding $selectedType: $e"),
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

  void _showColorPicker(StateSetter setState, Function(Color) onColorSelected) {
    final List<Color> colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Color"),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors.map((color) {
              return GestureDetector(
                onTap: () {
                  onColorSelected(color);
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Time Period"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Last Month"),
              onTap: () {
                setState(() {
                  _selectedTimePeriod = "Last Month";
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text("Last Week"),
              onTap: () {
                setState(() {
                  _selectedTimePeriod = "Last Week";
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text("All Time"),
              onTap: () {
                setState(() {
                  _selectedTimePeriod = "All Time";
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
