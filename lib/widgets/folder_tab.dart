import 'package:flutter/material.dart';
import '../models/folder.dart';

class FolderTab extends StatelessWidget {
  final Folder folder;
  final bool isSelected;
  final VoidCallback onTap;

  const FolderTab({
    super.key,
    required this.folder,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9C834F) : const Color(0xFFF5F5DB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Text(
            //   folder.name,
            //   style: TextStyle(
            //     color: isSelected ? Colors.white : Colors.black87,
            //     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            //   ),
            // ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              // child: Text(
              //   folder.noteCount.toString(),
              //   style: TextStyle(
              //     fontSize: 12,
              //     color: isSelected ? Colors.white : Colors.black54,
              //   ),
              // ),
            ),
          ],
        ),
      ),
    );
  }
}