import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/core/providers/clock_providers.dart';
import 'package:medipulse_medical/core/sync/offline_first_repository.dart';
import 'package:medipulse_medical/core/sync/sync_providers.dart';
import 'package:medipulse_medical/features/medications/data/dose_logs_local_source.dart';
import 'package:medipulse_medical/features/medications/domain/dose_log.dart';
import 'package:medipulse_medical/features/medications/domain/dose_schedule.dart';
import 'package:medipulse_medical/features/medications/domain/dose_state.dart';
import 'package:medipulse_medical/features/medications/presentation/providers/medications_providers.dart';
import 'package:medipulse_medical/features/medications/presentation/providers/schedule_providers.dart';

/// Device copy first, cloud copy when signed in.
final doseLogsSourceProvider = Provider<OfflineFirstRepository<List<DoseLog>>>((ref) {
  final local = DoseLogsLocalSource();

  return OfflineFirstRepository<List<DoseLog>>(
    kind: 'dose_logs',
    readLocal: local.load,
    writeLocal: local.saveAll,
    empty: () => const [],
    encode: (list) => [for (final log in list) log.toJson()],
    decode: (data) => [
      for (final item in data as List<dynamic>)
        DoseLog.fromJson(Map<String, dynamic>.from(item as Map)),
    ],
    remote: ref.watch(remoteSnapshotSourceProvider),
    dirtyFlags: ref.watch(dirtyFlagStoreProvider),
  );
});

class DoseLogsController extends AsyncNotifier<List<DoseLog>> {
  @override
  Future<List<DoseLog>> build() {
    return ref.read(doseLogsSourceProvider).load();
  }

  /// Logs a dose as taken or skipped (replacing any earlier log of it).
  Future<void> mark(ScheduledDose dose, DoseLogStatus status) async {
    final current = state.value ?? await future;
    final key = doseKey(dose.medication.id, dose.time);
    final previous = current.where((l) => l.key == key).firstOrNull;

    final entry = DoseLog(
      medicationId: dose.medication.id,
      medicationName: dose.medication.name,
      dosage: dose.medication.dosage,
      scheduledAt: dose.time,
      status: status,
      loggedAt: DateTime.now(),
    );

    // Keep 90 days of history so storage never grows forever
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    final next = [
      for (final log in current)
        if (log.key != key && log.scheduledAt.isAfter(cutoff)) log,
      entry,
    ];

    state = AsyncData(next);
    await ref.read(doseLogsSourceProvider).save(next);

    await _syncStock(
      dose.medication.id,
      wasTaken: previous?.status == DoseLogStatus.taken,
      isTaken: status == DoseLogStatus.taken,
    );
  }

  /// Removes the log of a dose (undo).
  Future<void> clear(ScheduledDose dose) async {
    final current = state.value ?? await future;
    final key = doseKey(dose.medication.id, dose.time);
    final previous = current.where((l) => l.key == key).firstOrNull;
    if (previous == null) return;

    final next = [
      for (final log in current)
        if (log.key != key) log,
    ];

    state = AsyncData(next);
    await ref.read(doseLogsSourceProvider).save(next);

    await _syncStock(
      dose.medication.id,
      wasTaken: previous.status == DoseLogStatus.taken,
      isTaken: false,
    );
  }

  // Taking a dose uses one pill; undoing it gives the pill back.
  Future<void> _syncStock(
    String medicationId, {
    required bool wasTaken,
    required bool isTaken,
  }) async {
    final delta = (wasTaken ? 1 : 0) - (isTaken ? 1 : 0);
    if (delta == 0) return;
    await ref.read(medicationsProvider.notifier).adjustStock(medicationId, delta);
  }
}

final doseLogsProvider =
    AsyncNotifierProvider<DoseLogsController, List<DoseLog>>(
  DoseLogsController.new,
);

/// Today's doses with their log and state. Powers Today and the dashboard.
final doseEntriesProvider = Provider<List<DoseEntry>>((ref) {
  final doses = ref.watch(todaysDosesProvider);
  final logs = ref.watch(doseLogsProvider).value ?? const <DoseLog>[];
  final now = ref.watch(clockProvider).value ?? DateTime.now();

  final byKey = {for (final log in logs) log.key: log};

  return [
    for (final dose in doses)
      (
        dose: dose,
        log: byKey[doseKey(dose.medication.id, dose.time)],
        state: doseStateFor(
          time: dose.time,
          log: byKey[doseKey(dose.medication.id, dose.time)],
          now: now,
        ),
      ),
  ];
});
