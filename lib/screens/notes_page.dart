import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/folder.dart';
import '../widgets/note_card.dart';
import '../services/folder_service.dart';
import '../services/note_service.dart';
import '../widgets/move_entry_dialog.dart';
import 'note_entry_page.dart';
import 'folders_page.dart';

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

  void _navigateToFolders() async {
    final selectedFolderId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => FoldersPage(
          folderType: FolderType.note,
          title: 'NOTE FOLDERS',
        ),
      ),
    );
    
    if (selectedFolderId != null) {
      _selectFolder(selectedFolderId);
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
            _buildHeader(),
            
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
            _buildSearchBar(),
            
            // Navigation bar
            // _buildNavigationBar(), // REMOVED
          ],
        ),
      ),
    );
  }

  //LOGO AND PAGE NAME
  Widget _buildHeader() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Image.asset('assets/logo/LoginLogo.png',
              height: 52,
              width: 52,
            ),
            const Text(
              'NOTES',
              style: TextStyle(
                color: Color(0xFF9C834F),
                fontSize: 40,
                fontFamily: 'Inria Sans',
                fontWeight: FontWeight.w700,
                letterSpacing: -1.60,
              ),
            ),
            const SizedBox(width: 84),
            IconButton(
              icon: const Icon(
                Icons.folder_outlined,
                color: Color(0xFF9C834F),
                size: 32,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoldersPage(
                      folderType: FolderType.note,
                      title: 'NOTE FOLDERS',
                    ),
                  ),
                );
              },
            ),
          ],
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        width: 249,
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: ShapeDecoration(
          color: const Color(0xFFF5F5DB),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1.5,
              color: Color(0xFF9C834F),
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.search,
              color: Color(0x7F9C834F),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _filterNotes,
                style: const TextStyle(
                  fontFamily: 'Inria Sans',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.24,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Search for Leaves',
                  hintStyle: TextStyle(
                    color: Color(0x7F9C834F),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Inria Sans',
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildNavigationBar() {
  //   return Container(
  //     margin: const EdgeInsets.all(16.0),
  //     height: 60,
  //     decoration: BoxDecoration(
  //       color: const Color(0xFF9C834F),
  //       borderRadius: BorderRadius.circular(30),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //       children: [
  //         IconButton(
  //           icon: Icon(Icons.book, color: Colors.white),
  //           onPressed: () {
  //             Navigator.pushReplacementNamed(context, '/journal');
  //           },
  //         ),
  //         IconButton(
  //           icon: Icon(Icons.description, color: Colors.white),
  //           onPressed: () {
  //             // Already on notes page
  //           },
  //         ),
  //         Container(
  //           width: 50,
  //           height: 50,
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             shape: BoxShape.circle,
  //           ),
  //           child: IconButton(
  //             icon: Icon(
  //               Icons.add,
  //               color: const Color(0xFF9C834F),
  //               size: 30,
  //             ),
  //             onPressed: () {
  //               // Navigate to create note page
  //             },
  //           ),
  //         ),
  //         IconButton(
  //           icon: Icon(Icons.check_box, color: Colors.white),
  //           onPressed: () {
  //             // Navigate to tasks page
  //             Navigator.pushReplacementNamed(context, '/tasks');
  //           },
  //         ),
  //         IconButton(
  //           icon: Icon(Icons.person, color: Colors.white),
  //           onPressed: () {
  //             // Navigate to profile page
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }
//NAVIGATION BAR
  // Widget _buildNavigationBar() { // ENTIRE METHOD REMOVED
  //   return SizedBox(
  //     width: 320,
  //     height: 65,
  //     child: Stack(
  //       children: [
  //         // Background bar with 4 icons
  //         Positioned(
  //           bottom:12.0, // move it up from the screen edge
  //           left: 0,
  //           top: 11,
  //           child: Container(
  //             height: 54,
  //             width: 320,
  //             padding: const EdgeInsets.symmetric(horizontal: 28),
  //             decoration: ShapeDecoration(
  //               color: const Color(0xFF9C834F),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(40),
  //               ),
  //               shadows: const [
  //                 BoxShadow(
  //                   color: Color(0x3F000000),
  //                   blurRadius: 4,
  //                   offset: Offset(0, 4),
  //                   spreadRadius: 0,
  //                 ),
  //               ],
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 IconButton(
  //                   icon: const Icon(Icons.menu_book, color: Color(0xFFF5F5DB), size: 24),
  //                   onPressed: () {
  //                     Navigator.pushReplacementNamed(context, '/journal');
  //                   },
  //                 ),
  //                 IconButton(
  //                   icon: const Icon(Icons.description, color: Color(0xFFF5F5DB), size: 24),
  //                   onPressed: () {
  //                     Navigator.pushReplacementNamed(context, '/notes');
  //                   },
  //                 ),
  //                 const SizedBox(width: 48), // space for center button
  //                 IconButton(
  //                   icon: const Icon(Icons.assignment, color: Color(0xFFF5F5DB), size: 24),
  //                   onPressed: () {
  //                     Navigator.pushReplacementNamed(context, '/tasks');
  //                   },
  //                 ),
  //                 IconButton(
  //                   icon: const Icon(Icons.person_outline, color: Color(0xFFF5F5DB), size: 24),
  //                   onPressed: () {},
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         // Center floating action button
  //         Positioned(
  //           left: 136,
  //           top: 0,
  //           child: Container(
  //             width: 48,
  //             height: 48,
  //             decoration: const ShapeDecoration(
  //               color: Color(0xFFF5F5DB),
  //               shape: OvalBorder(
  //                 side: BorderSide(
  //                   width: 1.5,
  //                   color: Color(0xFF9C834F),
  //                 ),
  //               ),
  //             ),
  //             child: Center(
  //               child: IconButton(
  //                 icon: const Icon(Icons.add, color: Color(0xFF9C834F), size: 24),
  //                 onPressed: () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(builder: (context) => const NoteEntryPage()),
  //                   );
  //                 },
  //               ),
  //             ),
  //           ),
  //         ),
  //         const SizedBox(
  //           height: 10,
  //         )
  //       ],
  //     ),
  //   );
  // }
}