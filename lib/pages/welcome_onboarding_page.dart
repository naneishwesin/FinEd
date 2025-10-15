// lib/pages/welcome_onboarding_page.dart
import 'package:flutter/material.dart';

import '../services/app_flow_service.dart';
import '../utils/page_transitions.dart';
import 'auth_page.dart';

class WelcomeOnboardingPage extends StatefulWidget {
  const WelcomeOnboardingPage({super.key});

  @override
  _WelcomeOnboardingPageState createState() => _WelcomeOnboardingPageState();
}

class _WelcomeOnboardingPageState extends State<WelcomeOnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _welcomePages = [
    {
      'title': 'Welcome to Expense Tracker',
      'subtitle':
          'Take control of your finances with our intuitive expense tracking app',
      'image': Icons.account_balance_wallet,
      'color': Colors.blue,
    },
    {
      'title': 'Track Your Spending',
      'subtitle':
          'Monitor your expenses, set budgets, and achieve your financial goals',
      'image': Icons.pie_chart,
      'color': Colors.green,
    },
    {
      'title': 'Start Your Journey',
      'subtitle':
          'Let\'s set up your profile and begin managing your finances today',
      'image': Icons.rocket_launch,
      'color': Colors.orange,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 60), // Spacer
                  TextButton(
                    onPressed: () => _navigateToAuth(),
                    child: const Text(
                      "Skip",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _welcomePages.length,
                itemBuilder: (context, index) {
                  return _buildWelcomePage(_welcomePages[index]);
                },
              ),
            ),

            // Page Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _welcomePages.length,
                  (index) => _buildPageIndicator(index),
                ),
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous Button
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text(
                        "Previous",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  else
                    const SizedBox(width: 80),

                  // Next/Get Started Button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _welcomePages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _navigateToAuth();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      _currentPage < _welcomePages.length - 1
                          ? "Next"
                          : "Get Started",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(Map<String, dynamic> pageData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon/Image
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: pageData['color'].withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(pageData['image'], size: 100, color: pageData['color']),
          ),

          const SizedBox(height: 60),

          // Title
          Text(
            pageData['title'],
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Subtitle
          Text(
            pageData['subtitle'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _navigateToAuth() async {
    // Mark welcome as completed
    await AppFlowService.markWelcomeCompleted();

    // Navigate to auth page
    AnimatedNavigation.replaceWithAnimation(context, const AuthPage());
  }
}
