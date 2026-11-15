import 'dart:convert';

import 'package:medipulse_medical/features/medications/domain/dose_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoseLogsLocalSource {
  static const _key = 'dose_logs_v1';

  Future<List<DoseLog>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final items = jsonDecode(raw) as List<dynamic>;
    return [
      for (final item in items) DoseLog.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<void> saveAll(List<DoseLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final log in logs) log.toJson()]),
    );
  }
}
