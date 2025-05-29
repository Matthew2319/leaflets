import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note.dart';

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collectionName = 'tbl_note_entries';
  
  String _getCheckedCurrentUserId() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in. Cannot perform note operations.');
    }
    return userId;
  }

  // Get notes stream
  Stream<List<Note>> getNotes({String? folderId}) async* {
    final userId = _getCheckedCurrentUserId();

    Query query = _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true);

    if (folderId == 'bookmarks') {
      query = query.where('isBookmark', isEqualTo: true);
    } else if (folderId != null && folderId != 'all') {
      query = query.where('folderId', isEqualTo: folderId);
    }

    yield* query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
    });
  }

  // Create a new note
  Future<void> createNote(
    String title,
    String content, {
    String? folderId,
    bool isBookmark = false,
  }) async {
    final userId = _getCheckedCurrentUserId();

    final note = Note(
      id: '',
      title: title,
      content: content,
      createdAt: DateTime.now(),
      userId: userId,
      folderId: folderId,
      isBookmark: isBookmark,
    );

    await _firestore.collection(_collectionName).add(note.toMap());
  }

  // Update an existing note
  Future<void> updateNote(
    String id,
    String title,
    String content, {
    String? folderId,
    bool? isBookmark,
  }) async {
    final userId = _getCheckedCurrentUserId();

    final data = {
      'title': title,
      'content': content,
      if (folderId != null) 'folderId': folderId,
      if (isBookmark != null) 'isBookmark': isBookmark,
    };

    await _firestore.collection(_collectionName).doc(id).update(data);
  }

  // Toggle bookmark status
  Future<void> toggleBookmark(String id, bool isBookmark) async {
    await _firestore.collection(_collectionName).doc(id).update({
      'isBookmark': isBookmark,
    });
  }

  // Move note to a different folder
  Future<void> moveNote(String id, String? newFolderId) async {
    await _firestore.collection(_collectionName).doc(id).update({
      'folderId': newFolderId,
    });
  }

  // Archive a note (move to Recently Deleted)
  Future<void> archiveNote(String id) async {
    await _firestore.collection(_collectionName).doc(id).update({
      'isArchived': true,
    });
  }

  // Permanently delete a note
  Future<void> deleteNote(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }

  // Get archived notes
  Stream<List<Note>> getArchivedNotes() async* {
    final userId = _getCheckedCurrentUserId();

    yield* _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
        });
  }

  // Restore an archived note
  Future<void> restoreNote(String id) async {
    await _firestore.collection(_collectionName).doc(id).update({
      'isArchived': false,
    });
  }
} 