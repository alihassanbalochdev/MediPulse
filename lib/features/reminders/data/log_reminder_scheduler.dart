import 'package:flutter/foundation.dart';
import 'package:medipulse_medical/features/medications/domain/dose_schedule.dart';
import 'package:medipulse_medical/features/reminders/domain/reminder_scheduler.dart';

/// For Chrome and tests: prints the reminders instead of scheduling them.
class LogReminderScheduler implements ReminderScheduler {
  const LogReminderScheduler();

  @override
  Future<void> replaceAll(List<ScheduledDose> doses) async {
    debugPrint('--- Reminders (${doses.length}) ---');
    for (final (:medication, :time) in doses) {
      debugPrint('${time.toIso8601String()}  ${medication.name} ${medication.dosage}');
    }
  }
}