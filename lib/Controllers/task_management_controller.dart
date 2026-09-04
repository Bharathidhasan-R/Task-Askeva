import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Models/task_model.dart';
import '../Routes/app_routes.dart';
import '../Services/task_api_service.dart';
import '../common/app_toast.dart';

class TaskManagementController extends GetxController {
  static TaskManagementController get to =>
      Get.find<TaskManagementController>();

  final TaskApiService _apiService = TaskApiService();

  // User Auth State
  var isLoggedIn = false.obs;
  var userName = 'Field Technician'.obs;
  var userRole = 'Senior Field Technician'.obs;
  var employeeId = 'TECH-8492'.obs;
  var userPhone = '+91 98765 43210'.obs;
  var isOnline = true.obs;

  // Task lists & filters
  var tasks = <TaskItem>[].obs;
  var selectedStatusFilter =
      'All'.obs; // All, Assigned, Accepted, In Progress, Completed
  var selectedPriorityFilter = 'All'.obs; // All, Low, Medium, High, Urgent
  var searchQuery = ''.obs;
  var isLoading = false.obs;
  var isSyncing = false.obs;

  final ImagePicker _imagePicker = ImagePicker();
  static const String _taskCacheKey = 'field_service_tasks';

  @override
  void onInit() {
    super.onInit();
    isLoggedIn.value = _apiService.isAuthenticated;
    _initializeTasks();
  }

  Future<void> _initializeTasks() async {
    await _loadCachedTasks();
    if (_apiService.isAuthenticated) {
      await fetchTasksFromApi();
    }
  }

