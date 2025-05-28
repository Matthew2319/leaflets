import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';

class RecentlyDeletedPage extends StatefulWidget {
  const RecentlyDeletedPage({super.key});

  @override
  State<RecentlyDeletedPage> createState() => _RecentlyDeletedPageState();
}

class _RecentlyDeletedPageState extends State<RecentlyDeletedPage> {
  final JournalService _journalService = JournalService();
  List<JournalEntry> _deletedEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeletedEntries();
  }

  void _loadDeletedEntries() {
    _journalService.getArchivedEntries().listen(
      (entries) {
        setState(() {
          _deletedEntries = entries;
          _isLoading = false;
        });
      },
      onError: (error) {
        print('Error loading deleted entries: $error');
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _restoreEntry(String entryId) async {
    try {
      await _journalService.restoreEntry(entryId);
      // Remove the entry from the local list immediately
      setState(() {
        _deletedEntries.removeWhere((entry) => entry.id == entryId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry restored successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error restoring entry: $e')),
      );
    }
  }

  Future<void> _permanentlyDeleteEntry(String entryId, String title) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
        await _journalService.permanentlyDeleteEntry(entryId);
        // Remove the entry from the local list immediately
        setState(() {
          _deletedEntries.removeWhere((entry) => entry.id == entryId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entry permanently deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting entry: $e')),
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
                          : _deletedEntries.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No deleted entries',
                                    style: TextStyle(
                                      color: Color(0xFF9C834F),
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _deletedEntries.length,
                                  itemBuilder: (context, index) {
                                    final entry = _deletedEntries[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Card(
                                        elevation: 4,
                                        shadowColor: Colors.black26,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF5F5DB),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      entry.title,
                                                      style: const TextStyle(
                                                        color: Color(0xFF9C834F),
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.restore,
                                                          color: Color(0xFF9C834F),
                                                        ),
                                                        onPressed: () => _restoreEntry(entry.id),
                                                        tooltip: 'Restore',
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.delete_forever,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed: () => _permanentlyDeleteEntry(
                                                          entry.id,
                                                          entry.title,
                                                        ),
                                                        tooltip: 'Delete Permanently',
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                entry.content,
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
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
                  const Text(
                    'RECENTLY DELETED',
                    style: TextStyle(
                      color: Color(0xFF9C834F),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 48), // For balance
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 