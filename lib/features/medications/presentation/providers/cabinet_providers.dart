import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/features/medications/domain/medication.dart';
import 'package:medipulse_medical/features/medications/presentation/providers/medications_providers.dart';

enum CabinetFilter {
  all('All'),
  active('Active'),
  finished('Finished');

  const CabinetFilter(this.label);

  final String label;

  bool matches(Medication medication) => switch (this) {
        CabinetFilter.all => true,
        CabinetFilter.active => medication.isActive,
        CabinetFilter.finished => !medication.isActive,
      };
}

class CabinetFilterController extends Notifier<CabinetFilter> {
  @override
  CabinetFilter build() => CabinetFilter.all;

  void select(CabinetFilter filter) => state = filter;
}

final cabinetFilterProvider =
    NotifierProvider<CabinetFilterController, CabinetFilter>(
  CabinetFilterController.new,
);

/// The list the screen shows: all medicines, narrowed by the chosen tab.
final visibleMedicationsProvider = Provider<AsyncValue<List<Medication>>>((ref) {
  final filter = ref.watch(cabinetFilterProvider);
  return ref.watch(medicationsProvider).whenData(
        (all) => all.where(filter.matches).toList(),
      );
});

typedef CabinetCounts = ({int all, int active, int finished});

/// The numbers shown on the tabs, like "All 5".
final cabinetCountsProvider = Provider<CabinetCounts>((ref) {
  final all = ref.watch(medicationsProvider).value ?? const <Medication>[];
  final active = all.where((m) => m.isActive).length;
  return (all: all.length, active: active, finished: all.length - active);
});