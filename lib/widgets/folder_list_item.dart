import 'package:flutter/material.dart';
import '../models/folder.dart';

class FolderListItem extends StatelessWidget {
  final Folder folder;

  const FolderListItem({
    super.key,
    required this.folder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description_outlined,
            color: const Color(0xFF9C834F),
          ),
          const SizedBox(width: 12),
          // Text(
          //   // folder.name,
          //   style: TextStyle(
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            // child: Text(
            //   // folder.noteCount.toString(),
            //   style: TextStyle(
            //     fontSize: 12,
            //     color: Colors.black54,
            //   ),
            // ),
          ),
        ],
      ),
    );
  }
}