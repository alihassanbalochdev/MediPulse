import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/core/sync/offline_first_repository.dart';
import 'package:medipulse_medical/core/sync/sync_providers.dart';
import 'package:medipulse_medical/features/dashboard/data/emergency_profile_local_source.dart';
import 'package:medipulse_medical/features/dashboard/domain/emergency_profile.dart';
import 'package:medipulse_medical/features/medications/presentation/providers/medications_providers.dart';

/// Device copy first, cloud copy when signed in.
final emergencyProfileSourceProvider =
    Provider<OfflineFirstRepository<EmergencyProfile>>((ref) {
  final local = EmergencyProfileLocalSource();

  return OfflineFirstRepository<EmergencyProfile>(
    kind: 'emergency_profile',
    readLocal: local.loadOrSeed,
    writeLocal: local.save,
    empty: () => EmergencyProfile.empty,
    encode: (profile) => profile.toJson(),
    decode: (data) =>
        EmergencyProfile.fromJson(Map<String, dynamic>.from(data as Map)),
    remote: ref.watch(remoteSnapshotSourceProvider),
    dirtyFlags: ref.watch(dirtyFlagStoreProvider),
  );
});

/// The person's own details: name, blood type, allergies, contact.
class EmergencyProfileController extends AsyncNotifier<EmergencyProfile> {
  @override
  Future<EmergencyProfile> build() {
    return ref.read(emergencyProfileSourceProvider).load();
  }

  Future<void> save(EmergencyProfile profile) async {
    state = AsyncData(profile);
    await ref.read(emergencyProfileSourceProvider).save(profile);
  }
}

final emergencyProfileProvider =
    AsyncNotifierProvider<EmergencyProfileController, EmergencyProfile>(
  EmergencyProfileController.new,
);

/// What the emergency card shows: the saved details, plus the medicines
/// from the cabinet that are active right now. No double typing.
final emergencyCardProfileProvider = Provider<AsyncValue<EmergencyProfile>>((ref) {
  final profile = ref.watch(emergencyProfileProvider);
  final medications = ref.watch(medicationsProvider).value ?? const [];

  return profile.whenData(
    (p) => p.copyWith(
      prescriptions: [
        for (final m in medications)
          if (m.isActive)
            '${m.name} ${m.dosage}, ${m.frequency.label.toLowerCase()}',
      ],
    ),
  );
});
