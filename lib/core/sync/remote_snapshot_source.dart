/// Where a snapshot of the app's data lives in the cloud.
/// Supabase is one implementation; tests use a fake.
abstract interface class RemoteSnapshotSource {
  /// True when the cloud can be used right now (the person is signed in).
  bool get isAvailable;

  /// The saved snapshot for [kind], or null if none exists yet.
  Future<Object?> fetch(String kind);

  Future<void> push(String kind, Object data);
}

/// Used when Supabase is not configured: local-only mode.
class NoRemoteSource implements RemoteSnapshotSource {
  const NoRemoteSource();

  @override
  bool get isAvailable => false;

  @override
  Future<Object?> fetch(String kind) async => null;

  @override
  Future<void> push(String kind, Object data) async {
    throw StateError('No cloud configured');
  }
}
