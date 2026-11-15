import 'package:flutter/material.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/features/dashboard/domain/dose_urgency.dart';
import 'package:medipulse_medical/features/dashboard/presentation/widgets/ecg_line_painter.dart';

/// Shown when no doses are waiting: a calm 60 BPM resting pulse.
class AllDoneHeroCard extends StatefulWidget {
  const AllDoneHeroCard({super.key, required this.message});

  final String message;

  @override
  State<AllDoneHeroCard> createState() => _AllDoneHeroCardState();
}

class _AllDoneHeroCardState extends State<AllDoneHeroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static final _look = DoseUrgency.calm.look;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 60000 ~/ _look.bpm),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.scrub,
          borderRadius: AppRadius.hero,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resting pulse · 60 BPM',
                style: AppTextStyles.caption.copyWith(color: _look.color),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.message,
                style: AppTextStyles.display.copyWith(color: AppColors.paper),
              ),
              const SizedBox(height: AppSpacing.md),
              RepaintBoundary(
                child: SizedBox(
                  height: 34,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: EcgLinePainter(
                      progress: _controller,
                      color: _look.color,
                      beatsVisible: _look.beatsVisible,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
