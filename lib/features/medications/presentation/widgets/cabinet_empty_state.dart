import 'package:flutter/material.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/core/widgets/pill_illustration.dart';

class CabinetEmptyState extends StatelessWidget {
  const CabinetEmptyState({super.key, required this.isFiltered});

  /// True when a tab like "Finished" is empty, but the cabinet itself is not.
  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    final (title, message) = isFiltered
        ? ('Nothing here', 'No medicines match this tab.')
        : ('Your cabinet is empty', 'Scan a prescription to add your first medicine.');

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PillIllustration(size: 96),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}