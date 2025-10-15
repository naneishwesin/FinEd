import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static const String _tutorialCompletedPrefix = 'tutorial_completed_';

  // Tutorial keys for different features
  static const String homePageOverview = 'home_page_overview';
  static const String balanceManagement = 'balance_management';
  static const String emergencyFund = 'emergency_fund';
  static const String investmentTab = 'investment_tab';
  static const String recentTransactions = 'recent_transactions';
  static const String billsPageCalendar = 'bills_page_calendar';
  static const String billsPageCharts = 'bills_page_charts';
  static const String billsPageTransactions = 'bills_page_transactions';
  static const String assetsPageOverview = 'assets_page_overview';
  static const String assetsPageCharts = 'assets_page_charts';
  static const String settingsPageProfile = 'settings_page_profile';
  static const String settingsPageCustom = 'settings_page_custom';
  static const String settingsPageManagement = 'settings_page_management';
  static const String quickCalculator = 'quick_calculator';
  static const String transactionDetails = 'transaction_details';
  static const String searchAndFilter = 'search_and_filter';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      print('TutorialService: Failed to initialize SharedPreferences: $e');
    }
  }

  static bool isTutorialCompleted(String tutorialKey) {
    return _prefs?.getBool('$_tutorialCompletedPrefix$tutorialKey') ?? false;
  }

  static Future<void> markTutorialCompleted(String tutorialKey) async {
    await _prefs?.setBool('$_tutorialCompletedPrefix$tutorialKey', true);
  }

  static Future<void> resetAllTutorials() async {
    if (_prefs == null) return;

    final keys = _prefs!.getKeys();
    for (String key in keys) {
      if (key.startsWith(_tutorialCompletedPrefix)) {
        await _prefs!.remove(key);
      }
    }
  }

  static Future<void> showTutorial(
    BuildContext context,
    String tutorialKey,
    Widget tutorialWidget, {
    bool force = false,
  }) async {
    if (!force && isTutorialCompleted(tutorialKey)) {
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          TutorialDialog(tutorialKey: tutorialKey, child: tutorialWidget),
    );
  }

  static Widget buildTooltip({
    required String message,
    required Widget child,
    String? tutorialKey,
    bool showOnce = true,
  }) {
    return TutorialTooltip(
      message: message,
      tutorialKey: tutorialKey,
      showOnce: showOnce,
      child: child,
    );
  }

  static Widget buildHighlight({
    required Widget child,
    String? tutorialKey,
    bool showOnce = true,
  }) {
    return TutorialHighlight(
      tutorialKey: tutorialKey,
      showOnce: showOnce,
      child: child,
    );
  }

  static Widget buildTutorialOverlay({
    required String title,
    required String description,
    required Widget target,
    required GlobalKey targetKey,
    String? tutorialKey,
    bool showOnce = true,
  }) {
    return TutorialOverlay(
      title: title,
      description: description,
      target: target,
      targetKey: targetKey,
      tutorialKey: tutorialKey,
      showOnce: showOnce,
    );
  }
}

class TutorialDialog extends StatefulWidget {
  final String tutorialKey;
  final Widget child;

  const TutorialDialog({
    super.key,
    required this.tutorialKey,
    required this.child,
  });

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(
              'Tutorial',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(child: widget.child),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await TutorialService.markTutorialCompleted(
                        widget.tutorialKey,
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text('Got it!'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TutorialTooltip extends StatefulWidget {
  final String message;
  final Widget child;
  final String? tutorialKey;
  final bool showOnce;

  const TutorialTooltip({
    super.key,
    required this.message,
    required this.child,
    this.tutorialKey,
    this.showOnce = true,
  });

  @override
  State<TutorialTooltip> createState() => _TutorialTooltipState();
}

class _TutorialTooltipState extends State<TutorialTooltip> {
  bool _showTooltip = false;

  @override
  void initState() {
    super.initState();
    if (widget.tutorialKey != null && widget.showOnce) {
      _showTooltip = !TutorialService.isTutorialCompleted(widget.tutorialKey!);
    } else {
      _showTooltip = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showTooltip) {
      return widget.child;
    }

    return Tooltip(message: widget.message, child: widget.child);
  }
}

class TutorialHighlight extends StatefulWidget {
  final Widget child;
  final String? tutorialKey;
  final bool showOnce;

  const TutorialHighlight({
    super.key,
    required this.child,
    this.tutorialKey,
    this.showOnce = true,
  });

  @override
  State<TutorialHighlight> createState() => _TutorialHighlightState();
}

class _TutorialHighlightState extends State<TutorialHighlight> {
  bool _showHighlight = false;

  @override
  void initState() {
    super.initState();
    if (widget.tutorialKey != null && widget.showOnce) {
      _showHighlight = !TutorialService.isTutorialCompleted(
        widget.tutorialKey!,
      );
    } else {
      _showHighlight = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showHighlight) {
      return widget.child;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: widget.child,
    );
  }
}

class TutorialOverlay extends StatefulWidget {
  final String title;
  final String description;
  final Widget target;
  final GlobalKey targetKey;
  final String? tutorialKey;
  final bool showOnce;

  const TutorialOverlay({
    super.key,
    required this.title,
    required this.description,
    required this.target,
    required this.targetKey,
    this.tutorialKey,
    this.showOnce = true,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    if (widget.tutorialKey != null && widget.showOnce) {
      _showOverlay = !TutorialService.isTutorialCompleted(widget.tutorialKey!);
    } else {
      _showOverlay = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showOverlay) {
      return widget.target;
    }

    return Stack(
      children: [
        widget.target,
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lightbulb,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _showOverlay = false;
                              });
                            },
                            child: const Text('Skip'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (widget.tutorialKey != null) {
                                await TutorialService.markTutorialCompleted(
                                  widget.tutorialKey!,
                                );
                              }
                              setState(() {
                                _showOverlay = false;
                              });
                            },
                            child: const Text('Got it!'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
