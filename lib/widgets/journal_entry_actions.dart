import 'package:flutter/material.dart';

class JournalEntryActions extends StatelessWidget {
  final VoidCallback onFavorite;
  final VoidCallback onMove;
  final VoidCallback onDelete;

  const JournalEntryActions({
    super.key,
    required this.onFavorite,
    required this.onMove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionButton(
            icon: Icons.star_outline,
            color: Colors.amber,
            onTap: onFavorite,
          ),
          _ActionButton(
            icon: Icons.drive_file_move_outline,
            color: const Color(0xFF9C834F),
            onTap: onMove,
          ),
          _ActionButton(
            icon: Icons.delete_outline,
            color: Colors.red,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DB),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
} 