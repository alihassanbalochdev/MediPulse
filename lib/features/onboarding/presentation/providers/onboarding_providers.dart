import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/features/onboarding/data/onboarding_local_source.dart';

final onboardingSourceProvider = Provider<OnboardingLocalSource>(
  (ref) => OnboardingLocalSource(),
);

/// true once the person has finished the intro.
class OnboardingController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    // Reading the flag takes a few milliseconds. Wait at least 1.2 s so the
    // splash is actually seen instead of flashing past.
    final (isDone, _) = await (
      ref.read(onboardingSourceProvider).isDone(),
      Future<void>.delayed(const Duration(milliseconds: 1200)),
    ).wait;
    return isDone;
  }

  Future<void> complete() async {
    await ref.read(onboardingSourceProvider).markDone();
    state = const AsyncData(true); // the router reacts to this by itself
  }
}

final onboardingProvider =
    AsyncNotifierProvider<OnboardingController, bool>(OnboardingController.new);
