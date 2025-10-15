import 'package:flutter/material.dart';

import '../services/tutorial_service.dart';

class TutorialOverlay extends StatefulWidget {
  final String title;
  final String description;
  final Widget child;
  final String? tutorialKey;
  final bool showOnce;
  final TutorialPosition position;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? arrowColor;

  const TutorialOverlay({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.tutorialKey,
    this.showOnce = true,
    this.position = TutorialPosition.bottom,
    this.backgroundColor,
    this.textColor,
    this.arrowColor,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  bool _showOverlay = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: widget.position == TutorialPosition.top
              ? const Offset(0, -0.5)
              : const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _checkTutorialStatus();
  }

  void _checkTutorialStatus() {
    if (widget.tutorialKey != null && widget.showOnce) {
      _showOverlay = !TutorialService.isTutorialCompleted(widget.tutorialKey!);
    } else {
      _showOverlay = true;
    }

    if (_showOverlay) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showOverlay) {
      return widget.child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildTutorialCard(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTutorialCard() {
    final theme = Theme.of(context);
    final backgroundColor =
        widget.backgroundColor ?? theme.scaffoldBackgroundColor;
    final textColor = widget.textColor ?? theme.textTheme.bodyLarge?.color;

    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
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
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lightbulb, size: 32, color: theme.primaryColor),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            widget.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            widget.description,
            style: theme.textTheme.bodyLarge?.copyWith(color: textColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _dismissTutorial,
                  child: Text(
                    'Skip',
                    style: TextStyle(color: textColor?.withOpacity(0.7)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _completeTutorial,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Got it!'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _dismissTutorial() {
    setState(() {
      _showOverlay = false;
    });
    _animationController.reverse();
  }

  void _completeTutorial() async {
    if (widget.tutorialKey != null) {
      await TutorialService.markTutorialCompleted(widget.tutorialKey!);
    }
    _dismissTutorial();
  }
}

enum TutorialPosition { top, bottom, center }

class TutorialTooltip extends StatefulWidget {
  final String message;
  final Widget child;
  final String? tutorialKey;
  final bool showOnce;
  final Duration? duration;
  final TooltipTriggerMode triggerMode;

  const TutorialTooltip({
    super.key,
    required this.message,
    required this.child,
    this.tutorialKey,
    this.showOnce = true,
    this.duration,
    this.triggerMode = TooltipTriggerMode.tap,
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

    return Tooltip(
      message: widget.message,
      triggerMode: widget.triggerMode,
      child: widget.child,
    );
  }
}

class TutorialHighlight extends StatefulWidget {
  final Widget child;
  final String? tutorialKey;
  final bool showOnce;
  final Color? highlightColor;
  final double? borderWidth;
  final BorderRadius? borderRadius;

  const TutorialHighlight({
    super.key,
    required this.child,
    this.tutorialKey,
    this.showOnce = true,
    this.highlightColor,
    this.borderWidth = 2.0,
    this.borderRadius,
  });

  @override
  State<TutorialHighlight> createState() => _TutorialHighlightState();
}

class _TutorialHighlightState extends State<TutorialHighlight>
    with SingleTickerProviderStateMixin {
  bool _showHighlight = false;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.tutorialKey != null && widget.showOnce) {
      _showHighlight = !TutorialService.isTutorialCompleted(
        widget.tutorialKey!,
      );
    } else {
      _showHighlight = true;
    }

    if (_showHighlight) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showHighlight) {
      return widget.child;
    }

    final theme = Theme.of(context);
    final highlightColor = widget.highlightColor ?? theme.primaryColor;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: highlightColor,
                width: widget.borderWidth ?? 2.0,
              ),
              borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: highlightColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
