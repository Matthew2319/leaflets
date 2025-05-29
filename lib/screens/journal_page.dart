import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/journal_entry.dart';
import '../widgets/journal_entry_card.dart';
import '../services/journal_service.dart';
import '../services/folder_service.dart';
import '../widgets/move_entry_dialog.dart';
import 'journal_entry_page.dart';
import 'folders_page.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final JournalService _journalService = JournalService();
  final FolderService _folderService = FolderService();
  List<JournalEntry> _allEntries = []; // All entries for counting
  List<JournalEntry> _journalEntries = []; // Current folder entries
  List<JournalEntry> _filteredEntries = []; // Search filtered entries
  List<Folder> _folders = [];
  String? _selectedFolderId;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subscribeFolders();
    _subscribeToAllEntries();
    _subscribeToJournalEntries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _subscribeFolders() {
    _folderService.getFolders(type: FolderType.journal).listen(
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

  void _subscribeToAllEntries() {
    _journalService.getJournalEntries().listen(
      (entries) {
        setState(() {
          _allEntries = entries;
        });
      },
      onError: (error) {
        print('Error loading all entries: $error');
      },
    );
  }

  void _subscribeToJournalEntries() {
    _journalService.getJournalEntries(folderId: _selectedFolderId).listen(
      (entries) {
        setState(() {
          _journalEntries = entries;
          _filteredEntries = entries;
          _isLoading = false;
        });
      },
      onError: (error) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading journal entries: $error')),
        );
      },
    );
  }

  void _filterEntries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredEntries = _journalEntries;
      } else {
        _filteredEntries = _journalEntries.where((entry) {
          final titleMatch = entry.title.toLowerCase().contains(query.toLowerCase());
          final contentMatch = entry.content.toLowerCase().contains(query.toLowerCase());
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
    _subscribeToJournalEntries();
  }

  void _navigateToEntry(JournalEntry? entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalEntryPage(
          entryId: entry?.id,
          initialTitle: entry?.title,
          initialContent: entry?.content,
          initialMood: entry?.mood,
          initialFolderId: entry?.folderId ?? _selectedFolderId,
          currentFolderId: _selectedFolderId,
        ),
      ),
    );
  }

  void _navigateToFolders() async {
    final selectedFolderId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => FoldersPage(
          folderType: FolderType.journal,
          title: 'JOURNAL FOLDERS',
        ),
      ),
    );
    
    if (selectedFolderId != null) {
      _selectFolder(selectedFolderId);
    }
  }

  void _handleBookmarkToggle(String entryId, bool newValue) async {
    try {
      await _journalService.toggleBookmark(entryId, newValue);
      // No need to manually update state as the stream will handle it
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating bookmark status: $e')),
        );
      }
    }
  }

  void _handleMoveEntry(String entryId, String? currentFolderId) async {
    final newFolderId = await showDialog<String>(
      context: context,
      builder: (context) => MoveEntryDialog(
        currentFolderId: currentFolderId ?? '',
        folderType: FolderType.journal,
      ),
    );

    if (newFolderId != null && newFolderId != currentFolderId) {
      try {
        await _journalService.moveEntry(entryId, newFolderId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entry moved successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error moving entry: $e')),
          );
        }
      }
    }
  }

  void _handleArchiveEntry(String entryId, String title) async {
    try {
      await _journalService.archiveEntry(entryId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted and moved to Recently Deleted')),
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

  void _handleDeleteEntry(String entryId, String title) async {
    try {
      await _journalService.permanentlyDeleteEntry(entryId);
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

  int _getEntryCount(String? folderId) {
    if (folderId == null) {
      return _allEntries.length;
    } else if (folderId == 'bookmarks') {
      return _allEntries.where((entry) => entry.isBookmark).length;
    } else {
      return _allEntries.where((entry) => entry.folderId == folderId).length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3DB85), // Light green background
      body: SafeArea(
        child: Column(
          children: [
            // Header with folder button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/logo/LoginLogo.png',
                    height: 52,
                    width: 52,
                  ),
                  const Text(
                    'JOURNALS',
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
                    onPressed: _navigateToFolders,
                  ),
                ],
              ),
            ),
            
            // Folder tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildFolderTabs(),
            ),
            
            const SizedBox(height: 16.0), // Add consistent spacing
            
            // Main content - either empty state, loading state, or journal entries
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredEntries.isEmpty
                      ? _buildEmptyState()
                      : _buildJournalEntries(),
            ),
            
            // Search bar
            _buildSearchBar(),
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
            'JOURNALS',
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
              Navigator.pushNamed(context, '/folders');
            },
          ),
        ],
      )
    );
  }


  //IF EMPTY WILL SHOW THIS
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Journal illustration
          Image.asset(
            'assets/images/JournalsIllus.png',
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
                        Icons.book_outlined,
                        size: 80,
                        color: Color(0xFF9C834F),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Journal Illustration",
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
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            width: 296,
            child: Text(
              'Create your personal journal.     Tap the plus button to get started.',
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


//SEARCH BAR
  Widget _buildJournalEntries() {
    // Filter entries for bookmarks folder
    final displayedEntries = _selectedFolderId == 'bookmarks'
        ? _filteredEntries.where((entry) => entry.isBookmark).toList()
        : _filteredEntries;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        final entry = displayedEntries[index];
        return JournalEntryCard(
          entry: entry,
          onTap: () => _navigateToEntry(entry),
          onBookmarkToggle: (newValue) => _handleBookmarkToggle(entry.id, newValue),
          onMove: (_) => _handleMoveEntry(entry.id, entry.folderId),
          onArchive: _handleArchiveEntry,
          onDelete: () => _handleDeleteEntry(entry.id, entry.title),
        );
      },
      itemCount: displayedEntries.length,
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
                onChanged: _filterEntries,
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

  Widget _buildFolderTabs() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // All folder tab (always first)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => _selectFolder(null),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: _selectedFolderId == null
                      ? const Color(0xFF9C834F)
                      : const Color(0xFFF5F5DB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF9C834F),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'All',
                      style: TextStyle(
                        color: _selectedFolderId == null
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
                        color: _selectedFolderId == null
                            ? Colors.white.withOpacity(0.2)
                            : const Color(0xFF9C834F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _getEntryCount(null).toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _selectedFolderId == null
                              ? Colors.white
                              : const Color(0xFF9C834F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bookmarks folder tab (always second)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => _selectFolder('bookmarks'),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: _selectedFolderId == 'bookmarks'
                      ? const Color(0xFF9C834F)
                      : const Color(0xFFF5F5DB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF9C834F),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Bookmarks',
                      style: TextStyle(
                        color: _selectedFolderId == 'bookmarks'
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
                        color: _selectedFolderId == 'bookmarks'
                            ? Colors.white.withOpacity(0.2)
                            : const Color(0xFF9C834F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _getEntryCount('bookmarks').toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _selectedFolderId == 'bookmarks'
                              ? Colors.white
                              : const Color(0xFF9C834F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // User created folders
          ..._folders.map((folder) {
            final isSelected = folder.id == _selectedFolderId;
            final entriesInFolder = _getEntryCount(folder.id);

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () => _selectFolder(folder.id),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF9C834F)
                        : const Color(0xFFF5F5DB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        folder.name,
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
                          entriesInFolder.toString(),
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
          }).toList(),
        ],
      ),
    );
  }
}