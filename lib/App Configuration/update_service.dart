import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_config.dart';

class UpdateService {
  static UpdateService? _instance;
  static UpdateService get instance => _instance ??= UpdateService._();

  UpdateService._();

  bool _isCheckingForUpdate = false;
  DateTime? _lastUpdateCheck;

  // Enable/disable rate limiting for testing
  static bool enableRateLimiting = false;

  Future<void> checkForUpdates(BuildContext context, {bool forceCheck = false}) async {
    // Prevent multiple simultaneous checks
    if (_isCheckingForUpdate) {
      debugPrint('🔄 Update check already in progress');
      return;
    }

    // // Rate limiting: only check once per hour unless forced (can be disabled for testing)
    // if (enableRateLimiting && !forceCheck && _lastUpdateCheck != null) {
    //   final timeDifference = DateTime.now().difference(_lastUpdateCheck!);
    //   if (timeDifference.inHours < 1) {
    //     debugPrint('⏱️ Update check rate limited (last check: ${_lastUpdateCheck})');
    //     return;
    //   }
    // }

    if (!Platform.isAndroid) {
      debugPrint('❌ Update check skipped: Not Android platform');
      return;
    }

    _isCheckingForUpdate = true;
    _lastUpdateCheck = DateTime.now();

    try {
      debugPrint('🔍 Starting update check...');
      await _performUpdateCheck(context);
    } catch (e) {
      debugPrint('❌ Error during update check: $e');
      if (forceCheck && context.mounted) {
        _showUpdateError(context);
      }
    } finally {
      _isCheckingForUpdate = false;
    }
  }

  Future<void> _performUpdateCheck(BuildContext context) async {
    try {
      final packageInfo = await PackageManager.getPackageInfo();
      debugPrint('📦 Current App Info:');
      debugPrint('   - Package: ${packageInfo.packageName}');
      debugPrint('   - Version: ${packageInfo.version}');
      debugPrint('   - Build: ${packageInfo.buildNumber}');

      final manager = InAppUpdateManager();
      final appUpdateInfo = await manager.checkForUpdate();

      if (appUpdateInfo == null) {
        debugPrint('⚠️ No update information available from Play Store');
        return;
      }

      debugPrint('📱 Update Info:');
      debugPrint('   - Availability: ${appUpdateInfo.updateAvailability}');
      debugPrint('   - Priority: ${appUpdateInfo.updatePriority}');
      debugPrint('   - Client Version Code: ${appUpdateInfo.clientVersionStalenessDays}');

      switch (appUpdateInfo.updateAvailability) {
        case UpdateAvailability.developerTriggeredUpdateInProgress:
          debugPrint('🔄 Resuming in-progress update');
          await manager.startAnUpdate();
          break;

        case UpdateAvailability.updateAvailable:
          final updatePriority = appUpdateInfo.updatePriority ?? 0;
          debugPrint('✅ Update available! Priority: $updatePriority');

          if (updatePriority >= 4) {
            debugPrint('🔴 High priority update - showing immediate dialog');
            await _handleImmediateUpdate(context, manager);
          } else {
            debugPrint('🟡 Normal priority update - trying flexible update');
            await _handleFlexibleUpdate(context, manager, packageInfo.packageName);
          }
          break;

        case UpdateAvailability.updateNotAvailable:
          debugPrint('✔️ No update available');
          break;

        case UpdateAvailability.unknown:
        default:
          debugPrint('❓ Unknown update availability status');
          break;
      }
    } catch (e) {
      debugPrint('❌ Error checking for updates: $e');
      if (context.mounted) {
        await _showPlayStoreUpdate(context, AppConfig.packageName);
      }
    }
  }

  Future<void> _handleImmediateUpdate(BuildContext context, InAppUpdateManager manager) async {
    try {
      final result = await manager.startAnUpdate(type: AppUpdateType.immediate);
      if (result != null) {
        debugPrint('✅ Immediate update started: $result');
      }
    } catch (e) {
      debugPrint('❌ Error starting immediate update: $e');
      if (context.mounted) {
        await _showPlayStoreUpdate(context, AppConfig.packageName);
      }
    }
  }

