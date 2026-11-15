import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/core/widgets/dashed_divider.dart';
import 'package:medipulse_medical/features/dashboard/presentation/providers/emergency_profile_provider.dart';
import 'package:medipulse_medical/features/profile/presentation/widgets/account_section.dart';
import 'package:medipulse_medical/features/profile/presentation/widgets/profile_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(emergencyProfileProvider).value;
    final name = profile?.fullName.trim() ?? '';
    final bloodType = profile?.bloodType ?? '?';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screen,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Text(name.isEmpty ? 'Your profile' : name, style: AppTextStyles.display),
            const SizedBox(height: AppSpacing.xs),
            Text(
              bloodType == '?' ? 'Blood type not set' : 'Blood type $bloodType',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: AppSpacing.xl),
            const DashedDivider(),
            ProfileTile(
              icon: Icons.medical_information_outlined,
              title: 'Medical ID',
              subtitle: 'Blood type, allergies and emergency contact',
              onTap: () => context.push('/medical-id'),
            ),
            const DashedDivider(),
            const AccountSection(),
            const DashedDivider(),
            ProfileTile(
              icon: Icons.info_outline,
              title: 'About MediPulse',
              subtitle: 'Version 1.0.0',
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'MediPulse',
                applicationVersion: '1.0.0',
                children: const [
                  Text(
                    'MediPulse helps you remember your medicines. '
                    'It does not give medical advice.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
