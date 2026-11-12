import 'package:flutter/material.dart';

/// AppColors defines the color palette used throughout SnapScan (Cam & Scan).
/// Based on the visual specifications in `spec/vibe_spec.md` and `spec/design.jpeg`.
class AppColors {
  // Primary brand color: Rich Indigo/Deep Blue
  static const Color primary = Color(0xFF3949AB);
  static const Color primaryDark = Color(0xFF283593);
  static const Color primaryLight = Color(0xFF5C6BC0);

  // Background and surface colors
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Colors.white;
  static const Color darkSurface = Color(0xFF1E1E1E);

  // Success and accent colors
  static const Color successGreen = Color(0xFF00A86B);
  static const Color successGreenDark = Color(0xFF008F5B);

  // Barcode scanner neon cyan glow
  static const Color scannerCyan = Color(0xFF4CE0D2);
  static const Color scannerCyanGlow = Color(0x804CE0D2);

  // Typography / Neutral colors
  static const Color textDark = Color(0xFF1A1F2C);
  static const Color textMuted = Color(0xFF757575);
  static const Color textLight = Colors.white;
  static const Color divider = Color(0xFFE0E0E0);

  // Toast / Dark SnackBar pill
  static const Color toastBackground = Color(0xFF262C36);
}
