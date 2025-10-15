import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../services/database_service.dart';

class TransactionCalendar extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  final Function(Map<String, dynamic>)? onTransactionUpdated;
  final Function(Map<String, dynamic>)? onTransactionDeleted;

  const TransactionCalendar({
    super.key,
    required this.transactions,
    this.onTransactionUpdated,
    this.onTransactionDeleted,
  });

  @override
  State<TransactionCalendar> createState() => _TransactionCalendarState();
}

class _TransactionCalendarState extends State<TransactionCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String selectedType = "expense";
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Transaction Calendar",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Calendar
          TableCalendar<Map<String, dynamic>>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return _getEventsForDay(day);
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              markersMaxCount: 3,
              markerDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),

          const SizedBox(height: 16),

          // Transaction Type Filter
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
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Selected Day Transactions
          if (_selectedDay != null) ...[
            Text(
              "Transactions for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildDayTransactions(),
          ],
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return widget.transactions.where((transaction) {
      try {
        final transactionDate = DateTime.parse(transaction['date']);
        return isSameDay(transactionDate, day);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  Widget _buildDayTransactions() {
    final dayTransactions = _getEventsForDay(_selectedDay!);
    final filteredTransactions = dayTransactions.where((transaction) {
      return transaction['type'] == selectedType;
    }).toList();

    if (filteredTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          "No transactions for this day",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: filteredTransactions.map((transaction) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              transaction['type'] == 'income'
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: transaction['type'] == 'income'
                  ? Colors.green
                  : Colors.red,
            ),
            title: Text(transaction['category'] ?? 'Unknown'),
            subtitle: Text(transaction['remark'] ?? ''),
            trailing: Text(
              '฿${transaction['amount'].abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transaction['type'] == 'income'
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            onTap: () => _showTransactionDetails(transaction),
          ),
        );
      }).toList(),
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
