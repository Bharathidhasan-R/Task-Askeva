import 'dart:async';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_utils.dart';

class ErrorHandlerService {
  static ErrorHandlerService? _instance;
  static ErrorHandlerService get instance => _instance ??= ErrorHandlerService._();

  ErrorHandlerService._();

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set up Flutter error handling
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        _reportError(details.exception, details.stack, details.context?.toString());
      };

      // Set up async error handling
      PlatformDispatcher.instance.onError = (error, stack) {
        _reportError(error, stack, 'Async Error');
        return true;
      };

      // Initialize Crashlytics if available
      if (!kDebugMode) {
        try {
          await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
          debugPrint('Crashlytics initialized successfully');
        } catch (e) {
          debugPrint('Crashlytics initialization failed: $e');
        }
      }

      _isInitialized = true;
      debugPrint('Error handler service initialized');
    } catch (e) {
      debugPrint('Error initializing error handler service: $e');
    }
  }

  static void _reportError(dynamic error, StackTrace? stackTrace, String? context) {
    try {
      final errorInfo = _extractErrorInfo(error, stackTrace, context);

      // Log to console in debug mode
      if (kDebugMode) {
        debugPrint('=== ERROR REPORT ===');
        debugPrint('Error: ${errorInfo['error']}');
        debugPrint('Type: ${errorInfo['type']}');
        debugPrint('Context: ${errorInfo['context']}');
        debugPrint('Stack: ${errorInfo['stackTrace']}');
        debugPrint('==================');
      }

      // Report to Crashlytics in release mode
      if (!kDebugMode) {
        _reportToCrashlytics(error, stackTrace, context);
      }
    } catch (e) {
      debugPrint('Error in error reporting: $e');
    }
  }

  static Map<String, dynamic> _extractErrorInfo(
      dynamic error,
      StackTrace? stackTrace,
      String? context,
      ) {
    return {
      'error': error.toString(),
      'type': error.runtimeType.toString(),
      'context': context ?? 'Unknown',
      'stackTrace': stackTrace?.toString() ?? 'No stack trace available',
      'timestamp': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
      'isNetworkError': AppUtils.isNetworkError(error),
    };
  }

  static void _reportToCrashlytics(dynamic error, StackTrace? stackTrace, String? context) {
    try {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        information: [
          if (context != null) 'Context: $context',
          'Platform: ${Platform.operatingSystem}',
          'Timestamp: ${DateTime.now().toIso8601String()}',
        ],
        printDetails: false,
      );
    } catch (e) {
      debugPrint('Error reporting to Crashlytics: $e');
    }
  }

  // Report custom errors
  static void reportError(
      dynamic error, {
        StackTrace? stackTrace,
        String? context,
        Map<String, dynamic>? additionalData,
      }) {
    try {
      _reportError(error, stackTrace, context);

      if (additionalData != null && !kDebugMode) {
        FirebaseCrashlytics.instance.setCustomKey('additionalData', additionalData.toString());
      }
    } catch (e) {
      debugPrint('Error in reportError: $e');
    }
  }

  // Report network errors specifically
  static void reportNetworkError(
      dynamic error, {
        String? url,
        int? statusCode,
        String? method,
      }) {
    final context = 'Network Error - ${method ?? 'Unknown'} ${url ?? 'Unknown URL'}';
    final additionalData = {
      'url': url,
      'statusCode': statusCode,
      'method': method,
      'isNetworkError': true,
    };

    reportError(error, context: context, additionalData: additionalData);
  }

  // Report authentication errors
  static void reportAuthError(dynamic error, {String? userId}) {
    final additionalData = {
      'userId': userId ?? 'Unknown',
      'errorType': 'Authentication',
    };

    reportError(error, context: 'Authentication Error', additionalData: additionalData);
  }

  // Report UI errors
  static void reportUIError(dynamic error, {String? widgetName, String? action}) {
    final context = 'UI Error - ${widgetName ?? 'Unknown Widget'} - ${action ?? 'Unknown Action'}';
    final additionalData = {
      'widgetName': widgetName,
      'action': action,
      'errorType': 'UI',
    };

    reportError(error, context: context, additionalData: additionalData);
  }

  // Set user information for crash reporting
  static Future<void> setUserInfo({
    required String userId,
    String? email,
    String? name,
  }) async {
    try {
      if (!kDebugMode) {
        await FirebaseCrashlytics.instance.setUserIdentifier(userId);
        if (email != null) {
          await FirebaseCrashlytics.instance.setCustomKey('userEmail', email);
        }
        if (name != null) {
          await FirebaseCrashlytics.instance.setCustomKey('userName', name);
        }
      }
    } catch (e) {
      debugPrint('Error setting user info: $e');
    }
  }

  // Clear user information
  static Future<void> clearUserInfo() async {
    try {
      if (!kDebugMode) {
        await FirebaseCrashlytics.instance.setUserIdentifier('');
        await FirebaseCrashlytics.instance.setCustomKey('userEmail', '');
        await FirebaseCrashlytics.instance.setCustomKey('userName', '');
      }
    } catch (e) {
      debugPrint('Error clearing user info: $e');
    }
  }

  // Log custom events for debugging
  static void logEvent(String event, {Map<String, dynamic>? parameters}) {
    try {
      if (kDebugMode) {
        debugPrint('Event: $event${parameters != null ? ' - $parameters' : ''}');
      }

      if (!kDebugMode) {
        FirebaseCrashlytics.instance.log('$event${parameters != null ? ' - $parameters' : ''}');
      }
    } catch (e) {
      debugPrint('Error logging event: $e');
    }
  }

  // Handle specific error types and show appropriate UI feedback
  static void handleErrorWithUI(
      BuildContext context,
      dynamic error, {
        String? customMessage,
        VoidCallback? onRetry,
      }) {
    try {
      String message = customMessage ?? _getErrorMessage(error);

      // Report the error
      reportError(error, context: 'UI Error Handler');

      // Show appropriate UI feedback
      if (AppUtils.isNetworkError(error)) {
        _showNetworkErrorDialog(context, message, onRetry);
      } else {
        AppUtils.showErrorSnackBar(context, message);
      }
    } catch (e) {
      debugPrint('Error in handleErrorWithUI: $e');
      AppUtils.showErrorSnackBar(context, 'An unexpected error occurred');
    }
  }

  static String _getErrorMessage(dynamic error) {
    if (AppUtils.isNetworkError(error)) {
      return 'Network connection error. Please check your internet connection.';
    }

    if (error is FormatException) {
      return 'Invalid data format received.';
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }

    if (error is HttpException) {
      return 'Server error occurred. Please try again later.';
    }

    // Generic error message
    return 'An error occurred. Please try again.';
  }

  static void _showNetworkErrorDialog(
      BuildContext context,
      String message,
      VoidCallback? onRetry,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Network Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  // Test crash reporting (for debugging purposes)
  static void testCrashReporting() {
    if (kDebugMode) {
      debugPrint('Testing crash reporting...');
      throw Exception('Test crash for debugging purposes');
    }
  }

  // Force crash for testing Crashlytics
  static void forceCrash() {
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.crash();
    } else {
      debugPrint('Force crash only works in release mode');
    }
  }
}