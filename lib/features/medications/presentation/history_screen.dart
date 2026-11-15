import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/core/utils/date_labels.dart';
import 'package:medipulse_medical/core/widgets/dashed_divider.dart';
import 'package:medipulse_medical/features/medications/domain/dose_log.dart';
import 'package:medipulse_medical/features/medications/presentation/providers/history_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(historyProvider);
    final week = ref.watch(weekSummaryProvider);

    return Scaffold(
      appBar: AppBar(title:  Text('History', style: AppTextStyles.title)),
      body: SafeArea(
        child: days.isEmpty
            ? Center(
                child: Text(
                  'No doses logged yet.',
                  style: AppTextStyles.body.copyWith(color: AppColors.muted),
                ),
              )
            : ListView(
                padding: AppSpacing.screen,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Last 7 days: ${week.taken} taken · ${week.skipped} skipped',
                    style: AppTextStyles.body,
                  ),
                  for (final (:day, :logs) in days) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Text(dateLabel(day), style: AppTextStyles.title),
                    for (final log in logs) ...[
                      _HistoryRow(log: log),
                      const DashedDivider(),
                    ],
                  ],
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.log});

  final DoseLog log;

  @override
  Widget build(BuildContext context) {
    final isTaken = log.status == DoseLogStatus.taken;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              TimeOfDay.fromDateTime(log.scheduledAt).format(context),
              style: AppTextStyles.itemName,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.medicationName, style: AppTextStyles.itemName),
                Text(log.dosage, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(
            isTaken
                ? 'Taken ${TimeOfDay.fromDateTime(log.loggedAt).format(context)}'
                : 'Skipped',
            style: AppTextStyles.caption.copyWith(
              color: isTaken ? AppColors.scrub : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
