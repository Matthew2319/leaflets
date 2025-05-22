class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String folderId;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.folderId,
  });

  // Format the date as DD/MM/YYYY
  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }
}