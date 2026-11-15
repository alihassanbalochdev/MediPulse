import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/core/sync/sync_providers.dart';
import 'package:medipulse_medical/features/auth/data/auth_repository.dart';
import 'package:medipulse_medical/features/auth/domain/auth_user.dart';

/// null in local-only mode.
final authRepositoryProvider = Provider<AuthRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : AuthRepository(client);
});

/// The signed-in person, or null. Updates when they sign in or out.
final authUserProvider = StreamProvider<AuthUser?>((ref) async* {
  final repository = ref.watch(authRepositoryProvider);
  if (repository == null) {
    yield null;
    return;
  }
  yield repository.currentUser;
  yield* repository.changes;
});
