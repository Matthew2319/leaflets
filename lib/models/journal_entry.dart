class JournalEntry {
  final String id;
  final String title;
  final String content;
  final String mood;
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.createdAt,
  });

  // Format the date as DD/MM/YYYY
  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }
}