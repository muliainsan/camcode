import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Camera icon with edit pencil badge matching Card 1 in `spec/design.jpeg`.
class CameraIconWidget extends StatelessWidget {
  final double size;
  final Color color;

  const CameraIconWidget({
    super.key,
    this.size = 64,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 16,
      height: size + 16,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Main Camera Icon
          Icon(
            Icons.camera_alt_rounded,
            size: size,
            color: color,
          ),
          // Edit Pencil at bottom-right
          Positioned(
            right: 0,
            bottom: 2,
            child: Transform.rotate(
              angle: -0.6,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit_rounded,
                  size: size * 0.38,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
