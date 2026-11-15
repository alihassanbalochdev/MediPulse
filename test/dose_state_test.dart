import 'package:flutter_test/flutter_test.dart';
import 'package:medipulse_medical/features/medications/domain/dose_log.dart';
import 'package:medipulse_medical/features/medications/domain/dose_state.dart';

void main() {
  final time = DateTime(2026, 11, 14, 8);

  DoseLog log(DoseLogStatus status) => DoseLog(
        medicationId: '1',
        medicationName: 'Panadol',
        dosage: '500 mg',
        scheduledAt: time,
        status: status,
        loggedAt: time,
      );

  test('before the time it is upcoming', () {
    expect(
      doseStateFor(time: time, log: null, now: time.subtract(const Duration(minutes: 5))),
      DoseState.upcoming,
    );
  });

  test('up to an hour late it is due', () {
    expect(
      doseStateFor(time: time, log: null, now: time.add(const Duration(minutes: 30))),
      DoseState.due,
    );
  });

  test('after the grace hour it is missed', () {
    expect(
      doseStateFor(time: time, log: null, now: time.add(const Duration(hours: 2))),
      DoseState.missed,
    );
  });

  test('a log decides the state, whatever the time', () {
    final now = time.add(const Duration(hours: 5));
    expect(doseStateFor(time: time, log: log(DoseLogStatus.taken), now: now), DoseState.taken);
    expect(doseStateFor(time: time, log: log(DoseLogStatus.skipped), now: now), DoseState.skipped);
  });
}
