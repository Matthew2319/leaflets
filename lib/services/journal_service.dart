import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_entry.dart';
import 'auth_service.dart';

class JournalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  static const String _collectionName = 'tbl_journal_entries';
  
  // Get current user ID from SharedPreferences
  Future<String?> _getCurrentUserId() async {
    final currentUser = await _authService.getCurrentUser();
    return currentUser?.uid;
  }

  // Get journal entries stream
  Stream<List<JournalEntry>> getJournalEntries({String? folderId}) async* {
    final currentUser = await _authService.getCurrentUser();
    final userId = currentUser?.uid;
    if (userId == null) {
      yield [];
      return;
    }

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
      return snapshot.docs.map((doc) => JournalEntry.fromFirestore(doc)).toList();
    });
  }

  // Create a new journal entry
  Future<void> createJournalEntry(
    String title,
    String content,
    String mood, {
    String? folderId,
    bool isBookmark = false,
  }) async {
    final currentUser = await _authService.getCurrentUser();
    final userId = currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final entry = JournalEntry(
      id: '',
      title: title,
      content: content,
      mood: mood,
      createdAt: DateTime.now(),
      userId: userId,
      folderId: folderId,
      isBookmark: isBookmark,
    );

    await _firestore.collection(_collectionName).add(entry.toMap());
  }

  // Update an existing journal entry
  Future<void> updateJournalEntry(
    String id,
    String title,
    String content,
    String mood, {
    String? folderId,
    bool? isBookmark,
  }) async {
    final currentUser = await _authService.getCurrentUser();
    final userId = currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final data = {
      'title': title,
      'content': content,
      'mood': mood,
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

  // Move entry to a different folder
  Future<void> moveEntry(String id, String? newFolderId) async {
    await _firestore.collection(_collectionName).doc(id).update({
      'folderId': newFolderId,
    });
  }

  // Delete a journal entry
  Future<void> deleteJournalEntry(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }

  // Get archived entries
  Stream<List<JournalEntry>> getArchivedEntries() async* {
    final currentUser = await _authService.getCurrentUser();
    final userId = currentUser?.uid;
    if (userId == null) {
      yield [];
      return;
    }

    yield* _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: true)
        .orderBy('archivedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => JournalEntry.fromFirestore(doc)).toList();
        });
  }

  // Archive an entry instead of deleting
  Future<void> archiveEntry(String id) async {
    await _firestore.collection(_collectionName).doc(id).update({
      'isArchived': true,
      'archivedAt': FieldValue.serverTimestamp(),
    });
  }

  // Restore an archived entry
  Future<void> restoreEntry(String id) async {
    await _firestore.collection(_collectionName).doc(id).update({
      'isArchived': false,
      'archivedAt': null,
    });
  }

  // Permanently delete an entry
  Future<void> permanentlyDeleteEntry(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }

  // Delete entries that have been in archive for more than 30 days
  Future<void> cleanupOldArchivedEntries() async {
    final currentUser = await _authService.getCurrentUser();
    final userId = currentUser?.uid;
    if (userId == null) return;

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: true)
        .where('archivedAt', isLessThan: thirtyDaysAgo)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}