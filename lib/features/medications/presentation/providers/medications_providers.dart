import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/core/sync/offline_first_repository.dart';
import 'package:medipulse_medical/core/sync/sync_providers.dart';
import 'package:medipulse_medical/features/medications/data/medications_local_source.dart';
import 'package:medipulse_medical/features/medications/domain/medication.dart';

/// Device copy first, cloud copy when signed in.
final medicationsSourceProvider =
    Provider<OfflineFirstRepository<List<Medication>>>((ref) {
  final local = MedicationsLocalSource();

  return OfflineFirstRepository<List<Medication>>(
    kind: 'medications',
    readLocal: local.load,
    writeLocal: local.saveAll,
    empty: () => const [],
    encode: (list) => [for (final m in list) m.toJson()],
    decode: (data) => [
      for (final item in data as List<dynamic>)
        Medication.fromJson(Map<String, dynamic>.from(item as Map)),
    ],
    remote: ref.watch(remoteSnapshotSourceProvider),
    dirtyFlags: ref.watch(dirtyFlagStoreProvider),
  );
});

class MedicationsController extends AsyncNotifier<List<Medication>> {
  @override
  Future<List<Medication>> build() {
    return ref.read(medicationsSourceProvider).load();
  }

  /// Adds the medicines that are not already in the cabinet.
  /// Returns how many were actually new.
  Future<int> addAll(List<Medication> candidates) async {
    final current = await future; // waits for the first load to finish
    final known = current.map((m) => m.duplicateKey).toSet();

    // Set.add returns false when the key was already there, so this
    // skips both existing medicines and repeats inside `candidates`
    final fresh = candidates.where((m) => known.add(m.duplicateKey)).toList();
    if (fresh.isEmpty) return 0;

    final next = [...current, ...fresh];
    await ref.read(medicationsSourceProvider).save(next);
    state = AsyncData(next);
    return fresh.length;
  }

  /// Adds a new medicine, or replaces the one with the same id (editing).
  /// Returns false if a different medicine already has the same name + dose.
  Future<bool> save(Medication medication) async {
    final current = state.value ?? await future;

    final clash = current.any(
      (m) => m.id != medication.id && m.duplicateKey == medication.duplicateKey,
    );
    if (clash) return false;

    final isEdit = current.any((m) => m.id == medication.id);
    final next = isEdit
        ? [for (final m in current) m.id == medication.id ? medication : m]
        : [...current, medication];

    await ref.read(medicationsSourceProvider).save(next);
    state = AsyncData(next);
    return true;
  }

  /// Changes the pill count by [delta] (negative = a pill was taken).
  /// Medicines that don't track stock are left alone.
  Future<void> adjustStock(String id, int delta) async {
    final current = state.value ?? await future;

    final next = [
      for (final m in current)
        if (m.id == id && m.stockRemaining != null)
          m.copyWith(
            stockRemaining:
                (m.stockRemaining! + delta) < 0 ? 0 : m.stockRemaining! + delta,
          )
        else
          m,
    ];

    state = AsyncData(next);
    await ref.read(medicationsSourceProvider).save(next);
  }

  Future<void> remove(String id) async {
    // Update the screen first. A swiped-away Dismissible must leave the
    // list in the very same frame, or Flutter throws an error.
    final current = state.value ?? await future;
    final next = [
      for (final medication in current)
        if (medication.id != id) medication,
    ];
    state = AsyncData(next);
    await ref.read(medicationsSourceProvider).save(next);
  }
}

final medicationsProvider =
    AsyncNotifierProvider<MedicationsController, List<Medication>>(
  MedicationsController.new,
);
