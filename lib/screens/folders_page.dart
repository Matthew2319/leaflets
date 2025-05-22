import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../widgets/folder_list_item.dart';
import '../widgets/new_folder_dialog.dart';

class FoldersPage extends StatefulWidget {
  const FoldersPage({super.key});

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  List<Folder> _folders = [];

  @override
  void initState() {
    super.initState();
    // _loadFolders();
  }

  // void _loadFolders() {
  //   // This would typically fetch from a database
  //   _folders = [
  //     Folder(id: 'all', name: 'All', noteCount: 0),
  //   ];
  // }

  void _addFolder(String name) {
    if (name.isNotEmpty) {
      // setState(() {
      //   _folders.add(
      //     Folder(
      //       id: DateTime.now().millisecondsSinceEpoch.toString(),
      //       name: name,
      //       noteCount: 0,
      //     ),
      //   );
      // });
    }
  }

  void _showNewFolderDialog() {
    showDialog(
      context: context,
      builder: (context) => NewFolderDialog(
        onSave: _addFolder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3DB85), // Light green background
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Folder list
                    Expanded(
                      child: ListView.builder(
                        itemCount: _folders.length,
                        itemBuilder: (context, index) {
                          final folder = _folders[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: FolderListItem(folder: folder),
                          );
                        },
                      ),
                    ),
                    
                    // New Folder button
                    GestureDetector(
                      onTap: _showNewFolderDialog,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5DB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: const Color(0xFF9C834F),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'New Folder',
                              style: TextStyle(
                                color: const Color(0xFF9C834F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: const Color(0xFF9C834F),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    'FOLDERS',
                    style: TextStyle(
                      color: const Color(0xFF9C834F),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: const Color(0xFF9C834F),
                    ),
                    onPressed: () {
                      // Implement delete functionality
                    },
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