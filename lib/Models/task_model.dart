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
    return TaskItem(
      id: json['id'] ?? '',
      taskNumber: json['taskNumber'] ?? '',
      title: json['title'] ?? '',
      serviceCategory: json['serviceCategory'] ?? 'General Service',
      description: json['description'] ?? '',
      priority: TaskPriority.fromString(json['priority']),
      status: TaskStatus.fromString(json['status']),
      scheduledDateTime: json['scheduledDateTime'] != null
          ? DateTime.tryParse(json['scheduledDateTime']) ?? DateTime.now()
          : DateTime.now(),
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      customerLatitude: (json['customerLatitude'] as num?)?.toDouble() ?? 11.0168,
      customerLongitude: (json['customerLongitude'] as num?)?.toDouble() ?? 76.9558,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null,
      startLatitude: (json['startLatitude'] as num?)?.toDouble(),
      startLongitude: (json['startLongitude'] as num?)?.toDouble(),
      completeLatitude: (json['completeLatitude'] as num?)?.toDouble(),
      completeLongitude: (json['completeLongitude'] as num?)?.toDouble(),
      notes: (json['notes'] as List<dynamic>?)
              ?.map((e) => TaskNote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      evidenceImages: (json['evidenceImages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      customerConfirmationRemark: json['customerConfirmationRemark'],
      isCustomerConfirmed: json['isCustomerConfirmed'] ?? false,
      syncState: SyncState.values.firstWhere(
        (s) => s.name == json['syncState'],
        orElse: () => SyncState.synced,
      ),
      lastModified: json['lastModified'] != null
          ? DateTime.tryParse(json['lastModified']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
