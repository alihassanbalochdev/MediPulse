import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/features/medications/domain/dose_log.dart';
import 'package:medipulse_medical/features/medications/presentation/providers/dose_logs_providers.dart';
import 'package:medipulse_medical/features/medications/presentation/providers/medications_providers.dart';
import 'package:medipulse_medical/features/reminders/data/local_notifications_scheduler.dart';
import 'package:medipulse_medical/features/reminders/data/log_reminder_scheduler.dart';
import 'package:medipulse_medical/features/reminders/domain/reminder_plan.dart';
import 'package:medipulse_medical/features/reminders/domain/reminder_scheduler.dart';

/// Chrome prints, phones schedule real alarms.
final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => kIsWeb ? const LogReminderScheduler() : LocalNotificationsScheduler(),
);

/// Keeps reminders in step with the cabinet AND the dose log.
/// Watched once, from the app root.
final reminderSyncProvider = Provider<void>((ref) {
  final scheduler = ref.watch(reminderSchedulerProvider);

  void resync() {
    final medications = ref.read(medicationsProvider).value;
    final logs = ref.read(doseLogsProvider).value;
    if (medications == null || logs == null) return; // still loading

    final logged = {for (final DoseLog log in logs) log.key};
    final doses = [
      for (final dose in upcomingDoses(medications, DateTime.now()))
        if (!logged.contains(doseKey(dose.medication.id, dose.time))) dose,
    ];

    scheduler.replaceAll(doses);
  }

  ref.listen(medicationsProvider, (previous, next) => resync());
  ref.listen(doseLogsProvider, (previous, next) => resync());
  resync();
});
