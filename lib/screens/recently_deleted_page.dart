import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../models/folder.dart';
import '../widgets/recently_deleted_item_card.dart';
import '../services/task_service.dart';
import '../models/task.dart';

class RecentlyDeletedPage extends StatefulWidget {
  final FolderType entryType;

  const RecentlyDeletedPage({
    super.key,
    required this.entryType,
  });

  @override
  State<RecentlyDeletedPage> createState() => _RecentlyDeletedPageState();
}

class _RecentlyDeletedPageState extends State<RecentlyDeletedPage> {
  final JournalService _journalService = JournalService();
  final NoteService _noteService = NoteService();
  final TaskService _taskService = TaskService();
  List<dynamic> _deletedItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeletedItems();
  }

  void _loadDeletedItems() {
    if (widget.entryType == FolderType.journal) {
      _journalService.getArchivedEntries().listen(
        (entries) {
          setState(() {
            _deletedItems = entries;
            _isLoading = false;
          });
        },
        onError: (error) {
          print('Error loading deleted journal entries: $error');
          setState(() {
            _isLoading = false;
          });
        },
      );
    } else if (widget.entryType == FolderType.note) {
      _noteService.getArchivedNotes().listen(
        (notes) {
          setState(() {
            _deletedItems = notes;
            _isLoading = false;
          });
        },
        onError: (error) {
          print('Error loading deleted notes: $error');
          setState(() {
            _isLoading = false;
          });
        },
      );
    } else if (widget.entryType == FolderType.task) {
      _taskService.getArchivedTasks().listen(
        (tasks) {
          setState(() {
            _deletedItems = tasks;
            _isLoading = false;
          });
        },
        onError: (error) {
          print('Error loading deleted tasks: $error');
          setState(() {
            _isLoading = false;
          });
        },
      );
    }
  }

  Future<void> _restoreItem(String itemId) async {
    try {
      if (widget.entryType == FolderType.journal) {
        await _journalService.restoreEntry(itemId);
      } else if (widget.entryType == FolderType.note) {
        await _noteService.restoreNote(itemId);
      } else if (widget.entryType == FolderType.task) {
        await _taskService.restoreTask(itemId);
      }
      setState(() {
        _deletedItems.removeWhere((item) => item.id == itemId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item restored successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error restoring item: $e')),
      );
    }
  }

  Future<void> _permanentlyDeleteItem(String itemId, String title) async {
    final shouldDelete = await showDialog<bool>(
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
                'Are you sure you want to delete "$title"?\nThis action cannot be undone.',
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
                    onPressed: () => Navigator.pop(context, false),
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
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldDelete == true && mounted) {
      try {
        if (widget.entryType == FolderType.journal) {
          await _journalService.permanentlyDeleteEntry(itemId);
        } else if (widget.entryType == FolderType.note) {
          await _noteService.deleteNote(itemId);
        } else if (widget.entryType == FolderType.task) {
          await _taskService.deleteTask(itemId);
        }
        setState(() {
          _deletedItems.removeWhere((item) => item.id == itemId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item permanently deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting item: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3DB85),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Info text
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Items in Recently Deleted will be permanently deleted after 30 days.',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Entries list
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _deletedItems.isEmpty
                              ? Center(
                                  child: Text(
                                    'No deleted ${widget.entryType == FolderType.journal ? 'entries' : (widget.entryType == FolderType.note ? 'notes' : 'tasks')}',
                                    style: const TextStyle(
                                      color: Color(0xFF9C834F),
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _deletedItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _deletedItems[index];
                                    String title;
                                    if (item is JournalEntry) {
                                      title = item.title;
                                    } else if (item is Note) {
                                      title = item.title;
                                    } else if (item is Task) {
                                      title = item.title;
                                    } else {
                                      title = 'Unknown Item'; // Should not happen
                                    }

                                    return RecentlyDeletedItemCard(
                                      item: item,
                                      onRestore: () => _restoreItem(item.id),
                                      onPermanentlyDelete: () => _permanentlyDeleteItem(item.id, title),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom bar with title and back button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFF9C834F).withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF9C834F),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'RECENTLY DELETED ${widget.entryType == FolderType.journal ? 'ENTRIES' : (widget.entryType == FolderType.note ? 'NOTES' : 'TASKS')}',
                    style: const TextStyle(
                      color: Color(0xFF9C834F),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 