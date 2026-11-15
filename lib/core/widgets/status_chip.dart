import 'package:flutter/material.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';


enum DoseStatus { taken, upcoming, missed }

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final DoseStatus status;

  @override
  Widget build(BuildContext context) {
    // Switch expression returns a record; destructure it into three variables
    final (label, background, foreground) = switch (status) {
      DoseStatus.taken => ('Taken', AppColors.aqua, AppColors.scrub),
      DoseStatus.upcoming => ('Upcoming', AppColors.plasterSoft, AppColors.scrub),
      DoseStatus.missed => ('Missed', AppColors.alert, Colors.white),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: foreground,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}