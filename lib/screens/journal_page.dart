import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../widgets/leaf_logo.dart';
import '../widgets/journal_entry_card.dart';
import 'journal_entry_page.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  // This would typically come from a database or state management solution
  // For now, we'll use a simple list that can be toggled for demonstration
  List<JournalEntry> _journalEntries = [];
  bool _showEntries = false; // Toggle this for demo purposes

  @override
  void initState() {
    super.initState();
    // Simulate loading entries
    _loadJournalEntries();
  }

  void _loadJournalEntries() {
    // This would typically fetch from a database
    if (_showEntries) {
      _journalEntries = [
        JournalEntry(
          id: '1',
          title: 'Log Title #1',
          content: "On Today's thoughts, I had a sandwich today, not only that, I also had some cookies and...",
          mood: 'Neutral',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        JournalEntry(
          id: '2',
          title: 'Log Title #2',
          content: "On Today's thoughts, I had a sandwich today, not only that, I also had some cookies and...",
          mood: 'Neutral',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        JournalEntry(
          id: '3',
          title: 'Log Title #3',
          content: "On Today's thoughts, I had a sandwich today, not only that, I also had some cookies and...",
          mood: 'Neutral',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        JournalEntry(
          id: '4',
          title: 'Log Title #4',
          content: "On Today's thoughts, I had a sandwich today, not only that, I also had some cookies and...",
          mood: 'Neutral',
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
      ];
    } else {
      _journalEntries = [];
    }
  }

  // For demo purposes - toggle between empty and filled states
  void _toggleEntries() {
    setState(() {
      _showEntries = !_showEntries;
      _loadJournalEntries();
    });
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
            
            // Main content - either empty state or journal entries
            Expanded(
              child: _journalEntries.isEmpty
                  ? _buildEmptyState()
                  : _buildJournalEntries(),
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
            'JOURNALS',
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
              'Create your personal journal.      Tap the plus button to get started.',
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
            onPressed: _toggleEntries,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF9C834F),
            ),
            child: Text('Toggle Entries (Demo)'),
          ),
        ],
      ),
    );
  }


//SEARCH BAR
  Widget _buildJournalEntries() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _journalEntries.length,
      itemBuilder: (context, index) {
        final entry = _journalEntries[index];
        return JournalEntryCard(entry: entry);
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
                    // Navigate to journal entry page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const JournalEntryPage()),
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