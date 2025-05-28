class Task {
  final String id;
  final String title;
  final DateTime date;
  final List<SubTask> subTasks;
  final String? folderId;
  final bool isBookmark;

  Task({
    required this.id,
    required this.title,
    required this.date,
    required this.subTasks,
    this.folderId,
    this.isBookmark = false,
  });

  // Format the date as "14 NOV WEDNESDAY"
  String get formattedDate {
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
    
    return '${date.day} ${months[date.month - 1]} ${days[date.weekday - 1]}';
  }
}

class SubTask {
  final String id;
  final String title;
  bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}