import 'package:flutter/material.dart';

class EditFolderDialog extends StatefulWidget {
  final String currentName;
  final Function(String) onSave;

  const EditFolderDialog({
    super.key,
    required this.currentName,
    required this.onSave,
  });

  @override
  State<EditFolderDialog> createState() => _EditFolderDialogState();
}

class _EditFolderDialogState extends State<EditFolderDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              'Edit Folder',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE9B1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
                autofocus: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF9C834F),
                  ),
                  label: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF9C834F),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton.icon(
                  icon: const Icon(
                    Icons.check,
                    color: Color(0xFF9C834F),
                  ),
                  label: const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFF9C834F),
                    ),
                  ),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      widget.onSave(_controller.text);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 