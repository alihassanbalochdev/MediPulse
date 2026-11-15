import 'package:flutter_test/flutter_test.dart';
import 'package:medipulse_medical/core/router/route_guards.dart';

void main() {
  test('while loading, everything goes to the splash screen', () {
    expect(onboardingRedirect(onboardingDone: null, location: '/home'), splashPath);
    expect(onboardingRedirect(onboardingDone: null, location: splashPath), isNull);
  });

  test('a new user is sent to onboarding', () {
    expect(onboardingRedirect(onboardingDone: false, location: '/home'), onboardingPath);
    expect(onboardingRedirect(onboardingDone: false, location: splashPath), onboardingPath);
    expect(onboardingRedirect(onboardingDone: false, location: onboardingPath), isNull);
  });

  test('a returning user never sees splash or onboarding', () {
    expect(onboardingRedirect(onboardingDone: true, location: splashPath), homePath);
    expect(onboardingRedirect(onboardingDone: true, location: onboardingPath), homePath);
    expect(onboardingRedirect(onboardingDone: true, location: '/cabinet'), isNull);
  });
}
