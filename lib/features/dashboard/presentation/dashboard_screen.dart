import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/core/providers/clock_providers.dart';
import 'package:medipulse_medical/core/services/haptic_service.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/core/utils/date_labels.dart';
import 'package:medipulse_medical/core/widgets/plaster_highlighter.dart';
import 'package:medipulse_medical/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:medipulse_medical/features/dashboard/presentation/providers/emergency_profile_provider.dart';
import 'package:medipulse_medical/features/dashboard/presentation/widgets/all_done_hero_card.dart';
import 'package:medipulse_medical/features/dashboard/presentation/widgets/emergency_id_panel.dart';
import 'package:medipulse_medical/features/dashboard/presentation/widgets/flippable_dashboard.dart';
import 'package:medipulse_medical/features/dashboard/presentation/widgets/next_dose_hero_card.dart';
import 'package:medipulse_medical/features/medications/domain/dose_log.dart';
import 'package:medipulse_medical/features/medications/domain/dose_state.dart';
import 'package:medipulse_medical/features/medications/presentation/providers/dose_logs_providers.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screen.copyWith(
            top: AppSpacing.lg,
            bottom: AppSpacing.lg,
          ),
          child: FlippableDashboard(
            frontBuilder: (context, flip) => _DashboardFront(onFlip: flip),
            back: const EmergencyIdPanel(),
          ),
        ),
      ),
    );
  }
}

class _DashboardFront extends ConsumerWidget {
  const _DashboardFront({required this.onFlip});

  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final (:next, :taken, :total) = ref.watch(dashboardSummaryProvider);

    final fullName = ref.watch(emergencyProfileProvider).value?.fullName.trim() ?? '';
    final firstName = fullName.isEmpty ? 'there' : fullName.split(' ').first;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateLabel(now), style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.xs),
          Text(greetingFor(now), style: AppTextStyles.display),
          PlasterHighlight(text: firstName),
          const SizedBox(height: AppSpacing.md),
          if (next == null)
            AllDoneHeroCard(
              message: total == 0 ? 'Nothing scheduled today' : 'All caught up',
            )
          else
            // Long-press anywhere on the card logs the dose, no tiny buttons
            GestureDetector(
              onLongPress: () => _logDose(context, ref, next),
              child: NextDoseHeroCard(
                dose: (
                  name: next.dose.medication.name,
                  dosage: next.dose.medication.dosage,
                  time: next.dose.time,
                ),
                remaining: next.dose.time.difference(now),
                onLogDose: () => _logDose(context, ref, next),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Text(
            total == 0
                ? 'Add a medicine to see your doses here'
                : '$taken of $total doses taken today'
                    '${next != null ? ' · hold the card to log' : ''}',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: TextButton.icon(
              onPressed: onFlip,
              icon: const Icon(Icons.medical_information_outlined),
              label: const Text('Show Medical ID'),
            ),
          ),
          Center(
            child: Text('Or tilt your phone quickly', style: AppTextStyles.caption),
          ),
        ],
      ),
    );
  }
}

void _logDose(BuildContext context, WidgetRef ref, DoseEntry entry) {
  ref.read(hapticServiceProvider).heartbeat(); // lub-dub
  final controller = ref.read(doseLogsProvider.notifier);
  controller.mark(entry.dose, DoseLogStatus.taken);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('${entry.dose.medication.name} logged'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => controller.clear(entry.dose),
        ),
      ),
    );
}
