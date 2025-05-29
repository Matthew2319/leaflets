import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/folder.dart';
import '../services/task_service.dart';
import '../services/folder_service.dart';
import '../widgets/task_card.dart';
import '../widgets/move_entry_dialog.dart'; // Re-use for moving tasks
import 'task_entry_page.dart';
import 'folders_page.dart'; // For managing task folders

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TaskService _taskService = TaskService();
  final FolderService _folderService = FolderService();
  List<Task> _allTasks = []; // All tasks for counting and filtering
  List<Task> _currentFolderTasks = []; // Tasks in the selected folder
  List<Task> _filteredTasks = []; // Search filtered tasks
  List<Folder> _folders = [];
  String? _selectedFolderId; // null for 'All' tasks
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subscribeToFolders();
    _subscribeToAllTasks(); // For counts
    _subscribeToCurrentFolderTasks(); // For display
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _subscribeToFolders() {
    _folderService.getFolders(type: FolderType.task).listen(
      (folders) {
        if (mounted) setState(() => _folders = folders);
      },
      onError: (error) {
        print('Error loading task folders: $error');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading task folders: $error')));
      },
    );
  }

  void _subscribeToAllTasks() {
    _taskService.getTasks().listen( // Gets all non-archived tasks for the user
      (tasks) {
        if (mounted) setState(() => _allTasks = tasks);
      },
      onError: (error) => print('Error loading all tasks for counts: $error'),
    );
  }

  void _subscribeToCurrentFolderTasks() {
    setState(() => _isLoading = true);
    _taskService.getTasks(folderId: _selectedFolderId).listen(
      (tasks) {
        if (mounted) {
          setState(() {
            _currentFolderTasks = tasks;
            _filterTasks(_searchController.text); // Apply current search filter
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        print('Error loading tasks for folder $_selectedFolderId: $error');
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading tasks: $error')));
        }
      },
    );
  }

  void _filterTasks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTasks = _currentFolderTasks;
      } else {
        _filteredTasks = _currentFolderTasks.where((task) {
          final titleMatch = task.title.toLowerCase().contains(query.toLowerCase());
          final descriptionMatch = task.description?.toLowerCase().contains(query.toLowerCase()) ?? false;
          return titleMatch || descriptionMatch;
        }).toList();
      }
    });
  }

  void _selectFolder(String? folderId) {
    setState(() {
      _selectedFolderId = folderId;
      _searchController.clear(); // Clear search on folder change
    });
    _subscribeToCurrentFolderTasks();
  }

  void _navigateToTaskEntry(Task? task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskEntryPage(
          task: task, // Pass task if editing, null if new
          currentFolderId: _selectedFolderId, // Pass current folder for new tasks
        ),
      ),
    );
  }

  void _navigateToFoldersPage() async {
    final newSelectedFolderId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => FoldersPage(
          folderType: FolderType.task,
          title: 'TASK FOLDERS',
        ),
      ),
    );
    if (newSelectedFolderId != null) {
      _selectFolder(newSelectedFolderId);
    }
  }

  void _handleToggleCompletion(String taskId, bool isCompleted) async {
    try {
      await _taskService.toggleTaskCompletion(taskId, isCompleted);
      // Stream will update the UI
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating task: $e')));
    }
  }

  void _handleMoveTask(String taskId, String? currentTaskFolderId) async {
    final newFolderId = await showDialog<String>(
      context: context,
      builder: (context) => MoveEntryDialog(
        currentFolderId: currentTaskFolderId ?? '', // Pass task's current folder
        folderType: FolderType.task, // Specify task type for dialog
      ),
    );

    if (newFolderId != null && newFolderId != currentTaskFolderId) {
      try {
        await _taskService.moveTask(taskId, newFolderId == '' ? null : newFolderId ); // '' from dialog means no folder
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task moved successfully')));
        // Stream will update UI
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error moving task: $e')));
      }
    }
  }

  void _handleArchiveTask(String taskId, String title) async {
    // Optimistically remove from local lists for immediate UI feedback
    final originalFilteredTasks = List<Task>.from(_filteredTasks);
    final originalCurrentFolderTasks = List<Task>.from(_currentFolderTasks);
    final originalAllTasks = List<Task>.from(_allTasks);

    setState(() {
      _filteredTasks.removeWhere((task) => task.id == taskId);
      _currentFolderTasks.removeWhere((task) => task.id == taskId);
      _allTasks.removeWhere((task) => task.id == taskId);
    });

    try {
      await _taskService.archiveTask(taskId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted and moved to Recently Deleted')),
        );
      }
      // Stream will eventually update and confirm the state from Firestore
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting item: $e')),
        );
        // Revert optimistic update if error occurs
        setState(() {
          _filteredTasks = originalFilteredTasks;
          _currentFolderTasks = originalCurrentFolderTasks;
          _allTasks = originalAllTasks;
        });
      }
    }
  }

  int _getTaskCount(String? folderId) {
    if (folderId == null) return _allTasks.length; // _allTasks is already filtered for non-archived
    // Add other specific counts like 'completed' or 'overdue' if needed later
    return _allTasks.where((task) => task.folderId == folderId).length; // Count from _allTasks for a specific folder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3DB85), // Light green background
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Folder Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildFolderTabs(),
            ),
            const SizedBox(height: 16.0),
            // Task List or Empty State
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C834F))))
                  : _filteredTasks.isEmpty
                      ? _buildEmptyState()
                      : _buildTaskList(),
            ),
            // Search Bar
            _buildSearchBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Image.asset('assets/logo/LoginLogo.png', height: 52, width: 52),
          const SizedBox(width: 12),
          const Text(
            'TASKS',
            style: TextStyle(
              color: Color(0xFF9C834F),
              fontSize: 40,
              fontFamily: 'Inria Sans',
              fontWeight: FontWeight.w700,
              letterSpacing: -1.60,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.folder_outlined, color: Color(0xFF9C834F), size: 32),
            onPressed: _navigateToFoldersPage,
          ),
        ],
      ),
    );
  }

  Widget _buildFolderTabs() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFolderTab(null, 'All', _getTaskCount(null)),
          // Add other default tabs like 'Completed' or 'Due Today' if needed
          ..._folders.map((folder) => _buildFolderTab(folder.id, folder.name, _getTaskCount(folder.id))),
        ],
      ),
    );
  }

  Widget _buildFolderTab(String? folderId, String name, int count) {
    final isSelected = _selectedFolderId == folderId;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () => _selectFolder(folderId),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF9C834F) : const Color(0xFFF5F5DB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF9C834F), width: 1.5),
          ),
          child: Row(
            children: [
              Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF9C834F),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : const Color(0xFF9C834F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : const Color(0xFF9C834F)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/TasksIllus.png', // Replace with your tasks illustration
            height: 200,
            errorBuilder: (context, error, stackTrace) => 
              const Icon(Icons.check_circle_outline, size: 100, color: Color(0xFF9C834F)),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Tasks Yet',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add your first task.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), // Space for FAB and Nav bar
      itemCount: _filteredTasks.length,
      itemBuilder: (context, index) {
        final task = _filteredTasks[index];
        return TaskCard(
          key: ValueKey(task.id),
          task: task,
          onTap: () => _navigateToTaskEntry(task),
          onCompletionToggle: (isCompleted) => _handleToggleCompletion(task.id, isCompleted),
          onMove: () => _handleMoveTask(task.id, task.folderId),
          onArchive: () => _handleArchiveTask(task.id, task.title),
          onSubTaskToggle: (subTaskId, isCompleted) async {
            final String currentTaskId = task.id; // task is from the itemBuilder scope

            // --- Immediate local UI update ---
            setState(() {
              final filteredTaskIndex = _filteredTasks.indexWhere((t) => t.id == currentTaskId);
              if (filteredTaskIndex != -1) {
                final taskInFiltered = _filteredTasks[filteredTaskIndex];
                final subTaskIndex = taskInFiltered.subTasks.indexWhere((st) => st.id == subTaskId);
                if (subTaskIndex != -1) {
                  taskInFiltered.subTasks[subTaskIndex].isCompleted = isCompleted;
                }
              }

              final currentTaskIndex = _currentFolderTasks.indexWhere((t) => t.id == currentTaskId);
              if (currentTaskIndex != -1) {
                final taskInCurrent = _currentFolderTasks[currentTaskIndex];
                final subTaskIndex = taskInCurrent.subTasks.indexWhere((st) => st.id == subTaskId);
                if (subTaskIndex != -1) {
                  taskInCurrent.subTasks[subTaskIndex].isCompleted = isCompleted;
                }
              }

              final allTaskIndex = _allTasks.indexWhere((t) => t.id == currentTaskId);
              if (allTaskIndex != -1) {
                final taskInAll = _allTasks[allTaskIndex];
                final subTaskIndex = taskInAll.subTasks.indexWhere((st) => st.id == subTaskId);
                if (subTaskIndex != -1) {
                  taskInAll.subTasks[subTaskIndex].isCompleted = isCompleted;
                }
              }
            });
            // --- End immediate local UI update ---

            try {
              // Fetch the task for backend update. Assumes task exists in at least one of these lists.
              Task taskForBackendUpdate;
              int taskIdx = _currentFolderTasks.indexWhere((t) => t.id == currentTaskId);
              if (taskIdx != -1) {
                taskForBackendUpdate = _currentFolderTasks[taskIdx];
              } else {
                taskIdx = _allTasks.indexWhere((t) => t.id == currentTaskId);
                if (taskIdx != -1) {
                  taskForBackendUpdate = _allTasks[taskIdx];
                } else {
                  // This case should ideally not be reached if currentTaskId is valid and lists are synced.
                  throw Exception('Task not found for backend update');
                }
              }
              await _taskService.updateSubTasks(currentTaskId, taskForBackendUpdate.subTasks);
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating subtask: $e')),
                );
                // Revert local change if backend fails
                setState(() {
                  final filteredTaskIndex = _filteredTasks.indexWhere((t) => t.id == currentTaskId);
                  if (filteredTaskIndex != -1) {
                    final taskInFiltered = _filteredTasks[filteredTaskIndex];
                    final subTaskIndex = taskInFiltered.subTasks.indexWhere((st) => st.id == subTaskId);
                    if (subTaskIndex != -1) {
                      taskInFiltered.subTasks[subTaskIndex].isCompleted = !isCompleted; // Revert
                    }
                  }

                  final currentTaskIndex = _currentFolderTasks.indexWhere((t) => t.id == currentTaskId);
                  if (currentTaskIndex != -1) {
                    final taskInCurrent = _currentFolderTasks[currentTaskIndex];
                    final subTaskIndex = taskInCurrent.subTasks.indexWhere((st) => st.id == subTaskId);
                    if (subTaskIndex != -1) {
                      taskInCurrent.subTasks[subTaskIndex].isCompleted = !isCompleted; // Revert
                    }
                  }

                  final allTaskIndex = _allTasks.indexWhere((t) => t.id == currentTaskId);
                  if (allTaskIndex != -1) {
                    final taskInAll = _allTasks[allTaskIndex];
                    final subTaskIndex = taskInAll.subTasks.indexWhere((st) => st.id == subTaskId);
                    if (subTaskIndex != -1) {
                      taskInAll.subTasks[subTaskIndex].isCompleted = !isCompleted; // Revert
                    }
                  }
                });
              }
            }
          },
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7, // Adjust width as needed
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: ShapeDecoration(
          color: const Color(0xFFF5F5DB),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1.5, color: Color(0xFF9C834F)),
            borderRadius: BorderRadius.circular(18),
          ),
          shadows: const [BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.search, color: Color(0x7F9C834F), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _filterTasks,
                style: const TextStyle(fontSize: 12, color: Colors.black),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Search for Tasks...',
                  hintStyle: TextStyle(color: Color(0x7F9C834F), fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}