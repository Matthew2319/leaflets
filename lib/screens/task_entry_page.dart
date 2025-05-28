import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskEntryPage extends StatefulWidget {
  const TaskEntryPage({super.key});

  @override
  State<TaskEntryPage> createState() => _TaskEntryPageState();
}

class _TaskEntryPageState extends State<TaskEntryPage> {
  final _titleController = TextEditingController();
  final List<SubTask> _subTasks = [];
  final _subtaskController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  void _showAddSubtaskDialog() {
    _subtaskController.clear();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5DB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _subtaskController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Tap \"Enter\" to create subtasks",
                  hintStyle: TextStyle(
                    color: Colors.black54,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _addSubtask(value);
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 28,
                    ),
                    onPressed: () {
                      if (_subtaskController.text.isNotEmpty) {
                        _addSubtask(_subtaskController.text);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSubtask(String title) {
    setState(() {
      _subTasks.add(
        SubTask(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          isCompleted: false,
        ),
      );
    });
  }

  void _toggleSubtask(String id) {
    setState(() {
      final index = _subTasks.indexWhere((subtask) => subtask.id == id);
      if (index != -1) {
        _subTasks[index].isCompleted = !_subTasks[index].isCompleted;
      }
    });
  }

  void _removeSubtask(String id) {
    setState(() {
      _subTasks.removeWhere((subtask) => subtask.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DB), // Light cream background
      body: SafeArea(
        child: Column(
          children: [
            // Task entry content
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
                    
                    // Subtasks list
                    Expanded(
                      child: ListView.builder(
                        itemCount: _subTasks.length,
                        itemBuilder: (context, index) {
                          final subtask = _subTasks[index];
                          return _buildSubtaskItem(subtask);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Add task button
            Center(
              child: TextButton.icon(
                onPressed: _showAddSubtaskDialog,
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF9C834F),
                ),
                label: const Text(
                  'Add Task',
                  style: TextStyle(
                    color: Color(0xFF9C834F),
                    fontWeight: FontWeight.bold,
                  ),
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
                      // Save task and go back
                      _saveTask();
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

  Widget _buildSubtaskItem(SubTask subtask) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DB).darker(10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleSubtask(subtask.id),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
              child: subtask.isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Color(0xFF9C834F),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              subtask.title,
              style: TextStyle(
                fontSize: 14,
                decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                color: subtask.isCompleted ? Colors.grey : Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 16,
              color: Colors.grey,
            ),
            onPressed: () => _removeSubtask(subtask.id),
          ),
        ],
      ),
    );
  }

  void _saveTask() {
    // This would typically save the task to a database
    final title = _titleController.text.trim();
    
    if (title.isEmpty && _subTasks.isEmpty) {
      // Don't save empty tasks
      return;
    }
    
    // For now, just print the task details
    print('Saving task:');
    print('Title: ${title.isEmpty ? 'Untitled' : title}');
    print('Subtasks: ${_subTasks.length}');
    for (var subtask in _subTasks) {
      print('- ${subtask.title} (${subtask.isCompleted ? 'Completed' : 'Not completed'})');
    }
    print('Date: ${DateTime.now()}');
    
    // In a real app, you would save this to a database
    // Example with a state management solution:
    // context.read<TasksProvider>().addTask(
    //   title: title.isEmpty ? 'Untitled' : title,
    //   subTasks: _subTasks,
    // );
  }
}

// Extension to darken colors
extension ColorExtension on Color {
  Color darker(int percent) {
    assert(1 <= percent && percent <= 100);
    final value = 1 - percent / 100;
    return Color.fromARGB(
      alpha,
      (red * value).round(),
      (green * value).round(),
      (blue * value).round(),
    );
  }
}