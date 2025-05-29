import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../services/folder_service.dart';

class MoveEntryDialog extends StatefulWidget {
  final String currentFolderId;
  final FolderType folderType;

  const MoveEntryDialog({
    super.key,
    required this.currentFolderId,
    required this.folderType,
  });

  @override
  State<MoveEntryDialog> createState() => _MoveEntryDialogState();
}

class _MoveEntryDialogState extends State<MoveEntryDialog> {
  final FolderService _folderService = FolderService();
  List<Folder> _folders = [];
  bool _isLoading = true;
  String? _selectedFolderId;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  void _loadFolders() {
    _folderService.getFolders(type: widget.folderType).listen(
      (folders) {
        setState(() {
          _folders = folders;
          _isLoading = false;
        });
      },
      onError: (error) {
        print('Error loading folders: $error');
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
            const Text(
              'Move to Folder',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C834F),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_folders.isEmpty)
              const Text(
                'No folders available',
                style: TextStyle(
                  color: Colors.black54,
                ),
              )
            else
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _folders.length,
                  itemBuilder: (context, index) {
                    final folder = _folders[index];
                    final isSelected = _selectedFolderId == folder.id;
                    final isCurrentFolder = widget.currentFolderId == folder.id;

                    if (isCurrentFolder) return const SizedBox.shrink();

                    return ListTile(
                      leading: const Icon(
                        Icons.folder_outlined,
                        color: Color(0xFF9C834F),
                      ),
                      title: Text(
                        folder.name,
                        style: TextStyle(
                          color: isCurrentFolder ? Colors.black38 : Colors.black87,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFF9C834F),
                            )
                          : null,
                      onTap: isCurrentFolder
                          ? null
                          : () {
                              setState(() {
                                _selectedFolderId = folder.id;
                              });
                            },
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _selectedFolderId == null
                      ? null
                      : () => Navigator.pop(context, _selectedFolderId),
                  child: const Text(
                    'Move',
                    style: TextStyle(
                      color: Color(0xFF9C834F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 