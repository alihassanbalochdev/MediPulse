import 'package:flutter/material.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/core/widgets/pill_illustration.dart';
import 'package:medipulse_medical/features/dashboard/domain/dose_urgency.dart';
import 'package:medipulse_medical/features/dashboard/domain/next_dose.dart';
import 'package:medipulse_medical/features/dashboard/presentation/widgets/ecg_line_painter.dart';


class NextDoseHeroCard extends StatefulWidget {
  const NextDoseHeroCard({
    super.key,
    required this.dose,
    required this.remaining,
    required this.onLogDose,
  });

  final NextDose dose;
  final Duration remaining;
  final VoidCallback onLogDose;

  @override
  State<NextDoseHeroCard> createState() => _NextDoseHeroCardState();
}

class _NextDoseHeroCardState extends State<NextDoseHeroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  DoseUrgency get _urgency => urgencyFor(widget.remaining);

  // 60000 ms per minute / beats per minute = milliseconds per beat
  Duration get _beatDuration =>
      Duration(milliseconds: 60000 ~/ _urgency.look.bpm);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _beatDuration)
      ..repeat();
  }

  @override
  void didUpdateWidget(NextDoseHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only touch the controller if the urgency state actually changed
    if (urgencyFor(oldWidget.remaining) != _urgency) {
      _controller
        ..duration = _beatDuration
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final look = _urgency.look;
    final clock = widget.dose.time.clock12;

    return Padding(
      // Room above the card so the pill can poke out of the top
      padding: const EdgeInsets.only(top: 28),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
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
                      'Next up · ${widget.dose.name} ${widget.dose.dosage}',
                      style: AppTextStyles.caption.copyWith(color: look.color),
                    ),
                    Text.rich(
                      TextSpan(
                        text: clock.time,
                        children: [
                          TextSpan(
                            text: ' ${clock.period}',
                            style: AppTextStyles.title
                                .copyWith(color: AppColors.paper),
                          ),
                        ],
                      ),
                      style: AppTextStyles.heroTime
                          .copyWith(color: AppColors.paper),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Transform.rotate(
                      angle: -0.05, // a slight tilt, like a sticker
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: look.color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          child: Text(
                            countdownLabel(widget.remaining),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.scrub,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    RepaintBoundary(
                      child: SizedBox(
                        height: 34,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: EcgLinePainter(
                            progress: _controller,
                            color: look.color,
                            beatsVisible: look.beatsVisible,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: widget.onLogDose,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.paper,
                        foregroundColor: AppColors.scrub,
                      ),
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Log this dose'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(top: -28, right: 6, child: PillIllustration()),
        ],
      ),
    );
  }
}