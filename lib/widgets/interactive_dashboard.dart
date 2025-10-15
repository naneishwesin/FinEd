// lib/widgets/interactive_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/chart_service.dart';
import '../services/data_service.dart';
import '../services/theme_service.dart';

class InteractiveDashboard extends StatefulWidget {
  const InteractiveDashboard({super.key});

  @override
  _InteractiveDashboardState createState() => _InteractiveDashboardState();
}

class _InteractiveDashboardState extends State<InteractiveDashboard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final balance = DataService.getCurrentBalance();
    final income = DataService.getIncome();
    final expenses = DataService.getExpenses();
    final healthScore = ChartService.getFinancialHealthScore();
    final insights = ChartService.getSpendingInsights();

    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          // Financial Health Score Card
          _buildHealthScoreCard(healthScore, themeService),

          const SizedBox(height: 16),

          // Quick Stats with Animations
          _buildQuickStats(balance, income, expenses, themeService),

          const SizedBox(height: 16),

          // Insights Card
          if (insights.isNotEmpty) _buildInsightsCard(insights, themeService),

          const SizedBox(height: 16),

          // Interactive Action Buttons
          _buildActionButtons(themeService),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard(double score, ThemeService themeService) {
    Color scoreColor;
    String scoreText;

    if (score >= 80) {
      scoreColor = Colors.green;
      scoreText = "Excellent";
    } else if (score >= 60) {
      scoreColor = Colors.orange;
      scoreText = "Good";
    } else if (score >= 40) {
      scoreColor = Colors.amber;
      scoreText = "Fair";
    } else {
      scoreColor = Colors.red;
      scoreText = "Needs Improvement";
    }

    return TooltipOverlay(
      message:
          "Your financial health score based on savings rate and balance ratio",
      targetKey: GlobalKey(),
      tutorialId: "health_score",
      child: Container(
        key: GlobalKey(),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scoreColor.withOpacity(0.1), scoreColor.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scoreColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: scoreColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        score.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Financial Health Score",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scoreText,
                    style: TextStyle(
                      fontSize: 14,
                      color: scoreColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(
    double balance,
    double income,
    double expenses,
    ThemeService themeService,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "Balance",
            "${themeService.getCurrencySymbol()}${balance.toStringAsFixed(2)}",
            Icons.account_balance_wallet,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            "Income",
            "${themeService.getCurrencySymbol()}${income.toStringAsFixed(2)}",
            Icons.trending_up,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            "Expenses",
            "${themeService.getCurrencySymbol()}${expenses.toStringAsFixed(2)}",
            Icons.trending_down,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return TooltipOverlay(
      message: "Tap to view detailed $title information",
      targetKey: GlobalKey(),
      tutorialId: "${title.toLowerCase()}_card",
      child: GestureDetector(
        key: GlobalKey(),
        onTap: () => _showDetailDialog(title, value, icon, color),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsCard(List<String> insights, ThemeService themeService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                "Financial Insights",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      insight,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                        height: 1.4,
                      ),
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

  Widget _buildActionButtons(ThemeService themeService) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            "Add Transaction",
            Icons.add,
            Colors.green,
            () => _showAddTransactionDialog(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            "View Reports",
            Icons.analytics,
            Colors.blue,
            () => _navigateToReports(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            "Set Goals",
            Icons.flag,
            Colors.orange,
            () => _navigateToGoals(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return TooltipOverlay(
      message: title,
      targetKey: GlobalKey(),
      tutorialId: "${title.toLowerCase().replaceAll(' ', '_')}_button",
      child: GestureDetector(
        key: GlobalKey(),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text("Current $title: $value"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog() {
    // Implementation for add transaction dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Transaction feature coming soon!')),
    );
  }

  void _navigateToReports() {
    // Implementation for navigation to reports
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigate to Reports')));
  }

  void _navigateToGoals() {
    // Implementation for navigation to goals
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigate to Goals')));
  }
}
