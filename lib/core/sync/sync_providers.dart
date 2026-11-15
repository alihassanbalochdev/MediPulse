import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/core/sync/dirty_flag_store.dart';
import 'package:medipulse_medical/core/sync/remote_snapshot_source.dart';
import 'package:medipulse_medical/core/sync/supabase_snapshot_source.dart';
import 'package:medipulse_medical/core/sync/sync_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// null when the build has no Supabase keys (local-only mode).
final supabaseClientProvider = Provider<SupabaseClient?>(
  (ref) => isSupabaseConfigured ? Supabase.instance.client : null,
);

final remoteSnapshotSourceProvider = Provider<RemoteSnapshotSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? const NoRemoteSource() : SupabaseSnapshotSource(client);
});

final dirtyFlagStoreProvider = Provider<DirtyFlagStore>(
  (ref) => PrefsDirtyFlagStore(),
);
