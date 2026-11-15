import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/core/result/result.dart';
import 'package:medipulse_medical/core/sync/offline_first_repository.dart';
import 'package:medipulse_medical/features/auth/domain/auth_user.dart';
import 'package:medipulse_medical/features/auth/presentation/providers/auth_providers.dart';
import 'package:medipulse_medical/features/dashboard/presentation/providers/emergency_profile_provider.dart';
import 'package:medipulse_medical/features/medications/presentation/providers/dose_logs_providers.dart';
import 'package:medipulse_medical/features/medications/presentation/providers/medications_providers.dart';

/// Every repository that is backed up to the cloud.
final syncablesProvider = Provider<List<Syncable>>((ref) => [
      ref.watch(medicationsSourceProvider),
      ref.watch(doseLogsSourceProvider),
      ref.watch(emergencyProfileSourceProvider),
    ]);

final connectivityProvider = StreamProvider<List<ConnectivityResult>>(
  (ref) => Connectivity().onConnectivityChanged,
);

/// true while some change has not been uploaded yet.
final hasPendingChangesProvider = FutureProvider.autoDispose<bool>((ref) async {
  for (final syncable in ref.watch(syncablesProvider)) {
    if (await syncable.hasPending()) return true;
  }
  return false;
});

// Re-runs the controllers' load(), which pulls from the cloud when signed in.
void _reloadAllData(Ref ref) {
  ref.invalidate(medicationsProvider);
  ref.invalidate(doseLogsProvider);
  ref.invalidate(emergencyProfileProvider);
  ref.invalidate(hasPendingChangesProvider);
}

/// Watched once, from the app root:
///  * signing in      -> pull the cloud data
///  * internet is back -> upload changes made while offline
final syncCoordinatorProvider = Provider<void>((ref) {
  ref.listen(authUserProvider, (previous, next) {
    final wasSignedOut = previous is AsyncData<AuthUser?> && previous.value == null;
    if (wasSignedOut && next.value != null) _reloadAllData(ref);
  });

  ref.listen(connectivityProvider, (previous, next) {
    final isOnline =
        next.value?.any((result) => result != ConnectivityResult.none) ?? false;
    if (isOnline) ref.read(syncActionsProvider.notifier).syncNow();
  });
});

class SyncActions extends Notifier<void> {
  @override
  void build() {}

  Future<void> syncNow() async {
    for (final syncable in ref.read(syncablesProvider)) {
      await syncable.syncPending();
    }
    ref.invalidate(hasPendingChangesProvider);
  }

  /// Signs out only when everything is safely in the cloud, then clears this
  /// device so the next person never sees (or uploads) this person's data.
  Future<Result<void>> signOutSafely() async {
    final auth = ref.read(authRepositoryProvider);
    if (auth == null) return const Success<void>(null);

    final syncables = ref.read(syncablesProvider);
    for (final syncable in syncables) {
      await syncable.syncPending();
    }
    for (final syncable in syncables) {
      if (await syncable.hasPending()) {
        return const Failure<void>(
          'Some changes are not backed up yet. Connect to the internet and try again.',
        );
      }
    }

    await auth.signOut();
    for (final syncable in syncables) {
      await syncable.clearLocal();
    }
    _reloadAllData(ref);
    return const Success<void>(null);
  }
}

final syncActionsProvider = NotifierProvider<SyncActions, void>(SyncActions.new);
