// lib/pages/bookmarks_page.dart
import 'package:flutter/material.dart';

import '../services/database_service.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  _BookmarksPageState createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  // Database service instance
  final DatabaseService _dbService = DatabaseService();

  // Loading state
  bool _isLoading = true;

  // Bookmarked data from database
  List<Map<String, dynamic>> _bookmarkedBudgets = [];
  List<Map<String, dynamic>> _bookmarkedEmergencies = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  /// Load bookmarks from database
  Future<void> _loadBookmarks() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load bookmarked budgets and emergencies from database
      // For now, we'll use sample data but this could be extended to store bookmarks in the database
      _bookmarkedBudgets = await _getBookmarkedBudgets();
      _bookmarkedEmergencies = await _getBookmarkedEmergencies();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading bookmarks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Get bookmarked budgets from database
  Future<List<Map<String, dynamic>>> _getBookmarkedBudgets() async {
    try {
      // Get spending by category from database
      final spendingByCategory = await _dbService.getSpendingByCategory();

      // Convert to budget format
      final List<Map<String, dynamic>> budgets = [];
      final categoryIcons = {
        '🍕 Food & Dining': Icons.restaurant,
        '🚗 Transportation': Icons.directions_car,
        '🛍️ Shopping': Icons.shopping_cart,
        '🏠 Housing': Icons.home,
        '💼 Salary': Icons.work,
        '💳 Freelance': Icons.computer,
        '🎁 Allowance': Icons.card_giftcard,
      };

      final categoryColors = {
        '🍕 Food & Dining': Colors.orange,
        '🚗 Transportation': Colors.blue,
        '🛍️ Shopping': Colors.purple,
        '🏠 Housing': Colors.green,
        '💼 Salary': Colors.teal,
        '💳 Freelance': Colors.indigo,
        '🎁 Allowance': Colors.pink,
      };

      spendingByCategory.forEach((category, spent) {
        // Estimate budget as 1.5x of what was spent
        final estimatedBudget = spent * 1.5;

        budgets.add({
          'title': '$category Budget',
          'amount': estimatedBudget,
          'spent': spent,
          'icon': categoryIcons[category] ?? Icons.category,
          'color': categoryColors[category] ?? Colors.grey,
          'type': 'budget',
        });
      });

      return budgets;
    } catch (e) {
      print('Error getting bookmarked budgets: $e');
      return [];
    }
  }

  /// Get bookmarked emergencies from database
  Future<List<Map<String, dynamic>>> _getBookmarkedEmergencies() async {
    try {
      // Get emergency fund and investment balance from database
      final emergencyFund = await _dbService.getEmergencyBalance();
      final investmentBalance = await _dbService.getInvestmentBalance();

      final List<Map<String, dynamic>> emergencies = [];

      if (emergencyFund > 0) {
        emergencies.add({
          'title': 'Emergency Fund',
          'target': emergencyFund * 2, // Target is 2x current amount
          'saved': emergencyFund,
          'icon': Icons.local_hospital,
          'color': Colors.red,
          'type': 'emergency',
        });
      }

      if (investmentBalance > 0) {
        emergencies.add({
          'title': 'Investment Fund',
          'target': investmentBalance * 3, // Target is 3x current amount
          'saved': investmentBalance,
          'icon': Icons.trending_up,
          'color': Colors.green,
          'type': 'emergency',
        });
      }

      // Add some default emergency scenarios if no funds exist
      if (emergencies.isEmpty) {
        emergencies.addAll([
          {
            'title': 'Medical Emergency Fund',
            'target': 50000.0,
            'saved': 0.0,
            'icon': Icons.local_hospital,
            'color': Colors.red,
            'type': 'emergency',
          },
          {
            'title': 'Car Repair Fund',
            'target': 15000.0,
            'saved': 0.0,
            'icon': Icons.build,
            'color': Colors.orange,
            'type': 'emergency',
          },
        ]);
      }

      return emergencies;
    } catch (e) {
      print('Error getting bookmarked emergencies: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Bookmarks"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bookmarked Budget Plans Section
            _buildSectionHeader(
              "Bookmarked Budget Plans",
              Icons.account_balance_wallet,
            ),
            const SizedBox(height: 16),

            if (_bookmarkedBudgets.isEmpty)
              _buildEmptyState(
                "No bookmarked budget plans",
                "Bookmark budget plans from the Budget Management page to see them here",
                Icons.bookmark_border,
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _bookmarkedBudgets.length,
                itemBuilder: (context, index) {
                  return _buildBudgetCard(_bookmarkedBudgets[index], index);
                },
              ),

            const SizedBox(height: 32),

            // Bookmarked Emergency Scenarios Section
            _buildSectionHeader("Bookmarked Emergency Funds", Icons.warning),
            const SizedBox(height: 16),

            if (_bookmarkedEmergencies.isEmpty)
              _buildEmptyState(
                "No bookmarked emergency funds",
                "Bookmark emergency scenarios from the Emergency tab to see them here",
                Icons.bookmark_border,
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _bookmarkedEmergencies.length,
                itemBuilder: (context, index) {
                  return _buildEmergencyCard(
                    _bookmarkedEmergencies[index],
                    index,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.teal[600], size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(Map<String, dynamic> budget, int index) {
    final percentage = (budget['spent'] / budget['amount']) * 100;
    final remaining = budget['amount'] - budget['spent'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: budget['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(budget['icon'], color: budget['color'], size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "฿${budget['spent'].toStringAsFixed(0)} of ฿${budget['amount'].toStringAsFixed(0)}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark, color: Colors.teal),
                onPressed: () => _removeBookmark(index, 'budget'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: percentage > 80 ? Colors.red : Colors.teal,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${percentage.toStringAsFixed(0)}% used",
                style: TextStyle(
                  color: percentage > 80 ? Colors.red : Colors.teal,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Text(
                "฿${remaining.toStringAsFixed(0)} remaining",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(Map<String, dynamic> emergency, int index) {
    final percentage = (emergency['saved'] / emergency['target']) * 100;
    final remaining = emergency['target'] - emergency['saved'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: emergency['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  emergency['icon'],
                  color: emergency['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emergency['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "฿${emergency['saved'].toStringAsFixed(0)} of ฿${emergency['target'].toStringAsFixed(0)}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark, color: Colors.teal),
                onPressed: () => _removeBookmark(index, 'emergency'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: percentage > 80 ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${percentage.toStringAsFixed(0)}% saved",
                style: TextStyle(
                  color: percentage > 80 ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Text(
                "฿${remaining.toStringAsFixed(0)} to go",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
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
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _removeBookmark(int index, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Remove Bookmark"),
          content: Text("Are you sure you want to remove this bookmark?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (type == 'budget') {
                    _bookmarkedBudgets.removeAt(index);
                  } else {
                    _bookmarkedEmergencies.removeAt(index);
                  }
                });

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Bookmark removed successfully!"),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("Remove"),
            ),
          ],
        );
      },
    );
  }
}
