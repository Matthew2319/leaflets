import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../services/folder_service.dart';
import '../services/journal_service.dart';
import '../models/journal_entry.dart';
import '../widgets/folder_list_item.dart';
import '../widgets/new_folder_dialog.dart';
import '../widgets/edit_folder_dialog.dart';
import '../widgets/delete_confirmation_dialog.dart';
import 'recently_deleted_page.dart';

class FoldersPage extends StatefulWidget {
  final FolderType folderType;
  final String title;

  const FoldersPage({
    super.key,
    required this.folderType,
    required this.title,
  });

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  final FolderService _folderService = FolderService();
  final JournalService _journalService = JournalService();
  List<Folder> _folders = [];
  List<JournalEntry> _journalEntries = [];
  bool _isLoading = true;
  Folder? _selectedFolder;

  @override
  void initState() {
    super.initState();
    _subscribeFolders();
    _subscribeToJournalEntries();
  }

  void _subscribeFolders() {
    _folderService.getFolders(type: widget.folderType).listen(
      (folders) {
        setState(() {
          _folders = folders;
          _isLoading = false;
        });
      },
      onError: (error) {
        print('Error loading folders: $error');
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading folders: $error')),
        );
      },
    );
  }

  void _subscribeToJournalEntries() {
    _journalService.getJournalEntries().listen(
      (entries) {
        setState(() {
          _journalEntries = entries;
        });
      },
      onError: (error) {
        print('Error loading journal entries: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading journal entries: $error')),
        );
      },
    );
  }

  int _getEntryCount(String? folderId) {
    if (folderId == 'all') {
      return _journalEntries.length;
    } else if (folderId == 'bookmarks') {
      return _journalEntries.where((entry) => entry.isBookmark).length;
    } else {
      return _journalEntries.where((entry) => entry.folderId == folderId).length;
    }
  }

  Future<void> _addFolder(String name, FolderType type) async {
    if (name.isNotEmpty) {
      try {
        await _folderService.createFolder(name, type);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Folder "$name" created successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating folder: $e')),
        );
      }
    }
  }

  Future<void> _editFolder(Folder folder) async {
    showDialog(
      context: context,
      builder: (context) => EditFolderDialog(
        currentName: folder.name,
        onSave: (newName) async {
          try {
            await _folderService.updateFolder(folder.id, newName);
            setState(() => _selectedFolder = null);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Folder renamed to "$newName"')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating folder: $e')),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteFolder(Folder folder) async {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        folderName: folder.name,
        onConfirm: () async {
          try {
            await _folderService.deleteFolder(folder.id);
            setState(() => _selectedFolder = null);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Folder "${folder.name}" deleted')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error deleting folder: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showNewFolderDialog() {
    showDialog(
      context: context,
      builder: (context) => NewFolderDialog(
        onSave: _addFolder,
        folderType: widget.folderType,
      ),
    );
  }

  void _handleFolderTap(String folderId) {
    // Pop back to journal page with selected folder
    Navigator.pop(context, folderId);
  }

  Widget _buildActionButton() {
    if (_selectedFolder != null) {
      return Container(
        width: double.infinity,
        height: 52,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5DB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: TextButton.icon(
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF9C834F),
                ),
                label: const Text(
                  'Edit',
                  style: TextStyle(
                    color: Color(0xFF9C834F),
                  ),
                ),
                onPressed: () => _editFolder(_selectedFolder!),
              ),
            ),
            Container(
              width: 1,
              height: 24,
              color: const Color(0xFF9C834F).withOpacity(0.2),
            ),
            Expanded(
              child: TextButton.icon(
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
                onPressed: () => _deleteFolder(_selectedFolder!),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _showNewFolderDialog,
      child: Container(
        width: double.infinity,
        height: 52,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5DB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Color(0xFF9C834F),
            ),
            SizedBox(width: 8),
            Text(
              'New Folder',
              style: TextStyle(
                color: Color(0xFF9C834F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
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
                    // Folder list
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView(
                              children: [
                                // All folder item (always first)
                                FolderListItem(
                                  folder: Folder(
                                    id: 'all',
                                    name: 'All',
                                    noteCount: _getEntryCount('all'),
                                    userId: '',
                                    createdAt: DateTime.now(),
                                    type: widget.folderType,
                                  ),
                                  showEditButton: false,
                                  isDefaultFolder: true,
                                  onTap: () => _handleFolderTap('all'),
                                ),
                                const SizedBox(height: 8),
                                // Bookmarks folder (always second)
                                FolderListItem(
                                  folder: Folder(
                                    id: 'bookmarks',
                                    name: 'Bookmarks',
                                    noteCount: _getEntryCount('bookmarks'),
                                    userId: '',
                                    createdAt: DateTime.now(),
                                    type: widget.folderType,
                                  ),
                                  showEditButton: false,
                                  isDefaultFolder: true,
                                  onTap: () => _handleFolderTap('bookmarks'),
                                ),
                                const SizedBox(height: 8),
                                // User created folders
                                if (_folders.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 24.0),
                                      child: Text(
                                        'No folders yet.\nTap the button below to create one.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFF9C834F),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  ...List.generate(
                                    _folders.length,
                                    (index) {
                                      final folder = _folders[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: FolderListItem(
                                          folder: folder.copyWith(
                                            noteCount: _getEntryCount(folder.id),
                                          ),
                                          showEditButton: false,
                                          onTap: () => _handleFolderTap(folder.id),
                                          onLongPress: () {
                                            setState(() {
                                              _selectedFolder = _selectedFolder?.id == folder.id ? null : folder;
                                            });
                                          },
                                          isSelected: _selectedFolder?.id == folder.id,
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                    ),
                    
                    // Action button (New Folder or Edit/Delete)
                    _buildActionButton(),
                  ],
                ),
              ),
            ),
            
            // Bottom bar (always visible)
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
                    onPressed: () {
                      if (_selectedFolder != null) {
                        setState(() {
                          _selectedFolder = null;
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Color(0xFF9C834F),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFF9C834F),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecentlyDeletedPage(entryType: widget.folderType),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}