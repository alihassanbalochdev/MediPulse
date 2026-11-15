import 'package:medipulse_medical/features/medications/domain/dose_log.dart';
import 'package:medipulse_medical/features/medications/domain/dose_schedule.dart';

enum DoseState { upcoming, due, taken, skipped, missed }

/// How long after its time a dose still counts as "due now" before "missed".
const doseGracePeriod = Duration(hours: 1);

/// A scheduled dose together with its log (if any) and its state.
typedef DoseEntry = ({ScheduledDose dose, DoseLog? log, DoseState state});

DoseState doseStateFor({
  required DateTime time,
  required DoseLog? log,
  required DateTime now,
}) {
  return switch (log?.status) {
    DoseLogStatus.taken => DoseState.taken,
    DoseLogStatus.skipped => DoseState.skipped,
    null when time.isAfter(now) => DoseState.upcoming,
    null when now.difference(time) <= doseGracePeriod => DoseState.due,
    null => DoseState.missed,
  };
}
