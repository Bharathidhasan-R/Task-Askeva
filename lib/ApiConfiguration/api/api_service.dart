import 'dart:io';
import 'package:dio/dio.dart';
import '../api_client/api_client.dart';

class ApiService {
  static final ApiService _genericApiService = ApiService._internal();

  factory ApiService() => _genericApiService;

  ApiService._internal();

  // -------------------------
  // TOKEN & AUTH HELPERS
  // -------------------------
  Future<String> getToken() async {
    return await ApiClient.getToken();
  }

  Future<void> setToken(String token) async {
    await ApiClient.saveToken(token);
  }

  Future<void> clearToken() async {
    await ApiClient.deleteToken();
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token.isNotEmpty;
  }

  // -------------------------
  // GET METHOD
  // -------------------------
  Future<Response> get({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final apiClient = await ApiClient().getApiClient();
    return apiClient.get(
      endpoint,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // -------------------------
  // POST METHOD (JSON or Object Body)
  // -------------------------
  Future<Response> post({
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final apiClient = await ApiClient().getApiClient();
    return apiClient.post(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // -------------------------
  // PATCH METHOD
  // -------------------------
  Future<Response> patch({
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final apiClient = await ApiClient().getApiClient();
    return apiClient.patch(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // -------------------------
  // PUT METHOD
  // -------------------------
  Future<Response> put({
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final apiClient = await ApiClient().getApiClient();
    return apiClient.put(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // -------------------------
  // DELETE METHOD
  // -------------------------
  Future<Response> delete({
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final apiClient = await ApiClient().getApiClient();
    return apiClient.delete(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // -------------------------
  // FORM DATA METHOD (Legacy Form data)
  // -------------------------
  Future<Response> formData({
    required String endpoint,
    required Map<String, dynamic> queryParameters,
    File? file,
    String? filename,
  }) async {
    final documentFormData = <String, dynamic>{};
    queryParameters.forEach((k, v) {
      documentFormData[k] = v;
    });

    if (file != null) {
      documentFormData['file'] = await MultipartFile.fromFile(
        file.path,
        filename: filename ?? file.path.split('/').last,
      );
    }

    final formData = FormData.fromMap(documentFormData);
    final apiClient = await ApiClient().getApiClient();

    return apiClient.post(
      endpoint,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  // -------------------------
  // MULTIPART POST (image/file upload)
  // -------------------------
  Future<Response> postMultipart({
    required String endpoint,
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final apiClient = await ApiClient().getApiClient();
    final customOptions = options ?? Options();
    customOptions.contentType = "multipart/form-data";

    return apiClient.post(
      endpoint,
      data: formData,
      queryParameters: queryParameters,
      options: customOptions,
    );
  }

  // -------------------------
  // HEADERS WITH DYNAMIC TOKEN
  // -------------------------
  Future<Map<String, dynamic>> getHeaders({bool isMultipart = false}) async {
    final token = await getToken();

    return {
      "Content-Type": isMultipart ? "multipart/form-data" : "application/json",
      "Accept": "application/json",
      "X-Source": "mobile-app",
      if (token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }
}