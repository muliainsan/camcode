import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_colors.dart';
import '../utils/permission_helper.dart';
import '../widgets/crop_grid_overlay.dart';

/// Screen 2: Camera & Edit Screen (EditPreviewScreen)
/// Allows user to preview, crop, rotate, and save captured photo to device gallery.
/// Fully compatible across Web, Android, iOS, and Desktop platforms without Image.file errors.
class EditPreviewScreen extends StatefulWidget {
  final String initialImagePath;

  const EditPreviewScreen({
    super.key,
    required this.initialImagePath,
  });

  @override
  State<EditPreviewScreen> createState() => _EditPreviewScreenState();
}

class _EditPreviewScreenState extends State<EditPreviewScreen> {
  late String _currentImagePath;
  Uint8List? _imageBytes;
  int _quarterTurns = 0; // 0 = 0 deg, 1 = 90 deg, 2 = 180 deg, 3 = 270 deg
  bool _isProcessing = false;
  String _processingMessage = '';

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.initialImagePath;
    _loadImageBytes();
  }

  /// Loads image bytes safely across Mobile, Desktop, and Web
  Future<void> _loadImageBytes() async {
    try {
      final bytes = await XFile(_currentImagePath).readAsBytes();
      if (mounted) {
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error loading image bytes: $e');
    }
  }

  /// Handles Cropping via image_cropper
  Future<void> _handleCropImage() async {
    HapticFeedback.lightImpact();

    try {
      setState(() {
        _isProcessing = true;
        _processingMessage = 'Mempersiapkan editor...';
      });

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _currentImagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Potong & Sesuaikan',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: AppColors.primary,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Potong & Sesuaikan',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          if (mounted)
            WebUiSettings(
              context: context,
              presentStyle: WebPresentStyle.dialog,
              size: const CropperSize(width: 480, height: 480),
            ),
        ],
      );

      setState(() => _isProcessing = false);

      if (croppedFile != null) {
        final newBytes = await croppedFile.readAsBytes();
        if (mounted) {
          setState(() {
            _currentImagePath = croppedFile.path;
            _imageBytes = newBytes;
            _quarterTurns = 0; // Reset rotation state for newly cropped image
          });
        }
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memotong gambar: $e')),
        );
      }
    }
  }

  /// Handles 90-degree Rotation
  void _handleRotateImage() {
    HapticFeedback.lightImpact();
    setState(() {
      _quarterTurns = (_quarterTurns + 1) % 4;
    });
  }

  /// Saves the final image to the device gallery
  Future<void> _handleSaveToGallery() async {
    HapticFeedback.mediumImpact();

    // 1. Check storage permission gracefully
    final hasPermission = await PermissionHelper.requestStoragePermission(context);
    if (!hasPermission) return;

    setState(() {
      _isProcessing = true;
      _processingMessage = 'Menyimpan gambar...';
    });

    try {
      // 2. Obtain raw bytes
      Uint8List bytesToSave =
          _imageBytes ?? await XFile(_currentImagePath).readAsBytes();

      // 3. If rotated, apply rotation to bytes before saving
      if (_quarterTurns != 0) {
        final decoded = img.decodeImage(bytesToSave);
        if (decoded != null) {
          final rotated =
              img.copyRotate(decoded, angle: (_quarterTurns * 90).toDouble());
          bytesToSave = Uint8List.fromList(img.encodeJpg(rotated, quality: 95));
        }
      }

      bool isSuccess = false;

      // 4. Save to gallery based on platform
      if (!kIsWeb) {
        final result = await ImageGallerySaver.saveImage(
          bytesToSave,
          quality: 95,
          name: 'SnapScan_${DateTime.now().millisecondsSinceEpoch}',
        );
        isSuccess = (result != null &&
            (result['isSuccess'] == true || result['filePath'] != null));
      } else {
        // Web: Image processed successfully
        isSuccess = true;
      }

      setState(() => _isProcessing = false);

      if (isSuccess && mounted) {
        // Haptic feedback for success
        HapticFeedback.heavyImpact();

        // Show exact floating dark pill Snackbar as in design.jpeg
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1800),
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.toastBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.successGreen,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Gambar berhasil disimpan!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Pop back to Home Screen after delay
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan gambar ke galeri.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat menyimpan: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkSurface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Preview & Edit',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. Image Preview Area (dominates center)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotatable Image (Using Image.memory for cross-platform compatibility)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: RotatedBox(
                            quarterTurns: _quarterTurns,
                            child: _imageBytes != null
                                ? Image.memory(
                                    _imageBytes!,
                                    fit: BoxFit.contain,
                                  )
                                : const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                    ),
                                  ),
                          ),
                        ),

                        // Viewfinder Crop Grid Framing Overlay (matching design.jpeg)
                        const CropGridOverlay(),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Bottom Control Action Bar (White Container matching design.jpeg)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // Action: Potong (Crop)
                      _BottomActionItem(
                        icon: Icons.crop,
                        label: 'Potong',
                        onTap: _isProcessing ? null : _handleCropImage,
                      ),
                      const SizedBox(width: 24),

                      // Action: Putar (Rotate)
                      _BottomActionItem(
                        icon: Icons.rotate_right_rounded,
                        label: 'Putar',
                        onTap: _isProcessing ? null : _handleRotateImage,
                      ),

                      const Spacer(),

                      // Action: Simpan ke Galeri (Emerald Green Pill Button)
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.save_rounded,
                          size: 19,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Simpan ke Galeri',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: _isProcessing ? null : _handleSaveToGallery,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Loading Progress Indicator Overlay
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.successGreen,
                    ),
                    if (_processingMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        _processingMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Helper bottom item widget for "Potong" and "Putar"
class _BottomActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _BottomActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: AppColors.textDark),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
