import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_config.dart';

class NotificationService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelKey: AppConfig.notificationChannelKey,
            channelName: AppConfig.notificationChannelName,
            channelDescription: AppConfig.notificationChannelDescription,
            defaultColor: AppConfig.primaryColor,
            ledColor: Colors.white,
            importance: NotificationImportance.High,
            channelShowBadge: true,
            playSound: true,
            enableVibration: true,
            enableLights: true,
          ),
        ],
        channelGroups: [
          NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group',
          ),
        ],
        debug: kDebugMode,
      );

      // Setup action handlers
      _setupActionHandlers();

      _isInitialized = true;
      debugPrint('Notification service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
      rethrow;
    }
  }

  static void _setupActionHandlers() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceived,
      onNotificationCreatedMethod: _onNotificationCreated,
      onNotificationDisplayedMethod: _onNotificationDisplayed,
      onDismissActionReceivedMethod: _onDismissActionReceived,
    );
  }

  static Future<void> _onActionReceived(ReceivedAction receivedAction) async {
    try {
      debugPrint('Notification action received: ${receivedAction.buttonKeyPressed}');

      if (receivedAction.buttonKeyPressed == 'OPEN_URL') {
        final url = receivedAction.payload?['url'];
        if (url != null && url.isNotEmpty) {
          await _launchUrl(url);
        }
      }
    } catch (e) {
      debugPrint('Error handling notification action: $e');
    }
  }

  static Future<void> _onNotificationCreated(ReceivedNotification receivedNotification) async {
    debugPrint('Notification created: ${receivedNotification.id}');
  }

  static Future<void> _onNotificationDisplayed(ReceivedNotification receivedNotification) async {
    debugPrint('Notification displayed: ${receivedNotification.id}');
  }

  static Future<void> _onDismissActionReceived(ReceivedAction receivedAction) async {
    debugPrint('Notification dismissed: ${receivedAction.id}');
  }

  static Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  static Future<void> handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Handling foreground message: ${message.messageId}');
    await _createImageNotification(message);
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Handling background message: ${message.messageId}');
    await _createImageNotification(message);
  }

  static Future<void> _createImageNotification(RemoteMessage message) async {
    try {
      final data = message.data;
      final notification = message.notification;

      final title = notification?.title ?? data['title'] ?? 'Notification';
      final body = notification?.body ?? data['body'] ?? 'New message';
      final imageUrl = data['notify_image'];
      final actionUrl = data['url'];

      // Download image with retry logic
      String? localImagePath = await _downloadNotificationImage(imageUrl);

      // Create notification
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: _generateNotificationId(),
          channelKey: AppConfig.notificationChannelKey,
          title: title,
          body: body,
          bigPicture: localImagePath,
          notificationLayout: localImagePath != null
              ? NotificationLayout.BigPicture
              : NotificationLayout.Default,
          payload: actionUrl != null ? {'url': actionUrl} : null,
          category: NotificationCategory.Message,
          wakeUpScreen: true,
          fullScreenIntent: false,
          criticalAlert: false,
        ),
        actionButtons: actionUrl != null ? [
          NotificationActionButton(
            key: 'OPEN_URL',
            label: 'Open Link',
            actionType: ActionType.Default,
          ),
        ] : null,
      );

      debugPrint('Notification created successfully');
    } catch (e) {
      debugPrint('Error creating notification: $e');
    }
  }

  static Future<String?> _downloadNotificationImage(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) {
      return 'resource://mipmap-hdpi/vayillogo';
    }

    for (int attempt = 1; attempt <= AppConfig.maxRetryAttempts; attempt++) {
      try {
        final response = await http.get(
          Uri.parse(imageUrl),
        ).timeout(Duration(seconds: AppConfig.imageDownloadTimeoutSeconds));

        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final file = File('${tempDir.path}/notification_image_$timestamp.jpg');
          await file.writeAsBytes(response.bodyBytes);
          return 'file://${file.path}';
        }
      } catch (e) {
        debugPrint('Image download attempt $attempt failed: $e');
      }
    }

    // Return fallback image if all attempts failed
    return 'resource://drawable/vayil';
  }

  static int _generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch % 2147483647; // Max int32 value
  }

  static Future<bool> isNotificationAllowed() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  static Future<void> requestNotificationPermission() async {
    try {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
  }

  static Future<void> cancelAllNotifications() async {
    try {
      await AwesomeNotifications().cancelAll();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    try {
      await AwesomeNotifications().cancel(id);
      debugPrint('Notification $id cancelled');
    } catch (e) {
      debugPrint('Error cancelling notification $id: $e');
    }
  }

  static Future<List<NotificationModel>> getActiveNotifications() async {
    try {
      return await AwesomeNotifications().listScheduledNotifications();
    } catch (e) {
      debugPrint('Error getting active notifications: $e');
      return [];
    }
  }

  static Future<void> createSimpleNotification({
    required String title,
    required String body,
    Map<String, String>? payload,
    String? imageUrl,
  }) async {
    try {
      String? localImagePath;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        localImagePath = await _downloadNotificationImage(imageUrl);
      }

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: _generateNotificationId(),
          channelKey: AppConfig.notificationChannelKey,
          title: title,
          body: body,
          bigPicture: localImagePath,
          notificationLayout: localImagePath != null
              ? NotificationLayout.BigPicture
              : NotificationLayout.Default,
          payload: payload,
          category: NotificationCategory.Message,
        ),
      );

      debugPrint('Simple notification created: $title');
    } catch (e) {
      debugPrint('Error creating simple notification: $e');
    }
  }

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, String>? payload,
    String? imageUrl,
  }) async {
    try {
      String? localImagePath;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        localImagePath = await _downloadNotificationImage(imageUrl);
      }

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: _generateNotificationId(),
          channelKey: AppConfig.notificationChannelKey,
          title: title,
          body: body,
          bigPicture: localImagePath,
          notificationLayout: localImagePath != null
              ? NotificationLayout.BigPicture
              : NotificationLayout.Default,
          payload: payload,
          category: NotificationCategory.Reminder,
        ),
        schedule: NotificationCalendar.fromDate(date: scheduledDate),
      );

      debugPrint('Scheduled notification created for: $scheduledDate');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  static Future<void> createProgressNotification({
    required String title,
    required String body,
    required int progress,
    int maxProgress = 100,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: _generateNotificationId(),
          channelKey: AppConfig.notificationChannelKey,
          title: title,
          body: body,
          notificationLayout: NotificationLayout.ProgressBar,
          category: NotificationCategory.Progress,
        ),
      );

      debugPrint('Progress notification created: $progress%');
    } catch (e) {
      debugPrint('Error creating progress notification: $e');
    }
  }

  static Future<void> createNotificationWithActions({
    required String title,
    required String body,
    required List<NotificationActionButton> actions,
    Map<String, String>? payload,
    String? imageUrl,
  }) async {
    try {
      String? localImagePath;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        localImagePath = await _downloadNotificationImage(imageUrl);
      }

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: _generateNotificationId(),
          channelKey: AppConfig.notificationChannelKey,
          title: title,
          body: body,
          bigPicture: localImagePath,
          notificationLayout: localImagePath != null
              ? NotificationLayout.BigPicture
              : NotificationLayout.Default,
          payload: payload,
          category: NotificationCategory.Message,
        ),
        actionButtons: actions,
      );

      debugPrint('Notification with actions created: $title');
    } catch (e) {
      debugPrint('Error creating notification with actions: $e');
    }
  }

  // Cleanup temp notification images (call this periodically)
  static Future<void> cleanupTempImages() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();

      for (final file in files) {
        if (file is File && file.path.contains('notification_image_')) {
          final fileStats = await file.stat();
          final fileAge = DateTime.now().difference(fileStats.modified);

          // Delete files older than 24 hours
          if (fileAge.inHours > 24) {
            await file.delete();
            debugPrint('Deleted old notification image: ${file.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up temp images: $e');
    }
  }
}