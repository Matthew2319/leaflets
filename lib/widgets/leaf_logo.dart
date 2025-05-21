import 'package:flutter/material.dart';

class LeafLogo extends StatelessWidget {
  final double size;
  final Color color;

  const LeafLogo({
    super.key,
    this.size = 60.0,
    this.color = const Color(0xFF9C834F),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        painter: LeafPainter(color: color),
      ),
    );
  }
}

class LeafPainter extends CustomPainter {
  final Color color;

  LeafPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final Path mainLeaf = Path()
      ..moveTo(size.width * 0.85, size.height * 0.15)
      ..quadraticBezierTo(
        size.width * 0.65, size.height * 0.15,
        size.width * 0.35, size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.35, size.height * 0.65,
        size.width * 0.35, size.height * 0.85,
      )
      ..quadraticBezierTo(
        size.width * 0.55, size.height * 0.85,
        size.width * 0.85, size.height * 0.15,
      );

    final Path stem = Path()
      ..moveTo(size.width * 0.35, size.height * 0.85)
      ..quadraticBezierTo(
        size.width * 0.35, size.height * 0.55,
        size.width * 0.15, size.height * 0.45,
      );

    canvas.drawPath(mainLeaf, paint);
    canvas.drawPath(stem, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}