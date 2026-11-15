import 'dart:math' as math;

import 'package:flutter/material.dart';

class EcgLinePainter extends CustomPainter {
  EcgLinePainter({
    required this.progress,
    required this.color,
    required this.beatsVisible,
  }) : super(repaint: progress);

  final Animation<double> progress; // loops 0 -> 1, once per heartbeat
  final Color color;
  final double beatsVisible;

  // One heartbeat shape. t goes 0..1 across a single beat.
  // Each wave is a bell curve: exp(-((t - centre) / width)^2)
  double _beat(double t) {
    double bump(double centre, double width) {
      final d = (t - centre) / width;
      return math.exp(-d * d);
    }

    return 0.15 * bump(0.18, 0.05) //  P wave (small hump)
        - 0.15 * bump(0.40, 0.012) //  Q dip
        + 1.00 * bump(0.44, 0.012) //  R spike (the tall peak)
        - 0.35 * bump(0.48, 0.014) //  S dip
        + 0.25 * bump(0.70, 0.07); //  T wave (rounded hump)
  }

  @override
  void paint(Canvas canvas, Size size) {
    final beatWidth = size.width / beatsVisible;
    final baseline = size.height * 0.62;
    final amplitude = size.height * 0.55;

    final path = Path();
    for (double x = 0; x <= size.width; x += 2) {
      // Position inside the current beat, shifted by animation progress
      final t = ((x / beatWidth) + progress.value) % 1.0;
      final y = baseline - _beat(t) * amplitude;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(EcgLinePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.beatsVisible != beatsVisible;
}