// lib/pages/quick_calculator_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/database_service.dart';
import '../services/validation_service.dart';

class QuickCalculatorPage extends StatefulWidget {
  const QuickCalculatorPage({super.key});

  @override
  _QuickCalculatorPageState createState() => _QuickCalculatorPageState();
}

class _QuickCalculatorPageState extends State<QuickCalculatorPage> {
  String _selectedType = 'Expenses';
  String _selectedCategory = 'Food';
  String _amount = '';
  String _remark = '';
  DateTime _selectedDate = DateTime.now();
  String _selectedLedger = 'Default Ledger';
  String _selectedPayment = 'Cash';

  // Database service instance
  final DatabaseService _dbService = DatabaseService();

  /// Notify other pages that data has changed
  void _notifyDataChanged() {
    // This will trigger a refresh in other pages
    print(
      'Quick calculator transaction added - data changed notification sent',
    );
  }

  final List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'Food', 'icon': Icons.restaurant, 'color': Color(0xFFD4A574)},
    {'name': 'Fruit', 'icon': Icons.apple, 'color': Color(0xFFF4A460)},
    {'name': 'Drink', 'icon': Icons.local_drink, 'color': Color(0xFF87CEEB)},
    {'name': 'Dessert', 'icon': Icons.cake, 'color': Color(0xFFF4A460)},
    {'name': 'Noodle', 'icon': Icons.ramen_dining, 'color': Color(0xFFF4A460)},
    {'name': 'Greens', 'icon': Icons.eco, 'color': Color(0xFF90EE90)},
    {'name': 'Coffee', 'icon': Icons.coffee, 'color': Color(0xFFF4A460)},
    {'name': 'Car', 'icon': Icons.directions_car, 'color': Color(0xFF87CEEB)},
    {'name': 'Bus', 'icon': Icons.directions_bus, 'color': Color(0xFFF4A460)},
    {'name': 'Plane', 'icon': Icons.flight, 'color': Color(0xFF87CEEB)},
    {
      'name': 'Shoes',
      'icon': Icons.directions_walk,
      'color': Color(0xFF87CEEB),
    },
    {'name': 'Clothes', 'icon': Icons.checkroom, 'color': Color(0xFF87CEEB)},
    {'name': 'Watch', 'icon': Icons.watch, 'color': Color(0xFFDDA0DD)},
    {'name': 'Cosmetic', 'icon': Icons.face, 'color': Color(0xFFDDA0DD)},
    {'name': 'Game', 'icon': Icons.sports_esports, 'color': Color(0xFFDDA0DD)},
    {'name': 'Sport', 'icon': Icons.sports_soccer, 'color': Color(0xFFDDA0DD)},
    {'name': 'Pill', 'icon': Icons.medication, 'color': Color(0xFFF4A460)},
    {
      'name': 'Tooth',
      'icon': Icons.health_and_safety,
      'color': Color(0xFF87CEEB),
    },
    {
      'name': 'Clean',
      'icon': Icons.cleaning_services,
      'color': Color(0xFF90EE90),
    },
    {
      'name': 'Medical',
      'icon': Icons.local_hospital,
      'color': Color(0xFFFFB6C1),
    },
    {'name': 'Party', 'icon': Icons.celebration, 'color': Color(0xFF90EE90)},
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {'name': 'Salary', 'icon': Icons.work, 'color': Color(0xFF90EE90)},
    {'name': 'Freelance', 'icon': Icons.laptop, 'color': Color(0xFF87CEEB)},
    {
      'name': 'Investment',
      'icon': Icons.trending_up,
      'color': Color(0xFFDDA0DD),
    },
    {'name': 'Gift', 'icon': Icons.card_giftcard, 'color': Color(0xFFF4A460)},
    {'name': 'Bonus', 'icon': Icons.star, 'color': Color(0xFFFFD700)},
    {'name': 'Other', 'icon': Icons.more_horiz, 'color': Color(0xFFD3D3D3)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Quick Calculator',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Transaction Type Selection
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTypeButton('Expenses', _selectedType == 'Expenses'),
                _buildTypeButton('Income', _selectedType == 'Income'),
              ],
            ),
          ),

          // Category Grid
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedType == 'Expenses'
                    ? _expenseCategories.length
                    : _incomeCategories.length,
                itemBuilder: (context, index) {
                  final categories = _selectedType == 'Expenses'
                      ? _expenseCategories
                      : _incomeCategories;
                  final category = categories[index];
                  final isSelected = _selectedCategory == category['name'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['name'];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? category['color']
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category['icon'],
                            color: isSelected ? Colors.white : Colors.grey[600],
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            category['name'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Input Fields
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Amount and Remark Row
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField('Amount', _amount, (value) {
                        setState(() {
                          _amount = value;
                        });
                      }),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField('Remark', _remark, (value) {
                        setState(() {
                          _remark = value;
                        });
                      }),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Date, Ledger, Cash Row
                Row(
                  children: [
                    Expanded(child: _buildDateField()),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdownField(
                        'Ledger',
                        _selectedLedger,
                        ['Default Ledger', 'Personal', 'Business'],
                        (value) {
                          setState(() {
                            _selectedLedger = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdownField(
                        'Payment',
                        _selectedPayment,
                        ['Cash', 'Card', 'Bank Transfer'],
                        (value) {
                          setState(() {
                            _selectedPayment = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Numeric Keypad
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Keypad Rows
                  Expanded(
                    child: Column(
                      children: [
                        _buildKeypadRow(['1', '2', '3', '+']),
                        _buildKeypadRow(['4', '5', '6', '-']),
                        _buildKeypadRow(['7', '8', '9', '←']),
                        _buildKeypadRow(['0', '.', '=', '✓']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String type, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            // Reset category when switching type
            if (type == 'Expenses') {
              _selectedCategory = 'Food';
            } else {
              _selectedCategory = 'Salary';
            }
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            type,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String value,
    Function(String) onChanged,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          TextField(
            controller: TextEditingController(text: value),
            onChanged: onChanged,
            keyboardType: label == 'Amount'
                ? TextInputType.number
                : TextInputType.text,
            inputFormatters: label == 'Amount'
                ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                : null,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: label == 'Amount' ? '0.00' : 'Enter remark',
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(Duration(days: 365)),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            SizedBox(height: 4),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
              items: options.map<DropdownMenuItem<String>>((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option, style: TextStyle(fontSize: 14)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Expanded(
      child: Row(
        children: keys.map((key) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.all(2),
              child: ElevatedButton(
                onPressed: () => _onKeyPressed(key),
                style: ElevatedButton.styleFrom(
                  backgroundColor: key == '✓' ? Colors.red : Colors.grey[100],
                  foregroundColor: key == '✓' ? Colors.white : Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  key,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (key == '←') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
      } else if (key == '=') {
        // Calculate result if needed
        _calculateResult();
      } else if (key == '✓') {
        _saveTransaction();
      } else if (key == '+' || key == '-') {
        // Handle operators
        _amount += key;
      } else {
        _amount += key;
      }
    });
  }

  void _calculateResult() {
    try {
      // Simple calculation for demonstration
      if (_amount.contains('+') || _amount.contains('-')) {
        // Basic arithmetic operations
        double result = 0;
        if (_amount.contains('+')) {
          List<String> parts = _amount.split('+');
          if (parts.length == 2) {
            result =
                (double.tryParse(parts[0]) ?? 0) +
                (double.tryParse(parts[1]) ?? 0);
          }
        } else if (_amount.contains('-')) {
          List<String> parts = _amount.split('-');
          if (parts.length == 2) {
            result =
                (double.tryParse(parts[0]) ?? 0) -
                (double.tryParse(parts[1]) ?? 0);
          }
        }
        _amount = result.toStringAsFixed(2);
      }
    } catch (e) {
      _amount = 'Error';
    }
  }

  void _saveTransaction() async {
    if (_amount.isEmpty || _amount == '0.00') {
      ValidationService.showValidationError(context, 'Please enter an amount');
      return;
    }

    // Validate amount
    final amountError = ValidationService.validateAmount(_amount);
    if (amountError != null) {
      ValidationService.showValidationError(context, amountError);
      return;
    }

    try {
      final amount = double.parse(_amount);
      final isExpense = _selectedType == 'Expenses';

      // For expenses, make amount negative; for income, keep positive
      final transactionAmount = isExpense ? -amount : amount;

      // Create transaction data
      final transaction = {
        'category': _selectedCategory,
        'amount': transactionAmount,
        'date': _selectedDate.toIso8601String().split(
          'T',
        )[0], // YYYY-MM-DD format
        'time': DateTime.now()
            .toString()
            .split(' ')[1]
            .substring(0, 5), // HH:MM format
        'asset': _selectedPayment,
        'ledger': _selectedLedger,
        'remark': _remark.isEmpty ? 'Quick calculator transaction' : _remark,
        'type': isExpense ? 'expense' : 'income',
      };

      // Save to database
      await _dbService.insertTransaction(transaction);

      // Notify other pages that data has changed
      _notifyDataChanged();

      // Show success message
      ValidationService.showSuccessMessage(
        context,
        '$_selectedType saved: ฿${amount.toStringAsFixed(2)}',
      );

      // Reset form
      setState(() {
        _amount = '';
        _remark = '';
        _selectedDate = DateTime.now();
      });

      // Close the page after successful save
      Navigator.of(context).pop();
    } catch (e) {
      print('Error saving transaction: $e');
      ValidationService.showValidationError(
        context,
        'Failed to save transaction. Please try again.',
      );
    }
  }
}
