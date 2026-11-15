import 'package:flutter/material.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/features/dashboard/domain/emergency_profile.dart';

/// The red outline and white background, shared by every state of the card.
class EmergencyCardFrame extends StatelessWidget {
  const EmergencyCardFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.emergency, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card - 2),
        child: child,
      ),
    );
  }
}

class EmergencyIdCard extends StatelessWidget {
  const EmergencyIdCard({super.key, required this.profile});

  final EmergencyProfile profile;

  @override
  Widget build(BuildContext context) {
    return EmergencyCardFrame(
      child: Column(
        children: [
          _Header(name: profile.fullName, age: profile.age),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _Details(profile: profile),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.age});

  final String name;
  final int age;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.emergency,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'In case of emergency',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.emergencySoft),
              ),
              Text(
                name.isEmpty ? 'Name not set' : name,
                style: AppTextStyles.display.copyWith(color: Colors.white),
              ),
              Text(
                age > 0 ? 'Age $age' : 'Add your details in Profile',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.emergencySoft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.profile});

  final EmergencyProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BloodType(profile: profile),
        _Section(
          label: 'Severe allergies',
          child: profile.allergies.isEmpty
              ? const _BodyText('None recorded')
              : Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final allergy in profile.allergies)
                      _AllergyChip(label: allergy),
                  ],
                ),
        ),
        _Section(
          label: 'Taking now',
          child: profile.prescriptions.isEmpty
              ? const _BodyText('None recorded')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final rx in profile.prescriptions) _BodyText(rx),
                  ],
                ),
        ),
        _Section(label: 'Call', child: _ContactRow(profile: profile)),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Text(
            'Read from offline storage · tap to flip back',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.emergencyMuted),
          ),
        ),
      ],
    );
  }
}

class _BloodType extends StatelessWidget {
  const _BloodType({required this.profile});

  final EmergencyProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.emergency,
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: 80,
            height: 80,
            child: Center(
              child: Text(
                profile.bloodType,
                style: AppTextStyles.display
                    .copyWith(color: Colors.white, fontSize: 34),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Blood type',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.emergencyMuted),
            ),
            Text(
              profile.bloodTypeSpoken,
              style: AppTextStyles.title
                  .copyWith(color: AppColors.emergencyInk, fontSize: 24),
            ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.emergency,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _AllergyChip extends StatelessWidget {
  const _AllergyChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.emergencyTint,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 5,
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.emergencyDeep,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(color: AppColors.emergencyInk),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.profile});

  final EmergencyProfile profile;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.emergency, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.contactName.isEmpty
                        ? 'No emergency contact set'
                        : profile.contactName,
                    style: AppTextStyles.itemName
                        .copyWith(color: AppColors.emergencyInk),
                  ),
                  Text(
                    profile.contactName.isEmpty
                        ? 'Add one in Profile'
                        : '${profile.contactRelation} · ${profile.contactPhone}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.emergencyMuted),
                  ),
                ],
              ),
            ),
            // Icon only for now. Real calling (url_launcher) comes later.
            const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.emergency,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.phone, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}