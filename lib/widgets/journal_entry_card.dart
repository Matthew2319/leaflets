import 'package:flutter/material.dart';
import '../models/journal_entry.dart';

class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;

  const JournalEntryCard({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DB), // Light cream color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mood: ${entry.mood}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entry.content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              entry.formattedDate,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}