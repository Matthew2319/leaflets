import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(String, String) onToggleSubTask;
  final VoidCallback onAddSubTask;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleSubTask,
    required this.onAddSubTask,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.formattedDate.toLowerCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: const Color(0xFF9C834F),
                  ),
                  onPressed: onAddSubTask,
                ),
              ],
            ),
          ),
          
          // Subtasks
          ...task.subTasks.map((subTask) => _buildSubTaskItem(subTask)),
        ],
      ),
    );
  }

  Widget _buildSubTaskItem(SubTask subTask) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onToggleSubTask(task.id, subTask.id),
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
              child: subTask.isCompleted
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: const Color(0xFF9C834F),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              subTask.title,
              style: TextStyle(
                fontSize: 14,
                decoration: subTask.isCompleted ? TextDecoration.lineThrough : null,
                color: subTask.isCompleted ? Colors.grey : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}