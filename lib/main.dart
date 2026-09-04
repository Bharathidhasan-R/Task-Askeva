import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'App Configuration/app_config.dart';
import 'App Configuration/connectivity_service.dart';
import 'App Configuration/notification_service.dart';
import 'App Configuration/update_service.dart';
import 'Routes/app_routes.dart';
import 'services/task_api_service.dart';
import 'View/no_network_page.dart';
import 'common/getx_binding.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize core services
    await _initializeCore();

    // Initialize notifications
    await NotificationService.initialize();

    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error in main: $e');
    // Fallback app
    runApp(const MyAppFallback());
  }
}

Future<void> _initializeCore() async {
  await Hive.initFlutter();
  await Hive.openBox('itemsDB');
  await TaskApiService().initialize();

  // Set preferred orientations if needed
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  final UpdateService _updateService = UpdateService.instance;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isOffline = false;
  bool _isCheckingConnectivity = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();

    // ✅ FIX: Add post-frame callback for update check
    // This ensures context is available and mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Platform.isAndroid && kReleaseMode) {
        // Disable rate limiting for first check after app start
        UpdateService.enableRateLimiting = false;
        _updateService.forceUpdateCheck(context);

        // Re-enable rate limiting after first check
        Future.delayed(const Duration(milliseconds: 500), () {
          UpdateService.enableRateLimiting = true;
        });
      }
    });
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize connectivity monitoring
      await _connectivityService.initialize();
      if (!mounted) return;

      setState(() {
        _isOffline = !_connectivityService.isConnected;
      });

      _connectivitySubscription = _connectivityService.connectivityStream
          .listen(_onConnectivityChanged);

      // Request permissions
      await _requestPermissions();

      debugPrint('✅ All services initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing services: $e');
    }
  }

  Future<void> _requestPermissions() async {
    final permissions = [Permission.notification];

    for (final permission in permissions) {
      final status = await permission.request();
      debugPrint('${permission.toString()} status: $status');
    }
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    debugPrint('Connectivity changed: ${result.name}');

    if (mounted) {
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
    }

    // Check for updates when connectivity is restored
    if (result != ConnectivityResult.none && Platform.isAndroid && mounted) {
      _updateService.forceUpdateCheck(context);
    }
  }

  Future<void> _retryConnectivityCheck() async {
    if (_isCheckingConnectivity) return;

    setState(() {
      _isCheckingConnectivity = true;
    });

    try {
      final result = await _connectivityService.checkConnectivity();
      if (!mounted) return;

      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingConnectivity = false;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('App resumed');
        // ✅ Check for updates when app resumes
        if (Platform.isAndroid && mounted && kReleaseMode) {
          _updateService.checkForUpdates(context);
        }
        break;
      case AppLifecycleState.paused:
        debugPrint('App paused');
        break;
      case AppLifecycleState.detached:
        debugPrint('App detached');
        break;
      case AppLifecycleState.inactive:
        debugPrint('App inactive');
        break;
      case AppLifecycleState.hidden:
        debugPrint('App hidden');
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Vayil',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(),
          fallbackLocale: const Locale('en', 'US'),
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _isOffline
                    ? NoNetworkPage(
                        key: const ValueKey('no-network-page'),
                        onRetry: _retryConnectivityCheck,
                        isChecking: _isCheckingConnectivity,
                      )
                    : widget!,
              ),
            );
          },
          initialBinding: CommonBindings(),
          initialRoute: AppRoutes.initialRoute,
          getPages: AppRoutes.pages,
          unknownRoute: GetPage(name: '/error', page: () => const ErrorPage()),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: GoogleFonts.lexendTextTheme(Theme.of(context).textTheme),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConfig.primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }
}

// Fallback app in case of initialization errors
class MyAppFallback extends StatelessWidget {
  const MyAppFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vayil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'App initialization failed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text('Please restart the app'),
            ],
          ),
        ),
      ),
    );
  }
}

// Error page for unknown Routes
class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Page not found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
