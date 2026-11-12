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

  /// Handles Camera Capture and navigates to EditPreviewScreen
  Future<void> _handleCameraCapture() async {
    // 1. Check & Request Camera Permission gracefully
    final hasPermission = await PermissionHelper.requestCameraPermission(context);
    if (!hasPermission) return;

    try {
      setState(() => _isLoading = true);

      // 2. Open device camera to capture photo
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      setState(() => _isLoading = false);

      // 3. Navigate to EditPreviewScreen if photo taken
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
            content: Text('Gagal membuka kamera: $e'),
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
                  onTap: _handleCameraCapture,
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
                        crossAxisAlignment: isWide
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          // Section Header Title
                          Text(
                            isWide
                                ? 'Pilih fitur yang ingin digunakan:'
                                : 'Pilih fitur yang ingin\ndigunakan:',
                            textAlign: isWide ? TextAlign.center : TextAlign.start,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                              height: 1.25,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 28),

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
