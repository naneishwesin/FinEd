// lib/pages/categories_management_page.dart
import 'package:flutter/material.dart';

class CategoriesManagementPage extends StatefulWidget {
  const CategoriesManagementPage({super.key});

  @override
  _CategoriesManagementPageState createState() =>
      _CategoriesManagementPageState();
}

class _CategoriesManagementPageState extends State<CategoriesManagementPage> {
  int _selectedTabIndex = 0; // 0 for Expense, 1 for Income

  // Expense Categories
  final List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'Food', 'icon': Icons.restaurant, 'color': Colors.orange},
    {'name': 'Daily', 'icon': Icons.shopping_cart, 'color': Colors.blue},
    {'name': 'Transport', 'icon': Icons.directions_car, 'color': Colors.green},
    {'name': 'Social', 'icon': Icons.people, 'color': Colors.purple},
    {'name': 'Housing', 'icon': Icons.home, 'color': Colors.brown},
    {'name': 'Gifts', 'icon': Icons.card_giftcard, 'color': Colors.pink},
    {'name': 'Communication', 'icon': Icons.phone, 'color': Colors.indigo},
    {'name': 'Clothing', 'icon': Icons.checkroom, 'color': Colors.teal},
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': Colors.red},
    {'name': 'Beauty', 'icon': Icons.face, 'color': Colors.amber},
    {
      'name': 'Medical',
      'icon': Icons.local_hospital,
      'color': Colors.red[300]!,
    },
    {'name': 'Tax', 'icon': Icons.receipt_long, 'color': Colors.grey},
    {'name': 'Education', 'icon': Icons.school, 'color': Colors.blue[300]!},
    {'name': 'Pet', 'icon': Icons.pets, 'color': Colors.orange[300]!},
    {'name': 'Travel', 'icon': Icons.flight, 'color': Colors.cyan},
    {'name': 'Other', 'icon': Icons.more_horiz, 'color': Colors.grey[600]!},
  ];

  // Income Categories
  final List<Map<String, dynamic>> _incomeCategories = [
    {'name': 'Salary', 'icon': Icons.work, 'color': Colors.green},
    {'name': 'Bonus', 'icon': Icons.stars, 'color': Colors.amber},
    {'name': 'Investment', 'icon': Icons.trending_up, 'color': Colors.blue},
    {'name': 'Part-time', 'icon': Icons.schedule, 'color': Colors.purple},
    {
      'name': 'Monthly Allowance',
      'icon': Icons.account_balance_wallet,
      'color': Colors.teal,
    },
    {'name': 'Pocket Money', 'icon': Icons.money, 'color': Colors.orange},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Categories Management"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Selection
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 0
                            ? Colors.teal
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            color: _selectedTabIndex == 0
                                ? Colors.white
                                : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Expense",
                            style: TextStyle(
                              color: _selectedTabIndex == 0
                                  ? Colors.white
                                  : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 1
                            ? Colors.teal
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_upward,
                            color: _selectedTabIndex == 1
                                ? Colors.white
                                : Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Income",
                            style: TextStyle(
                              color: _selectedTabIndex == 1
                                  ? Colors.white
                                  : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categories List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _selectedTabIndex == 0
                    ? _expenseCategories.length
                    : _incomeCategories.length,
                itemBuilder: (context, index) {
                  final categories = _selectedTabIndex == 0
                      ? _expenseCategories
                      : _incomeCategories;
                  final category = categories[index];

                  return _buildCategoryCard(category, index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, int index) {
    return GestureDetector(
      onTap: () => _showEditCategoryDialog(category, index),
      onLongPress: () => _showDeleteCategoryDialog(category, index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: category['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(category['icon'], color: category['color'], size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              category['name'],
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    Color selectedColor = Colors.blue;
    IconData selectedIcon = Icons.category;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "Add ${_selectedTabIndex == 0 ? 'Expense' : 'Income'} Category",
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Category Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Text("Color: ")),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.palette,
                            color: Colors.white,
                            size: 16,
                          ),
                          onPressed: () => _showColorPicker(
                            setState,
                            (color) => selectedColor = color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Text("Icon: ")),
                      IconButton(
                        icon: Icon(selectedIcon),
                        onPressed: () => _showIconPicker(
                          setState,
                          (icon) => selectedIcon = icon,
                        ),
                      ),
                    ],
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
                    if (nameController.text.isNotEmpty) {
                      final newCategory = {
                        'name': nameController.text,
                        'icon': selectedIcon,
                        'color': selectedColor,
                      };

                      setState(() {
                        if (_selectedTabIndex == 0) {
                          _expenseCategories.add(newCategory);
                        } else {
                          _incomeCategories.add(newCategory);
                        }
                      });

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Category added successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditCategoryDialog(Map<String, dynamic> category, int index) {
    final TextEditingController nameController = TextEditingController(
      text: category['name'],
    );
    Color selectedColor = category['color'];
    IconData selectedIcon = category['icon'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Category"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Category Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Text("Color: ")),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.palette,
                            color: Colors.white,
                            size: 16,
                          ),
                          onPressed: () => _showColorPicker(
                            setState,
                            (color) => selectedColor = color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Text("Icon: ")),
                      IconButton(
                        icon: Icon(selectedIcon),
                        onPressed: () => _showIconPicker(
                          setState,
                          (icon) => selectedIcon = icon,
                        ),
                      ),
                    ],
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
                    if (nameController.text.isNotEmpty) {
                      setState(() {
                        if (_selectedTabIndex == 0) {
                          _expenseCategories[index] = {
                            'name': nameController.text,
                            'icon': selectedIcon,
                            'color': selectedColor,
                          };
                        } else {
                          _incomeCategories[index] = {
                            'name': nameController.text,
                            'icon': selectedIcon,
                            'color': selectedColor,
                          };
                        }
                      });

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Category updated successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteCategoryDialog(Map<String, dynamic> category, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Category"),
          content: Text(
            "Are you sure you want to delete '${category['name']}'?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_selectedTabIndex == 0) {
                    _expenseCategories.removeAt(index);
                  } else {
                    _incomeCategories.removeAt(index);
                  }
                });

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Category deleted successfully!"),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
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
      Colors.black,
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Color"),
          content: SizedBox(
            width: 300,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: colors.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    onColorSelected(colors[index]);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors[index],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showIconPicker(
    StateSetter setState,
    Function(IconData) onIconSelected,
  ) {
    final List<IconData> icons = [
      Icons.home,
      Icons.restaurant,
      Icons.directions_car,
      Icons.shopping_cart,
      Icons.work,
      Icons.school,
      Icons.local_hospital,
      Icons.flight,
      Icons.people,
      Icons.movie,
      Icons.music_note,
      Icons.sports,
      Icons.pets,
      Icons.card_giftcard,
      Icons.phone,
      Icons.checkroom,
      Icons.money,
      Icons.account_balance_wallet,
      Icons.trending_up,
      Icons.stars,
      Icons.schedule,
      Icons.more_horiz,
      Icons.category,
      Icons.favorite,
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Icon"),
          content: SizedBox(
            width: 300,
            height: 400,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: icons.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    onIconSelected(icons[index]);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icons[index], size: 24),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
