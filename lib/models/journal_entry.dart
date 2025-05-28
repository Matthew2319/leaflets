import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String id;
  final String title;
  final String content;
  final String mood;
  final String userId;
  final String? folderId;
  final bool isBookmark;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? archivedAt;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.userId,
    this.folderId,
    this.isBookmark = false,
    this.isArchived = false,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
  });

  // Format the date as DD/MM/YYYY
  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }

  // Convert Firestore document to JournalEntry object
  factory JournalEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JournalEntry(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      mood: data['mood'] ?? 'Neutral',
      userId: data['userId'] ?? '',
      folderId: data['folderId'],
      isBookmark: data['isBookmark'] ?? false,
      isArchived: data['isArchived'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      archivedAt: data['archivedAt'] != null
          ? (data['archivedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert JournalEntry object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'mood': mood,
      'userId': userId,
      'folderId': folderId,
      'isBookmark': isBookmark,
      'isArchived': isArchived,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'archivedAt': archivedAt != null ? Timestamp.fromDate(archivedAt!) : null,
    };
  }

  // Create a copy of the entry with updated fields
  JournalEntry copyWith({
    String? id,
    String? title,
    String? content,
    String? mood,
    String? userId,
    String? folderId,
    bool? isBookmark,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      userId: userId ?? this.userId,
      folderId: folderId ?? this.folderId,
      isBookmark: isBookmark ?? this.isBookmark,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }
}