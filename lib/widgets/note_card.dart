import 'package:flutter/material.dart';
import '../models/note.dart';
import 'package:intl/intl.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final Function(bool)? onBookmarkToggle;
  final VoidCallback? onMove;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onBookmarkToggle,
    this.onMove,
    this.onArchive,
    this.onDelete,
  });

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: 200, // Make dialog smaller
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5DB),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bookmark option
              _buildOptionButton(
                icon: note.isBookmark ? Icons.bookmark : Icons.bookmark_border,
                label: note.isBookmark ? 'Remove Bookmark' : 'Add Bookmark',
                color: const Color(0xFFFFD700),
                onTap: () {
                  Navigator.pop(context);
                  if (onBookmarkToggle != null) {
                    onBookmarkToggle!(!note.isBookmark);
                  }
                },
              ),
              // Move option
              _buildOptionButton(
                icon: Icons.drive_file_move_outlined,
                label: 'Move to Folder',
                color: const Color(0xFF9C834F),
                onTap: () {
                  Navigator.pop(context);
                  if (onMove != null) {
                    onMove!();
                  }
                },
              ),
              // Archive option (only show if not already archived)
              if (!note.isArchived)
                _buildOptionButton(
                  icon: Icons.archive_outlined,
                  label: 'Move to Recently Deleted',
                  color: const Color(0xFFFF6B6B),
                  onTap: () {
                    Navigator.pop(context);
                    if (onArchive != null) {
                      onArchive!();
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5DB),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Note content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    note.title,
                    style: const TextStyle(
                      color: Color(0xFF9C834F),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Content
                  Expanded(
                    child: Text(
                      note.content,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Date and options row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Date
                      Text(
                        _formatDate(note.createdAt),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      // Options menu
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Color(0xFF9C834F),
                            size: 20,
                          ),
                          onPressed: () => _showOptionsDialog(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          alignment: Alignment.centerRight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Bookmark indicator
            if (note.isBookmark)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.bookmark,
                  color: const Color(0xFF9C834F).withOpacity(0.3),
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}