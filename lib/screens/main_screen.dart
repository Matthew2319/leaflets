import 'package:flutter/material.dart';
import 'package:leaflets/screens/journal_page.dart';
import 'package:leaflets/screens/notes_page.dart';
import 'package:leaflets/screens/tasks_page.dart';
import 'package:leaflets/widgets/custom_bottom_nav_bar.dart';

// Placeholder for the profile page
class ProfilePlaceholderPage extends StatelessWidget {
  const ProfilePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profile Page',
        style: TextStyle(fontSize: 24, color: Color(0xFF9C834F)),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Default to Journals page initially

  final List<Widget> _pages = [
    const JournalPage(),
    const NotesPage(),
    const TasksPage(),
    const ProfilePlaceholderPage(),
  ];

  // Map CurrentPage enum to index
  int _pageEnumToIndex(CurrentPage page) {
    switch (page) {
      case CurrentPage.journal:
        return 0;
      case CurrentPage.notes:
        return 1;
      case CurrentPage.tasks:
        return 2;
      case CurrentPage.profile:
        return 3;
    }
  }

  CurrentPage _indexToPageEnum(int index) {
    switch (index) {
      case 0:
        return CurrentPage.journal;
      case 1:
        return CurrentPage.notes;
      case 2:
        return CurrentPage.tasks;
      case 3:
        return CurrentPage.profile;
      default:
        throw ArgumentError('Invalid index: $index');
    }
  }

  void _onPageSelected(CurrentPage page) {
    setState(() {
      _currentIndex = _pageEnumToIndex(page);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3DB85), // Keep background color
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Row( // Use Row for centering
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomBottomNavBar(
            currentPage: _indexToPageEnum(_currentIndex),
            onPageSelected: _onPageSelected,
          ),
        ],
      ),
    );
  }
} 