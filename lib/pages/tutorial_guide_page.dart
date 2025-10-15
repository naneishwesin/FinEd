import 'package:flutter/material.dart';

import '../main_app.dart';
import '../services/app_flow_service.dart';
import '../services/tutorial_service.dart';

class TutorialGuidePage extends StatefulWidget {
  const TutorialGuidePage({super.key});

  @override
  _TutorialGuidePageState createState() => _TutorialGuidePageState();
}

class _TutorialGuidePageState extends State<TutorialGuidePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialPage> _tutorialPages = [
    TutorialPage(
      title: "Welcome to Expense Tracker",
      description: "Your personal finance management app",
      icon: Icons.home,
      color: Colors.blue,
      content: [
        "Track your daily expenses and income",
        "Manage your budget and financial goals",
        "View detailed reports and analytics",
        "Get personalized insights and recommendations",
      ],
    ),
    TutorialPage(
      title: "Home Dashboard",
      description: "Your financial overview at a glance",
      icon: Icons.dashboard,
      color: Colors.green,
      content: [
        "View your current balance with + and - buttons",
        "Access Budget, Goals, Reports, and Wallet features",
        "Manage your emergency fund",
        "Track your investments",
        "See recent transactions",
      ],
    ),
    TutorialPage(
      title: "Bills & Transactions",
      description: "Manage your financial records",
      icon: Icons.receipt_long,
      color: Colors.orange,
      content: [
        "View daily spending calendar with expense/income toggle",
        "Search and filter transactions",
        "Add, edit, or delete transaction records",
        "View detailed expense and income breakdowns",
        "Analyze spending patterns with charts",
      ],
    ),
    TutorialPage(
      title: "Assets & Liabilities",
      description: "Track your financial health",
      icon: Icons.account_balance,
      color: Colors.purple,
      content: [
        "Monitor your total assets and liabilities",
        "View trending charts over time",
        "Filter data by different time periods",
        "Manage cash transactions",
        "Analyze asset/liability breakdowns",
      ],
    ),
    TutorialPage(
      title: "Settings & Customization",
      description: "Personalize your experience",
      icon: Icons.settings,
      color: Colors.teal,
      content: [
        "Edit your profile information",
        "Switch between light and dark themes",
        "Change language and currency settings",
        "Manage notifications and alerts",
        "Organize categories and bookmarks",
      ],
    ),
    TutorialPage(
      title: "Quick Actions",
      description: "Fast access to common features",
      icon: Icons.flash_on,
      color: Colors.red,
      content: [
        "Use the floating calculator button for quick entries",
        "Tap transaction items to view details",
        "Use three-dot menus for edit/delete options",
        "Swipe between tabs for different views",
        "Long-press for additional options",
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Tutorial"),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () async {
              await TutorialService.resetAllTutorials();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("All tutorials have been reset!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              "Reset All",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / _tutorialPages.length,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _tutorialPages[_currentPage].color,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  "${_currentPage + 1}/${_tutorialPages.length}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Page content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _tutorialPages.length,
              itemBuilder: (context, index) {
                return _buildTutorialPage(_tutorialPages[index]);
              },
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text("Previous"),
                  )
                else
                  const SizedBox.shrink(),

                if (_currentPage < _tutorialPages.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _tutorialPages[_currentPage].color,
                    ),
                    child: const Text("Next"),
                  )
                else
                  ElevatedButton(
                    onPressed: () async {
                      // Mark tutorial as completed
                      await AppFlowService.markTutorialCompleted();

                      // Navigate to main app
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => MainApp()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text("Finish"),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialPage(TutorialPage page) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 64, color: page.color),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: page.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Content list
          Expanded(
            child: ListView.builder(
              itemCount: page.content.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: page.color.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: page.color.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: page.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          page.content[index],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
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
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class TutorialPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> content;

  TutorialPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.content,
  });
}
