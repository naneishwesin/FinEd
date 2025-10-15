// lib/pages/financial_goals_page.dart
import 'package:flutter/material.dart';

import '../services/database_service.dart';

class FinancialGoalsPage extends StatefulWidget {
  const FinancialGoalsPage({super.key});

  @override
  _FinancialGoalsPageState createState() => _FinancialGoalsPageState();
}

class _FinancialGoalsPageState extends State<FinancialGoalsPage> {
  // Database service instance
  final DatabaseService _dbService = DatabaseService();

  // Loading state
  bool _isLoading = true;

  // Dynamic data from database
  int _activeGoals = 0;
  double _totalSaved = 0.0;
  List<Map<String, dynamic>> _userGoals = [];

  @override
  void initState() {
    super.initState();
    _loadGoalsData();
  }

  /// Load financial goals data from database
  Future<void> _loadGoalsData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load emergency fund and investment balances as saved amounts
      final emergencyFund = await _dbService.getEmergencyBalance();
      final investmentBalance = await _dbService.getInvestmentBalance();

      _totalSaved = emergencyFund + investmentBalance;

      // For now, use sample goals (could be extended to store goals in database)
      _userGoals = [
        {
          'title': 'Emergency Fund',
          'target': 50000.0,
          'saved': emergencyFund,
          'icon': Icons.local_hospital,
          'color': Colors.red,
          'deadline': 'Dec 2024',
        },
        {
          'title': 'Investment Portfolio',
          'target': 100000.0,
          'saved': investmentBalance,
          'icon': Icons.trending_up,
          'color': Colors.green,
          'deadline': 'Dec 2025',
        },
      ];

      _activeGoals = _userGoals.length;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading goals data: $e');
      setState(() {
        _isLoading = false;
      });
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
        title: const Text("Financial Goals"),
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
            // Active Goals & Total Saved Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[300]!, Colors.blue[400]!],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        "Active Goals",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$_activeGoals",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "Total Saved",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "฿${_totalSaved.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Your Goals Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Your Goals",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.purple[300],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white, size: 20),
                    onPressed: () => _showAddGoalDialog(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Your Goals List
            if (_userGoals.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No goals set yet",
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
              ..._userGoals.map((goal) => _buildGoalCard(goal)),

            const SizedBox(height: 24),

            // Goal Suggestions Section
            const Text(
              "Goal Suggestions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Education Fund Suggestion
            _buildGoalSuggestionCard(
              "Education Fund",
              Icons.school,
              "Save for courses or certifications.",
              () => _addSuggestionGoal("Education Fund", Icons.school),
            ),

            const SizedBox(height: 12),

            // New Laptop Suggestion
            _buildGoalSuggestionCard(
              "New Laptop",
              Icons.laptop,
              "Upgrade your technology.",
              () => _addSuggestionGoal("New Laptop", Icons.laptop),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
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
              color: Colors.purple[300],
              shape: BoxShape.circle,
            ),
            child: Icon(goal['icon'], color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Target: ฿${goal['target'].toStringAsFixed(2)}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (goal['saved'] / goal['target']).clamp(
                      0.0,
                      1.0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.purple[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Saved: ฿${goal['saved'].toStringAsFixed(2)} (${((goal['saved'] / goal['target']) * 100).toStringAsFixed(0)}%)",
                  style: TextStyle(
                    color: Colors.purple[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSuggestionCard(
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.purple[300],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController targetController = TextEditingController();
    IconData selectedIcon = Icons.flag;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add New Goal"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Goal Title
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Goal Title",
                        hintText: "e.g., Vacation Fund, New Phone",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Target Amount
                    TextField(
                      controller: targetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Target Amount",
                        hintText: "Enter target amount in ฿",
                        border: OutlineInputBorder(),
                        prefixText: "฿",
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Icon Selection
                    const Text("Select Icon:"),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildIconOption(Icons.flag, selectedIcon, () {
                          setDialogState(() {
                            selectedIcon = Icons.flag;
                          });
                        }),
                        _buildIconOption(Icons.school, selectedIcon, () {
                          setDialogState(() {
                            selectedIcon = Icons.school;
                          });
                        }),
                        _buildIconOption(Icons.laptop, selectedIcon, () {
                          setDialogState(() {
                            selectedIcon = Icons.laptop;
                          });
                        }),
                        _buildIconOption(Icons.home, selectedIcon, () {
                          setDialogState(() {
                            selectedIcon = Icons.home;
                          });
                        }),
                        _buildIconOption(
                          Icons.directions_car,
                          selectedIcon,
                          () {
                            setDialogState(() {
                              selectedIcon = Icons.directions_car;
                            });
                          },
                        ),
                        _buildIconOption(
                          Icons.airplane_ticket,
                          selectedIcon,
                          () {
                            setDialogState(() {
                              selectedIcon = Icons.airplane_ticket;
                            });
                          },
                        ),
                      ],
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
                    if (titleController.text.isNotEmpty &&
                        targetController.text.isNotEmpty) {
                      final target = double.tryParse(targetController.text);
                      if (target != null && target > 0) {
                        setState(() {
                          _userGoals.add({
                            'title': titleController.text,
                            'target': target,
                            'saved': 0.0,
                            'icon': selectedIcon,
                          });
                          _activeGoals = _userGoals.length;
                        });
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Goal added successfully!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter a valid target amount"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill in all fields"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Add Goal"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildIconOption(
    IconData icon,
    IconData selectedIcon,
    VoidCallback onTap,
  ) {
    final isSelected = icon == selectedIcon;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple[600] : Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[600],
          size: 20,
        ),
      ),
    );
  }

  void _addSuggestionGoal(String title, IconData icon) {
    final TextEditingController targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add $title Goal"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Set your target amount for $title"),
              const SizedBox(height: 16),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Target Amount",
                  hintText: "Enter target amount in ฿",
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
                final target = double.tryParse(targetController.text);
                if (target != null && target > 0) {
                  setState(() {
                    _userGoals.add({
                      'title': title,
                      'target': target,
                      'saved': 0.0,
                      'icon': icon,
                    });
                    _activeGoals = _userGoals.length;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("$title goal added successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid target amount"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[600],
                foregroundColor: Colors.white,
              ),
              child: const Text("Add Goal"),
            ),
          ],
        );
      },
    );
  }
}
