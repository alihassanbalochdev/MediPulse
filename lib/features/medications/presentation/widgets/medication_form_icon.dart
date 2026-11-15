import 'package:flutter/material.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';
import 'package:medipulse_medical/core/widgets/pill_illustration.dart';
import 'package:medipulse_medical/features/medications/domain/medication_form.dart';

class MedicationFormIcon extends StatelessWidget {
  const MedicationFormIcon({super.key, required this.form, this.size = 40});

  final MedicationForm form;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: switch (form) {
        MedicationForm.capsule => PillIllustration(
            size: size,
            angleDegrees: -35,
          ),
        MedicationForm.tablet => const CustomPaint(painter: _TabletPainter()),
        MedicationForm.syrup => const CustomPaint(painter: _BottlePainter()),
        MedicationForm.injection => const _InjectionBadge(),
      },
    );
  }
}

class _TabletPainter extends CustomPainter {
  const _TabletPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.32;
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..color = AppColors.scrub;

    canvas.drawCircle(center, radius, Paint()..color = AppColors.aqua);
    canvas.drawCircle(center, radius, outline);
    canvas.drawLine(
      center.translate(-radius, 0),
      center.translate(radius, 0),
      outline,
    );
  }

  @override
  bool shouldRepaint(_TabletPainter oldDelegate) => false;
}

class _BottlePainter extends CustomPainter {
  const _BottlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.25, w * 0.30, w * 0.50, w * 0.62),
      Radius.circular(w * 0.14),
    );

    canvas.drawRRect(body, Paint()..color = AppColors.paper);

    // Peach liquid: clip to the bottle, then fill the lower part
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.25, w * 0.58, w * 0.50, w * 0.34),
      Paint()..color = AppColors.plaster,
    );
    canvas.restore();

    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.04
        ..color = AppColors.scrub,
    );

    // The cap
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.32, w * 0.12, w * 0.36, w * 0.16),
        Radius.circular(w * 0.04),
      ),
      Paint()..color = AppColors.scrub,
    );
  }

  @override
  bool shouldRepaint(_BottlePainter oldDelegate) => false;
}

class _InjectionBadge extends StatelessWidget {
  const _InjectionBadge();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.aqua,
        shape: BoxShape.circle,
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.scrub, width: 1.6),
        ),
      ),
      child: Center(
        child: Icon(Icons.vaccines_outlined, size: 20, color: AppColors.scrub),
      ),
    );
  }
}