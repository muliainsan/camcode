import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_colors.dart';
import '../utils/permission_helper.dart';
import '../widgets/barcode_icon_widget.dart';
import '../widgets/camera_icon_widget.dart';
import '../widgets/feature_card.dart';
import 'edit_preview_screen.dart';
import 'scanner_screen.dart';

/// Screen 1: Home Screen (MainMenuScreen)
/// Displays two square cards dynamically:
/// - Wide screen (landscape / tablet): Side-by-side ("kanan kiri").
/// - Narrow screen (portrait mobile): Stacked vertically ("atas bawah").
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  /// Shows bottom sheet allowing user to choose between Camera or Gallery
  void _showImageSourcePicker() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag indicator bar
              Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 18),

              // Title and Subtitle
              const Text(
                'Pilih Sumber Gambar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tentukan cara untuk mengambil atau memilih foto',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 22),

              // Option 1: Buka Kamera
              _ImageSourceOptionTile(
                icon: Icons.camera_alt_rounded,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                title: 'Kamera',
                subtitle: 'Ambil foto langsung menggunakan kamera',
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),

              // Option 2: Pilih dari Galeri
              _ImageSourceOptionTile(
                icon: Icons.photo_library_rounded,
                iconColor: AppColors.successGreen,
                iconBgColor: AppColors.successGreen.withValues(alpha: 0.12),
                title: 'Galeri',
                subtitle: 'Pilih foto yang ada di galeri perangkat',
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles image picking from Camera or Gallery and navigates to EditPreviewScreen
  Future<void> _pickImage(ImageSource source) async {
    // 1. Check & Request appropriate permission gracefully
    bool hasPermission = false;
    if (source == ImageSource.camera) {
      hasPermission = await PermissionHelper.requestCameraPermission(context);
    } else {
      hasPermission = await PermissionHelper.requestStoragePermission(context);
    }

    if (!hasPermission) return;

    try {
      setState(() => _isLoading = true);

      // 2. Open Camera or Gallery based on user selection
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );

      setState(() => _isLoading = false);

      // 3. Navigate to EditPreviewScreen if photo selected
      if (photo != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditPreviewScreen(initialImagePath: photo.path),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil gambar: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Handles Navigation to Scanner Screen
  Future<void> _handleOpenScanner() async {
    // 1. Check & Request Camera Permission gracefully
    final hasPermission = await PermissionHelper.requestCameraPermission(context);
    if (!hasPermission) return;

    // 2. Navigate to ScannerScreen
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ScannerScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Cam & Scan',
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
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Breakpoint untuk layout dinamis:
                // >= 600px: Layar lebar (kanan kiri)
                // < 600px: Layar kecil / portrait (atas bawah)
                final bool isWide = constraints.maxWidth >= 600;

                // Definisi Card 1
                final cardCamera = FeatureCard(
                  icon: const CameraIconWidget(size: 60),
                  title: 'Ambil & Edit Gambar',
                  subtitle: 'Ambil foto, potong, putar, dan simpan',
                  onTap: _showImageSourcePicker,
                );

                // Definisi Card 2
                final cardScanner = FeatureCard(
                  icon: const BarcodeIconWidget(size: 60),
                  title: 'Scan Barcode',
                  subtitle: 'Pindai & ambil data dari barcode',
                  onTap: _handleOpenScanner,
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Dynamic Menu Layout:
                          // Kanan-Kiri jika layar lebar, Atas-Bawah jika layar kecil
                          if (isWide)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 280,
                                        maxHeight: 280,
                                      ),
                                      child: cardCamera,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 28),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 280,
                                        maxHeight: 280,
                                      ),
                                      child: cardScanner,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 330,
                                      maxHeight: 330,
                                    ),
                                    child: cardCamera,
                                  ),
                                  const SizedBox(height: 22),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 330,
                                      maxHeight: 330,
                                    ),
                                    child: cardScanner,
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Loading overlay indicator
          if (_isLoading)
            Container(
              color: Colors.black38,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget tile interaktif untuk opsi pemilihan sumber gambar (Kamera / Galeri)
class _ImageSourceOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ImageSourceOptionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200, width: 1.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
