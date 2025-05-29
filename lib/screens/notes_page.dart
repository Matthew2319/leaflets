import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/folder.dart';
import '../widgets/note_card.dart';
import '../services/folder_service.dart';
import '../services/note_service.dart';
import '../widgets/move_entry_dialog.dart';
import 'note_entry_page.dart';
import 'folders_page.dart';
import 'package:leaflets/widgets/custom_search_bar.dart';
import 'package:leaflets/widgets/custom_page_header.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final FolderService _folderService = FolderService();
  final NoteService _noteService = NoteService();
  List<Note> _allNotes = []; // All notes for counting
  List<Note> _notes = []; // Current folder notes
  List<Note> _filteredNotes = []; // Search filtered notes
  List<Folder> _folders = [];
  String? _selectedFolderId;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subscribeFolders();
    _subscribeToAllNotes();
    _subscribeToNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _subscribeFolders() {
    _folderService.getFolders(type: FolderType.note).listen(
      (folders) {
        setState(() {
          _folders = folders;
        });
      },
      onError: (error) {
        print('Error loading folders: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading folders: $error')),
        );
      },
    );
  }

  void _subscribeToAllNotes() {
    _noteService.getNotes().listen(
      (notes) {
        setState(() {
          _allNotes = notes;
        });
      },
      onError: (error) {
        print('Error loading all notes: $error');
      },
    );
  }

  void _subscribeToNotes() {
    _noteService.getNotes(folderId: _selectedFolderId).listen(
      (notes) {
        setState(() {
          _notes = notes;
          _filteredNotes = notes;
          _isLoading = false;
        });
      },
      onError: (error) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notes: $error')),
        );
      },
    );
  }

  void _filterNotes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredNotes = _notes;
      } else {
        _filteredNotes = _notes.where((note) {
          final titleMatch = note.title.toLowerCase().contains(query.toLowerCase());
          final contentMatch = note.content.toLowerCase().contains(query.toLowerCase());
          return titleMatch || contentMatch;
        }).toList();
      }
    });
  }

  void _selectFolder(String? folderId) {
    setState(() {
      _selectedFolderId = folderId;
      _searchController.clear();
    });
    _subscribeToNotes();
  }

  void _handleBookmarkToggle(String noteId, bool newValue) async {
    try {
      await _noteService.toggleBookmark(noteId, newValue);
      // No need to manually update state as the stream will handle it
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating bookmark status: $e')),
        );
      }
    }
  }

  void _handleMoveNote(String noteId, String? currentFolderId) async {
    final newFolderId = await showDialog<String>(
      context: context,
      builder: (context) => MoveEntryDialog(
        currentFolderId: currentFolderId ?? '',
        folderType: FolderType.note,
      ),
    );

    if (newFolderId != null && newFolderId != currentFolderId) {
      try {
        await _noteService.moveNote(noteId, newFolderId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note moved successfully')),
          );
  }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error moving note: $e')),
          );
        }
      }
    }
  }

  void _handleArchiveNote(String noteId, String title) async {
    try {
      await _noteService.archiveNote(noteId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note moved to Recently Deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error moving note to Recently Deleted: $e')),
        );
      }
    }
  }

  void _handleDeleteNote(String noteId, String title) async {
    try {
      await _noteService.deleteNote(noteId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note permanently deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting note: $e')),
        );
      }
    }
  }

  void _navigateToNoteEntry(Note? note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEntryPage(
          noteId: note?.id,
          initialTitle: note?.title,
          initialContent: note?.content,
          initialFolderId: note?.folderId,
          currentFolderId: _selectedFolderId,
        ),
      ),
    );
  }

  int _getEntryCount(String? folderId) {
    if (folderId == null) {
      return _allNotes.where((note) => !note.isArchived).length;
    } else if (folderId == 'bookmarks') {
      return _allNotes.where((note) => note.isBookmark && !note.isArchived).length;
    } else {
      return _allNotes.where((note) => note.folderId == folderId && !note.isArchived).length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3DB85), // Light green background
      body: SafeArea(
        child: Column(
          children: [
            // Header
            CustomPageHeader(
              pageTitle: 'NOTES',
              onFolderIconPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FoldersPage(
                      folderType: FolderType.note,
                      title: 'NOTE FOLDERS',
                    ),
                  ),
                );
              },
            ),
            
            // Folder tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildFolderTabs(),
            ),
            
            const SizedBox(height: 16.0),
            
            // Main content - either empty state or notes
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _notes.isEmpty
                  ? _buildEmptyState()
                  : _buildNotesList(),
            ),
            
            // Search bar
            CustomSearchBar(
              controller: _searchController,
              onChanged: _filterNotes,
              hintText: 'Search for Leaves',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderTabs() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // All folder tab (always first)
          _buildFolderTab(
            name: 'All',
            isSelected: _selectedFolderId == null,
            count: _getEntryCount(null),
            onTap: () => _selectFolder(null),
            isDefaultFolder: true,
          ),

          // Bookmarks folder tab (always second)
          _buildFolderTab(
            name: 'Bookmarks',
            isSelected: _selectedFolderId == 'bookmarks',
            count: _getEntryCount('bookmarks'),
            onTap: () => _selectFolder('bookmarks'),
            isDefaultFolder: true,
          ),

          // User created folders
          ..._folders.map((folder) => _buildFolderTab(
            name: folder.name,
            isSelected: folder.id == _selectedFolderId,
            count: _getEntryCount(folder.id),
            onTap: () => _selectFolder(folder.id),
          )),
        ],
      ),
    );
  }

  Widget _buildFolderTab({
    required String name,
    required bool isSelected,
    required int count,
    required VoidCallback onTap,
    bool isDefaultFolder = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF9C834F)
                : const Color(0xFFF5F5DB),
            borderRadius: BorderRadius.circular(20),
            border: isDefaultFolder
                ? Border.all(
                    color: const Color(0xFF9C834F),
                    width: 1.5,
                  )
                : null,
          ),
          child: Row(
            children: [
              Text(
                name,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF9C834F),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : const Color(0xFF9C834F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF9C834F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //IF EMPTY WILL SHOW THIS
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Notes illustration
          Image.asset(
            'assets/images/NotesIllus.png',
            height: 240,
            // If you don't have the image yet, use a placeholder
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 240,
                width: 240,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF9C834F)),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 80,
                        color: Color(0xFF9C834F),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Notes Illustration",
                        style: TextStyle(
                          color: Color(0xFF9C834F),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(
            width: 296,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Start your',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 36,
                      fontFamily: 'Inria Sans',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.44,
                    ),
                  ),
                  TextSpan(
                    text: ' ',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 36,
                      fontFamily: 'Inria Sans',
                      fontWeight: FontWeight.w400,
                      letterSpacing: -1.44,
                    ),
                  ),
                  TextSpan(
                    text: 'Journey',
                    style: TextStyle(
                      color: Color(0xFF9C834F),
                      fontSize: 36,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Inria Sans',
                      fontWeight: FontWeight.w400,
                      letterSpacing: -1.44,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            width: 296,
            child: Text(
              'Create your personal note.\nTap the plus button to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 16,
                fontFamily: 'Inria Sans',
                fontWeight: FontWeight.w400,
                letterSpacing: -0.64,
              ),
            ),
                  ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    // Filter notes for bookmarks folder
    final displayedNotes = _selectedFolderId == 'bookmarks'
        ? _filteredNotes.where((note) => note.isBookmark).toList()
        : _filteredNotes;

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.0,
      ),
      itemCount: displayedNotes.length,
      itemBuilder: (context, index) {
        final note = displayedNotes[index];
        return NoteCard(
          note: note,
          onTap: () => _navigateToNoteEntry(note),
          onBookmarkToggle: (newValue) => _handleBookmarkToggle(note.id, newValue),
          onMove: () => _handleMoveNote(note.id, note.folderId),
          onArchive: () => _handleArchiveNote(note.id, note.title),
          onDelete: () => _handleDeleteNote(note.id, note.title),
        );
      },
    );
  }
}