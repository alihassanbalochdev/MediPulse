import 'package:medipulse_medical/features/medications/domain/dose_frequency.dart';
import 'package:medipulse_medical/features/medications/domain/medication.dart';

/// One dose that should be taken at one moment.
typedef ScheduledDose = ({Medication medication, DateTime time});

/// Default clock times for each frequency, as (hour, minute) records.
List<({int hour, int minute})> defaultTimesFor(DoseFrequency frequency) {
  return switch (frequency) {
    DoseFrequency.onceDaily => [(hour: 8, minute: 0)],
    DoseFrequency.twiceDaily => [(hour: 8, minute: 0), (hour: 20, minute: 0)],
    DoseFrequency.threeTimesDaily => [
        (hour: 8, minute: 0),
        (hour: 14, minute: 0),
        (hour: 20, minute: 0),
      ],
    DoseFrequency.fourTimesDaily => [
        (hour: 8, minute: 0),
        (hour: 12, minute: 0),
        (hour: 16, minute: 0),
        (hour: 20, minute: 0),
      ],
    // No fixed time, so no reminder
    DoseFrequency.asNeeded || DoseFrequency.unknown => [],
  };
}

/// Every dose of [day] for the active medicines, earliest first.
/// [day] is passed in (not read from the clock) so this is easy to test.
List<ScheduledDose> buildDosesForDay(List<Medication> medications, DateTime day) {
  final List<ScheduledDose> doses = [
    for (final medication in medications)
      if (medication.isActive)
        for (final t in defaultTimesFor(medication.frequency))
          (
            medication: medication,
            time: DateTime(day.year, day.month, day.day, t.hour, t.minute),
          ),
  ];

  doses.sort((a, b) => a.time.compareTo(b.time));
  return doses;
}