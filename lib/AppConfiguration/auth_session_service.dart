import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';

import '../Routes/app_routes.dart';
import '../services/task_api_service.dart';

class AuthSessionService {
  AuthSessionService._();

  static const String _hiveBox = 'itemsDB';
  static bool _isRedirectingToLogin = false;

  static Future<void> handleInvalidToken({String? message}) async {
    if (_isRedirectingToLogin) return;

    _isRedirectingToLogin = true;

    try {
      final box = await Hive.openBox(_hiveBox);
      await box.delete('userId');
      await box.delete('customerId');
      await box.delete('token');
      await box.delete('auth_token');
      await box.delete('phone');
      await TaskApiService().clearToken();

      if (Get.currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      debugPrint('Error handling invalid token: $e');
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        _isRedirectingToLogin = false;
      });
    }
  }
}
