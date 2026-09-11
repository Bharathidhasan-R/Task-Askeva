enum TaskStatus {
  assigned,
  accepted,
  inProgress,
  completed;

  String get label {
    switch (this) {
      case TaskStatus.assigned:
        return 'Assigned';
      case TaskStatus.accepted:
        return 'Accepted';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  static TaskStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'accepted':
        return TaskStatus.accepted;
      case 'in progress':
      case 'in_progress':
      case 'inprogress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'assigned':
      default:
        return TaskStatus.assigned;
    }
  }
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  static TaskPriority fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'urgent':
        return TaskPriority.urgent;
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      case 'medium':
      default:
        return TaskPriority.medium;
    }
  }
}

enum SyncState {
  synced,
  pending,
  failed;

  String get label {
    switch (this) {
      case SyncState.synced:
        return 'Synced';
      case SyncState.pending:
        return 'Pending Sync';
      case SyncState.failed:
        return 'Sync Failed';
    }
  }
}

class TaskNote {
  final String id;
  final String content;
  final DateTime createdAt;
  final String authorName;

  TaskNote({
    required this.id,
    required this.content,
    required this.createdAt,
    this.authorName = 'Technician',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'authorName': authorName,
      };

  factory TaskNote.fromJson(Map<String, dynamic> json) => TaskNote(
        id: json['id'] ?? '',
        content: json['content'] ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
            : DateTime.now(),
        authorName: json['authorName'] ?? 'Technician',
      );
}

class TaskItem {
  final String id;
  final String taskNumber;
  final String title;
  final String serviceCategory;
  final String description;
  final TaskPriority priority;
  TaskStatus status;
  final DateTime scheduledDateTime;
  
  // Customer info
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final double customerLatitude;
  final double customerLongitude;

  // Tracking locations & times
  DateTime? startedAt;
  DateTime? completedAt;
  double? startLatitude;
  double? startLongitude;
  double? completeLatitude;
  double? completeLongitude;

  // Evidence & remarks
  List<TaskNote> notes;
  List<String> evidenceImages;
  String? customerConfirmationRemark;
  bool isCustomerConfirmed;

  // Offline Sync state
  SyncState syncState;
  DateTime lastModified;

  TaskItem({
    required this.id,
    required this.taskNumber,
    required this.title,
    required this.serviceCategory,
    required this.description,
    required this.priority,
    required this.status,
    required this.scheduledDateTime,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.customerLatitude,
    required this.customerLongitude,
    this.startedAt,
    this.completedAt,
    this.startLatitude,
    this.startLongitude,
    this.completeLatitude,
    this.completeLongitude,
    List<TaskNote>? notes,
    List<String>? evidenceImages,
    this.customerConfirmationRemark,
    this.isCustomerConfirmed = false,
    this.syncState = SyncState.synced,
    DateTime? lastModified,
  })  : notes = notes ?? [],
        evidenceImages = evidenceImages ?? [],
        lastModified = lastModified ?? DateTime.now();

  TaskItem copyWith({
    String? id,
    String? taskNumber,
    String? title,
    String? serviceCategory,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? scheduledDateTime,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    double? customerLatitude,
    double? customerLongitude,
    DateTime? startedAt,
    DateTime? completedAt,
    double? startLatitude,
    double? startLongitude,
    double? completeLatitude,
    double? completeLongitude,
    List<TaskNote>? notes,
    List<String>? evidenceImages,
    String? customerConfirmationRemark,
    bool? isCustomerConfirmed,
    SyncState? syncState,
    DateTime? lastModified,
  }) {
    return TaskItem(
      id: id ?? this.id,
      taskNumber: taskNumber ?? this.taskNumber,
      title: title ?? this.title,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      customerLatitude: customerLatitude ?? this.customerLatitude,
      customerLongitude: customerLongitude ?? this.customerLongitude,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      startLatitude: startLatitude ?? this.startLatitude,
      startLongitude: startLongitude ?? this.startLongitude,
      completeLatitude: completeLatitude ?? this.completeLatitude,
      completeLongitude: completeLongitude ?? this.completeLongitude,
      notes: notes ?? List.from(this.notes),
      evidenceImages: evidenceImages ?? List.from(this.evidenceImages),
      customerConfirmationRemark:
          customerConfirmationRemark ?? this.customerConfirmationRemark,
      isCustomerConfirmed: isCustomerConfirmed ?? this.isCustomerConfirmed,
      syncState: syncState ?? this.syncState,
      lastModified: lastModified ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskNumber': taskNumber,
        'title': title,
        'serviceCategory': serviceCategory,
        'description': description,
        'priority': priority.name,
        'status': status.name,
        'scheduledDateTime': scheduledDateTime.toIso8601String(),
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerAddress': customerAddress,
        'customerLatitude': customerLatitude,
        'customerLongitude': customerLongitude,
        'startedAt': startedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'startLatitude': startLatitude,
        'startLongitude': startLongitude,
        'completeLatitude': completeLatitude,
        'completeLongitude': completeLongitude,
        'notes': notes.map((n) => n.toJson()).toList(),
        'evidenceImages': evidenceImages,
        'customerConfirmationRemark': customerConfirmationRemark,
        'isCustomerConfirmed': isCustomerConfirmed,
        'syncState': syncState.name,
        'lastModified': lastModified.toIso8601String(),
      };

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] is Map
        ? json['customer']
        : (json['customers'] is Map ? json['customers'] : null);

