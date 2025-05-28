import 'package:flutter/material.dart';
import '../models/folder.dart';

class FolderListItem extends StatelessWidget {
  final Folder folder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showEditButton;
  final bool isSelected;
  final bool isDefaultFolder;

  const FolderListItem({
    super.key,
    required this.folder,
    this.onTap,
    this.onLongPress,
    this.showEditButton = true,
    this.isSelected = false,
    this.isDefaultFolder = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: isDefaultFolder ? null : onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF9C834F).withOpacity(0.1)
              : const Color(0xFFF5F5DB),
          borderRadius: BorderRadius.circular(12),
          border: isDefaultFolder
              ? Border.all(
                  color: const Color(0xFF9C834F),
                  width: 1.5,
                )
              : null,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.folder_outlined,
              color: Color(0xFF9C834F),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                folder.name,
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontSize: 16,
                  fontWeight: isDefaultFolder ? FontWeight.bold : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF9C834F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                folder.noteCount.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9C834F),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}