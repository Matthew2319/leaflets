import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String? folderId;
  final bool isBookmark;
  final bool isArchived;
  final String userId;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.folderId,
    this.isBookmark = false,
    this.isArchived = false,
    required this.userId,
  });

  // Convert Firestore document to Note object
  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      folderId: data['folderId'],
      isBookmark: data['isBookmark'] ?? false,
      isArchived: data['isArchived'] ?? false,
      userId: data['userId'] ?? '',
    );
  }

  // Convert Note object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'folderId': folderId,
      'isBookmark': isBookmark,
      'isArchived': isArchived,
      'userId': userId,
    };
  }

  // Create a copy of the note with updated fields
  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    String? folderId,
    bool? isBookmark,
    bool? isArchived,
    String? userId,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      folderId: folderId ?? this.folderId,
      isBookmark: isBookmark ?? this.isBookmark,
      isArchived: isArchived ?? this.isArchived,
      userId: userId ?? this.userId,
    );
  }

  // Format the date as DD/MM/YYYY
  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }
}