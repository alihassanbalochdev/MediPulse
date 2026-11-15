import 'package:medipulse_medical/core/sync/remote_snapshot_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Stores one JSON snapshot per (user, kind) in the `user_data` table.
/// Row Level Security makes sure a person can only reach their own rows.
class SupabaseSnapshotSource implements RemoteSnapshotSource {
  SupabaseSnapshotSource(this._client);

  final SupabaseClient _client;
  static const _table = 'user_data';

  @override
  bool get isAvailable => _client.auth.currentUser != null;

  @override
  Future<Object?> fetch(String kind) async {
    final row = await _client
        .from(_table)
        .select('data')
        .eq('kind', kind)
        .maybeSingle();
    return row?['data'];
  }

  @override
  Future<void> push(String kind, Object data) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Not signed in');

    await _client.from(_table).upsert(
      {
        'user_id': user.id,
        'kind': kind,
        'data': data,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id,kind',
    );
  }
}
