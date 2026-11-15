import 'package:shared_preferences/shared_preferences.dart';

/// Remembers which kinds of data have changes that were not uploaded yet.
abstract interface class DirtyFlagStore {
  Future<bool> isDirty(String kind);
  Future<void> setDirty(String kind, bool value);
}

class PrefsDirtyFlagStore implements DirtyFlagStore {
  String _key(String kind) => 'sync_dirty_$kind';

  @override
  Future<bool> isDirty(String kind) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(kind)) ?? false;
  }

  @override
  Future<void> setDirty(String kind, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(kind), value);
  }
}
