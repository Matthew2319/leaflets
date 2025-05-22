import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../widgets/leaf_logo.dart';
import '../widgets/journal_entry_card.dart';

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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          LeafLogo(size: 30, color: const Color(0xFF9C834F)),
          const SizedBox(width: 8),
          Text(
            'JOURNALS',
            style: TextStyle(
              color: const Color(0xFF9C834F),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Journal illustration
          Image.asset(
            'assets/images/journal_illustration.png',
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
          const SizedBox(height: 32),
          // Start your Journey text
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Start your ',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: 'Journey',
                  style: TextStyle(
                    color: const Color(0xFF9C834F),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Create your personal journal.\nTap the plus button to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
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
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF9C834F).withOpacity(0.3)),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search for Leaves',
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF9C834F),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.book, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.description, color: Colors.white),
            onPressed: () {},
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.add,
                color: const Color(0xFF9C834F),
                size: 30,
              ),
              onPressed: () {
                // Navigate to create journal entry page
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.check_box, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}