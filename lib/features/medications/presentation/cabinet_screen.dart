import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/core/widgets/dashed_divider.dart';
import 'package:medipulse_medical/core/widgets/plaster_highlighter.dart';
import 'package:medipulse_medical/features/medications/domain/medication.dart';
import 'package:medipulse_medical/features/medications/presentation/medication_form_screen.dart';
import 'package:medipulse_medical/features/medications/presentation/providers/cabinet_providers.dart';
import 'package:medipulse_medical/features/medications/presentation/providers/medications_providers.dart';
import 'package:medipulse_medical/features/medications/presentation/widgets/cabinet_empty_state.dart';
import 'package:medipulse_medical/features/medications/presentation/widgets/cabinet_filter_tabs.dart';
import 'package:medipulse_medical/features/medications/presentation/widgets/medication_tile.dart';
import 'package:medipulse_medical/features/scanner/presentation/scanner_screen.dart';

class CabinetScreen extends ConsumerWidget {
  const CabinetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(visibleMedicationsProvider);
    final filter = ref.watch(cabinetFilterProvider);
    final counts = ref.watch(cabinetCountsProvider);

    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: null,
            tooltip: 'Scan a prescription',
            backgroundColor: AppColors.aqua,
            foregroundColor: AppColors.scrub,
            elevation: 0,
            onPressed: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute<void>(builder: (_) => const ScannerScreen()),
            ),
            child: const Icon(Icons.document_scanner_outlined),
          ),
          const SizedBox(height: AppSpacing.md),
          FloatingActionButton(
            heroTag: null,
            tooltip: 'Add medicine',
            backgroundColor: AppColors.plaster,
            foregroundColor: AppColors.scrub,
            elevation: 0,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.scrub, width: 1.5),
            ),
            onPressed: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute<void>(
                builder: (_) => const MedicationFormScreen(),
              ),
            ),
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('Your ', style: AppTextStyles.display),
                        const PlasterHighlight(text: 'cabinet'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              CabinetFilterTabs(
                selected: filter,
                counts: counts,
                onSelected: ref.read(cabinetFilterProvider.notifier).select,
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: switch (medications) {
                  AsyncData(:final value) => value.isEmpty
                      ? CabinetEmptyState(isFiltered: filter != CabinetFilter.all)
                      : _CabinetList(items: value),
                  AsyncError() => Center(
                      child: Text(
                        'Could not load your medicines.',
                        style: AppTextStyles.body.copyWith(color: AppColors.alert),
                      ),
                    ),
                  _ => const Center(child: CircularProgressIndicator()),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CabinetList extends ConsumerWidget {
  const _CabinetList({required this.items});

  final List<Medication> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 140), // room for the two buttons
      itemCount: items.length,
      separatorBuilder: (context, index) => const DashedDivider(),
      itemBuilder: (context, index) {
        final medication = items[index];

        return Dismissible(
          key: ValueKey(medication.id),
          direction: DismissDirection.endToStart,
          background: const _DeleteBackground(),
          onDismissed: (_) {
            final controller = ref.read(medicationsProvider.notifier);
            controller.remove(medication.id);

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('${medication.name} removed'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () => controller.addAll([medication]),
                  ),
                ),
              );
          },
          child: InkWell(
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute<void>(
                builder: (_) => MedicationFormScreen(medication: medication),
              ),
            ),
            child: MedicationTile(medication: medication),
          ),
        );
      },
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.alert,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: AppSpacing.xl),
          child: Icon(Icons.delete_outline, color: Colors.white),
        ),
      ),
    );
  }
}