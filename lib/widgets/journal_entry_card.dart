import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import 'package:intl/intl.dart';
import '../controllers/journal_card_controller.dart';

class JournalEntryCard extends StatefulWidget {
  final JournalEntry entry;
  final VoidCallback? onTap;
  final String? folderName;
  final Function(String)? onMove;
  final Function(bool)? onBookmarkToggle;
  final Function(String, String)? onArchive;
  final VoidCallback? onDelete;

  const JournalEntryCard({
    Key? key,
    required this.entry,
    this.onTap,
    this.folderName,
    this.onMove,
    this.onBookmarkToggle,
    this.onArchive,
    this.onDelete,
  }) : super(key: key);

  @override
  State<JournalEntryCard> createState() => _JournalEntryCardState();
}

class _JournalEntryCardState extends State<JournalEntryCard> {
  final double _actionButtonWidth = 60.0;
  final double _slideOffset = -0.45;

  bool get _isActionsVisible => journalCardController.activeCardId == widget.entry.id;

  @override
  void initState() {
    super.initState();
    journalCardController.addListener(_handleControllerUpdate);
  }

  @override
  void dispose() {
    journalCardController.removeListener(_handleControllerUpdate);
    super.dispose();
  }

  void _handleControllerUpdate() {
    setState(() {});
  }

  void _showActions() {
    journalCardController.setActiveCard(widget.entry.id);
  }

  void _hideActions() {
    journalCardController.clearActiveCard();
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }

  void _handleMove() {
    if (widget.onMove != null) {
      _hideActions();
      widget.onMove!(widget.entry.folderId ?? '');
    }
  }

  void _handleDelete() {
    _hideActions();
    if (widget.entry.isArchived) {
      // If already archived, show permanent delete confirmation
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 20.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5DB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Delete Permanently?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to delete "${widget.entry.title}"?\nThis action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF9C834F),
                      ),
                      label: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF9C834F),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton.icon(
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        if (widget.onDelete != null) {
                          widget.onDelete!();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // If not archived, show archive confirmation
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 20.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5DB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Delete Item?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Delete "${widget.entry.title}"?\nItem will be moved to Recently Deleted.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF9C834F),
                      ),
                      label: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF9C834F),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton.icon(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        if (widget.onArchive != null) {
                          widget.onArchive!(widget.entry.id, widget.entry.title);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Main card with action buttons
            Card(
              margin: EdgeInsets.zero,
              elevation: 4,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
      decoration: BoxDecoration(
                  color: const Color(0xFFF5F5DB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Action buttons (positioned to the right)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(
                            icon: widget.entry.isBookmark ? Icons.bookmark : Icons.bookmark_border,
                            backgroundColor: const Color(0xFFFFD700),
                            iconColor: Colors.white,
                            onTap: () {
                              if (widget.onBookmarkToggle != null) {
                                widget.onBookmarkToggle!(!widget.entry.isBookmark);
                                _hideActions();
                              }
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.drive_file_move_outlined,
                            backgroundColor: const Color(0xFF9C834F),
                            iconColor: Colors.white,
                            onTap: _handleMove,
                          ),
                          _buildActionButton(
                            icon: widget.entry.isArchived ? Icons.delete_forever : Icons.delete_outline,
                            backgroundColor: const Color(0xFFFF6B6B),
                            iconColor: Colors.white,
                            onTap: _handleDelete,
          ),
        ],
      ),
                    ),
                    // Content area
                    GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        if (details.delta.dx < 0 && !_isActionsVisible) {
                          _showActions();
                        } else if (details.delta.dx > 0 && _isActionsVisible) {
                          _hideActions();
                        }
                      },
                      onTap: () {
                        if (_isActionsVisible) {
                          _hideActions();
                        } else if (widget.onTap != null) {
                          widget.onTap!();
                        }
                      },
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        offset: Offset(_isActionsVisible ? _slideOffset : 0.0, 0.0),
                        child: Material(
                          color: const Color(0xFFF5F5DB),
                          child: Container(
                            width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                                // Title and mood row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.entry.title,
                                        style: const TextStyle(
                                          color: Color(0xFF9C834F),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF9C834F).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        widget.entry.mood,
                                        style: const TextStyle(
                                          color: Color(0xFF9C834F),
                                          fontSize: 12,
                                        ),
              ),
            ),
                                  ],
                                ),
                                if (widget.folderName != null) ...[
            const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF9C834F).withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.folder_outlined,
                                          size: 14,
                                          color: Color(0xFF9C834F),
                                        ),
                                        const SizedBox(width: 4),
            Text(
                                          widget.folderName!,
                                          style: const TextStyle(
                                            color: Color(0xFF9C834F),
                fontSize: 12,
                                          ),
                                        ),
                                      ],
              ),
            ),
                                ],
            const SizedBox(height: 8),
                                Expanded(
                                  child: Text(
                                    widget.entry.content,
                                    style: const TextStyle(
                                      color: Colors.black87,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
                                  ),
            ),
            const SizedBox(height: 8),
            Text(
                                  _formatDate(widget.entry.createdAt),
                                  style: const TextStyle(
                                    color: Colors.black54,
                fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: _actionButtonWidth,
          height: double.infinity,
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}