import 'package:shared_preferences/shared_preferences.dart';

class OnboardingLocalSource {
  static const _key = 'onboarding_done_v1';

  Future<bool> isDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> markDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
