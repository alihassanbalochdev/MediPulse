import 'dart:convert';

import 'package:medipulse_medical/features/medications/domain/medication.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicationsLocalSource {
  static const _key = 'medications_v1';

  Future<List<Medication>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const [];

    try {
      final items = jsonDecode(raw) as List<dynamic>;
      return [
        for (final item in items)
          ?_tryParse(item),
        ];
    } on Object {
      return const [];
    }
  }

  Future<void> saveAll(List<Medication> medications) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final m in medications) m.toJson()]),
    );
  }

  // One damaged record must not hide all the others
  Medication? _tryParse(Object? item) {
    try {
      return Medication.fromJson(item as Map<String, dynamic>);
    } on Object {
      return null;
    }
  }
}