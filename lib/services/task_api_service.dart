import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../Models/task_model.dart';

class TaskApiService {
  static final TaskApiService _instance = TaskApiService._internal();
  factory TaskApiService() => _instance;

  static const String baseUrl =
      'https://field-service-management-iota.vercel.app';

  late final Dio _dio;
  String? _accessToken;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const String _tokenKey = 'field_service_auth_token';

  TaskApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null && _accessToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          debugPrint(
            'API Error [${error.response?.statusCode}]: ${error.requestOptions.path}',
          );
          debugPrint('Error Data: ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> initialize() async {
    _accessToken = await _secureStorage.read(key: _tokenKey);

    // Remove tokens written by older builds after migrating them to secure storage.
    try {
      final box = Hive.box('itemsDB');
      final legacyToken = box.get('auth_token')?.toString();
      if ((_accessToken == null || _accessToken!.isEmpty) &&
          legacyToken != null &&
          legacyToken.isNotEmpty) {
        _accessToken = legacyToken;
        await _secureStorage.write(key: _tokenKey, value: legacyToken);
      }
      await box.delete('auth_token');
    } catch (_) {}
  }

  Future<void> setToken(String token) async {
    _accessToken = token;
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<void> clearToken() async {
    _accessToken = null;
    await _secureStorage.delete(key: _tokenKey);
    try {
      final box = Hive.box('itemsDB');
      await box.delete('auth_token');
    } catch (_) {}
  }

  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  // 1. Sign In
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/signin',
        data: {'email': email.trim(), 'password': password.trim()},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final token =
            data['data']?['accessToken'] ??
            data['accessToken'] ??
            data['data']?['token'] ??
            data['token'];

        if (token != null) {
          await setToken(token.toString());
        }
        return data is Map<String, dynamic> ? data : {'data': data};
      }
      return null;
    } on DioException {
      rethrow;
    }
  }

  // 2. Get Dashboard Metrics
  Future<Map<String, dynamic>?> getDashboard() async {
    try {
      final response = await _dio.get('/api/dashboard');
      if (response.statusCode == 200) {
        return response.data is Map<String, dynamic>
            ? response.data
            : {'data': response.data};
      }
      return null;
    } on DioException catch (e) {
      debugPrint('Get Dashboard Failed: ${e.message}');
      return null;
    }
  }

  // 3. List Tasks
  Future<List<TaskItem>?> getTasks({String? status, String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status.isNotEmpty && status != 'All') {
        queryParams['status'] = status.toLowerCase().replaceAll(' ', '_');
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        '/api/tasks',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final rawData = response.data;
        List list = [];
        if (rawData is Map) {
          if (rawData['data'] is Map && rawData['data']['items'] is List) {
            list = rawData['data']['items'] as List;
          } else if (rawData['data'] is List) {
            list = rawData['data'] as List;
          } else if (rawData['items'] is List) {
            list = rawData['items'] as List;
          }
        } else if (rawData is List) {
          list = rawData;
        }

        return list.map((json) => _mapJsonToTaskItem(json)).toList();
      }
      return null;
    } on DioException catch (e) {
      debugPrint('Get Tasks Failed: ${e.message}');
      return null;
    }
  }

  // 4. Get Task Details
  Future<TaskItem?> getTaskDetails(String taskId) async {
    try {
      final response = await _dio.get('/api/tasks/$taskId');
      if (response.statusCode == 200) {
        final data = response.data is Map && response.data['data'] != null
            ? response.data['data']
            : response.data;
        return _mapJsonToTaskItem(data);
      }
      return null;
    } on DioException catch (e) {
      debugPrint('Get Task Details Failed: ${e.message}');
      return null;
    }
  }

  // 5. Update Task Status & Coordinates (Accept, Start, Complete)
  Future<bool> updateTaskStatus({
    required String taskId,
    required String status,
    double? startLatitude,
    double? startLongitude,
    DateTime? startedAt,
    double? completeLatitude,
    double? completeLongitude,
    DateTime? completedAt,
    String? completionNote,
    String? customerRemark,
    bool? isCustomerConfirmed,
  }) async {
    try {
      // Map UI status to DB status enum ('pending', 'accepted', 'in_progress', 'completed', 'cancelled')
      String dbStatus = status.toLowerCase().replaceAll(' ', '_');
      if (dbStatus == 'assigned') dbStatus = 'pending';

      final body = <String, dynamic>{'status': dbStatus};

      if (startedAt != null) body['started_at'] = startedAt.toIso8601String();
      if (startLatitude != null) body['start_latitude'] = startLatitude;
      if (startLongitude != null) body['start_longitude'] = startLongitude;

      if (completeLatitude != null) {
        body['completion_latitude'] = completeLatitude;
        body['complete_latitude'] = completeLatitude;
      }
      if (completeLongitude != null) {
        body['completion_longitude'] = completeLongitude;
        body['complete_longitude'] = completeLongitude;
      }
      if (completedAt != null) {
        body['completed_at'] = completedAt.toIso8601String();
      }
      if (completionNote != null) body['completion_note'] = completionNote;
      if (customerRemark != null) {
        body['customer_confirmation_note'] = customerRemark;
        body['customer_confirmation_remark'] = customerRemark;
      }
      if (isCustomerConfirmed != null) {
        body['customer_confirmed'] = isCustomerConfirmed;
        body['is_customer_confirmed'] = isCustomerConfirmed;
      }

      final response = await _dio.patch('/api/tasks/$taskId', data: body);

      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      debugPrint('Update Task Status Failed: ${e.message}');
      return false;
    }
  }

  // 6. Create Task
  Future<TaskItem?> createTask({
    required String title,
    required String description,
    required String customerId,
    required String assignedTo,
    String priority = 'medium',
  }) async {
    try {
      final response = await _dio.post(
        '/api/tasks',
        data: {
          'title': title.trim(),
          'description': description.trim(),
          'customer_id': customerId,
          'assigned_to': assignedTo,
          'priority': priority.toLowerCase(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map && response.data['data'] != null
            ? response.data['data']
            : response.data;
        return _mapJsonToTaskItem(data);
      }
      return null;
    } on DioException catch (e) {
      debugPrint('Create Task Failed: ${e.message}');
      return null;
    }
  }

  // 7. List Notes
  Future<List<TaskNote>?> getNotes(String taskId) async {
    try {
      final response = await _dio.get('/api/tasks/$taskId/notes');
      if (response.statusCode == 200) {
        final rawData = response.data;
        List list = [];
        if (rawData is Map) {
          if (rawData['data'] is Map && rawData['data']['items'] is List) {
            list = rawData['data']['items'] as List;
          } else if (rawData['data'] is List) {
            list = rawData['data'] as List;
          } else if (rawData['items'] is List) {
            list = rawData['items'] as List;
          }
        } else if (rawData is List) {
          list = rawData;
        }

        return list.map((item) {
          return TaskNote(
            id: item['id']?.toString() ?? UniqueKey().toString(),
            content:
                item['note']?.toString() ?? item['content']?.toString() ?? '',
            createdAt: item['created_at'] != null
                ? DateTime.tryParse(item['created_at'].toString()) ??
                      DateTime.now()
                : DateTime.now(),
            authorName:
                item['author_name'] ??
                item['author']?['full_name'] ??
                'Technician',
          );
        }).toList();
      }
      return null;
    } on DioException catch (e) {
      debugPrint('Get Notes Failed: ${e.message}');
      return null;
    }
  }

  // 8. Add Note
  Future<bool> addNote(String taskId, String content) async {
    try {
      final response = await _dio.post(
        '/api/tasks/$taskId/notes',
        data: {
          'note': content.trim(),
          'clientId': 'mobile-note-${DateTime.now().millisecondsSinceEpoch}',
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      debugPrint('Add Note Failed: ${e.message}');
      return false;
    }
  }

  // 8. Upload Task Image Evidence
  Future<String?> uploadTaskImage(String taskId, String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/api/tasks/$taskId/images/upload',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return data['data']?['blob_url'] ??
            data['data']?['url'] ??
            data['blob_url'] ??
            data['url'];
      }
      return null;
    } on DioException catch (e) {
      debugPrint('Upload Task Image Failed: ${e.message}');
      return null;
    }
  }

  TaskItem _mapJsonToTaskItem(dynamic json) {
    if (json is! Map) {
      return TaskItem(
        id: 'TASK_UNKNOWN',
        taskNumber: 'TSK-000',
        title: 'Untitled Task',
        serviceCategory: 'General Maintenance',
        description: '',
        priority: TaskPriority.medium,
        status: TaskStatus.assigned,
        scheduledDateTime: DateTime.now(),
        customerName: 'Customer',
        customerPhone: '',
        customerAddress: '',
        customerLatitude: 11.0168,
        customerLongitude: 76.9558,
      );
    }

    TaskStatus status = TaskStatus.assigned;
    final statusStr =
        json['status']?.toString().toLowerCase().replaceAll('-', '_') ?? '';
    if (statusStr == 'accepted') {
      status = TaskStatus.accepted;
    } else if (statusStr == 'in_progress' || statusStr.contains('progress')) {
      status = TaskStatus.inProgress;
    } else if (statusStr == 'completed' || statusStr.contains('complet')) {
      status = TaskStatus.completed;
    } else {
      status = TaskStatus.assigned; // maps 'pending' to assigned
    }

    TaskPriority priority = TaskPriority.medium;
    final prioStr = json['priority']?.toString().toLowerCase() ?? '';
    if (prioStr == 'urgent') {
      priority = TaskPriority.urgent;
    } else if (prioStr == 'high') {
      priority = TaskPriority.high;
    } else if (prioStr == 'low') {
      priority = TaskPriority.low;
    } else {
      priority = TaskPriority.medium; // maps 'normal' to medium
    }

    final customer = json['customers'] is Map
        ? json['customers']
        : (json['customer'] is Map ? json['customer'] : null);

    final images = <String>[];
    if (json['task_images'] is List) {
      for (final img in json['task_images']) {
        if (img is Map && (img['blob_url'] != null || img['url'] != null)) {
          images.add(img['blob_url']?.toString() ?? img['url'].toString());
        } else if (img is String) {
          images.add(img);
        }
      }
    } else if (json['images'] is List) {
      for (final img in json['images']) {
        if (img is String) images.add(img);
      }
    }

    // Customer Address composition (address, city, state, postal_code)
    String customerAddr =
        customer?['address']?.toString() ??
        json['customer_address']?.toString() ??
        'Address not specified';
    if (customer?['city'] != null && customer!['city'].toString().isNotEmpty) {
      customerAddr += ', ${customer['city']}';
    }

    final completeLat =
        (json['completion_latitude'] as num?)?.toDouble() ??
        (json['complete_latitude'] as num?)?.toDouble();
    final completeLng =
        (json['completion_longitude'] as num?)?.toDouble() ??
        (json['complete_longitude'] as num?)?.toDouble();

    return TaskItem(
      id: json['id']?.toString() ?? '',
      taskNumber:
          json['task_number']?.toString() ??
          json['taskNumber']?.toString() ??
          'TSK-${json['id']?.toString().substring(0, 4) ?? '001'}',
      title: json['title']?.toString() ?? 'Service Task',
      serviceCategory:
          json['service_category']?.toString() ??
          json['category']?.toString() ??
          'General Maintenance',
      description: json['description']?.toString() ?? '',
      priority: priority,
      status: status,
      scheduledDateTime: json['scheduled_at'] != null
          ? DateTime.tryParse(json['scheduled_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'].toString())
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      startLatitude: (json['start_latitude'] as num?)?.toDouble(),
      startLongitude: (json['start_longitude'] as num?)?.toDouble(),
      completeLatitude: completeLat,
      completeLongitude: completeLng,
      customerName:
          customer?['name']?.toString() ??
          json['customer_name']?.toString() ??
          'Customer',
      customerPhone:
          customer?['phone']?.toString() ??
          json['customer_phone']?.toString() ??
          '',
      customerAddress: customerAddr,
      customerLatitude:
          (customer?['latitude'] as num?)?.toDouble() ??
          (json['customer_latitude'] as num?)?.toDouble() ??
          11.0168,
      customerLongitude:
          (customer?['longitude'] as num?)?.toDouble() ??
          (json['customer_longitude'] as num?)?.toDouble() ??
          76.9558,
      evidenceImages: images,
      customerConfirmationRemark:
          json['customer_confirmation_note']?.toString() ??
          json['customer_confirmation_remark']?.toString(),
      isCustomerConfirmed:
          json['customer_confirmed'] == true ||
          json['is_customer_confirmed'] == true,
      syncState: SyncState.synced,
    );
  }
}
