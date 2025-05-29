import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';
// For FolderType, though not used for selection yet
// import '../services/folder_service.dart'; // For fetching folders if needed later

class TaskEntryPage extends StatefulWidget {
  final Task? task; // If null, creating a new task; otherwise, editing
  final String? currentFolderId; // To assign to new task or pre-select

  const TaskEntryPage({super.key, this.task, this.currentFolderId});

  @override
  State<TaskEntryPage> createState() => _TaskEntryPageState();
}

class _TaskEntryPageState extends State<TaskEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TaskService _taskService = TaskService();
  // final FolderService _folderService = FolderService(); // For folder selection later

  DateTime? _selectedDueDate;
  String? _selectedFolderId;
  bool _isSaving = false;
  bool _isEditing = false;
  List<SubTask> _subTasks = []; // Added for subtasks
  final TextEditingController _subTaskTitleController = TextEditingController(); // For add/edit dialog

  // List<Folder> _folders = []; // For folder selection dropdown later

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _isEditing = true;
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedDueDate = widget.task!.dueDate;
      _selectedFolderId = widget.task!.folderId;
      _subTasks = List<SubTask>.from(widget.task!.subTasks.map((st) => 
        SubTask(id: st.id, title: st.title, isCompleted: st.isCompleted)));
    } else {
      _selectedFolderId = widget.currentFolderId;
      // _loadFolders(); // Load folders for new task if implementing selection
    }
  }

  /* // Example for loading folders if a dropdown is added
  void _loadFolders() async {
    // Assuming FolderService has a getFolders method that takes FolderType
    _folderService.getFolders(type: FolderType.task).listen((folders) {
      setState(() {
        _folders = folders;
        // Optionally, set a default folder if _selectedFolderId is still null
        if (_selectedFolderId == null && folders.isNotEmpty) {
          // _selectedFolderId = folders.first.id;
        }
      });
    });
  }
  */

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subTaskTitleController.dispose();
    super.dispose();
  }

  void _addSubtask(String title) {
    if (title.trim().isEmpty) return;
    final newSubtask = SubTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple unique ID
      title: title.trim(),
      isCompleted: false,
    );
    setState(() {
      _subTasks.add(newSubtask);
    });
  }

  void _toggleSubtaskCompletion(String subTaskId) {
    setState(() {
      final index = _subTasks.indexWhere((st) => st.id == subTaskId);
      if (index != -1) {
        _subTasks[index].isCompleted = !_subTasks[index].isCompleted;
      }
    });
  }

  void _removeSubtask(String subTaskId) {
    setState(() {
      _subTasks.removeWhere((st) => st.id == subTaskId);
    });
  }

  void _updateSubtaskTitle(String subTaskId, String newTitle) {
    if (newTitle.trim().isEmpty) return;
    setState(() {
      final index = _subTasks.indexWhere((st) => st.id == subTaskId);
      if (index != -1) {
        // Create a new SubTask with the updated title and other existing values
        _subTasks[index] = SubTask(
          id: _subTasks[index].id,
          title: newTitle.trim(),
          isCompleted: _subTasks[index].isCompleted,
        );
      }
    });
  }
  
  void _showAddOrEditSubtaskDialog({SubTask? existingSubtask}) {
    _subTaskTitleController.text = existingSubtask?.title ?? '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog( // Changed from AlertDialog
        backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero, // To allow custom margin/padding for content
          alignment: Alignment.bottomCenter, // Prepare for bottom alignment
        child: Container(
          width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 20.0), // Added bottom margin
            padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
              color: const Color(0xFFF5F5DB), // Dialog background
              borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                Text(
                  existingSubtask == null ? 'Add Subtask' : 'Edit Subtask',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333), // Consistent title color
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE9B1), // TextField background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _subTaskTitleController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Subtask title',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.0), // Adjust padding
                    ),
                    style: const TextStyle(color: Color(0xFF333333), fontSize: 16),
                    onSubmitted: (_) => _submitSubtaskDialog(existingSubtask),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spread actions
                  children: <Widget>[
                  IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent, size: 28),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _subTaskTitleController.clear();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green, size: 28),
                      onPressed: () => _submitSubtaskDialog(existingSubtask),
                  ),
                ],
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  void _submitSubtaskDialog(SubTask? existingSubtask) {
    final title = _subTaskTitleController.text;
    if (existingSubtask == null) {
      _addSubtask(title);
    } else {
      _updateSubtaskTitle(existingSubtask.id, title);
    }
    Navigator.of(context).pop();
    _subTaskTitleController.clear();
  }

  Future<void> _pickDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF9C834F),
              onPrimary: Colors.white,
              onSurface: Color(0xFF333333),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF9C834F),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      
      bool allSubtasksCompleted = _subTasks.isNotEmpty && _subTasks.every((st) => st.isCompleted);
      bool finalIsCompleted = _subTasks.isEmpty ? (widget.task?.isCompleted ?? false) : allSubtasksCompleted;

      try {
        if (_isEditing) {
          await _taskService.updateTask(
            widget.task!.id,
            title,
            description: description.isNotEmpty ? description : null,
            dueDate: _selectedDueDate,
            clearDueDate: _selectedDueDate == null && widget.task?.dueDate != null, 
            folderId: _selectedFolderId,
            subTasks: _subTasks, 
            isCompleted: finalIsCompleted, 
          );
        } else {
          await _taskService.createTask(
            title,
            description: description.isNotEmpty ? description : null,
            dueDate: _selectedDueDate,
            folderId: _selectedFolderId,
            subTasks: _subTasks,
          );
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving task: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DB), // Light cream background
      body: SafeArea(
        child: Column( // Main column for page structure
          children: [
            // Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Title
                      TextFormField(
                      controller: _titleController,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)), // Larger title
                        decoration: const InputDecoration(
                          hintText: 'Task Title',
                          hintStyle: TextStyle(color: Color(0xFF9C834F), fontSize: 24, fontWeight: FontWeight.bold),
                          border: InputBorder.none, // No border for title, similar to JournalEntry
                          contentPadding: EdgeInsets.zero,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a task title';
                          }
                          return null;
                        },
                      ),
                      Container( // Divider like in JournalEntry
                        height: 1,
                        color: const Color(0xFF9C834F),
                        margin: const EdgeInsets.symmetric(vertical: 16.0),
                      ),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      decoration: const InputDecoration(
                          hintText: 'Add more details...',
                          border: InputBorder.none, // No border for description
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null, // Allow multiline
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 24),

                      // Due Date Picker
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Due Date:',
                            style: TextStyle(fontSize: 16, color: Color(0xFF9C834F), fontWeight: FontWeight.w500),
                          ),
                          TextButton(
                            onPressed: () => _pickDueDate(context),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color: _selectedDueDate != null ? const Color(0xFF9C834F) : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedDueDate == null
                                      ? 'Not Set'
                                      : DateFormat('EEE, MMM d, yyyy').format(_selectedDueDate!),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedDueDate != null ? const Color(0xFF333333) : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_selectedDueDate != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedDueDate = null;
                              });
                            },
                            child: const Text('Clear Date', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Subtasks list will go here
                        const Text( // Subtasks Header
                          'Checklist / Subtasks:',
                          style: TextStyle(fontSize: 16, color: Color(0xFF9C834F), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        if (_subTasks.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'No subtasks yet. Tap "Add Subtask" below.',
                              style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                            ),
                          )
                        else
                          ListView.builder( // Display subtasks
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(), // Important inside SingleChildScrollView
                        itemCount: _subTasks.length,
                        itemBuilder: (context, index) {
                          final subtask = _subTasks[index];
                              return Material( // Wrap with Material for InkWell ripple
                                color: Colors.transparent,
                                child: InkWell( // Make row tappable to edit (optional)
                                  // onTap: () => _showAddOrEditSubtaskDialog(existingSubtask: subtask),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: subtask.isCompleted,
                                          onChanged: (bool? value) {
                                            if (value != null) {
                                              _toggleSubtaskCompletion(subtask.id);
                                            }
                                          },
                                          activeColor: const Color(0xFF9C834F),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        Expanded(
                                          child: Text(
                                            subtask.title,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: subtask.isCompleted ? Colors.grey : Colors.black87,
                                              decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blueGrey),
                                          onPressed: () => _showAddOrEditSubtaskDialog(existingSubtask: subtask),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, size: 20, color: Colors.redAccent),
                                          onPressed: () => _removeSubtask(subtask.id),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 80), // Space for Add Subtask and Bottom Bar
                    ],
                  ),
                ),
              ),
            ),
            
            // Add Subtask Button Area (Floating style)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0), // Space from bottom bar
              child: Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white), // Icon color white
                  label: const Text('Add Subtask', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), // Text color white
                  onPressed: () => _showAddOrEditSubtaskDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C834F), // Button background brownish-gold
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      // side: BorderSide(color: const Color(0xFF9C834F).withOpacity(0.5)) // Optional: remove side if bg is dark
                    ),
                  ),
                ),
              ),
            ),
            
            // Bottom Action Bar (Back, Title, Save)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.transparent, // Match JournalEntryPage background or page bg
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
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF9C834F)),
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                  ),
                  Text(
                    _isEditing ? 'EDIT TASK' : 'NEW TASK',
                    style: const TextStyle(
                      color: Color(0xFF9C834F),
                      fontSize: 18, // Consistent size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _isSaving ? null : _saveTask,
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF9C834F)),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C834F))),
                          )
                        : const Row( // Changed to Row for Icon + Text
                            children: [
                              Icon(Icons.check_circle_outline, size: 20), // Icon added
                        SizedBox(width: 4),
                              Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

// Extension to darken colors - remove if not used elsewhere
// extension ColorExtension on Color {
//   Color darker(int percent) {
//     assert(1 <= percent && percent <= 100);
//     final value = 1 - percent / 100;
//     return Color.fromARGB(
//       alpha,
//       (red * value).round(),
//       (green * value).round(),
//       (blue * value).round(),
//     );
//   }
// }