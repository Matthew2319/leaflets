import 'package:flutter/material.dart';
import '../services/note_service.dart';

class NoteEntryPage extends StatefulWidget {
  final String? noteId;
  final String? initialTitle;
  final String? initialContent;
  final String? initialFolderId;
  final String? currentFolderId;

  const NoteEntryPage({
    super.key,
    this.noteId,
    this.initialTitle,
    this.initialContent,
    this.initialFolderId,
    this.currentFolderId,
  });

  @override
  State<NoteEntryPage> createState() => _NoteEntryPageState();
}

class _NoteEntryPageState extends State<NoteEntryPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _noteService = NoteService();
  String? _selectedFolderId;
  bool _isSaving = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _selectedFolderId = widget.initialFolderId ?? widget.currentFolderId;
    
    // Initialize controllers with existing data if editing
    if (widget.noteId != null) {
      _isEditing = true;
      _titleController.text = widget.initialTitle ?? '';
      _contentController.text = widget.initialContent ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both title and content')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isEditing && widget.noteId != null) {
        await _noteService.updateNote(
          widget.noteId!,
          _titleController.text,
          _contentController.text,
          folderId: _selectedFolderId,
        );
      } else {
        await _noteService.createNote(
          _titleController.text,
          _contentController.text,
          folderId: _selectedFolderId,
        );
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DB),
      body: SafeArea(
        child: Column(
          children: [
            // Note content
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
                  
                  // Done button
                  TextButton(
                    onPressed: _isSaving ? null : _saveNote,
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