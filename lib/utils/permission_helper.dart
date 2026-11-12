import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_colors.dart';

/// Helper class to handle runtime permissions gracefully and prevent app crashes.
class PermissionHelper {
  /// Request Camera Permission with user-friendly dialogs if denied.
  static Future<bool> requestCameraPermission(BuildContext context) async {
    // Web handles permissions via browser prompt automatically
    if (kIsWeb) return true;

    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsDialog(
          context,
          title: 'Izin Kamera Diperlukan',
          message:
              'Aplikasi membutuhkan akses kamera untuk mengambil gambar dan memindai barcode. Silakan aktifkan izin di pengaturan perangkat.',
        );
      }
      return false;
    }

    final result = await Permission.camera.request();
    if (result.isGranted) {
      return true;
    } else {
      if (context.mounted) {
        _showPermissionSnackbar(
          context,
          'Akses kamera ditolak. Fitur ini tidak dapat digunakan tanpa izin kamera.',
        );
      }
      return false;
    }
  }

  /// Request Storage / Photos Permission to save images to device gallery.
  static Future<bool> requestStoragePermission(BuildContext context) async {
    // Web handles downloads/storage natively in browser
    if (kIsWeb) return true;

    // For Android 13+ (API 33+), saving to gallery usually works with photos permission
    // or scoped storage. For older Android versions, storage permission is required.
    Permission permissionToRequest = Permission.storage;

    if (Platform.isAndroid) {
      // In modern Android, check if storage or photos applies
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) return true;

      final photosStatus = await Permission.photos.status;
      if (photosStatus.isGranted) return true;

      // Try photos permission first for modern devices, fallback to storage
      if (await Permission.photos.request().isGranted) {
        return true;
      }
      permissionToRequest = Permission.storage;
    } else if (Platform.isIOS) {
      permissionToRequest = Permission.photos;
    }

    final status = await permissionToRequest.status;
    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsDialog(
          context,
          title: 'Izin Galeri / Penyimpanan Diperlukan',
          message:
              'Aplikasi membutuhkan izin penyimpanan untuk menyimpan foto yang diedit ke galeri Anda. Silakan aktifkan izin di pengaturan perangkat.',
        );
      }
      return false;
    }

    final result = await permissionToRequest.request();
    if (result.isGranted) {
      return true;
    } else {
      if (context.mounted) {
        _showPermissionSnackbar(
          context,
          'Akses penyimpanan ditolak. Foto tidak dapat disimpan ke galeri.',
        );
      }
      return false;
    }
  }

  /// Shows an alert dialog asking the user to open system settings.
  static void _showSettingsDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text(
              'Buka Pengaturan',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a clean SnackBar informing about denied permission.
  static void _showPermissionSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
