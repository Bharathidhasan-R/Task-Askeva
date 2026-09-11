import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../AppConfiguration/auth_session_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient.internal();
  ApiClient.internal();
  factory ApiClient() => _instance;

  Dio? _dio;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const String tokenKey = 'field_service_auth_token';
  static const String hiveBox = 'itemsDB';

  Future<Dio> getApiClient() async {
    if (_dio != null) return _dio!;

    final dioInstance = Dio(_getBaseOptions());
    dioInstance.interceptors.clear();
    dioInstance.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
          // Auto-inject Authorization header if not explicitly set
          if (!options.headers.containsKey('Authorization') ||
              options.headers['Authorization'] == null ||
              options.headers['Authorization'].toString().isEmpty) {
            final token = await getToken();
            if (token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          options.headers['Accept'] = 'application/json';
          options.headers['X-Source'] = 'mobile-app';

          return handler.next(options);
        },
        onResponse: (Response response, ResponseInterceptorHandler handler) async {
          if (kDebugMode) {
            debugPrint('[API RESPONSE] ${response.requestOptions.method} ${response.requestOptions.path} -> ${response.statusCode}');
          }
          await _handleUnauthorizedResponse(response.statusCode, response.data);
          return handler.next(response);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (kDebugMode) {
            debugPrint('[API ERROR] ${error.requestOptions.method} ${error.requestOptions.path} [${error.response?.statusCode}]: ${error.message}');
            debugPrint('[ERROR DATA] ${error.response?.data}');
          }
          await _handleUnauthorizedResponse(
            error.response?.statusCode,
            error.response?.data,
          );
          return handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dioInstance.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }

    _dio = dioInstance;
    return _dio!;
  }

  /// Retrieve the authentication token from SecureStorage or Hive fallback
  static Future<String> getToken() async {
    try {
      final secureToken = await _secureStorage.read(key: tokenKey);
      if (secureToken != null && secureToken.trim().isNotEmpty) {
        return secureToken.trim();
      }
    } catch (_) {}

    try {
      if (Hive.isBoxOpen(hiveBox)) {
        final box = Hive.box(hiveBox);
        final token = box.get('token') ?? box.get('auth_token');
        if (token != null && token.toString().trim().isNotEmpty) {
          return token.toString().trim();
        }
      }
    } catch (_) {}

    return '';
  }

  /// Save token across SecureStorage and Hive
  static Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: tokenKey, value: token);
    } catch (_) {}

    try {
      if (Hive.isBoxOpen(hiveBox)) {
        final box = Hive.box(hiveBox);
        await box.put('token', token);
        await box.put('auth_token', token);
      }
    } catch (_) {}
  }

  /// Remove token across SecureStorage and Hive
  static Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: tokenKey);
    } catch (_) {}

    try {
      if (Hive.isBoxOpen(hiveBox)) {
        final box = Hive.box(hiveBox);
        await box.delete('token');
        await box.delete('auth_token');
      }
    } catch (_) {}
  }

  Future<void> _handleUnauthorizedResponse(
    int? statusCode,
    dynamic responseData,
  ) async {
    if (!_shouldRedirectToLogin(statusCode, responseData)) return;

    await AuthSessionService.handleInvalidToken(
      message: _extractResponseMessage(responseData) ?? 'Invalid token',
    );
  }

  bool _shouldRedirectToLogin(int? statusCode, dynamic responseData) {
    if (statusCode == 401) return true;

    final responseMessage = _extractResponseMessage(responseData);
    if (responseMessage == null) return false;

    final normalizedMessage = responseMessage.toLowerCase();
    return normalizedMessage.contains('invalid token') ||
        normalizedMessage.contains('token invalid') ||
        normalizedMessage.contains('token expired') ||
        normalizedMessage.contains('unauthorized');
  }

  String? _extractResponseMessage(dynamic responseData) {
    if (responseData is Map) {
      for (final key in ['message', 'msg', 'error']) {
        final value = responseData[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
        if (value is Map && value['message'] is String) {
          return value['message'].toString().trim();
        }
      }
    }

    if (responseData is String && responseData.trim().isNotEmpty) {
      return responseData.trim();
    }

    return null;
  }

  BaseOptions _getBaseOptions() {
    return BaseOptions(
      baseUrl: 'https://field-service-management-iota.vercel.app',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }
}
