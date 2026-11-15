import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/core/providers/clock_providers.dart';
import 'package:medipulse_medical/features/medications/domain/dose_schedule.dart';
import 'package:medipulse_medical/features/medications/presentation/providers/medications_providers.dart';

/// Today's doses. Recomputes when the cabinet changes or the day changes.
final todaysDosesProvider = Provider<List<ScheduledDose>>((ref) {
  final medications = ref.watch(medicationsProvider).value ?? const [];
  final today = ref.watch(todayProvider);
  return buildDosesForDay(medications, today);
});
