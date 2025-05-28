import 'package:flutter/material.dart';

class NoteEntryPage extends StatefulWidget {
  final String? folderId; // Optional folder ID if creating note in a specific folder

  const NoteEntryPage({
    super.key,
    this.folderId,
  });

  @override
  State<NoteEntryPage> createState() => _NoteEntryPageState();
}

class _NoteEntryPageState extends State<NoteEntryPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
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
            // Note entry content
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  
                  // Date
                  Text(
                    _getCurrentDate(),
                    style: const TextStyle(
                      color: Color(0xFF9C834F),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // Done button
                  TextButton(
                    onPressed: () {
                      // Save note and go back
                      _saveNote();
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF9C834F),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_outline),
                        SizedBox(width: 4),
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

  void _saveNote() {
    // This would typically save the note to a database
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    
    if (title.isEmpty && content.isEmpty) {
      // Don't save empty notes
      return;
    }
    
    // For now, just print the note details
    print('Saving note:');
    print('Title: ${title.isEmpty ? 'Untitled' : title}');
    print('Content: $content');
    print('Folder ID: ${widget.folderId ?? 'None (Root)'}');
    print('Date: ${DateTime.now()}');
    
    // In a real app, you would save this to a database
    // Example with a state management solution:
    // context.read<NotesProvider>().addNote(
    //   title: title.isEmpty ? 'Untitled' : title,
    //   content: content,
    //   folderId: widget.folderId,
    // );
  }
}