import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/folder.dart';
import '../widgets/leaf_logo.dart';
import '../widgets/note_card.dart';
import '../widgets/folder_tab.dart';
import 'note_entry_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  // This would typically come from a database or state management solution
  List<Note> _notes = [];
  List<Folder> _folders = [];
  String _selectedFolderId = 'all';
  bool _showNotes = false; // Toggle this for demo purposes

  @override
  void initState() {
    super.initState();
    // Simulate loading data
    // _loadFolders();
    _loadNotes();
  }

  // void _loadFolders() {
  //   _folders = [
  //     Folder(id: 'all', name: 'All Notes', noteCount: _showNotes ? 7 : 0),
  //     Folder(id: 'home', name: 'Home', noteCount: _showNotes ? 3 : 0),
  //     Folder(id: 'work', name: 'Work', noteCount: _showNotes ? 4 : 0),
  //   ];
  // }

  void _loadNotes() {
    if (_showNotes) {
      _notes = List.generate(
        7,
        (index) => Note(
          id: (index + 1).toString(),
          title: 'Note Title #${index + 1}',
          content: "On Today's thoughts, I had a...",
          createdAt: DateTime.now().subtract(Duration(days: index)),
          folderId: index < 3 ? 'home' : 'work',
        ),
      );
    } else {
      _notes = [];
    }
  }

  // For demo purposes - toggle between empty and filled states
  void _toggleNotes() {
    setState(() {
      _showNotes = !_showNotes;
      // _loadFolders();
      _loadNotes();
    });
  }

  List<Note> get _filteredNotes {
    if (_selectedFolderId == 'all') {
      return _notes;
    } else {
      return _notes.where((note) => note.folderId == _selectedFolderId).toList();
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
            // _buildFolderTabs(),
            
            // Main content - either empty state or notes
            Expanded(
              child: _notes.isEmpty
                  ? _buildEmptyState()
                  : _buildNotesList(),
            ),
            
            // Search bar
            _buildSearchBar(),
            
            // Navigation bar
            _buildNavigationBar(),
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
            Text(
              'NOTES',
              style: TextStyle(
                color: const Color(0xFF9C834F),
                fontSize: 40,
                fontFamily: 'Inria Sans',
                fontWeight: FontWeight.w700,
                letterSpacing: -1.60,
              ),
            ),
            SizedBox(width: 84),
            IconButton(
              icon: Icon(
                Icons.folder_outlined,
                color: const Color(0xFF9C834F),
                size: 32,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/folders');
              },
            ),
          ],
        ),
    );
  }

  // Widget _buildFolderTabs() {
  //   return Container(
  //     height: 40,
  //     margin: const EdgeInsets.symmetric(horizontal: 16.0),
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: _folders.length,
  //       itemBuilder: (context, index) {
  //         final folder = _folders[index];
  //         // final isSelected = folder.id == _selectedFolderId;
  //
  //         return Padding(
  //           padding: const EdgeInsets.only(right: 8.0),
  //           // child: FolderTab(
  //           //   folder: folder,
  //           //   // isSelected: isSelected,
  //           //   onTap: () {
  //           //     setState(() {
  //           //       _selectedFolderId = folder.id;
  //           //     });
  //           //   },
  //           // ),
  //         );
  //       },
  //     ),
  //   );
  // }
  //
  // Widget _buildEmptyState() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 24.0),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         // Notes illustration
  //         Image.asset(
  //           'assets/images/notes_illustration.png',
  //           height: 240,
  //           // If you don't have the image yet, use a placeholder
  //           errorBuilder: (context, error, stackTrace) {
  //             return Container(
  //               height: 240,
  //               width: 240,
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(12),
  //                 border: Border.all(color: const Color(0xFF9C834F)),
  //               ),
  //               child: Center(
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Icon(
  //                       Icons.note_alt_outlined,
  //                       size: 80,
  //                       color: const Color(0xFF9C834F),
  //                     ),
  //                     const SizedBox(height: 16),
  //                     Text(
  //                       "Notes Illustration",
  //                       style: TextStyle(
  //                         color: const Color(0xFF9C834F),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //         const SizedBox(height: 32),
  //         // Start your Journey text
  //         RichText(
  //           textAlign: TextAlign.center,
  //           text: TextSpan(
  //             children: [
  //               TextSpan(
  //                 text: 'Start your ',
  //                 style: TextStyle(
  //                   color: Colors.black87,
  //                   fontSize: 24,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               TextSpan(
  //                 text: 'Journey',
  //                 style: TextStyle(
  //                   color: const Color(0xFF9C834F),
  //                   fontSize: 24,
  //                   fontWeight: FontWeight.bold,
  //                   fontStyle: FontStyle.italic,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         Text(
  //           'Create your personal note.\nTap the plus button to get started.',
  //           textAlign: TextAlign.center,
  //           style: TextStyle(
  //             color: Colors.black87,
  //             fontSize: 16,
  //           ),
  //         ),
  //         // For demo purposes - button to toggle between states
  //         const SizedBox(height: 24),
  //         ElevatedButton(
  //           onPressed: _toggleNotes,
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.white,
  //             foregroundColor: const Color(0xFF9C834F),
  //           ),
  //           child: Text('Toggle Notes (Demo)'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //IF EMPTY WILL SHOW THIS
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Journal illustration
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 80,
                        color: const Color(0xFF9C834F),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Journal Illustration",
                        style: TextStyle(
                          color: const Color(0xFF9C834F),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(
            width: 296,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Start your',
                    style: TextStyle(
                      color: const Color(0xFF333333),
                      fontSize: 36,
                      fontFamily: 'Inria Sans',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.44,
                    ),
                  ),
                  TextSpan(
                    text: ' ',
                    style: TextStyle(
                      color: const Color(0xFF333333),
                      fontSize: 36,
                      fontFamily: 'Inria Sans',
                      fontWeight: FontWeight.w400,
                      letterSpacing: -1.44,
                    ),
                  ),
                  TextSpan(
                    text: 'Journey',
                    style: TextStyle(
                      color: const Color(0xFF9C834F),
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
                      color: const Color(0xFF333333),
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
          SizedBox(
            width: 296,
            child: Text(
              'Create your personal note.      Tap the plus button to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF333333),
                fontSize: 16,
                fontFamily: 'Inria Sans',
                fontWeight: FontWeight.w400,
                letterSpacing: -0.64,
              ),
            ),
          ),


          // For demo purposes - button to toggle between states
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _toggleNotes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF9C834F),
                    ),
                    child: Text('Toggle Notes (Demo)'),
                  ),
        ],
      ),
    );
  }



  Widget _buildNotesList() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.0,
      ),
      itemCount: _filteredNotes.length,
      itemBuilder: (context, index) {
        final note = _filteredNotes[index];
        return NoteCard(note: note);
      },
    );
  }

  // Widget _buildSearchBar() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  //     child: Container(
  //       height: 40,
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(20),
  //         border: Border.all(color: const Color(0xFF9C834F).withOpacity(0.3)),
  //       ),
  //       child: TextField(
  //         decoration: InputDecoration(
  //           hintText: 'Search for Leaves',
  //           hintStyle: TextStyle(
  //             color: Colors.grey,
  //             fontSize: 14,
  //           ),
  //           prefixIcon: Icon(
  //             Icons.search,
  //             color: Colors.grey,
  //             size: 20,
  //           ),
  //           border: InputBorder.none,
  //           contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
  //         ),
  //       ),
  //     ),
  //   );
  // }
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
            side: BorderSide(
              width: 1.5,
              color: Color(0xFF9C834F),
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          shadows: [
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
            Icon(
              Icons.search,
              color: Color(0x7F9C834F),
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                style: TextStyle(
                  fontFamily: 'Inria Sans',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.24,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
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
  Widget _buildNavigationBar() {
    return Container(
      width: 320,
      height: 65,
      child: Stack(
        children: [
          // Background bar with 4 icons
          Positioned(
            bottom:12.0, // move it up from the screen edge
            left: 0,
            top: 11,
            child: Container(
              height: 54,
              width: 320,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              decoration: ShapeDecoration(
                color: const Color(0xFF9C834F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.menu_book, color: Color(0xFFF5F5DB), size: 24),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/journal');
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.description, color: Color(0xFFF5F5DB), size: 24),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/notes');
                    },
                  ),
                  SizedBox(width: 48), // space for center button
                  IconButton(
                    icon: Icon(Icons.assignment, color: Color(0xFFF5F5DB), size: 24),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/tasks');
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.person_outline, color: Color(0xFFF5F5DB), size: 24),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          // Center floating action button
          Positioned(
            left: 136,
            top: 0,
            child: Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                color: const Color(0xFFF5F5DB),
                shape: OvalBorder(
                  side: BorderSide(
                    width: 1.5,
                    color: const Color(0xFF9C834F),
                  ),
                ),
              ),
              child: Center(
                child: IconButton(
                  icon: Icon(Icons.add, color: Color(0xFF9C834F), size: 24),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NoteEntryPage()),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}