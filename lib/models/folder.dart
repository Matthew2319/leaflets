import 'package:cloud_firestore/cloud_firestore.dart';

enum FolderType {
  journal,
  note,
  task
}

class Folder {
  final String id;
  final String name;
  final int noteCount;
  final String userId;
  final DateTime createdAt;
  final FolderType type;

  Folder({
    required this.id,
    required this.name,
    this.noteCount = 0,
    required this.userId,
    required this.createdAt,
    required this.type,
  });

  // Convert Firestore document to Folder object
  factory Folder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Folder(
      id: doc.id,
      name: data['name'] ?? '',
      noteCount: data['noteCount'] ?? 0,
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      type: FolderType.values.firstWhere(
        (e) => e.toString() == 'FolderType.${data['type'] ?? 'journal'}',
        orElse: () => FolderType.journal,
      ),
    );
  }

  // Convert Folder object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'noteCount': noteCount,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'type': type.toString().split('.').last,
    };
  }

  // Create a copy of the folder with updated fields
  Folder copyWith({
    String? id,
    String? name,
    int? noteCount,
    String? userId,
    DateTime? createdAt,
    FolderType? type,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      noteCount: noteCount ?? this.noteCount,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
    );
  }
}