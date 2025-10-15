import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../services/validation_service.dart';

class CashRecordsPage extends StatefulWidget {
  const CashRecordsPage({super.key});

  @override
  State<CashRecordsPage> createState() => _CashRecordsPageState();
}

class _CashRecordsPageState extends State<CashRecordsPage> {
  List<Map<String, dynamic>> allTransactions = [];
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _dbService.getAllTransactions();
      setState(() {
        allTransactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ValidationService.showErrorMessage(
        context,
        'Failed to load transactions: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cash Records"),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : allTransactions.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No Cash Records",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Add some transactions to see your cash records here",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allTransactions.length,
              itemBuilder: (context, index) {
                final transaction = allTransactions[index];
                final isExpense = transaction['type'] == 'expense';
                final amount = transaction['amount'].abs();

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isExpense ? Colors.red : Colors.green,
                      child: Icon(
                        isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      transaction['category'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (transaction['remark'] != null &&
                            transaction['remark'].isNotEmpty)
                          Text(transaction['remark']),
                        Text(
                          'Date: ${transaction['date']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '฿${amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isExpense ? Colors.red : Colors.green,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          isExpense ? 'Expense' : 'Income',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showTransactionDetails(transaction),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: "cash_records_fab",
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Add transaction feature temporarily disabled"),
              backgroundColor: Colors.orange,
            ),
          );
        },
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Transaction Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Category: ${transaction['category']}"),
            Text("Amount: ฿${transaction['amount'].abs().toStringAsFixed(2)}"),
            Text("Type: ${transaction['type']}"),
            Text("Date: ${transaction['date']}"),
            if (transaction['remark'] != null &&
                transaction['remark'].isNotEmpty)
              Text("Remark: ${transaction['remark']}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
