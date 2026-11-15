import 'package:flutter_test/flutter_test.dart';
import 'package:medipulse_medical/core/result/result.dart';
import 'package:medipulse_medical/core/sync/dirty_flag_store.dart';
import 'package:medipulse_medical/core/sync/offline_first_repository.dart';
import 'package:medipulse_medical/core/sync/remote_snapshot_source.dart';

class FakeRemote implements RemoteSnapshotSource {
  bool available = true;
  bool failing = false; // pretend the network is down
  final store = <String, Object>{};
  int pushes = 0;

  @override
  bool get isAvailable => available;

  @override
  Future<Object?> fetch(String kind) async {
    if (failing) throw Exception('offline');
    return store[kind];
  }

  @override
  Future<void> push(String kind, Object data) async {
    if (failing) throw Exception('offline');
    pushes++;
    store[kind] = data;
  }
}

class MemoryDirtyFlags implements DirtyFlagStore {
  final flags = <String, bool>{};

  @override
  Future<bool> isDirty(String kind) async => flags[kind] ?? false;

  @override
  Future<void> setDirty(String kind, bool value) async => flags[kind] = value;
}

void main() {
  late FakeRemote remote;
  late MemoryDirtyFlags dirty;
  late List<String> local;
  late OfflineFirstRepository<List<String>> repo;

  setUp(() {
    remote = FakeRemote();
    dirty = MemoryDirtyFlags();
    local = ['a'];
    repo = OfflineFirstRepository<List<String>>(
      kind: 'test',
      readLocal: () async => local,
      writeLocal: (value) async => local = value,
      empty: () => const [],
      encode: (value) => value,
      decode: (data) => List<String>.from(data as List),
      remote: remote,
      dirtyFlags: dirty,
    );
  });

  test('signed out: loads from the device and never touches the cloud', () async {
    remote.available = false;

    final result = await repo.loadResult();
    await repo.save(['b']);

    expect(result, isA<Success<List<String>>>());
    expect((result as Success<List<String>>).isFromCache, isTrue);
    expect(local, ['b']);
    expect(remote.pushes, 0);
    expect(await dirty.isDirty('test'), isFalse);
  });

  test('first sign-in with an empty cloud uploads the device data', () async {
    final result = await repo.loadResult();

    expect((result as Success<List<String>>).value, ['a']);
    expect(remote.store['test'], ['a']);
  });

  test('the cloud wins when the device has nothing waiting', () async {
    remote.store['test'] = ['from-cloud'];

    final result = await repo.loadResult();

    expect((result as Success<List<String>>).value, ['from-cloud']);
    expect(local, ['from-cloud']); // the device copy is refreshed too
  });

  test('offline: load falls back to the device copy', () async {
    remote.failing = true;

    final result = await repo.loadResult() as Success<List<String>>;

    expect(result.value, ['a']);
    expect(result.isFromCache, isTrue);
  });

  test('a failed upload is remembered and retried later', () async {
    remote.failing = true;
    await repo.save(['x']);
    await repo.whenIdle();

    expect(await dirty.isDirty('test'), isTrue);
    expect(remote.store, isEmpty);

    remote.failing = false; // internet is back
    await repo.syncPending();

    expect(remote.store['test'], ['x']);
    expect(await dirty.isDirty('test'), isFalse);
  });

  test('device changes that were never uploaded win over the cloud', () async {
    remote.store['test'] = ['old-cloud'];
    dirty.flags['test'] = true;
    local = ['newer-local'];

    final result = await repo.loadResult() as Success<List<String>>;

    expect(result.value, ['newer-local']);
    expect(remote.store['test'], ['newer-local']);
    expect(await dirty.isDirty('test'), isFalse);
  });

  test('rapid saves upload in order, so the last one wins', () async {
    await repo.save(['1']);
    await repo.save(['2']);
    await repo.save(['3']);
    await repo.whenIdle();

    expect(remote.store['test'], ['3']);
    expect(await dirty.isDirty('test'), isFalse);
  });

  test('clearLocal empties the device and the dirty flag', () async {
    dirty.flags['test'] = true;

    await repo.clearLocal();

    expect(local, isEmpty);
    expect(await dirty.isDirty('test'), isFalse);
  });
}