  Future<void> _handleFlexibleUpdate(
      BuildContext context,
      InAppUpdateManager manager,
      String packageName,
      ) async {
    try {
      final result = await manager.startAnUpdate(type: AppUpdateType.flexible);

      if (result == null) {
        debugPrint('⚠️ Flexible update failed - showing Play Store dialog');
        if (context.mounted) {
          await _showPlayStoreUpdate(context, packageName);
        }
      } else {
        debugPrint('✅ Flexible update started: $result');
        _monitorFlexibleUpdate(context, manager);
      }
    } catch (e) {
      debugPrint('❌ Error starting flexible update: $e');
      if (context.mounted) {
        await _showPlayStoreUpdate(context, packageName);
      }
    }
  }

  void _monitorFlexibleUpdate(BuildContext context, InAppUpdateManager manager) {
    _checkFlexibleUpdateStatus(context, manager, 0);
  }

  void _checkFlexibleUpdateStatus(BuildContext context, InAppUpdateManager manager, int attemptCount) {
    if (attemptCount >= 10) {
      debugPrint('⏱️ Flexible update monitoring timed out');
      return;
    }

    Future.delayed(const Duration(seconds: 5), () async {
      try {
        final info = await manager.checkForUpdate();
        if (info != null) {
          if (info.updateAvailability == UpdateAvailability.developerTriggeredUpdateInProgress ||
              (info.updatePriority != null && info.updatePriority! > 0)) {
            if (context.mounted) {
              _showInstallUpdateDialog(context, manager);
            }
            return;
          }
        }

        _checkFlexibleUpdateStatus(context, manager, attemptCount + 1);
      } catch (e) {
        debugPrint('❌ Error monitoring flexible update: $e');
      }
    });
  }

  void _showInstallUpdateDialog(BuildContext context, InAppUpdateManager manager) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Update Downloaded',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'The update has been downloaded. Restart the app to complete the update.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await manager.startAnUpdate(type: AppUpdateType.immediate);
              } catch (e) {
                debugPrint('❌ Error completing flexible update: $e');
                await _launchPlayStore(AppConfig.packageName);
              }
            },
            child: Text(
              'Restart Now',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPlayStoreUpdate(BuildContext context, String packageName) async {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Update Available',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A new version is available on the Play Store.',
              style: GoogleFonts.inter(),
            ),
            const SizedBox(height: 8),
            Text(
              'Update now to get the latest features and improvements.',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later', style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _launchPlayStore(packageName);
            },
            child: Text(
              'Update Now',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateError(BuildContext context) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Unable to check for updates. Please try again later.',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: AppConfig.errorColor,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => checkForUpdates(context, forceCheck: true),
        ),
      ),
    );
  }

  Future<void> _launchPlayStore(String packageName) async {
    try {
      final playStoreUrl = 'https://play.google.com/store/apps/details?id=$packageName';
      final uri = Uri.parse(playStoreUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('❌ Could not launch Play Store URL: $playStoreUrl');
      }
    } catch (e) {
      debugPrint('❌ Error launching Play Store: $e');
    }
  }

  Future<bool> isUpdateAvailable() async {
    if (!Platform.isAndroid) return false;

    try {
      final manager = InAppUpdateManager();
      final appUpdateInfo = await manager.checkForUpdate();
      return appUpdateInfo?.updateAvailability == UpdateAvailability.updateAvailable;
    } catch (e) {
      debugPrint('❌ Error checking update availability: $e');
      return false;
    }
  }

  Future<String?> getCurrentVersion() async {
    try {
      final packageInfo = await PackageManager.getPackageInfo();
      return packageInfo.version;
    } catch (e) {
      debugPrint('❌ Error getting current version: $e');
      return null;
    }
  }

  Future<String?> getCurrentBuildNumber() async {
    try {
      final packageInfo = await PackageManager.getPackageInfo();
      return packageInfo.buildNumber;
    } catch (e) {
      debugPrint('❌ Error getting current build number: $e');
      return null;
    }
  }

  Future<Map<String, String?>> getAppInfo() async {
    try {
      final packageInfo = await PackageManager.getPackageInfo();
      return {
        'appName': packageInfo.appName,
        'packageName': packageInfo.packageName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
      };
    } catch (e) {
      debugPrint('❌ Error getting app info: $e');
      return {
        'appName': null,
        'packageName': null,
        'version': null,
        'buildNumber': null,
      };
    }
  }

  Future<void> showManualUpdateDialog(BuildContext context) async {
    final isAvailable = await isUpdateAvailable();

    if (!context.mounted) return;

    if (isAvailable) {
      await _showPlayStoreUpdate(context, AppConfig.packageName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You are using the latest version of the app.',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> forceUpdateCheck(BuildContext context) async {
    await checkForUpdates(context, forceCheck: true);
  }
}