import 'package:flutter/material.dart';

/// Camera viewfinder / crop framing overlay with corner brackets and rule-of-thirds grid.
/// Exactly matching Screen 2 in `spec/design.jpeg`.
class CropGridOverlay extends StatelessWidget {
  const CropGridOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _CropGridPainter(),
        ),
      ),
    );
  }
}

class _CropGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Rule-of-thirds grid lines (subtle translucent white)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Two vertical lines
    canvas.drawLine(Offset(w / 3, 0), Offset(w / 3, h), gridPaint);
    canvas.drawLine(Offset(2 * w / 3, 0), Offset(2 * w / 3, h), gridPaint);

    // Two horizontal lines
    canvas.drawLine(Offset(0, h / 3), Offset(w, h / 3), gridPaint);
    canvas.drawLine(Offset(0, 2 * h / 3), Offset(w, 2 * h / 3), gridPaint);

    // 2. Corner brackets (solid white, bold)
    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const cornerLength = 22.0;

    // Top-Left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), cornerPaint);

    // Top-Right
    canvas.drawLine(Offset(w, 0), Offset(w - cornerLength, 0), cornerPaint);
    canvas.drawLine(Offset(w, 0), Offset(w, cornerLength), cornerPaint);

    // Bottom-Left
    canvas.drawLine(Offset(0, h), Offset(cornerLength, h), cornerPaint);
    canvas.drawLine(Offset(0, h), Offset(0, h - cornerLength), cornerPaint);

    // Bottom-Right
    canvas.drawLine(Offset(w, h), Offset(w - cornerLength, h), cornerPaint);
    canvas.drawLine(Offset(w, h), Offset(w, h - cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
