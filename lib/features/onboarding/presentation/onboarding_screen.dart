import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/features/dashboard/presentation/providers/emergency_profile_provider.dart';
import 'package:medipulse_medical/features/onboarding/presentation/providers/onboarding_providers.dart';

typedef _IntroPage = ({IconData icon, String title, String body});

const _pages = <_IntroPage>[
  (
    icon: Icons.alarm,
    title: 'Never miss a dose',
    body: 'Smart reminders that work offline, even without internet.',
  ),
  (
    icon: Icons.document_scanner_outlined,
    title: 'Scan your prescription',
    body: 'Point your camera at a prescription and MediPulse reads the medicines for you.',
  ),
  (
    icon: Icons.medical_information_outlined,
    title: 'Your Medical ID, always ready',
    body: 'Blood type and allergies on one card for emergencies. Tilt your phone quickly to show it.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _name = TextEditingController();
  int _page = 0;

  bool get _isLast => _page == _pages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (!_isLast) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    final name = _name.text.trim();
    if (name.isNotEmpty) {
      final profile = await ref.read(emergencyProfileProvider.future);
      await ref
          .read(emergencyProfileProvider.notifier)
          .save(profile.copyWith(fullName: name));
    }
    // The router sees this change and moves to Home on its own
    await ref.read(onboardingProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screen,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) => setState(() => _page = index),
                  itemBuilder: (context, index) => _IntroPageView(
                    page: _pages[index],
                    nameField: index == _pages.length - 1
                        ? TextField(
                            controller: _name,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'What should we call you? (optional)',
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _pages.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page ? AppColors.scrub : AppColors.aqua,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(_isLast ? 'Get started' : 'Next'),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroPageView extends StatelessWidget {
  const _IntroPageView({required this.page, this.nameField});

  final _IntroPage page;
  final Widget? nameField;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl),
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.aqua,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Icon(page.icon, size: 64, color: AppColors.scrub),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.display,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
          if (nameField case final field?) ...[
            const SizedBox(height: AppSpacing.xl),
            field,
          ],
        ],
      ),
    );
  }
}
