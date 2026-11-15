import 'package:flutter/material.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';

class ScanFrame extends StatelessWidget {
  const ScanFrame({super.key, required this.isScanning});

  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: const _BracketPainter(color: AppColors.plaster),
        child: Center(
          child: isScanning
              ? const CircularProgressIndicator(color: AppColors.plaster)
              : Icon(
                  Icons.document_scanner_outlined,
                  size: 64,
                  color: AppColors.paper.withValues(alpha: 0.35),
                ),
        ),
      ),
    );
  }
}

// Draws four L-shaped corner brackets, like a camera viewfinder
class _BracketPainter extends CustomPainter {
  const _BracketPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const arm = 28.0; // length of each bracket arm
    final w = size.width;
    final h = size.height;

    // One Path with four separate sub-paths: moveTo starts a new one
    final path = Path()
      ..moveTo(0, arm)
      ..lineTo(0, 0)
      ..lineTo(arm, 0) // top left
      ..moveTo(w - arm, 0)
      ..lineTo(w, 0)
      ..lineTo(w, arm) // top right
      ..moveTo(w, h - arm)
      ..lineTo(w, h)
      ..lineTo(w - arm, h) // bottom right
      ..moveTo(arm, h)
      ..lineTo(0, h)
      ..lineTo(0, h - arm); // bottom left

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_BracketPainter oldDelegate) =>
      oldDelegate.color != color;
}