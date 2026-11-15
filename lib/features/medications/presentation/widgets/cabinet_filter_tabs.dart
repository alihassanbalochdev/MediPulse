import 'package:flutter/material.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/features/medications/presentation/providers/cabinet_providers.dart';

class CabinetFilterTabs extends StatelessWidget {
  const CabinetFilterTabs({
    super.key,
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  final CabinetFilter selected;
  final CabinetCounts counts;
  final ValueChanged<CabinetFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final filter in CabinetFilter.values)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xl),
            child: _Tab(
              label: '${filter.label} ${_countFor(filter)}',
              isSelected: filter == selected,
              onTap: () => onSelected(filter),
            ),
          ),
      ],
    );
  }

  int _countFor(CabinetFilter filter) => switch (filter) {
        CabinetFilter.all => counts.all,
        CabinetFilter.active => counts.active,
        CabinetFilter.finished => counts.finished,
      };
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.plaster : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: isSelected ? AppColors.scrub : AppColors.muted,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}