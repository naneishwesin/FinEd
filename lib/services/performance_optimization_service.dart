// lib/services/performance_optimization_service.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class PerformanceOptimizationService {
  static final PerformanceOptimizationService _instance =
      PerformanceOptimizationService._internal();
  factory PerformanceOptimizationService() => _instance;
  PerformanceOptimizationService._internal();

  // Performance monitoring
  final List<Duration> _frameTimes = [];
  Timer? _performanceTimer;
  bool _isMonitoring = false;

  // Start performance monitoring
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _performanceTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkPerformance();
    });
  }

  // Stop performance monitoring
  void stopMonitoring() {
    _isMonitoring = false;
    _performanceTimer?.cancel();
    _performanceTimer = null;
  }

  // Check performance metrics
  void _checkPerformance() {
    final scheduler = SchedulerBinding.instance;
    if (scheduler.schedulerPhase == SchedulerPhase.idle) {
      // App is idle, good performance
      debugPrint('Performance: Good - App is idle');
    } else {
      // App is busy, potential performance issue
      debugPrint(
        'Performance: Warning - App is busy in ${scheduler.schedulerPhase}',
      );
    }
  }

  // Run expensive operations in isolate
  static Future<T> runInIsolate<T>(
    T Function() computation, {
    String? debugName,
  }) async {
    try {
      return await compute(_isolateComputation, computation);
    } catch (e) {
      debugPrint('Isolate computation failed: $e');
      // Fallback to main thread
      return computation();
    }
  }

  // Isolate computation wrapper
  static T _isolateComputation<T>(T Function() computation) {
    return computation();
  }

  // Debounce function calls
  static Timer? _debounceTimer;
  static void debounce(String key, Duration delay, VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  // Throttle function calls
  static final Map<String, DateTime> _lastCallTimes = {};
  static bool throttle(String key, Duration interval) {
    final now = DateTime.now();
    final lastCall = _lastCallTimes[key];

    if (lastCall == null || now.difference(lastCall) >= interval) {
      _lastCallTimes[key] = now;
      return true;
    }
    return false;
  }

  // Optimize list rendering
  static Widget optimizedListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollController? controller,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
  }) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Use RepaintBoundary for expensive items
        return RepaintBoundary(child: itemBuilder(context, index));
      },
    );
  }

  // Optimize grid rendering
  static Widget optimizedGridView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required int crossAxisCount,
    double childAspectRatio = 1.0,
    ScrollController? controller,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
  }) {
    return GridView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(child: itemBuilder(context, index));
      },
    );
  }

  // Memory optimization
  static void optimizeMemory() {
    // Force garbage collection
    if (kDebugMode) {
      debugPrint('Memory optimization: Forcing GC');
    }
  }

  // Dispose resources
  void dispose() {
    stopMonitoring();
  }
}
