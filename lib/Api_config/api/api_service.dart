import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../api_client/api_client.dart';

class ApiService {
  static final ApiService _genericApiService = ApiService._internal();
  static const String hiveBox = 'itemsDB';

  factory ApiService() => _genericApiService;

  ApiService._internal();

  // -------------------------
  // GET TOKEN FROM HIVE
  // -------------------------
  Future<String> _getToken() async {
    try {
      final box = await Hive.openBox(hiveBox);
      final token = box.get('token', defaultValue: '');
      return token;
    } catch (e) {
      debugPrint('Error getting token: $e');
      return '';
    }
  }

  // -------------------------
  // GET METHOD
  // -------------------------
  Future<Response> get({required String endpoint}) async {
    var apiClient = await ApiClient().getApiClient();
    apiClient.options.headers = await getHeaders(isMultipart: false);
    return apiClient.get(endpoint);
  }

  // -------------------------
  // FORM DATA METHOD
  // -------------------------
  Future<Response> formData({
    required String endpoint,
    required Map<String, dynamic> queryParameters,
    File? file,
    String? filename,
  }) async {
    debugPrint('request/////');
    debugPrint(queryParameters.toString());

    var documentFormData = <String, dynamic>{};
    queryParameters.forEach((k, v) {
      documentFormData[k] = v;
    });

    var formData = FormData.fromMap(documentFormData);
    var apiClient = await ApiClient().getApiClient();
    apiClient.options.headers["Content-Type"] = "multipart/form-data";
    apiClient.options.headers = await getHeaders();

    return apiClient.post(endpoint, data: formData);
  }

  // -------------------------
  // NORMAL POST (JSON or FormData without files)
  // -------------------------
  Future<Response> post({
    required String endpoint,
    required Map<String, dynamic> queryParameters,
  }) async {
    var apiClient = await ApiClient().getApiClient();
    apiClient.options.headers = await getHeaders(isMultipart: true);
    return apiClient.post(
      endpoint,
      data: FormData.fromMap(queryParameters),
    );
  }

  // -------------------------
  // MULTIPART POST (image/file upload)
  // -------------------------
  Future<Response> postMultipart({
    required String endpoint,
    required FormData formData,
  }) async {
    var apiClient = await ApiClient().getApiClient();
    apiClient.options.headers = await getHeaders(isMultipart: true);

    return apiClient.post(
      endpoint,
      data: formData,
      options: Options(
        contentType: "multipart/form-data",
      ),
    );
  }

  // -------------------------
  // HEADERS WITH DYNAMIC TOKEN
  // -------------------------
  Future<Map<String, dynamic>> getHeaders({bool isMultipart = false}) async {
    final token = await _getToken();

    return {
      "Content-Type": isMultipart ? "multipart/form-data" : "application/json",
      "X-Source": "mobile-app",
      if (token.isNotEmpty) "Authorization":"Bearer $token",
      // If your API requires "Bearer " prefix, use:
      // if (token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }
}