// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import '../../App Configuration/app_config.dart';
//
// class ApiClient {
//   static final ApiClient _instance = ApiClient.internal();
//   ApiClient.internal();
//   factory ApiClient() => _instance;
//   late Dio dio;
//   int retry = 0;
//   Future<Dio> getApiClient() async {
//     dio = Dio(_getBaseOptions());
//     dio.interceptors.clear();
//     dio.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
//       return handler.next(options);
//     }, onResponse: (Response response, ResponseInterceptorHandler handler) async {
//       debugPrint('apiresponse');
//       debugPrint(response.data.toString());
//       return handler.next(response);
//     }, onError: (DioException error, ErrorInterceptorHandler handler) async {
//       // commonFunctions.errorSnackBar(Get.overlayContext!, "Server is busy, please try again later.");
//       debugPrint("ERROR MESSAGE:${error.message}");
//     }));
//     dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
//     return dio;
//   }
//   BaseOptions _getBaseOptions() {
//     return BaseOptions(
//         baseUrl:AppConfig.baseUrl,
//         connectTimeout:const Duration(seconds: 10),
//         receiveTimeout:const Duration(seconds: 10),
//         sendTimeout:const Duration(seconds: 10),
//       validateStatus: (status) => true, // Accept all status codes
//     );
//   }
// }
//
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../App Configuration/auth_session_service.dart';
import '../../App Configuration/app_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient.internal();
  ApiClient.internal();
  factory ApiClient() => _instance;
  late Dio dio;
  int retry = 0;

  Future<Dio> getApiClient() async {
    dio = Dio(_getBaseOptions());
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (
            RequestOptions options,
            RequestInterceptorHandler handler,
            ) {
          return handler.next(options);
        },
        onResponse: (
            Response response,
            ResponseInterceptorHandler handler,
            ) async {
          debugPrint('apiresponse');
          debugPrint(response.data.toString());
          await _handleUnauthorizedResponse(response.statusCode, response.data);
          return handler.next(response);
        },
        onError: (
            DioException error,
            ErrorInterceptorHandler handler,
            ) async {
          debugPrint("ERROR MESSAGE:${error.message}");
          await _handleUnauthorizedResponse(
            error.response?.statusCode,
            error.response?.data,
          );
          return handler.next(error);
        },
      ),
    );
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    return dio;
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
      }
    }

    if (responseData is String && responseData.trim().isNotEmpty) {
      return responseData.trim();
    }

    return null;
  }

  BaseOptions _getBaseOptions() {
    return BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      sendTimeout: const Duration(seconds: 12),
      validateStatus: (status) => true, // Accept all status codes
    );
  }
}
