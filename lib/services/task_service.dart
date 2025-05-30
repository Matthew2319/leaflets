import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import 'auth_service.dart'; // Assuming you have AuthService for user ID
import 'package:firebase_auth/firebase_auth.dart'; // Added import

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService(FirebaseAuth.instance); // For getting current user
  static const String _collectionName = 'tbl_task_entries'; // Firestore collection name

  // Helper to get current user ID
  Future<String?> _getCurrentUserId() async {
    final currentUser = await _authService.getCurrentUser();
    return currentUser?.uid;
  }

  // Get tasks stream (for a specific folder or all non-archived tasks)
  Stream<List<Task>> getTasks({String? folderId}) {
    return _authService.getCurrentUser().asStream().asyncExpand((currentUser) {
      if (currentUser == null) return Stream.value([]);

      Query query = _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: currentUser.uid)
          .where('isArchived', isEqualTo: false);

      if (folderId != null && folderId != 'all') {
        query = query.where('folderId', isEqualTo: folderId);
      }

      // Add orderBy after all where clauses
      query = query.orderBy('createdAt', descending: true);

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
      });
    });
  }

  // Create a new task
  Future<void> createTask(
    String title, {
    String? description,
    DateTime? dueDate,
    String? folderId,
    List<SubTask> subTasks = const [],
  }) async {
    final userId = await _getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated to create task');

    final timestamp = FieldValue.serverTimestamp(); // Use server timestamp
    final newTask = {
      'title': title,
      'description': description,
      'isCompleted': false,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'createdAt': timestamp,
      'folderId': folderId,
      'userId': userId,
      'isArchived': false,
      'subTasks': subTasks.map((st) => st.toMap()).toList(),
    };

    try {
      await _firestore.collection(_collectionName).add(newTask);
    } catch (e) {
      print('Error creating task: $e');
      throw Exception('Failed to create task: $e');
    }
  }

  // Update an existing task
  Future<void> updateTask(
    String taskId,
    String title, {
    String? description,
    DateTime? dueDate,
    bool? clearDueDate, // To explicitly set dueDate to null
    String? folderId, // Allow moving folder during update
    bool? isCompleted, // Allow updating completion status
    List<SubTask>? subTasks,
  }) async {
    final updateData = <String, dynamic>{
      'title': title,
    };
    if (description != null) updateData['description'] = description;
    if (clearDueDate == true) {
      updateData['dueDate'] = null;
    } else if (dueDate != null) {
      updateData['dueDate'] = Timestamp.fromDate(dueDate);
    }
    if (folderId != null) updateData['folderId'] = folderId;
    if (isCompleted != null) updateData['isCompleted'] = isCompleted;
    if (subTasks != null) updateData['subTasks'] = subTasks.map((st) => st.toMap()).toList();

    await _firestore.collection(_collectionName).doc(taskId).update(updateData);
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    await _firestore.collection(_collectionName).doc(taskId).update({
      'isCompleted': isCompleted,
    });
  }

  // Update subtasks for a specific task
  Future<void> updateSubTasks(String taskId, List<SubTask> subTasks) async {
    final List<Map<String, dynamic>> subTasksMap = subTasks.map((st) => st.toMap()).toList();
    await _firestore.collection(_collectionName).doc(taskId).update({
      'subTasks': subTasksMap,
    });
    // Also check if all subtasks are completed to update the main task's status
    bool allSubTasksCompleted = subTasks.isNotEmpty && subTasks.every((st) => st.isCompleted);
    if (subTasks.isNotEmpty) { // Only update if there are subtasks
         await _firestore.collection(_collectionName).doc(taskId).update({
            'isCompleted': allSubTasksCompleted,
        });
    }
  }

  // Move task to a different folder
  Future<void> moveTask(String taskId, String? newFolderId) async {
    await _firestore.collection(_collectionName).doc(taskId).update({
      'folderId': newFolderId, // newFolderId can be null to move to 'All'/'Uncategorized'
    });
  }

  // Archive a task (soft delete)
  Future<void> archiveTask(String taskId) async {
    await _firestore.collection(_collectionName).doc(taskId).update({
      'isArchived': true,
    });
  }

  // Get archived tasks stream
  Stream<List<Task>> getArchivedTasks() async* {
    final userId = await _getCurrentUserId();
    if (userId == null) {
      yield [];
      return;
    }

    yield* _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    });
  }

  // Restore an archived task
  Future<void> restoreTask(String taskId) async {
    await _firestore.collection(_collectionName).doc(taskId).update({
      'isArchived': false,
    });
  }

  // Permanently delete a task
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection(_collectionName).doc(taskId).delete();
  }
} 