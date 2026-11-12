import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_colors.dart';
import '../widgets/scan_result_sheet.dart';
import '../widgets/scanner_overlay.dart';

/// Screen 3: Barcode Scanner Screen (ScannerScreen)
/// Features live camera feed, glowing cyan viewfinder overlay, haptic feedback,
/// and a bottom sheet displaying the scanned result.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with WidgetsBindingObserver {
  late final MobileScannerController _controller;
  bool _isProcessing = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize MobileScannerController with high accuracy
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 250,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Manage camera lifecycle properly when switching apps
    if (!_controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      _controller.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  /// Handles barcode detection
  Future<void> _handleBarcode(BarcodeCapture capture) async {
    // Prevent duplicate triggers while bottom sheet is open or processing
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? scannedValue =
        barcodes.first.rawValue ?? barcodes.first.displayValue;
    if (scannedValue == null || scannedValue.trim().isEmpty) return;

    // Lock scanner processing so new camera frames are ignored during bottom sheet
    setState(() => _isProcessing = true);

    // 1. Haptic feedback on successful detection
    HapticFeedback.heavyImpact();

    if (!mounted) return;

    final String formatName = barcodes.first.format.name.toUpperCase();

    // 2. Show modal bottom sheet with result
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ScanResultSheet(
        scannedData: scannedValue,
        barcodeFormat: formatName,
        onScanAgain: () {
          // Bottom sheet closed, scanner unlocks below
        },
      ),
    );

    // 3. Unlock scanner cleanly after bottom sheet closes
    if (mounted) {
      // Cooldown delay so user has time to reposition or re-target
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Toggles flashlight / torch
  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Switches between front and back cameras
  Future<void> _switchCamera() async {
    try {
      HapticFeedback.selectionClick();
      await _controller.switchCamera();
      setState(() {
        if (_controller.value.cameraDirection == CameraFacing.front) {
          _isTorchOn = false;
        }
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Scan Barcode',
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
        actions: [
          // Flip Camera Button (Front / Back)
          IconButton(
            icon: const Icon(
              Icons.cameraswitch_rounded,
              color: Colors.white,
            ),
            tooltip: 'Ganti Kamera Depan/Belakang',
            onPressed: _switchCamera,
          ),
          // Flashlight Toggle Button
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: Colors.white,
            ),
            tooltip: 'Senter',
            onPressed: _toggleTorch,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Live Camera Preview
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.videocam_off_rounded,
                        size: 64,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        error.errorCode == MobileScannerErrorCode.permissionDenied
                            ? 'Izin kamera belum diberikan. Izinkan akses kamera untuk memindai barcode.'
                            : 'Tidak dapat memulai kamera: ${error.errorDetails?.message ?? error.errorCode.name}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () => openAppSettings(),
                        child: const Text(
                          'Buka Pengaturan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 2. Fullscreen Overlay with Cutout & Glowing Cyan Corners
          ScannerOverlay(isScanning: !_isProcessing),
        ],
      ),
    );
  }
}
