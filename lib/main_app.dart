// lib/main_app.dart
import 'package:flutter/material.dart';

import 'pages/assets_page.dart';
import 'pages/bills_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';

class MainApp extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;

  const MainApp({super.key, this.onThemeChanged});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    HomePage(),
    BillsPage(),
    AssetsPage(),
    SettingsPage(onThemeChanged: widget.onThemeChanged),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Bills",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: "Assets",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
