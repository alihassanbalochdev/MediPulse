import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/features/medications/domain/dose_state.dart';
import 'package:medipulse_medical/features/medications/presentation/providers/dose_logs_providers.dart';

typedef DashboardSummary = ({DoseEntry? next, int taken, int total});

/// The next dose still waiting, plus today's progress.
final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final entries = ref.watch(doseEntriesProvider);

  final next = entries
      .where((e) => e.state == DoseState.upcoming || e.state == DoseState.due)
      .firstOrNull;

  return (
    next: next,
    taken: entries.where((e) => e.state == DoseState.taken).length,
    total: entries.length,
  );
});
