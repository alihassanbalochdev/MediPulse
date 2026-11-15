import 'package:flutter/material.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/features/medications/domain/dose_state.dart';

class DoseTile extends StatelessWidget {
  const DoseTile({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onLongPress,
  });

  final DoseEntry entry;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final (:dose, :log, :state) = entry;
    final medication = dose.medication;

    final (icon, color, label) = switch (state) {
      DoseState.taken => (Icons.check_circle, AppColors.scrub, 'Taken'),
      DoseState.skipped => (Icons.remove_circle_outline, AppColors.muted, 'Skipped'),
      DoseState.missed => (Icons.error_outline, AppColors.alert, 'Missed'),
      DoseState.due => (Icons.radio_button_unchecked, AppColors.scrub, 'Due now'),
      DoseState.upcoming => (Icons.radio_button_unchecked, AppColors.muted, ''),
    };

    final isDone = state == DoseState.taken || state == DoseState.skipped;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Opacity(
        opacity: isDone ? 0.6 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              SizedBox(
                width: 84,
                child: Text(
                  TimeOfDay.fromDateTime(dose.time).format(context),
                  style: AppTextStyles.itemName,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(medication.name, style: AppTextStyles.itemName),
                    Text(
                      [medication.dosage, if (label.isNotEmpty) label].join(' · '),
                      style: AppTextStyles.caption.copyWith(
                        color: state == DoseState.missed ? AppColors.alert : null,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(icon, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
