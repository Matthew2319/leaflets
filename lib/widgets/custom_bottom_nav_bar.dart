import 'package:flutter/material.dart';
import 'package:leaflets/screens/note_entry_page.dart';
import 'package:leaflets/screens/journal_entry_page.dart';
import 'package:leaflets/screens/task_entry_page.dart';
// import 'package:leaflets/screens/profile_page.dart'; // Placeholder for ProfilePage

// Enum to represent the current page
enum CurrentPage { journal, notes, tasks, profile }

class CustomBottomNavBar extends StatelessWidget {
  final CurrentPage currentPage;
  final ValueChanged<CurrentPage> onPageSelected;

  const CustomBottomNavBar({
    super.key, 
    required this.currentPage,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Helper function to determine icon color based on current page
    Color getIconColor(CurrentPage page) {
      return currentPage == page ? const Color(0xFFD4BF8B) : const Color(0xFFF5F5DB); // Brighter color for active icon
    }

    return SizedBox(
      width: 340,
      height: 80,
      child: Stack(
        children: [
          // Background bar with 4 icons
          Positioned(
            bottom: 16.0, // move it up from the screen edge
            left: 0,
            top: 12,
            child: Container(
              height: 58,
              width: 340,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              decoration: ShapeDecoration(
                color: const Color(0xFF9C834F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.menu_book, color: getIconColor(CurrentPage.journal), size: 24),
                    onPressed: () {
                      onPageSelected(CurrentPage.journal);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.description, color: getIconColor(CurrentPage.notes), size: 24),
                    onPressed: () {
                      onPageSelected(CurrentPage.notes);
                    },
                  ),
                  const SizedBox(width: 48), // space for center button
                  IconButton(
                    icon: Icon(Icons.assignment, color: getIconColor(CurrentPage.tasks), size: 24),
                    onPressed: () {
                      onPageSelected(CurrentPage.tasks);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.person_outline, color: getIconColor(CurrentPage.profile), size: 24),
                    onPressed: () {
                      onPageSelected(CurrentPage.profile);
                    },
                  ),
                ],
              ),
            ),
          ),
          // Center floating action button
          Positioned(
            left: 146,
            top: 0,
            child: FloatingActionButton(
              elevation: 4,
              backgroundColor: const Color(0xFFF5F5DB),
              shape: const CircleBorder(
                side: BorderSide(
                  width: 1.5,
                  color: Color(0xFF9C834F),
                ),
              ),
              child: const Icon(Icons.add, color: Color(0xFF9C834F), size: 24),
              onPressed: () {
                // Determine action based on current page
                if (currentPage == CurrentPage.notes) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NoteEntryPage()),
                  );
                } else if (currentPage == CurrentPage.journal) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const JournalEntryPage()),
                  );
                } else if (currentPage == CurrentPage.tasks) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TaskEntryPage()),
                  );
                }
              },
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
} 