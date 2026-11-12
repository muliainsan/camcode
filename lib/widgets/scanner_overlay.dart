import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Fullscreen scanner overlay with center cutout, glowing cyan corners,
/// and smooth animated scan laser matching Screen 3 in `spec/design.jpeg`.
class ScannerOverlay extends StatefulWidget {
  final bool isScanning;
  final double scanWindowWidth;
  final double scanWindowHeight;
  final double cornerRadius;
  final double cornerLength;

  const ScannerOverlay({
    super.key,
    this.isScanning = true,
    this.scanWindowWidth = 280,
    this.scanWindowHeight = 160,
    this.cornerRadius = 18,
    this.cornerLength = 40,
  });

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    if (widget.isScanning) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ScannerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !_animationController.isAnimating) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isScanning && _animationController.isAnimating) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Calculate center scan rectangle
        final rectLeft = (screenWidth - widget.scanWindowWidth) / 2;
        final rectTop = (screenHeight - widget.scanWindowHeight) / 2 - 30; // slightly above center
        final scanRect = Rect.fromLTWH(
          rectLeft,
          rectTop,
          widget.scanWindowWidth,
          widget.scanWindowHeight,
        );

        return Stack(
          children: [
            // Dark Mask with Cutout
            CustomPaint(
              size: Size(screenWidth, screenHeight),
              painter: _ScannerMaskPainter(
                scanRect: scanRect,
                cornerRadius: widget.cornerRadius,
              ),
            ),

            // Animated Laser Beam
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(screenWidth, screenHeight),
                  painter: _ScannerLaserPainter(
                    scanRect: scanRect,
                    animationValue: _animationController.value,
                  ),
                );
              },
            ),

            // Glowing Cyan Corner Brackets
            CustomPaint(
              size: Size(screenWidth, screenHeight),
              painter: _ScannerCornersPainter(
                scanRect: scanRect,
                cornerRadius: widget.cornerRadius,
                cornerLength: widget.cornerLength,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Draws the semi-transparent black overlay with a rounded rectangular hole in the center.
class _ScannerMaskPainter extends CustomPainter {
  final Rect scanRect;
  final double cornerRadius;

  _ScannerMaskPainter({
    required this.scanRect,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(scanRect, Radius.circular(cornerRadius)),
      );

    // Subtract the cutout from the full screen background
    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final maskPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    canvas.drawPath(overlayPath, maskPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerMaskPainter oldDelegate) =>
      oldDelegate.scanRect != scanRect || oldDelegate.cornerRadius != cornerRadius;
}

/// Draws the neon cyan glowing rounded corner brackets around the cutout.
class _ScannerCornersPainter extends CustomPainter {
  final Rect scanRect;
  final double cornerRadius;
  final double cornerLength;

  _ScannerCornersPainter({
    required this.scanRect,
    required this.cornerRadius,
    required this.cornerLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final left = scanRect.left;
    final top = scanRect.top;
    final right = scanRect.right;
    final bottom = scanRect.bottom;
    final r = cornerRadius;
    final len = cornerLength;

    // Glowing shadow paint
    final glowPaint = Paint()
      ..color = AppColors.scannerCyanGlow
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Sharp neon cyan foreground paint
    final cornerPaint = Paint()
      ..color = AppColors.scannerCyan
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Build the 4 corner paths
    final cornersPath = Path();

    // Top-Left Corner
    cornersPath.moveTo(left, top + len);
    cornersPath.lineTo(left, top + r);
    cornersPath.quadraticBezierTo(left, top, left + r, top);
    cornersPath.lineTo(left + len, top);

    // Top-Right Corner
    cornersPath.moveTo(right - len, top);
    cornersPath.lineTo(right - r, top);
    cornersPath.quadraticBezierTo(right, top, right, top + r);
    cornersPath.lineTo(right, top + len);

    // Bottom-Left Corner
    cornersPath.moveTo(left, bottom - len);
    cornersPath.lineTo(left, bottom - r);
    cornersPath.quadraticBezierTo(left, bottom, left + r, bottom);
    cornersPath.lineTo(left + len, bottom);

    // Bottom-Right Corner
    cornersPath.moveTo(right - len, bottom);
    cornersPath.lineTo(right - r, bottom);
    cornersPath.quadraticBezierTo(right, bottom, right, bottom - r);
    cornersPath.lineTo(right, bottom - len);

    // Draw glow first, then crisp foreground line
    canvas.drawPath(cornersPath, glowPaint);
    canvas.drawPath(cornersPath, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerCornersPainter oldDelegate) =>
      oldDelegate.scanRect != scanRect;
}

/// Draws an animated glowing cyan scanning line moving up and down within the cutout.
class _ScannerLaserPainter extends CustomPainter {
  final Rect scanRect;
  final double animationValue;

  _ScannerLaserPainter({
    required this.scanRect,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final y = scanRect.top + 8 + ((scanRect.height - 16) * animationValue);
    final left = scanRect.left + 14;
    final right = scanRect.right - 14;

    // Glowing laser beam
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.scannerCyan.withValues(alpha: 0.0),
          AppColors.scannerCyanGlow,
          AppColors.scannerCyanGlow,
          AppColors.scannerCyan.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.25, 0.75, 1.0],
      ).createShader(Rect.fromLTRB(left, y - 3, right, y + 3))
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.scannerCyan.withValues(alpha: 0.0),
          AppColors.scannerCyan,
          AppColors.scannerCyan,
          AppColors.scannerCyan.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.2, 0.8, 1.0],
      ).createShader(Rect.fromLTRB(left, y - 1, right, y + 1))
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(left, y), Offset(right, y), glowPaint);
    canvas.drawLine(Offset(left, y), Offset(right, y), linePaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerLaserPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
