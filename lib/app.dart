import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/core/router/app_router.dart';
import 'package:medipulse_medical/core/theme/app_theme.dart';
import 'package:medipulse_medical/features/reminders/presentation/providers/reminder_providers.dart';
import 'package:medipulse_medical/features/sync/presentation/providers/sync_providers.dart';

class MediPulseApp extends ConsumerWidget {
  const MediPulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(reminderSyncProvider); // keeps reminders up to date
    ref.watch(syncCoordinatorProvider); // keeps the cloud copy up to date

    return MaterialApp.router(
      title: 'MediPulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
