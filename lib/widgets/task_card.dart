import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final Function(String, bool)? onSubTaskToggle; // Callback for subtask completion
  final VoidCallback? onMove;
  final VoidCallback? onArchive;
  final Function(bool)? onCompletionToggle; // Main task completion

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onSubTaskToggle,
    this.onMove,
    this.onArchive,
    this.onCompletionToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFF5F5DB), // Light cream, similar to other cards
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Date and Options Menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0), // Align with icon button
                    child: Text(
                      task.formattedDate, // Using the getter from Task model
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (onMove != null || onArchive != null)
                    SizedBox(
                      width: 24, // For compact menu icon
                      height: 24,
                      child: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
                        padding: EdgeInsets.zero,
                        onSelected: (value) {
                          if (value == 'move' && onMove != null) {
                            onMove!();
                          } else if (value == 'archive' && onArchive != null) {
                            // Show confirmation dialog for delete
                            showDialog(
                              context: context,
                              builder: (dialogContext) => Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: EdgeInsets.zero,
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 20.0),
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5DB),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Delete Item?',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Delete \"${task.title}\"?\\nItem will be moved to Recently Deleted.',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton.icon(
                                            icon: const Icon(Icons.close, color: Color(0xFF9C834F)),
                                            label: const Text('Cancel', style: TextStyle(color: Color(0xFF9C834F))),
                                            onPressed: () => Navigator.pop(dialogContext),
                                          ),
                                          TextButton.icon(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                                            label: const Text('Delete', style: TextStyle(color: Colors.red)),
                                            onPressed: () {
                                              Navigator.pop(dialogContext);
                                              onArchive!();
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
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          if (onMove != null)
                            const PopupMenuItem<String>(
                              value: 'move',
                              child: Row(children: [Icon(Icons.drive_file_move_outlined, size: 20), SizedBox(width: 8), Text('Move')]),
                            ),
                          if (onArchive != null)
                            const PopupMenuItem<String>(
                              value: 'archive',
                              child: Row(children: [Icon(Icons.delete_outline, size: 20, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))]),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),

              // Title and Description Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (task.description != null && task.description!.isNotEmpty)
                    const SizedBox(width: 8),
                  if (task.description != null && task.description!.isNotEmpty)
                    Expanded(
                      child: Text(
                        task.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                        maxLines: 3, // Allow more lines for description
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left, // Explicitly align left
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Subtasks Checklist
              if (task.subTasks.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: task.subTasks.map((subtask) {
                    return InkWell(
                      onTap: () {
                        if (onSubTaskToggle != null) {
                          onSubTaskToggle!(subtask.id, !subtask.isCompleted);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 3.0),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE9B1).withOpacity(0.7), // Accent yellow with opacity
                          borderRadius: BorderRadius.circular(8),
                           border: Border.all(color: const Color(0xFF9C834F).withOpacity(0.3))
                        ),
                        child: Row(
                          children: [
                            Transform.scale(
                              scale: 0.9,
                              child: Checkbox(
                                value: subtask.isCompleted,
                                onChanged: (bool? newValue) {
                                  if (onSubTaskToggle != null && newValue != null) {
                                    onSubTaskToggle!(subtask.id, newValue);
                                  }
                                },
                                activeColor: const Color(0xFF9C834F),
                                checkColor: Colors.white,
                                side: BorderSide(
                                  color: subtask.isCompleted ? const Color(0xFF9C834F) : Colors.grey,
                                  width: 1.5,
                                ),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            // SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                subtask.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: subtask.isCompleted ? Colors.grey[600] : Colors.black87,
                                  decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                                  decorationColor: subtask.isCompleted ? Colors.grey[600] : null, // Ensure strikethrough color matches text
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}