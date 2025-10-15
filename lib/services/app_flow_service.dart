// lib/services/app_flow_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main_app.dart';
import '../pages/tutorial_guide_page.dart';
import '../pages/welcome_onboarding_page.dart';

class AppFlowService {
  static const String _welcomeCompletedKey = 'welcome_completed';
  static const String _tutorialCompletedKey = 'tutorial_completed';
  static const String _profileSetupCompletedKey = 'profile_setup_completed';

  /// Check if user has completed welcome onboarding
  static Future<bool> isWelcomeCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_welcomeCompletedKey) ?? false;
  }

  /// Mark welcome onboarding as completed
  static Future<void> markWelcomeCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeCompletedKey, true);
  }

  /// Check if user has completed tutorial
  static Future<bool> isTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialCompletedKey) ?? false;
  }

  /// Mark tutorial as completed
  static Future<void> markTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, true);
  }

  /// Check if user has completed profile setup
  static Future<bool> isProfileSetupCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_profileSetupCompletedKey) ?? false;
  }

  /// Mark profile setup as completed
  static Future<void> markProfileSetupCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_profileSetupCompletedKey, true);
  }

  /// Reset all flow states (for testing or logout)
  static Future<void> resetFlow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_welcomeCompletedKey);
    await prefs.remove(_tutorialCompletedKey);
    await prefs.remove(_profileSetupCompletedKey);
  }

  /// Get the next page in the flow
  static Future<Widget> getNextPage(BuildContext context) async {
    // Check if user is authenticated first
    // This would be handled by Firebase auth state

    // If not authenticated, check welcome completion
    final welcomeCompleted = await isWelcomeCompleted();
    if (!welcomeCompleted) {
      // Show welcome onboarding
      return const WelcomeOnboardingPage();
    }

    // If authenticated, check tutorial completion
    final tutorialCompleted = await isTutorialCompleted();
    if (!tutorialCompleted) {
      // Show tutorial
      return const TutorialGuidePage();
    }

    // If everything is completed, show main app
    return MainApp(
      onThemeChanged: (theme) {
        // Handle theme changes if needed
      },
    );
  }
}
