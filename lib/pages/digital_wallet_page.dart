// lib/pages/digital_wallet_page.dart
import 'package:flutter/material.dart';

class DigitalWalletPage extends StatefulWidget {
  const DigitalWalletPage({super.key});

  @override
  _DigitalWalletPageState createState() => _DigitalWalletPageState();
}

class _DigitalWalletPageState extends State<DigitalWalletPage> {
  final double _availableBalance = 0.00;
  final List<Map<String, dynamic>> _connectedAccounts = [
    {
      'name': 'Main Account',
      'description': 'Primary spending account',
      'balance': 0.00,
      'icon': Icons.account_balance,
      'color': Colors.purple,
    },
  ];
  final List<Map<String, dynamic>> _recentActivity = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Digital Wallet"),
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
            // Available Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[300]!, Colors.purple[600]!],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Available Balance",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "฿${_availableBalance.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Connected Accounts Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Connected Accounts",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white, size: 20),
                    onPressed: () => _showAddAccountDialog(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Connected Accounts List
            ..._connectedAccounts.map((account) => _buildAccountCard(account)),

            const SizedBox(height: 24),

            // Recent Wallet Activity Section
            const Text(
              "Recent Wallet Activity",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Recent Activity List
            if (_recentActivity.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  "No recent activity",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ..._recentActivity.map(
                (activity) => _buildActivityCard(activity),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(Map<String, dynamic> account) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: account['color'],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(account['icon'], color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  account['description'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            "฿${account['balance'].toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
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
              color: activity['color'],
              shape: BoxShape.circle,
            ),
            child: Icon(activity['icon'], color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity['description'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            activity['amount'],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: activity['type'] == 'income' ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAccountDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    IconData selectedIcon = Icons.account_balance;
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Account"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Name
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Account Name",
                        hintText: "e.g., Savings Account, Credit Card",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Account Description
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        hintText: "Brief description of the account",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Icon Selection
                    const Text("Select Icon:"),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildIconOption(
                          Icons.account_balance,
                          selectedIcon,
                          () {
                            setDialogState(() {
                              selectedIcon = Icons.account_balance;
                            });
                          },
                        ),
                        _buildIconOption(Icons.credit_card, selectedIcon, () {
                          setDialogState(() {
                            selectedIcon = Icons.credit_card;
                          });
                        }),
                        _buildIconOption(Icons.savings, selectedIcon, () {
                          setDialogState(() {
                            selectedIcon = Icons.savings;
                          });
                        }),
                        _buildIconOption(Icons.payment, selectedIcon, () {
                          setDialogState(() {
                            selectedIcon = Icons.payment;
                          });
                        }),
                        _buildIconOption(
                          Icons.account_balance_wallet,
                          selectedIcon,
                          () {
                            setDialogState(() {
                              selectedIcon = Icons.account_balance_wallet;
                            });
                          },
                        ),
                        _buildIconOption(
                          Icons.monetization_on,
                          selectedIcon,
                          () {
                            setDialogState(() {
                              selectedIcon = Icons.monetization_on;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Color Selection
                    const Text("Select Color:"),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildColorOption(Colors.blue, selectedColor, () {
                          setDialogState(() {
                            selectedColor = Colors.blue;
                          });
                        }),
                        _buildColorOption(Colors.green, selectedColor, () {
                          setDialogState(() {
                            selectedColor = Colors.green;
                          });
                        }),
                        _buildColorOption(Colors.orange, selectedColor, () {
                          setDialogState(() {
                            selectedColor = Colors.orange;
                          });
                        }),
                        _buildColorOption(Colors.red, selectedColor, () {
                          setDialogState(() {
                            selectedColor = Colors.red;
                          });
                        }),
                        _buildColorOption(Colors.purple, selectedColor, () {
                          setDialogState(() {
                            selectedColor = Colors.purple;
                          });
                        }),
                        _buildColorOption(Colors.teal, selectedColor, () {
                          setDialogState(() {
                            selectedColor = Colors.teal;
                          });
                        }),
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
                    if (nameController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty) {
                      setState(() {
                        _connectedAccounts.add({
                          'name': nameController.text,
                          'description': descriptionController.text,
                          'balance': 0.00,
                          'icon': selectedIcon,
                          'color': selectedColor,
                        });
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Account added successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
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
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Add Account"),
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
          color: isSelected ? Colors.blue : Colors.grey[200],
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

  Widget _buildColorOption(
    Color color,
    Color selectedColor,
    VoidCallback onTap,
  ) {
    final isSelected = color == selectedColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