  Future<void> _loadCachedTasks() async {
    try {
      final box = Hive.box('itemsDB');
      final raw = box.get(_taskCacheKey);
      if (raw is List) {
        final cached = raw
            .whereType<Map>()
            .map((item) => TaskItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        if (cached.isNotEmpty) tasks.assignAll(cached);
      }
    } catch (e) {
      debugPrint('Could not load cached field-service tasks: $e');
    }
  }

  Future<void> _persistTasks() async {
    try {
      final box = Hive.box('itemsDB');
      await box.put(
        _taskCacheKey,
        tasks.map((task) => task.toJson()).toList(growable: false),
      );
    } catch (e) {
      debugPrint('Could not persist field-service tasks: $e');
    }
  }

  /// Fetch tasks from NestJS REST API with fallback to local cached tasks
  Future<void> fetchTasksFromApi() async {
    if (!isOnline.value) return;
    isLoading.value = true;
    try {
      final remoteTasks = await _apiService.getTasks();
      if (remoteTasks != null && remoteTasks.isNotEmpty) {
        tasks.assignAll(remoteTasks);
        await _persistTasks();
      } else if (tasks.isEmpty) {
        _loadInitialMockTasks();
      }
    } catch (e) {
      debugPrint('Error fetching tasks from API: $e');
      if (tasks.isEmpty) {
        _loadInitialMockTasks();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Reactive Task Statistics
  int get totalCount => tasks.length;
  int get assignedCount =>
      tasks.where((t) => t.status == TaskStatus.assigned).length;
  int get acceptedCount =>
      tasks.where((t) => t.status == TaskStatus.accepted).length;
  int get inProgressCount =>
      tasks.where((t) => t.status == TaskStatus.inProgress).length;
  int get completedCount =>
      tasks.where((t) => t.status == TaskStatus.completed).length;
  int get pendingSyncCount =>
      tasks.where((t) => t.syncState == SyncState.pending).length;
  int get failedSyncCount =>
      tasks.where((t) => t.syncState == SyncState.failed).length;

  TaskItem? get activeSpotlightTask {
    try {
      return tasks.firstWhere(
        (t) => t.status == TaskStatus.inProgress,
        orElse: () => tasks.firstWhere(
          (t) => t.status == TaskStatus.accepted,
          orElse: () => tasks.firstWhere(
            (t) => t.status == TaskStatus.assigned,
            orElse: () => tasks.first,
          ),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  List<TaskItem> get filteredTasks {
    return tasks.where((task) {
      // Status Filter
      if (selectedStatusFilter.value != 'All') {
        if (selectedStatusFilter.value == 'Pending Sync') {
          if (task.syncState != SyncState.pending) return false;
        } else if (task.status.label.toLowerCase() !=
            selectedStatusFilter.value.toLowerCase()) {
          return false;
        }
      }

      // Priority Filter
      if (selectedPriorityFilter.value != 'All') {
        if (task.priority.label.toLowerCase() !=
            selectedPriorityFilter.value.toLowerCase()) {
          return false;
        }
      }

      // Search Query
      if (searchQuery.value.trim().isNotEmpty) {
        final query = searchQuery.value.toLowerCase().trim();
        final matchesTitle = task.title.toLowerCase().contains(query);
        final matchesCustomer = task.customerName.toLowerCase().contains(query);
        final matchesNumber = task.taskNumber.toLowerCase().contains(query);
        final matchesCategory = task.serviceCategory.toLowerCase().contains(
          query,
        );
        final matchesAddress = task.customerAddress.toLowerCase().contains(
          query,
        );
        if (!matchesTitle &&
            !matchesCustomer &&
            !matchesNumber &&
            !matchesCategory &&
            !matchesAddress) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  TaskItem? getTaskById(String id) {
    try {
      return tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- Task Workflow Actions ---

  /// Accept an assigned task
  Future<void> acceptTask(String taskId) async {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final updated = tasks[index].copyWith(
        status: TaskStatus.accepted,
        syncState: isOnline.value ? SyncState.synced : SyncState.pending,
        lastModified: DateTime.now(),
      );
      tasks[index] = updated;
      tasks.refresh();
      await _persistTasks();

      if (isOnline.value) {
        _apiService.updateTaskStatus(taskId: taskId, status: 'accepted').then((
          success,
        ) async {
          tasks[index] = updated.copyWith(
            syncState: success ? SyncState.synced : SyncState.failed,
          );
          tasks.refresh();
          await _persistTasks();
        });
      }

      AppToast.success(
        'Task Accepted',
        'Task ${updated.taskNumber} has been moved to Accepted state.',
      );
    }
  }

  /// Start working on task -> Captures Current GPS Location
  Future<void> startTask(String taskId) async {
    isLoading.value = true;
    try {
      final position = await _getCurrentLocationSafe();
      if (position == null) {
        AppToast.error(
          'Location Required',
          'A verified GPS location is required to start this work order.',
        );
        return;
      }
      final lat = position.latitude;
      final lng = position.longitude;

      final index = tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        final now = DateTime.now();
        final updated = tasks[index].copyWith(
          status: TaskStatus.inProgress,
          startedAt: now,
          startLatitude: lat,
          startLongitude: lng,
          syncState: SyncState.pending,
          lastModified: now,
        );
        tasks[index] = updated;
        tasks.refresh();
        await _persistTasks();

        if (isOnline.value) {
          final success = await _apiService.updateTaskStatus(
            taskId: taskId,
            status: 'in_progress',
            startLatitude: lat,
            startLongitude: lng,
            startedAt: now,
          );
          tasks[index] = updated.copyWith(
            syncState: success ? SyncState.synced : SyncState.failed,
          );
          tasks.refresh();
          await _persistTasks();
        }

        AppToast.warning(
          'Task Started 🚀',
          'Service is now In-Progress. Start GPS recorded ($lat, $lng).',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Complete task with mandatory note, photo evidence, customer remark, & final GPS
  Future<bool> completeTask({
    required String taskId,
    required String completionNote,
    required List<String> images,
    String? customerRemark,
    required bool isCustomerConfirmed,
  }) async {
    if (completionNote.trim().isEmpty) {
      AppToast.error(
        'Validation Error',
        'Please enter service completion notes.',
      );
      return false;
    }

    if (images.isEmpty) {
      AppToast.error(
        'Photo Evidence Required',
        'Please add at least 1 photo evidence before completing.',
      );
      return false;
    }

    if (!isCustomerConfirmed) {
      AppToast.error(
        'Customer Confirmation Required',
        'Ask the customer to verify the completed work before submitting.',
      );
      return false;
    }

    isLoading.value = true;
    try {
      final position = await _getCurrentLocationSafe();
      if (position == null) {
        AppToast.error(
          'Location Required',
          'A verified GPS location is required to complete this work order.',
        );
        return false;
      }
      final lat = position.latitude;
      final lng = position.longitude;

      final index = tasks.indexWhere((t) => t.id == taskId);
      if (index == -1) return false;
      final now = DateTime.now();
      final currentNotes = List<TaskNote>.from(tasks[index].notes);
      currentNotes.add(
        TaskNote(
          id: 'note_${now.millisecondsSinceEpoch}',
          content: 'Completion Note: $completionNote',
          createdAt: now,
          authorName: userName.value,
        ),
      );

      final currentImages = List<String>.from(tasks[index].evidenceImages);
      for (final img in images) {
        if (!currentImages.contains(img)) {
          currentImages.add(img);
        }
      }

      final updated = tasks[index].copyWith(
        status: TaskStatus.completed,
        completedAt: now,
        completeLatitude: lat,
        completeLongitude: lng,
        notes: currentNotes,
        evidenceImages: currentImages,
        customerConfirmationRemark: customerRemark,
        isCustomerConfirmed: isCustomerConfirmed,
        syncState: SyncState.pending,
        lastModified: now,
      );

      tasks[index] = updated;
      tasks.refresh();
      await _persistTasks();

      if (isOnline.value) {
        final statusSaved = await _apiService.updateTaskStatus(
          taskId: taskId,
          status: 'completed',
          completeLatitude: lat,
          completeLongitude: lng,
          completedAt: now,
          completionNote: completionNote,
          customerRemark: customerRemark,
          isCustomerConfirmed: isCustomerConfirmed,
        );

        var imagesSaved = true;
        for (final img in images) {
          if (!img.startsWith('http')) {
            imagesSaved =
                (await _apiService.uploadTaskImage(taskId, img)) != null &&
                imagesSaved;
          }
        }
        tasks[index] = updated.copyWith(
          syncState: statusSaved && imagesSaved
              ? SyncState.synced
              : SyncState.failed,
        );
        tasks.refresh();
        await _persistTasks();
      }

      AppToast.success(
        'Job Completed Successfully! 🎉',
        'Task ${updated.taskNumber} completed with photos, notes & GPS tag.',
      );
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Add quick note to a task
  Future<void> addNote(String taskId, String content) async {
    if (content.trim().isEmpty) return;

    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final now = DateTime.now();
      final newNotes = List<TaskNote>.from(tasks[index].notes);
      newNotes.add(
        TaskNote(
          id: 'note_${now.millisecondsSinceEpoch}',
          content: content.trim(),
          createdAt: now,
          authorName: userName.value,
        ),
      );

      final updated = tasks[index].copyWith(
        notes: newNotes,
        syncState: isOnline.value ? SyncState.synced : SyncState.pending,
        lastModified: now,
      );
      tasks[index] = updated;
      tasks.refresh();
      await _persistTasks();

      if (isOnline.value) {
        final success = await _apiService.addNote(taskId, content.trim());
        tasks[index] = updated.copyWith(
          syncState: success ? SyncState.synced : SyncState.failed,
        );
        tasks.refresh();
        await _persistTasks();
      }

      AppToast.info('Note Saved', 'Note added to task activity timeline.');
    }
  }

  /// Add Image from Camera or Gallery
  Future<String?> pickEvidenceImage(ImageSource source) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );
      return file?.path;
    } catch (e) {
      debugPrint('Error picking image: $e');
      AppToast.error('Image Error', 'Could not access image picker: $e');
      return null;
    }
  }

  /// Attach photo directly to task
  Future<void> attachPhotoToTask(String taskId, ImageSource source) async {
    final path = await pickEvidenceImage(source);
    if (path != null) {
      final index = tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        final newImages = List<String>.from(tasks[index].evidenceImages)
          ..add(path);
        final updated = tasks[index].copyWith(
          evidenceImages: newImages,
          syncState: SyncState.pending,
          lastModified: DateTime.now(),
        );
        tasks[index] = updated;
        tasks.refresh();
        await _persistTasks();

        if (isOnline.value) {
          final uploaded = await _apiService.uploadTaskImage(taskId, path);
          tasks[index] = updated.copyWith(
            syncState: uploaded != null ? SyncState.synced : SyncState.failed,
          );
          tasks.refresh();
          await _persistTasks();
        }

        AppToast.success(
          'Photo Attached',
          'Evidence photo added successfully.',
        );
      }
    }
  }

  // --- External Integrations (Phone Call & Maps Navigation) ---

  Future<void> makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(' ', '').replaceAll('-', '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        AppToast.error(
          'Call Error',
          'Could not open phone dialer for $phoneNumber',
        );
      }
    } catch (e) {
      AppToast.error('Call Error', 'Error initiating call: $e');
    }
  }

  Future<void> openMapNavigation({
    required double lat,
    required double lng,
    required String address,
  }) async {
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($address)');

    try {
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri);
      } else if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        AppToast.error(
          'Navigation Error',
          'Could not open map navigation for this location.',
        );
      }
    } catch (e) {
      AppToast.error('Navigation Error', 'Error launching maps: $e');
    }
  }

  // --- Offline & Sync System ---

  Future<void> syncAllPending() async {
    if (!isOnline.value) {
      AppToast.warning(
        'Still Offline',
        'Connect to the internet before synchronizing pending changes.',
      );
      return;
    }
    isSyncing.value = true;
    var syncedCount = 0;
    var failedCount = 0;

    try {
      for (int i = 0; i < tasks.length; i++) {
        final task = tasks[i];
        if (task.syncState == SyncState.pending ||
            task.syncState == SyncState.failed) {
          var success = await _apiService.updateTaskStatus(
            taskId: task.id,
            status: task.status.name,
            startLatitude: task.startLatitude,
            startLongitude: task.startLongitude,
            startedAt: task.startedAt,
            completeLatitude: task.completeLatitude,
            completeLongitude: task.completeLongitude,
            completedAt: task.completedAt,
            completionNote: task.notes.isNotEmpty
                ? task.notes.last.content
                : null,
            customerRemark: task.customerConfirmationRemark,
            isCustomerConfirmed: task.isCustomerConfirmed,
          );

          if (success && task.notes.isNotEmpty) {
            success = await _apiService.addNote(
              task.id,
              task.notes.last.content.replaceFirst('Completion Note: ', ''),
            );
          }
          if (success) {
            for (final image in task.evidenceImages.where(
              (path) => !path.startsWith('http'),
            )) {
              if (await _apiService.uploadTaskImage(task.id, image) == null) {
                success = false;
                break;
              }
            }
          }

          tasks[i] = task.copyWith(
            syncState: success ? SyncState.synced : SyncState.failed,
          );
          success ? syncedCount++ : failedCount++;
        }
      }
      tasks.refresh();
      await _persistTasks();

      if (failedCount == 0) {
        AppToast.success(
          'Sync Complete ☁️',
          '$syncedCount pending work order(s) synchronized.',
        );
      } else {
        AppToast.error(
          'Sync Incomplete',
          '$failedCount work order(s) could not be synchronized. Please retry.',
        );
      }
    } finally {
      isSyncing.value = false;
    }
  }

  void toggleOnlineStatus() {
    isOnline.value = !isOnline.value;
    AppToast.info(
      isOnline.value ? 'Online Mode 🌐' : 'Offline Mode ⚡',
      isOnline.value
          ? 'Connected to server. Cloud auto-sync is active.'
          : 'Working offline. All changes will be saved to local storage.',
    );
  }

  // --- Authentication ---

  Future<bool> login(String identifier, String password) async {
    isLoading.value = true;

    try {
      final authResult = await _apiService.signIn(identifier, password);
      if (authResult != null) {
        final user = authResult['data']?['user'] ?? authResult['user'];
        if (user != null) {
          userName.value =
              user['fullName'] ??
              user['full_name'] ??
              user['name'] ??
              user['email'] ??
              'Field Technician';
          userRole.value = user['role'] ?? 'technician';
          employeeId.value =
              user['employee_id'] ??
              (user['id'] != null
                  ? 'TECH-${user['id'].toString().substring(0, 4)}'
                  : 'TECH-001');
          userPhone.value = user['phone'] ?? '+91 98765 43210';
        }
        isLoggedIn.value = true;
        isLoading.value = false;
        await fetchTasksFromApi();
        AppToast.success('Welcome Back 👋', 'Signed in successfully.');
        Get.offAllNamed(AppRoutes.home);
        return true;
      } else {
        isLoading.value = false;
        AppToast.error(
          'Login Failed',
          'Invalid credentials. Please check your email and password.',
        );
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      String errorMsg = 'Invalid email or password.';
      if (e is DioException) {
        if (e.response?.data is Map && e.response?.data['error'] != null) {
          final err = e.response!.data['error'];
          errorMsg = err is Map
              ? (err['message'] ?? 'Invalid credentials')
              : err.toString();
        } else if (e.response?.data is Map &&
            e.response?.data['message'] != null) {
          errorMsg = e.response!.data['message'].toString();
        } else if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          errorMsg =
              'Could not reach server. Please check internet connection.';
        }
      }
      AppToast.error('Authentication Error', errorMsg);
      return false;
    }
  }

  /// Optional Demo Mode Login for offline testing without server
  Future<void> loginDemoMode({
    String email = 'demo@local.invalid',
    String name = 'Demo Technician',
  }) async {
    userName.value = name;
    userRole.value = 'Senior Field Technician';
    employeeId.value = 'TECH-8492';
    isLoggedIn.value = true;
    _loadInitialMockTasks();
    await _persistTasks();
    AppToast.info('Demo Mode Active', 'Logged in as $name (Offline Demo Mode)');
    Get.offAllNamed(AppRoutes.home);
  }

  Future<void> logout() async {
    await _apiService.clearToken();
    isLoggedIn.value = false;
    Get.offAllNamed(AppRoutes.login);
    AppToast.info('Logged Out', 'You have been securely logged out.');
  }

  // --- Helper Methods ---

  Future<Position?> _getCurrentLocationSafe() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(
          const Duration(seconds: 10),
        );
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      debugPrint('Geolocator error: $e');
      return null;
    }
  }

  void _loadInitialMockTasks() {
    final now = DateTime.now();

    tasks.assignAll([
      TaskItem(
        id: 'TASK_101',
        taskNumber: 'TSK-2026-001',
        title: 'Air Conditioner Coil Cleaning & Gas Refill',
        serviceCategory: 'AC Install & Maintenance',
        description:
            'Customer reported low cooling in master bedroom Split AC (1.5 Ton). Check filter coils, compressor pressure, and refill refrigerant gas if required.',
        priority: TaskPriority.urgent,
        status: TaskStatus.inProgress,
        scheduledDateTime: now.subtract(const Duration(hours: 1)),
        startedAt: now.subtract(const Duration(minutes: 40)),
        startLatitude: 11.0168,
        startLongitude: 76.9558,
        customerName: 'Karthik Subramanian',
        customerPhone: '+91 94432 18900',
        customerAddress:
            'Flat 402, Green Valley Apartments, RS Puram, Coimbatore',
        customerLatitude: 11.0168,
        customerLongitude: 76.9558,
        notes: [
          TaskNote(
            id: 'n1',
            content:
                'Arrived on site. Outdoor unit gas level is at 45 PSI (nominal 65 PSI).',
            createdAt: now.subtract(const Duration(minutes: 30)),
            authorName: 'Bharathi Raman',
          ),
        ],
        evidenceImages: [
          'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=500&q=80',
        ],
        syncState: SyncState.synced,
      ),
      TaskItem(
        id: 'TASK_102',
        taskNumber: 'TSK-2026-002',
        title: 'Master Bathroom Shower Leakage & Mixer Replacement',
        serviceCategory: 'Plumbing',
        description:
            'Concealed shower valve leaking continuously into wall tiles. Requires mixer cartridge replacement and leak sealing.',
        priority: TaskPriority.high,
        status: TaskStatus.accepted,
        scheduledDateTime: now.add(const Duration(hours: 2)),
        customerName: 'Ananya Sharma',
        customerPhone: '+91 98840 55123',
        customerAddress: 'No. 18, 3rd Cross Street, Gandhipuram, Coimbatore',
        customerLatitude: 11.0180,
        customerLongitude: 76.9650,
        notes: [
          TaskNote(
            id: 'n2',
            content:
                'Customer requested technician to bring spare Jaquar mixer cartridges.',
            createdAt: now.subtract(const Duration(hours: 2)),
            authorName: 'Helpdesk Dispatch',
          ),
        ],
        syncState: SyncState.synced,
      ),
      TaskItem(
        id: 'TASK_103',
        taskNumber: 'TSK-2026-003',
        title: 'Main MCB Tripping & Short Circuit Inspection',
        serviceCategory: 'Electrical',
        description:
            'Kitchen circuit tripping 32A MCB whenever oven or microwave is turned on. Diagnose overload & replace faulty breaker.',
        priority: TaskPriority.high,
        status: TaskStatus.assigned,
        scheduledDateTime: now.add(const Duration(hours: 4)),
        customerName: 'Venkatesh Babu',
        customerPhone: '+91 97910 88442',
        customerAddress: 'Villa 12, Emerald Enclave, Peelamedu, Coimbatore',
        customerLatitude: 11.0289,
        customerLongitude: 77.0028,
        notes: [],
        syncState: SyncState.synced,
      ),
      TaskItem(
        id: 'TASK_104',
        taskNumber: 'TSK-2026-004',
        title: 'Kitchen Chimney Deep Cleaning & Filter Degreasing',
        serviceCategory: 'Kitchen Renovation',
        description:
            'Baffle filter high grease accumulation. Full motor housing disassembly and degreasing service.',
        priority: TaskPriority.medium,
        status: TaskStatus.assigned,
        scheduledDateTime: now.add(const Duration(days: 1)),
        customerName: 'Deepa Rajan',
        customerPhone: '+91 98402 11990',
        customerAddress: 'Plot 88, Anna Nagar West, Saibaba Colony, Coimbatore',
        customerLatitude: 11.0310,
        customerLongitude: 76.9420,
        notes: [],
        syncState: SyncState.synced,
      ),
      TaskItem(
        id: 'TASK_105',
        taskNumber: 'TSK-2026-005',
        title: 'Balcony Waterproofing & Weather Coat Painting',
        serviceCategory: 'Painting',
        description:
            'Rainwater seepage into lower floor ceiling. Apply 2 coats of Dr. Fixit Prime seal and exterior emulsion.',
        priority: TaskPriority.low,
        status: TaskStatus.completed,
        scheduledDateTime: now.subtract(const Duration(days: 1)),
        startedAt: now.subtract(const Duration(days: 1, hours: 4)),
        completedAt: now.subtract(const Duration(days: 1)),
        startLatitude: 11.0120,
        startLongitude: 76.9500,
        completeLatitude: 11.0122,
        completeLongitude: 76.9502,
        customerName: 'Suresh Kumar',
        customerPhone: '+91 94440 33881',
        customerAddress: 'No 45, Race Course Road, Coimbatore',
        customerLatitude: 11.0090,
        customerLongitude: 76.9740,
        notes: [
          TaskNote(
            id: 'n3',
            content:
                'Completed crack sealing and applied 2 coats of weatherproof coating.',
            createdAt: now.subtract(const Duration(days: 1)),
            authorName: 'Bharathi Raman',
          ),
        ],
        evidenceImages: [
          'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=500&q=80',
        ],
        customerConfirmationRemark:
            'Very neat and timely work done by technician.',
        isCustomerConfirmed: true,
        syncState: SyncState.synced,
      ),
    ]);
  }
}
