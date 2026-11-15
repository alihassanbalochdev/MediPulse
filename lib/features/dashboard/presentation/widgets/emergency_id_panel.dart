import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/features/dashboard/presentation/providers/emergency_profile_provider.dart';
import 'package:medipulse_medical/features/dashboard/presentation/widgets/emergency_id_card.dart';

class EmergencyIdPanel extends ConsumerWidget {
  const EmergencyIdPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(emergencyCardProfileProvider);

    // Dart 3 switch with object patterns: one branch per state
    return switch (profile) {
      AsyncData(:final value) => EmergencyIdCard(profile: value),
      AsyncError() => EmergencyCardFrame(
          child: Center(
            child: Text(
              'Medical ID could not be loaded',
              style: AppTextStyles.body.copyWith(color: AppColors.emergency),
            ),
          ),
        ),
      _ => const EmergencyCardFrame(
          child: Center(child: CircularProgressIndicator()),
        ),
    };
  }
}