import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HapticService {
  const HapticService();

  /// A "lub-dub" heartbeat: a heavy thump, a short pause, a lighter thump.
  Future<void> heartbeat() async {
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.lightImpact();
  }
}

final hapticServiceProvider = Provider<HapticService>(
  (ref) => const HapticService(),
);
