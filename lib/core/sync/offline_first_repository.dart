import 'dart:async';

import 'package:medipulse_medical/core/result/result.dart';
import 'package:medipulse_medical/core/sync/dirty_flag_store.dart';
import 'package:medipulse_medical/core/sync/remote_snapshot_source.dart';

/// What the sync coordinator needs from a repository, whatever its type T.
abstract interface class Syncable {
  String get kind;
  Future<bool> hasPending();
  Future<void> syncPending();
  Future<void> clearLocal();
}

/// Keeps one snapshot of type [T] on the device (always) and in the cloud
/// (when signed in and online).
///
/// Rules:
///  * The device is the source of truth. Reads and writes never wait for the network.
///  * A change made while the cloud is unreachable is remembered ("dirty")
///    and uploaded later. A dirty device wins over the cloud on load.
///  * Otherwise the cloud wins on load: it is how a second phone catches up.
///  * Last write wins. There is no field-level merge.
class OfflineFirstRepository<T> implements Syncable {
  OfflineFirstRepository({
    required this.kind,
    required this.readLocal,
    required this.writeLocal,
    required this.empty,
    required this.encode,
    required this.decode,
    required this.remote,
    required this.dirtyFlags,
    this.remoteTimeout = const Duration(seconds: 5),
  });

  @override
  final String kind;
  final Future<T> Function() readLocal;
  final Future<void> Function(T value) writeLocal;
  final T Function() empty;
  final Object Function(T value) encode;
  final T Function(Object data) decode;
  final RemoteSnapshotSource remote;
  final DirtyFlagStore dirtyFlags;
  final Duration remoteTimeout;

  int _version = 0; // grows with every save, so stale uploads can be skipped
  Future<void> _queue = Future.value(); // uploads run one at a time, in order

  /// Loads the data and says whether it came from the device cache.
  Future<Result<T>> loadResult() async {
    T local;
    try {
      local = await readLocal();
    } on Object catch (error) {
      return Failure('Could not read $kind from this device', cause: error);
    }

    if (!remote.isAvailable) return Success(local, isFromCache: true);

    try {
      if (await dirtyFlags.isDirty(kind)) {
        // Changes that never reached the cloud: they win. Try to upload them now.
        await _pushLocal();
        return Success(local);
      }

      final data = await remote.fetch(kind).timeout(remoteTimeout);
      if (data == null) {
        // First time in the cloud: upload what the device has.
        await remote.push(kind, encode(local)).timeout(remoteTimeout);
        return Success(local);
      }

      final fresh = decode(data);
      await writeLocal(fresh);
      return Success(fresh);
    } on Object {
      // Offline, slow, or unreadable cloud data: the device copy still works.
      return Success(local, isFromCache: true);
    }
  }

  Future<T> load() async => switch (await loadResult()) {
        Success(:final value) => value,
        Failure(:final message) => throw StateError(message),
      };

  /// Saves on the device at once, then uploads in the background.
  Future<void> save(T value) async {
    await writeLocal(value);
    if (!remote.isAvailable) return; // not signed in: nothing to sync

    final version = ++_version;
    await dirtyFlags.setDirty(kind, true);

    unawaited(_enqueue(() async {
      if (version != _version) return; // a newer save will upload instead
      await remote.push(kind, encode(value)).timeout(remoteTimeout);
      if (version == _version) await dirtyFlags.setDirty(kind, false);
    }));
  }

  @override
  Future<bool> hasPending() => dirtyFlags.isDirty(kind);

  @override
  Future<void> syncPending() async {
    if (!remote.isAvailable) return;
    await _enqueue(() async {
      if (!await dirtyFlags.isDirty(kind)) return;
      await _pushLocal();
    });
  }

  /// Wipes the device copy (used when signing out).
  @override
  Future<void> clearLocal() async {
    _version++;
    await writeLocal(empty());
    await dirtyFlags.setDirty(kind, false);
  }

  /// Completes when every queued upload has finished.
  Future<void> whenIdle() => _queue;

  Future<void> _pushLocal() async {
    final startVersion = _version;
    final local = await readLocal();
    await remote.push(kind, encode(local)).timeout(remoteTimeout);
    if (startVersion == _version) await dirtyFlags.setDirty(kind, false);
  }

  // Runs [job] after the previous one. A failed job is swallowed: the dirty
  // flag stays on, so the next sync retries it.
  Future<void> _enqueue(Future<void> Function() job) {
    final next = _queue.then((_) => job()).catchError((Object _) {});
    _queue = next;
    return next;
  }
}
