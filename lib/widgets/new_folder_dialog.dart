import 'package:flutter/material.dart';

class NewFolderDialog extends StatefulWidget {
  final Function(String) onSave;

  const NewFolderDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<NewFolderDialog> createState() => _NewFolderDialogState();
}

class _NewFolderDialogState extends State<NewFolderDialog> {
  final TextEditingController _controller = TextEditingController(text: 'Unnamed Folder');

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
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5DB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'New Folder',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                style: TextStyle(
                  fontSize: 16,
                ),
                autofocus: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 28,
                  ),
                  onPressed: () {
                    widget.onSave(_controller.text);
                    Navigator.pop(context);
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