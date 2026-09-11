import 'package:flutter/material.dart';

class AppConfig {
  // API Endpoints
  // static const String baseUrl = "https://app.vayil.in/customer/";
  // static const String baseUrl = "https://dev.vayil.in/customer/";//Dev
  // static const String baseUrl = "https://vayil-web.vercel.app/customer/";//Dev
  static const String baseUrl = "https://vayil.in/customer/";//Live


  static const String googleMapsApiKey = 'AIzaSyC9VBQpcsk5NRr6FEmUKRHHROiUChGBEWw';


  // Firebase Configuration
  static const FirebaseConfig firebaseConfig = FirebaseConfig(
    apiKey: "AIzaSyBzzSMQXeOzIWp1JphmMjrUlTN4Qirbon0",
    authDomain: "dulcet-theory-483105-q4.firebaseapp.com",
    projectId: "dulcet-theory-483105-q4",
    storageBucket: "dulcet-theory-483105-q4.firebasestorage.app",
    messagingSenderId: "999819276288",
    appId: "1:999819276288:android:ab6a57f6193ff96cc428e5",
  );

  // App Theme Colors
  static const Color primaryColor = Color(0xFF183954);
  // static const Color primaryColor1 = Color(0xFFE8943A);
  static const Color secondaryColor = Color(0xFFE8943A);
  static const Color buttonColor = Color(0xFF1A202C);
  static const Color headingColor = Color(0xFF183752);
  static const Color textColor = Color(0xFF183954);
  static const Color secondaryTextColor = Color(0xFF0D141C);


  static const Color errorColor = Colors.red;

  // App Constants
  static const String appName = "Vayil";
  static const String packageName = "com.vayil.customer";
  static const int notificationChannelId = 1000;
  static String deviceId="";
  static String loginRoute = "";
  static String serviceID = "";
  static String convenienceFee = "";
  static String sGST = "";
  static String cGST = "";
  static String iGST = "";
  static String platformFee = "";
  static String paymentKey = "";

  // Notification Settings
  static const String notificationChannelKey = 'basic_channel';
  static const String notificationChannelName = 'Basic Notifications';
  static const String notificationChannelDescription = 'Notification channel for basic notifications';

  // Network Settings
  static const int httpTimeoutSeconds = 30;
  static const int imageDownloadTimeoutSeconds = 10;
  static const int maxRetryAttempts = 3;

  // Storage Keys
  static const String userDataBox = 'itemsDB';
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';
}

class FirebaseConfig {
  final String apiKey;
  final String authDomain;
  final String projectId;
  final String storageBucket;
  final String messagingSenderId;
  final String appId;

  const FirebaseConfig({
    required this.apiKey,
    required this.authDomain,
    required this.projectId,
    required this.storageBucket,
    required this.messagingSenderId,
    required this.appId,
  });
}