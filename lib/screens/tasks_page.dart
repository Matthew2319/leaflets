import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/leaf_logo.dart';
import '../widgets/task_card.dart';
import 'task_entry_page.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  // This would typically come from a database or state management solution
  List<Task> _tasks = [];
  bool _showTasks = false; // Toggle this for demo purposes

  @override
  void initState() {
    super.initState();
    // Simulate loading tasks
    _loadTasks();
  }

  void _loadTasks() {
    if (_showTasks) {
      final date = DateTime(2023, 11, 14); // November 14, 2023 (Wednesday)
      
      _tasks = [
        Task(
          id: '1',
          title: 'Title',
          date: date,
          subTasks: [
            SubTask(id: '1-1', title: 'Task Page'),
            SubTask(id: '1-2', title: 'Making the Writing Pages'),
            SubTask(id: '1-3', title: '"How do you feel prompt"'),
            SubTask(id: '1-4', title: 'THE BACKEND'),
          ],
        ),
        Task(
          id: '2',
          title: 'Back End',
          date: date,
          subTasks: [
            SubTask(id: '2-1', title: 'Database'),
            SubTask(id: '2-2', title: 'Login & Regis'),
            SubTask(id: '2-3', title: 'Notes Pages'),
          ],
        ),
      ];
    } else {
      _tasks = [];
    }
  }

  // For demo purposes - toggle between empty and filled states
  void _toggleTasks() {
    setState(() {
      _showTasks = !_showTasks;
      _loadTasks();
    });
  }

  void _toggleSubTaskCompletion(String taskId, String subTaskId) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        final subTaskIndex = _tasks[taskIndex].subTasks.indexWhere((subTask) => subTask.id == subTaskId);
        if (subTaskIndex != -1) {
          _tasks[taskIndex].subTasks[subTaskIndex].isCompleted = 
            !_tasks[taskIndex].subTasks[subTaskIndex].isCompleted;
        }
      }
    });
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
            
            // Main content - either empty state or tasks
            Expanded(
              child: _tasks.isEmpty
                  ? _buildEmptyState()
                  : _buildTasksList(),
            ),
            
            // Search bar
            _buildSearchBar(),
            
            // Navigation bar
            _buildNavigationBar(),
          ],
        ),
      ),
    );
  }

  //LOGO AND PAGE NAME
  Widget _buildHeader() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Image.asset('assets/logo/LoginLogo.png',
              height: 52,
              width: 52,
            ),
            Text(
              'TASKS',
              style: TextStyle(
                color: const Color(0xFF9C834F),
                fontSize: 40,
                fontFamily: 'Inria Sans',
                fontWeight: FontWeight.w700,
                letterSpacing: -1.60,
              ),
            ),
            SizedBox(width: 84),
            IconButton(
              icon: Icon(
                Icons.folder_outlined,
                color: const Color(0xFF9C834F),
                size: 32,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/folders');
              },
            ),
          ],
        )
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Journal illustration
          Image.asset(
            'assets/images/TasksIllus.png',
            height: 240,
            // If you don't have the image yet, use a placeholder
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 240,
                width: 240,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF9C834F)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 80,
                        color: const Color(0xFF9C834F),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Journal Illustration",
                        style: TextStyle(
                          color: const Color(0xFF9C834F),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(
            width: 296,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Start your',
                    style: TextStyle(
                      color: const Color(0xFF333333),
                      fontSize: 36,
                      fontFamily: 'Inria Sans',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.44,
                    ),
                  ),
                  TextSpan(
                    text: ' ',
                    style: TextStyle(
                      color: const Color(0xFF333333),
                      fontSize: 36,
                      fontFamily: 'Inria Sans',
                      fontWeight: FontWeight.w400,
                      letterSpacing: -1.44,
                    ),
                  ),
                  TextSpan(
                    text: 'Journey',
                    style: TextStyle(
                      color: const Color(0xFF9C834F),
                      fontSize: 36,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Inria Sans',
                      fontWeight: FontWeight.w400,
                      letterSpacing: -1.44,
                    ),
                  ),
                  TextSpan(
                    text: ' ',
                    style: TextStyle(
                      color: const Color(0xFF333333),
                      fontSize: 36,
                      fontFamily: 'Inria Sans',
                      fontWeight: FontWeight.w400,
                      letterSpacing: -1.44,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 296,
            child: Text(
              'Create your personal task.      Tap the plus button to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF333333),
                fontSize: 16,
                fontFamily: 'Inria Sans',
                fontWeight: FontWeight.w400,
                letterSpacing: -0.64,
              ),
            ),
          ),

          // For demo purposes - button to toggle between states
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _toggleTasks,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF9C834F),
            ),
            child: Text('Toggle Tasks (Demo)'),
          ),
        ],
      ),
    );
  }

  //SEARCH BAR
  Widget _buildTasksList() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.0,
      ),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return TaskCard(
          task: task,
          onToggleSubTask: _toggleSubTaskCompletion,
          onAddSubTask: () {
            // Implement add subtask functionality
          },
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        width: 249,
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: ShapeDecoration(
          color: const Color(0xFFF5F5DB),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1.5,
              color: Color(0xFF9C834F),
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              color: Color(0x7F9C834F),
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                style: TextStyle(
                  fontFamily: 'Inria Sans',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.24,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Search for Leaves',
                  hintStyle: TextStyle(
                    color: Color(0x7F9C834F),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Inria Sans',
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //NAVIGATION BAR
  Widget _buildNavigationBar() {
    return Container(
      width: 320,
      height: 65,
      child: Stack(
        children: [
          // Background bar with 4 icons
          Positioned(
            bottom:12.0, // move it up from the screen edge
            left: 0,
            top: 11,
            child: Container(
              height: 54,
              width: 320,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              decoration: ShapeDecoration(
                color: const Color(0xFF9C834F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                shadows: [
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
                    icon: Icon(Icons.menu_book, color: Color(0xFFF5F5DB), size: 24),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/journal');
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.description, color: Color(0xFFF5F5DB), size: 24),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/notes');
                    },
                  ),
                  SizedBox(width: 48), // space for center button
                  IconButton(
                    icon: Icon(Icons.assignment, color: Color(0xFFF5F5DB), size: 24),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/tasks');
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.person_outline, color: Color(0xFFF5F5DB), size: 24),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          // Center floating action button
          Positioned(
            left: 136,
            top: 0,
            child: Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                color: const Color(0xFFF5F5DB),
                shape: OvalBorder(
                  side: BorderSide(
                    width: 1.5,
                    color: const Color(0xFF9C834F),
                  ),
                ),
              ),
              child: Center(
                child: IconButton(
                  icon: Icon(Icons.add, color: Color(0xFF9C834F), size: 24),
                  onPressed: () {
                    // Navigate to task entry page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TaskEntryPage()),
                    ).then((_) {
                      // Refresh tasks when returning from task entry page
                      _loadTasks();
                    });
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}