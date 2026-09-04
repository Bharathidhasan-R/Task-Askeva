import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'app_config.dart';

class FirebaseService {
  static FirebaseMessaging? _messaging;
  static FirebaseAnalytics? _analytics;

  static FirebaseMessaging get messaging => _messaging!;

  static FirebaseAnalytics get analytics => _analytics!;

  static Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: kIsWeb
            ? FirebaseOptions(
                apiKey: AppConfig.firebaseConfig.apiKey,
                authDomain: AppConfig.firebaseConfig.authDomain,
                projectId: AppConfig.firebaseConfig.projectId,
                storageBucket: AppConfig.firebaseConfig.storageBucket,
                messagingSenderId: AppConfig.firebaseConfig.messagingSenderId,
                appId: AppConfig.firebaseConfig.appId,
              )
            : null,
      );
      debugPrint('Firebase initialized successfully');

      // Initialize Firebase Messaging
      _messaging = FirebaseMessaging.instance;

      // Initialize Firebase Analytics
      _analytics = FirebaseAnalytics.instance;
      await _analytics!.logAppOpen();
      debugPrint('Firebase Analytics initialized and logged app_open event');

      // Request notification permissions
      await _requestNotificationPermissions();

      // Print FCM token after initialization
      await printToken();

      // Setup token refresh listener
      _setupTokenRefreshListener();
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
      rethrow;
    }
  }

  static Future<void> _requestNotificationPermissions() async {
    try {
      final NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('User granted permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permissions');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('User granted provisional notification permissions');
      } else {
        debugPrint(
          'User declined or has not accepted notification permissions',
        );
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  static Future<String?> getToken() async {
    try {
      if (_messaging == null) return null;
      return await _messaging!.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Print the current FCM token
  static Future<void> printToken() async {
    try {
      String? token = await getToken();
      if (token != null) {
        debugPrint('=== FCM TOKEN ===');
        debugPrint('Token: $token');
        debugPrint('================');
        AppConfig.deviceId = token;
        // Also print to regular console for easy copying
        print('FCM Token: $token');
      } else {
        debugPrint(
          'FCM Token is null - make sure Firebase is initialized and permissions are granted',
        );
      }
    } catch (e) {
      debugPrint('Error printing FCM token: $e');
    }
  }

  /// Setup listener for token refresh
  static void _setupTokenRefreshListener() {
    try {
      if (_messaging == null) return;

      _messaging!.onTokenRefresh.listen((String token) {
        debugPrint('FCM Token refreshed');
        debugPrint('New Token: $token');
        print('New FCM Token: $token');

        // You can add logic here to send the new token to your server
        // _sendTokenToServer(token);
      });
    } catch (e) {
      debugPrint('Error setting up token refresh listener: $e');
    }
  }

  /// Get and print token with detailed information
  static Future<void> getTokenWithDetails() async {
    try {
      if (_messaging == null) {
        debugPrint('Firebase Messaging not initialized');
        return;
      }

      String? token = await getToken();

      if (token != null) {
        debugPrint('=== FCM TOKEN DETAILS ===');
        debugPrint('Token: $token');
        debugPrint('Token Length: ${token.length}');
        debugPrint('Platform: ${defaultTargetPlatform.name}');
        debugPrint('Is Web: $kIsWeb');
        debugPrint('========================');

        print('FCM Token: $token');
      } else {
        debugPrint('Failed to retrieve FCM token');
      }
    } catch (e) {
      debugPrint('Error getting token with details: $e');
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    try {
      if (_messaging == null) return;
      await _messaging!.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      if (_messaging == null) return;
      await _messaging!.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  static Future<void> logEvent(
    String eventName,
    Map<String, Object>? parameters,
  ) async {
    try {
      if (_analytics == null) return;
      await _analytics!.logEvent(name: eventName, parameters: parameters);
      debugPrint('Logged event: $eventName');
    } catch (e) {
      debugPrint('Error logging event $eventName: $e');
    }
  }

  static Future<void> setUserId(String userId) async {
    try {
      if (_analytics == null) return;
      await _analytics!.setUserId(id: userId);
      debugPrint('Set user ID: $userId');
    } catch (e) {
      debugPrint('Error setting user ID: $e');
    }
  }

  static Future<void> setUserProperty(String name, String value) async {
    try {
      if (_analytics == null) return;
      await _analytics!.setUserProperty(name: name, value: value);
      debugPrint('Set user property: $name = $value');
    } catch (e) {
      debugPrint('Error setting user property: $e');
    }
  }

  static Future<void> deleteToken() async {
    try {
      if (_messaging == null) return;
      await _messaging!.deleteToken();
      debugPrint('FCM token deleted');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }

  /// Force refresh and print new token
  static Future<void> refreshAndPrintToken() async {
    try {
      if (_messaging == null) return;

      // Delete current token and get a new one
      await _messaging!.deleteToken();
      await Future.delayed(Duration(seconds: 1)); // Small delay

      String? newToken = await getToken();
      if (newToken != null) {
        debugPrint('=== REFRESHED FCM TOKEN ===');
        debugPrint('New Token: $newToken');
        debugPrint('==========================');
        print('Refreshed FCM Token: $newToken');
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
    }
  }
}
