import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medipulse_medical/core/result/result.dart';
import 'package:medipulse_medical/core/sync/sync_config.dart';
import 'package:medipulse_medical/features/auth/presentation/providers/auth_providers.dart';
import 'package:medipulse_medical/features/profile/presentation/widgets/profile_tile.dart';
import 'package:medipulse_medical/features/sync/presentation/providers/sync_providers.dart';

/// Cloud backup: sign in, see the sync state, sign out.
class AccountSection extends ConsumerWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isSupabaseConfigured) {
      return const ProfileTile(
        icon: Icons.cloud_off_outlined,
        title: 'Cloud backup',
        subtitle: 'Not set up in this build',
      );
    }

    final user = ref.watch(authUserProvider).value;
    if (user == null) {
      return ProfileTile(
        icon: Icons.cloud_upload_outlined,
        title: 'Sign in',
        subtitle: 'Back up your data and use it on other devices',
        onTap: () => context.push('/sign-in'),
      );
    }

    final hasPending = ref.watch(hasPendingChangesProvider).value ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileTile(
          icon: Icons.cloud_done_outlined,
          title: user.email,
          subtitle: hasPending
              ? 'Changes waiting to sync'
              : 'All changes backed up',
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => ref.read(syncActionsProvider.notifier).syncNow(),
              child: const Text('Sync now'),
            ),
            TextButton(
              onPressed: () => _confirmSignOut(context, ref),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Your data stays safe in your account. '
          'This device will be cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await ref.read(syncActionsProvider.notifier).signOutSafely();
    if (!context.mounted) return;

    if (result case Failure(:final message)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
