import 'package:flutter_test/flutter_test.dart';
import 'package:medipulse_medical/features/medications/domain/dose_frequency.dart';
import 'package:medipulse_medical/features/medications/domain/medication.dart';
import 'package:medipulse_medical/features/medications/domain/medication_form.dart';
import 'package:medipulse_medical/features/reminders/domain/reminder_plan.dart';

void main() {
  final panadol = Medication(
    id: '1',
    name: 'Panadol',
    dosage: '500 mg',
    form: MedicationForm.tablet,
    frequency: DoseFrequency.twiceDaily,
  );

  test('skips doses that already passed today', () {
    final now = DateTime(2026, 11, 12, 9, 0); // after 08:00, before 20:00
    final doses = upcomingDoses([panadol], now, days: 1);

    expect(doses.map((d) => d.time.hour), [20]);
  });

  test('covers several days in order', () {
    final now = DateTime(2026, 11, 12, 9, 0);
    final doses = upcomingDoses([panadol], now, days: 3);

    // 20:00 today, then 08:00 + 20:00 on each of the next two days
    expect(doses.length, 5);
    expect(doses.first.time, DateTime(2026, 11, 12, 20));
    expect(doses.last.time, DateTime(2026, 11, 14, 20));
  });

  test('rolls over the end of the month', () {
    final now = DateTime(2026, 11, 30, 21, 0);
    final doses = upcomingDoses([panadol], now, days: 2);

    expect(doses.first.time, DateTime(2026, 12, 1, 8));
  });
}