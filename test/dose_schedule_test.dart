import 'package:flutter_test/flutter_test.dart';
import 'package:medipulse_medical/features/medications/domain/dose_frequency.dart';
import 'package:medipulse_medical/features/medications/domain/dose_schedule.dart';
import 'package:medipulse_medical/features/medications/domain/medication.dart';
import 'package:medipulse_medical/features/medications/domain/medication_form.dart';

void main() {
  final day = DateTime(2026, 11, 12);

  Medication med(String name, DoseFrequency frequency, {bool active = true}) {
    return Medication(
      id: name,
      name: name,
      dosage: '500 mg',
      form: MedicationForm.tablet,
      frequency: frequency,
      isActive: active,
    );
  }

  test('twice daily gives doses at 08:00 and 20:00', () {
    final doses = buildDosesForDay([med('Panadol', DoseFrequency.twiceDaily)], day);

    expect(doses.map((d) => d.time.hour), [8, 20]);
  });

  test('finished medicines give no doses', () {
    final doses = buildDosesForDay(
      [med('Panadol', DoseFrequency.twiceDaily, active: false)],
      day,
    );

    expect(doses, isEmpty);
  });

  test('as-needed medicines give no doses', () {
    final doses = buildDosesForDay([med('Brufen', DoseFrequency.asNeeded)], day);

    expect(doses, isEmpty);
  });

  test('doses of different medicines are sorted by time', () {
    final doses = buildDosesForDay(
      [
        med('Evening', DoseFrequency.twiceDaily),
        med('Lunch', DoseFrequency.threeTimesDaily),
      ],
      day,
    );

    expect(doses.map((d) => d.time.hour), [8, 8, 14, 20, 20]);
    expect(doses.map((d) => d.time.isBefore(day)).contains(true), isFalse);
  });
}