    String customerAddr = json['customerAddress']?.toString() ??
        json['customer_address']?.toString() ??
        (customer != null
            ? "${customer['address'] ?? ''}${customer['city'] != null && customer['city'].toString().isNotEmpty ? ', ${customer['city']}' : ''}"
            : '');

    return TaskItem(
      id: json['id']?.toString() ?? '',
      taskNumber: json['taskNumber']?.toString() ??
          json['task_number']?.toString() ??
          'TSK-${json['id']?.toString().substring(0, json['id']?.toString().length.clamp(0, 4) ?? 0) ?? '001'}',
      title: json['title']?.toString() ?? '',
      serviceCategory: json['serviceCategory']?.toString() ??
          json['service_category']?.toString() ??
          json['category']?.toString() ??
          'General Service',
      description: json['description']?.toString() ?? '',
      priority: TaskPriority.fromString(json['priority']?.toString()),
      status: TaskStatus.fromString(json['status']?.toString()),
      scheduledDateTime: json['scheduledDateTime'] != null
          ? DateTime.tryParse(json['scheduledDateTime'].toString()) ?? DateTime.now()
          : (json['scheduled_at'] != null
              ? DateTime.tryParse(json['scheduled_at'].toString()) ?? DateTime.now()
              : DateTime.now()),
      customerName: json['customerName']?.toString() ??
          json['customer_name']?.toString() ??
          customer?['name']?.toString() ??
          '',
      customerPhone: json['customerPhone']?.toString() ??
          json['customer_phone']?.toString() ??
          customer?['phone']?.toString() ??
          '',
      customerAddress: customerAddr,
      customerLatitude: (json['customerLatitude'] as num?)?.toDouble() ??
          (json['customer_latitude'] as num?)?.toDouble() ??
          (customer?['latitude'] as num?)?.toDouble() ??
          11.0168,
      customerLongitude: (json['customerLongitude'] as num?)?.toDouble() ??
          (json['customer_longitude'] as num?)?.toDouble() ??
          (customer?['longitude'] as num?)?.toDouble() ??
          76.9558,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'].toString())
          : (json['started_at'] != null
              ? DateTime.tryParse(json['started_at'].toString())
              : null),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : (json['completed_at'] != null
              ? DateTime.tryParse(json['completed_at'].toString())
              : null),
      startLatitude: (json['startLatitude'] as num?)?.toDouble() ??
          (json['start_latitude'] as num?)?.toDouble(),
      startLongitude: (json['startLongitude'] as num?)?.toDouble() ??
          (json['start_longitude'] as num?)?.toDouble(),
      completeLatitude: (json['completeLatitude'] as num?)?.toDouble() ??
          (json['completion_latitude'] as num?)?.toDouble() ??
          (json['complete_latitude'] as num?)?.toDouble(),
      completeLongitude: (json['completeLongitude'] as num?)?.toDouble() ??
          (json['completion_longitude'] as num?)?.toDouble() ??
          (json['complete_longitude'] as num?)?.toDouble(),
      notes: (json['notes'] as List<dynamic>?)
              ?.map((e) => TaskNote.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      evidenceImages: (json['evidenceImages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      customerConfirmationRemark: json['customerConfirmationRemark']?.toString() ??
          json['customer_confirmation_note']?.toString() ??
          json['customer_confirmation_remark']?.toString(),
      isCustomerConfirmed: json['isCustomerConfirmed'] == true ||
          json['customer_confirmed'] == true ||
          json['is_customer_confirmed'] == true,
      syncState: SyncState.values.firstWhere(
        (s) => s.name == json['syncState'],
        orElse: () => SyncState.synced,
      ),
      lastModified: json['lastModified'] != null
          ? DateTime.tryParse(json['lastModified'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
