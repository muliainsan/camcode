import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Barcode icon with framing corner brackets matching Card 2 in `spec/design.jpeg`.
class BarcodeIconWidget extends StatelessWidget {
  final double size;
  final Color color;

  const BarcodeIconWidget({
    super.key,
    this.size = 64,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BarcodeIconPainter(color: color),
      ),
    );
  }
}

class _BarcodeIconPainter extends CustomPainter {
  final Color color;

  _BarcodeIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final bracketPaint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.075
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final barPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final cornerLen = w * 0.28;
    final r = w * 0.08; // Corner radius

    // 1. Draw 4 Corner Brackets
    // Top-Left
    final pathTL = Path()
      ..moveTo(0, cornerLen)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..lineTo(cornerLen, 0);
    canvas.drawPath(pathTL, bracketPaint);

    // Top-Right
    final pathTR = Path()
      ..moveTo(w - cornerLen, 0)
      ..lineTo(w - r, 0)
      ..quadraticBezierTo(w, 0, w, r)
      ..lineTo(w, cornerLen);
    canvas.drawPath(pathTR, bracketPaint);

    // Bottom-Left
    final pathBL = Path()
      ..moveTo(0, h - cornerLen)
      ..lineTo(0, h - r)
      ..quadraticBezierTo(0, h, r, h)
      ..lineTo(cornerLen, h);
    canvas.drawPath(pathBL, bracketPaint);

    // Bottom-Right
    final pathBR = Path()
      ..moveTo(w - cornerLen, h)
      ..lineTo(w - r, h)
      ..quadraticBezierTo(w, h, w, h - r)
      ..lineTo(w, h - cornerLen);
    canvas.drawPath(pathBR, bracketPaint);

    // 2. Draw Barcode Vertical Bars in Center
    final barcodeTop = h * 0.22;
    final barcodeBottom = h * 0.78;
    final barcodeHeight = barcodeBottom - barcodeTop;

    // Relative bar specifications: [widthRatio, gapRatio]
    final bars = [
      0.045, // thin
      0.035, // gap
      0.085, // thick
      0.040, // gap
      0.045, // thin
      0.040, // gap
      0.085, // thick
      0.035, // gap
      0.045, // thin
    ];

    final totalRatio = bars.reduce((a, b) => a + b);
    final totalBarcodeWidth = w * 0.44;
    final scale = totalBarcodeWidth / totalRatio;

    double currentX = (w - totalBarcodeWidth) / 2;
    for (int i = 0; i < bars.length; i++) {
      final width = bars[i] * scale;
      if (i % 2 == 0) {
        // Draw Bar
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(currentX, barcodeTop, width, barcodeHeight),
          Radius.circular(width * 0.2),
        );
        canvas.drawRRect(rect, barPaint);
      }
      currentX += width;
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodeIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
