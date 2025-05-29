import 'package:flutter/material.dart';

class CustomPageHeader extends StatelessWidget {
  final String pageTitle;
  final VoidCallback onFolderIconPressed;

  const CustomPageHeader({
    super.key,
    required this.pageTitle,
    required this.onFolderIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        // mainAxisSize: MainAxisSize.min, // This might not be needed if Row is not constrained by parent in a way that min is better
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Use spaceBetween to push folder icon to the end
        crossAxisAlignment: CrossAxisAlignment.center, // Vertically center items in the row
        children: [
          Row( // Group Logo and Title
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo/LoginLogo.png',
                height: 52,
                width: 52,
              ),
              const SizedBox(width: 8), // Spacing between logo and title
              Text(
                pageTitle.toUpperCase(), // Ensure title is uppercase as in original
                style: const TextStyle(
                  color: Color(0xFF9C834F),
                  fontSize: 40,
                  fontFamily: 'Inria Sans',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.60,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.folder_outlined,
              color: Color(0xFF9C834F),
              size: 32,
            ),
            onPressed: onFolderIconPressed,
          ),
        ],
      ),
    );
  }
} 