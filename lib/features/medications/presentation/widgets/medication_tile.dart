import 'package:flutter/material.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/features/medications/domain/medication.dart';
import 'package:medipulse_medical/features/medications/presentation/widgets/medication_form_icon.dart';

class MedicationTile extends StatelessWidget {
  const MedicationTile({super.key, required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final stock = medication.stockRemaining;

    return Opacity(
      opacity: medication.isActive ? 1 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            MedicationFormIcon(form: medication.form),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(medication.name, style: AppTextStyles.itemName),
                  Text(
                    '${medication.dosage} · ${medication.frequency.label}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            if (stock != null)
              Text(
                '$stock left',
                style: AppTextStyles.caption.copyWith(
                  color: medication.isLowStock
                      ? AppColors.alert
                      : AppColors.scrub,
                  fontWeight: medication.isLowStock ? FontWeight.w500 : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}