import 'package:medipulse_medical/features/medications/domain/dose_schedule.dart';
import 'package:medipulse_medical/features/medications/domain/medication.dart';

/// Doses that are still in the future, for the next [days] days (today included).
List<ScheduledDose> upcomingDoses(
  List<Medication> medications,
  DateTime now, {
  int days = 3,
}) {
  return [
    for (var i = 0; i < days; i++)
      // DateTime(y, m, d + i) rolls over month ends by itself
      for (final dose in buildDosesForDay(
        medications,
        DateTime(now.year, now.month, now.day + i),
      ))
        if (dose.time.isAfter(now)) dose,
  ];
}