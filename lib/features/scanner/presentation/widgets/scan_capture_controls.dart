import 'package:flutter/material.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';

class ScanCaptureControls extends StatelessWidget {
  const ScanCaptureControls({
    super.key,
    required this.enabled,
    required this.onCamera,
    required this.onGallery,
  });

  final bool enabled;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: enabled ? onGallery : null,
            tooltip: 'Pick from gallery',
            iconSize: 28,
            color: AppColors.paper,
            icon: const Icon(Icons.photo_library_outlined),
          ),
          Semantics(
            button: true,
            label: 'Take a photo',
            child: GestureDetector(
              onTap: enabled ? onCamera : null,
              child: const _ShutterButton(),
            ),
          ),
          // Same width as the gallery button, so the shutter stays centred
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.paper, width: 3),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(5),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.plaster,
            shape: BoxShape.circle,
          ),
          child: SizedBox(width: 58, height: 58),
        ),
      ),
    );
  }
}