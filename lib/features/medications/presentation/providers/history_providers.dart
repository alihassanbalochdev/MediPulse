import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/features/medications/domain/dose_log.dart';
import 'package:medipulse_medical/features/medications/presentation/providers/dose_logs_providers.dart';

typedef HistoryDay = ({DateTime day, List<DoseLog> logs});

/// Logs grouped by day, newest day first.
final historyProvider = Provider<List<HistoryDay>>((ref) {
  final logs = [...(ref.watch(doseLogsProvider).value ?? const <DoseLog>[])]
    ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

  final days = <DateTime, List<DoseLog>>{};
  for (final log in logs) {
    final day = DateTime(
      log.scheduledAt.year,
      log.scheduledAt.month,
      log.scheduledAt.day,
    );
    days.putIfAbsent(day, () => []).add(log);
  }

  return [for (final entry in days.entries) (day: entry.key, logs: entry.value)];
});

/// Taken and skipped counts for the last 7 days.
final weekSummaryProvider = Provider<({int taken, int skipped})>((ref) {
  final logs = ref.watch(doseLogsProvider).value ?? const <DoseLog>[];
  final since = DateTime.now().subtract(const Duration(days: 7));
  final recent = logs.where((l) => l.scheduledAt.isAfter(since));

  return (
    taken: recent.where((l) => l.status == DoseLogStatus.taken).length,
    skipped: recent.where((l) => l.status == DoseLogStatus.skipped).length,
  );
});
