import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';



class PillIllustration extends StatelessWidget {
  const PillIllustration({
    super.key,
    this.size = 84,
    this.angleDegrees = -32,
  });

  final double size;
  final double angleDegrees;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(size),
        painter: _PillPainter(angle: angleDegrees * math.pi / 180),
      ),
    );
  }
}

class _PillPainter extends CustomPainter {
  const _PillPainter({required this.angle});

  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    // Move the origin to the centre, then rotate the whole canvas
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(angle);

    // Every measurement is a fraction of size, so the pill scales cleanly
    final width = size.width * 0.82;
    final height = size.height * 0.33;
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: width, height: height),
      Radius.circular(height / 2),
    );

    // Left half: mint
    canvas.drawRRect(body, Paint()..color = AppColors.paper);

    // Right half: clip to the capsule shape, then fill the right side peach
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRect(
      Rect.fromLTRB(0, -height / 2, width / 2, height / 2),
      Paint()..color = AppColors.plaster,
    );
    canvas.restore();

    // Outline and the line where the two halves meet
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03
      ..strokeCap = StrokeCap.round
      ..color = AppColors.scrub;
    canvas.drawRRect(body, outline);
    canvas.drawLine(Offset(0, -height / 2), Offset(0, height / 2), outline);

    // Small white shine on the mint half
    canvas.drawLine(
      Offset(-width * 0.38, -height * 0.18),
      Offset(-width * 0.14, -height * 0.18),
      Paint()
        ..color = Colors.white
        ..strokeWidth = size.width * 0.035
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PillPainter oldDelegate) => oldDelegate.angle != angle;
}