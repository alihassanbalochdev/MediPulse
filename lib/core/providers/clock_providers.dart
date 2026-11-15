import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current time, refreshed every 30 seconds.
final clockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now());
});

/// Today at midnight. It only notifies listeners when the DAY changes,
/// so widgets that depend on it don't rebuild every 30 seconds.
final todayProvider = Provider<DateTime>((ref) {
  final now = ref.watch(clockProvider).value ?? DateTime.now();
  return DateTime(now.year, now.month, now.day);
});
