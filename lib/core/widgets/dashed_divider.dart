import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';

class DashedDivider extends StatelessWidget {
  const DashedDivider({
    super.key,
    this.color = AppColors.scrub,
    this.dashWidth = 5,
    this.gap = 4,
  });

  final Color color;
  final double dashWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashPainter(
          color: color.withValues(alpha: 0.3),
          dashWidth: dashWidth,
          gap: gap,
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter({
    required this.color,
    required this.dashWidth,
    required this.gap,
  });

  final Color color;
  final double dashWidth;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (var x = 0.0; x < size.width; x += dashWidth + gap) {
      canvas.drawLine(
        Offset(x, 0.5),
        Offset(math.min(x + dashWidth, size.width), 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.gap != gap;
}