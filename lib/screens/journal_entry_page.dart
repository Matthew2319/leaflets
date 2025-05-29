import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../services/journal_service.dart';
import '../widgets/mood_selection_dialog.dart';
import '../models/mood.dart';

class JournalEntryPage extends StatefulWidget {
  final String? entryId;
  final String? initialTitle;
  final String? initialContent;
  final String? initialMood;
  final String? initialFolderId;
  final String? currentFolderId;

  const JournalEntryPage({
    super.key,
    this.entryId,
    this.initialTitle,
    this.initialContent,
    this.initialMood,
    this.initialFolderId,
    this.currentFolderId,
  });

  @override
  State<JournalEntryPage> createState() => _JournalEntryPageState();
}

class _JournalEntryPageState extends State<JournalEntryPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _journalService = JournalService();
  String? _selectedFolderId;
  String? _selectedMood;
  bool _showMoodDialog = true;
  bool _isSaving = false;
  bool _isNewEntry = true;

  @override
  void initState() {
    super.initState();
    _isNewEntry = widget.entryId == null;
    _titleController.text = widget.initialTitle ?? '';
    _contentController.text = widget.initialContent ?? '';
    _selectedMood = widget.initialMood;
    _selectedFolderId = widget.initialFolderId ?? widget.currentFolderId;
    
    // Initialize controllers with existing data if editing
    if (widget.entryId != null) {
      _showMoodDialog = false;
    } else {
      // Show mood dialog when creating new entry
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_showMoodDialog) {
          _showMoodSelectionDialog();
        }
      });
    }
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
        initialMood: _selectedMood ?? MoodData.moods[3].name,
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

  Future<void> _saveEntry() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both title and content')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Ensure a mood is selected, default to Neutral if not
    final String moodToSave = _selectedMood ?? MoodData.moods[3].name; // Default to Neutral

    try {
      if (_isNewEntry && widget.entryId == null) {
        await _journalService.createJournalEntry(
          _titleController.text,
          _contentController.text,
          moodToSave, // Use non-nullable mood
          folderId: _selectedFolderId,
        );
      } else {
        await _journalService.updateJournalEntry(
          widget.entryId!,
          _titleController.text,
          _contentController.text,
          moodToSave, // Use non-nullable mood
          folderId: _selectedFolderId,
        );
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving journal entry: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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
      backgroundColor: const Color(0xFFF5F5DB),
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
                      style: const TextStyle(
                        color: Color(0xFF9C834F),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'TITLE',
                        hintStyle: TextStyle(
                          color: Color(0xFF9C834F),
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
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
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
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF9C834F),
                    ),
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                  ),
                  
                  // Date and mood
                  Column(
                    children: [
                      // Clickable mood section
                      GestureDetector(
                        onTap: _showMoodSelectionDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9C834F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Mood: ${_selectedMood ?? 'Neutral'}',
                                style: const TextStyle(
                                  color: Color(0xFF9C834F),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.edit,
                                size: 12,
                                color: Color(0xFF9C834F),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        _getCurrentDate(),
                        style: const TextStyle(
                          color: Color(0xFF9C834F),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  // Done button
                  TextButton(
                    onPressed: _isSaving ? null : _saveEntry,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF9C834F),
                    ),
                    child: Row(
                      children: [
                        _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF9C834F),
                                  ),
                                ),
                              )
                            : const Icon(Icons.check_circle_outline),
                        const SizedBox(width: 4),
                        Text(_isSaving ? 'Saving...' : 'Done'),
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