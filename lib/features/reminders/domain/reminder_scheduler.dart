import 'package:medipulse_medical/features/medications/domain/dose_schedule.dart';

/// Anything that can turn doses into reminders.
abstract interface class ReminderScheduler {
  /// Cancels every old reminder and sets reminders for [doses].
  Future<void> replaceAll(List<ScheduledDose> doses);
}