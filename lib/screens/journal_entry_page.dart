import 'package:flutter/material.dart';
import '../models/mood.dart';
import '../widgets/mood_selection_dialog.dart';

class JournalEntryPage extends StatefulWidget {
  const JournalEntryPage({super.key});

  @override
  State<JournalEntryPage> createState() => _JournalEntryPageState();
}

class _JournalEntryPageState extends State<JournalEntryPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedMood = 'Neutral';
  bool _showMoodDialog = true;

  @override
  void initState() {
    super.initState();
    // Show mood dialog when the page is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showMoodDialog) {
        _showMoodSelectionDialog();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showMoodSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MoodSelectionDialog(
        initialMood: _selectedMood,
        onCancel: () {
          Navigator.pop(context);
          Navigator.pop(context); // Go back to journal list
        },
        onSave: (mood) {
          setState(() {
            _selectedMood = mood;
            _showMoodDialog = false;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DB), // Light cream background
      body: SafeArea(
        child: Column(
          children: [
            // Journal entry content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    TextField(
                      controller: _titleController,
                      style: TextStyle(
                        color: const Color(0xFF9C834F),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'TITLE',
                        hintStyle: TextStyle(
                          color: const Color(0xFF9C834F),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Container(
                      height: 1,
                      color: const Color(0xFF9C834F),
                      margin: const EdgeInsets.only(bottom: 16.0),
                    ),
                    
                    // Content field
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Start Writing...',
                          hintStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFF9C834F).withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: const Color(0xFF9C834F),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  
                  // Date and mood
                  Column(
                    children: [
                      Text(
                        'Mood: $_selectedMood',
                        style: TextStyle(
                          color: const Color(0xFF9C834F),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _getCurrentDate(),
                        style: TextStyle(
                          color: const Color(0xFF9C834F),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  // Done button
                  TextButton(
                    onPressed: () {
                      // Save journal entry and go back
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF9C834F),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline),
                        const SizedBox(width: 4),
                        Text('Done'),
                      ],
                    ),
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