import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../models/journal_entry.dart'; // To identify journal entries
import '../models/note.dart'; // To identify notes
import '../models/task.dart'; // Added for Task type

class RecentlyDeletedItemCard extends StatelessWidget {
  final dynamic item; // Can be JournalEntry or Note or Task
  final VoidCallback onRestore;
  final VoidCallback onPermanentlyDelete;

  const RecentlyDeletedItemCard({
    super.key,
    required this.item,
    required this.onRestore,
    required this.onPermanentlyDelete,
  });

  String _getFormattedDate(DateTime date) {
    return DateFormat('MMM d, y ''at'' hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    String title;
    DateTime createdAt;
    IconData iconData;

    if (item is JournalEntry) {
      title = (item as JournalEntry).title;
      createdAt = (item as JournalEntry).createdAt;
      iconData = Icons.menu_book_outlined;
    } else if (item is Note) {
      title = (item as Note).title;
      createdAt = (item as Note).createdAt;
      iconData = Icons.note_outlined;
    } else if (item is Task) {
      title = (item as Task).title;
      createdAt = (item as Task).createdAt;
      iconData = Icons.check_circle_outline;
    } else {
      // Fallback for unknown item types, though this shouldn't happen
      title = 'Unknown Item';
      createdAt = DateTime.now();
      iconData = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      color: const Color(0xFFF5F5DB),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(iconData, color: const Color(0xFF9C834F), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF9C834F),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Archived: ${_getFormattedDate(createdAt)}', // Assuming createdAt is relevant, or use a specific archivedAt if available
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.restore_from_trash, color: Colors.green, size: 20),
                  label: const Text('Restore', style: TextStyle(color: Colors.green)),
                  onPressed: onRestore,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.delete_forever, color: Colors.red, size: 20),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: onPermanentlyDelete,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 