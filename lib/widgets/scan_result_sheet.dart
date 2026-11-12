import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// Modal bottom sheet displaying scan results, matching Screen 3 in `spec/design.jpeg`.
class ScanResultSheet extends StatelessWidget {
  final String scannedData;
  final String? barcodeFormat;
  final VoidCallback onScanAgain;

  const ScanResultSheet({
    super.key,
    required this.scannedData,
    this.barcodeFormat,
    required this.onScanAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle pill
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),

          // Title: "Hasil Scan"
          const Text(
            'Hasil Scan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),

          // Barcode Graphic & Code Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Stylized Barcode Graphic
                const _BarcodeLinesVisualizer(),
                const SizedBox(height: 10),

                // Scanned Value Text
                SelectableText(
                  scannedData,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    letterSpacing: 1.1,
                  ),
                ),

                // Format Chip / Label (if available)
                if (barcodeFormat != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      barcodeFormat!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons: "Salin Data" and "Scan Lagi"
          Row(
            children: [
              // 1. "Salin Data" Button (Filled Indigo Pill)
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 18, color: Colors.white),
                  label: const Text(
                    'Salin Data',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    // Copy to clipboard with haptic feedback
                    Clipboard.setData(ClipboardData(text: scannedData));
                    HapticFeedback.lightImpact();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Data berhasil disalin ke clipboard!'),
                          ],
                        ),
                        backgroundColor: AppColors.toastBackground,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),

              // 2. "Scan Lagi" Button (Outlined Indigo Pill)
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                    onScanAgain();
                  },
                  child: const Text(
                    'Scan Lagi',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Draws an aesthetic barcode illustration above the scanned digits.
class _BarcodeLinesVisualizer extends StatelessWidget {
  const _BarcodeLinesVisualizer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      width: 190,
      child: CustomPaint(
        painter: _BarcodeLinesPainter(),
      ),
    );
  }
}

class _BarcodeLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textDark
      ..style = PaintingStyle.fill;

    // Pattern of varying line widths and gaps for realistic barcode look
    final pattern = [
      2.0, 2.0, 4.0, 3.0, 1.5, 2.5, 3.5, 1.5, 2.0, 4.0, 
      1.5, 2.0, 3.0, 2.0, 1.5, 4.0, 2.0, 1.5, 3.5, 2.5, 
      2.0, 1.5, 4.0, 2.0, 1.5, 3.0, 2.0, 4.0, 1.5, 2.0
    ];

    double currentX = 0;
    for (int i = 0; i < pattern.length; i++) {
      if (i % 2 == 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(currentX, 0, pattern[i], size.height),
            const Radius.circular(0.5),
          ),
          paint,
        );
      }
      currentX += pattern[i] + 3.0;
      if (currentX > size.width) break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
