import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/core/services/haptic_service.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/core/widgets/dashed_divider.dart';
import 'package:medipulse_medical/features/medications/domain/dose_log.dart';
import 'package:medipulse_medical/features/medications/domain/dose_state.dart';
import 'package:medipulse_medical/features/medications/presentation/providers/dose_logs_providers.dart';
import 'package:medipulse_medical/features/medications/presentation/widgets/dose_tile.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(doseEntriesProvider);
    final taken = entries.where((e) => e.state == DoseState.taken).length;

    return Scaffold(
      appBar: AppBar(title:  Text('Today', style: AppTextStyles.title)),
      body: SafeArea(
        child: entries.isEmpty
            ? Center(
                child: Padding(
                  padding: AppSpacing.screen,
                  child: Text(
                    'No scheduled doses today.\nAdd a medicine with a daily frequency.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(color: AppColors.muted),
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: AppSpacing.screen.copyWith(top: AppSpacing.lg),
                    child: Text(
                      '$taken of ${entries.length} taken · tap to log, hold to skip',
                      style: AppTextStyles.caption,
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: AppSpacing.screen,
                      itemCount: entries.length,
                      separatorBuilder: (context, index) => const DashedDivider(),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return DoseTile(
                          entry: entry,
                          onTap: () => _toggle(ref, entry),
                          onLongPress: () => _skip(ref, entry),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Logged already -> undo it. Not logged -> mark taken, with the heartbeat.
void _toggle(WidgetRef ref, DoseEntry entry) {
  final logs = ref.read(doseLogsProvider.notifier);
  if (entry.log != null) {
    logs.clear(entry.dose);
  } else {
    ref.read(hapticServiceProvider).heartbeat();
    logs.mark(entry.dose, DoseLogStatus.taken);
  }
}

void _skip(WidgetRef ref, DoseEntry entry) {
  if (entry.log != null) return;
  ref.read(doseLogsProvider.notifier).mark(entry.dose, DoseLogStatus.skipped);
}
