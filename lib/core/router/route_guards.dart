const splashPath = '/splash';
const onboardingPath = '/onboarding';
const homePath = '/home';

/// Decides where the app must go, given whether onboarding is finished.
/// Returns null to mean "stay where you are".
///
/// [onboardingDone] is null while we are still reading it from storage.
String? onboardingRedirect({
  required bool? onboardingDone,
  required String location,
}) {
  return switch (onboardingDone) {
    null => location == splashPath ? null : splashPath,
    false => location == onboardingPath ? null : onboardingPath,
    true when location == splashPath || location == onboardingPath => homePath,
    true => null,
  };
}
