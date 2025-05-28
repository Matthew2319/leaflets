class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String? folderId;
  final bool isBookmark;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.folderId,
    this.isBookmark = false,
  });

  // Format the date as DD/MM/YYYY
  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }
}