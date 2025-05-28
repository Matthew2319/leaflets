import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/folder.dart';

class FolderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user ID from SharedPreferences
  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // Create a new folder
  Future<Folder> createFolder(String name, FolderType type) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final folder = Folder(
        id: '', // Firestore will generate this
        name: name,
        noteCount: 0,
        userId: userId,
        createdAt: DateTime.now(),
        type: type,
      );

      final docRef = await _firestore
          .collection('tbl_folders')
          .add(folder.toMap());

      return folder.copyWith(id: docRef.id);
    } catch (e) {
      print('Error creating folder: $e');
      throw Exception('Failed to create folder');
    }
  }

  // Get stream of folders for current user and specific type
  Stream<List<Folder>> getFolders({FolderType? type}) async* {
    final userId = await _getCurrentUserId();
    if (userId == null) {
      throw Exception('User not logged in');
    }

    try {
      var query = _firestore
          .collection('tbl_folders')
          .where('userId', isEqualTo: userId);

      if (type != null) {
        query = query.where('type', isEqualTo: type.toString().split('.').last);
      }

      yield* query
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Folder.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      print('Error getting folders: $e');
      yield [];
    }
  }

  // Delete a folder
  Future<void> deleteFolder(String folderId) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final doc = await _firestore
          .collection('tbl_folders')
          .doc(folderId)
          .get();

      if (!doc.exists || doc.data()?['userId'] != userId) {
        throw Exception('Folder not found or unauthorized');
      }

      await _firestore
          .collection('tbl_folders')
          .doc(folderId)
          .delete();
    } catch (e) {
      print('Error deleting folder: $e');
      throw Exception('Failed to delete folder');
    }
  }

  // Update folder name
  Future<void> updateFolder(String folderId, String newName) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final doc = await _firestore
          .collection('tbl_folders')
          .doc(folderId)
          .get();

      if (!doc.exists || doc.data()?['userId'] != userId) {
        throw Exception('Folder not found or unauthorized');
      }

      await _firestore
          .collection('tbl_folders')
          .doc(folderId)
          .update({
            'name': newName,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error updating folder: $e');
      throw Exception('Failed to update folder');
    }
  }

  // Update note count for a folder
  Future<void> updateNoteCount(String folderId, int count) async {
    try {
      await _firestore
          .collection('tbl_folders')
          .doc(folderId)
          .update({
            'noteCount': count,
          });
    } catch (e) {
      print('Error updating note count: $e');
      throw Exception('Failed to update note count');
    }
  }
} 