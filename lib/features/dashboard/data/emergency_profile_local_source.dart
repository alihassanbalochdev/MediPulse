import 'dart:convert';
import 'package:medipulse_medical/features/dashboard/domain/emergency_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyProfileLocalSource {
  static const _key = 'emergency_profile_v1';

  /// Returns the saved profile, or an empty one for a new person.
  Future<EmergencyProfile> loadOrSeed() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw != null) {
      try {
        return EmergencyProfile.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } on Object {
        // Corrupted data: fall through and start fresh below
      }
    }

    await save(EmergencyProfile.empty);
    return EmergencyProfile.empty;
  }

  Future<void> save(EmergencyProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }
}
