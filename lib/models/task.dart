import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime createdAt;
  final String? folderId;
  final String userId;
  final bool isArchived; // For soft delete
  final List<SubTask> subTasks; // Added

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.dueDate,
    required this.createdAt,
    this.folderId,
    required this.userId,
    this.isArchived = false,
    this.subTasks = const [], // Added default value
  });

  // Convert Firestore document to Task object
  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Handle server timestamp
    DateTime createdAt;
    final createdAtData = data['createdAt'];
    if (createdAtData is Timestamp) {
      createdAt = createdAtData.toDate();
    } else {
      createdAt = DateTime.now(); // Fallback if timestamp is not available
    }

    var subTasksFromFirestore = data['subTasks'] as List<dynamic>?;
    List<SubTask> parsedSubTasks = subTasksFromFirestore != null
        ? subTasksFromFirestore.map((subTaskData) => SubTask.fromMap(subTaskData as Map<String, dynamic>)).toList()
        : [];

    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] as String?,
      isCompleted: data['isCompleted'] ?? false,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      createdAt: createdAt,
      folderId: data['folderId'] as String?,
      userId: data['userId'] ?? '',
      isArchived: data['isArchived'] ?? false,
      subTasks: parsedSubTasks,
    );
  }

  // Convert Task object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'folderId': folderId,
      'userId': userId,
      'isArchived': isArchived,
      'subTasks': subTasks.map((st) => st.toMap()).toList(), // Added
    };
  }

  // Create a copy of the task with updated fields
  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    bool? clearDueDate, // Special flag to nullify dueDate
    DateTime? createdAt,
    String? folderId,
    String? userId,
    bool? isArchived,
    List<SubTask>? subTasks, // Added
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: clearDueDate == true ? null : (dueDate ?? this.dueDate),
      createdAt: createdAt ?? this.createdAt,
      folderId: folderId ?? this.folderId,
      userId: userId ?? this.userId,
      isArchived: isArchived ?? this.isArchived,
      subTasks: subTasks ?? this.subTasks, // Added
    );
  }

  // Format the date as "14 NOV WEDNESDAY"
  String get formattedDate {
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
    
    return '${createdAt.day} ${months[createdAt.month - 1]} ${days[createdAt.weekday - 1]}';
  }
}

class SubTask {
  final String id;
  final String title;
  bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  // Added fromMap and toMap for SubTask
  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}