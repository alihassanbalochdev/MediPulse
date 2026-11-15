import 'package:flutter/material.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/core/widgets/plaster_highlighter.dart';
import 'package:medipulse_medical/features/scanner/presentation/providers/scan_state.dart';

class ScanResultsSheet extends StatelessWidget {
  const ScanResultsSheet({
    super.key,
    required this.state,
    required this.onToggle,
    required this.onAdd,
    required this.onClose,
  });

  final ScanSuccess state;
  final ValueChanged<int> onToggle;
  final VoidCallback onAdd;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final count = state.medicines.length;
    final selectedCount = state.selected.length;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.65;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.paper,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _Title(count: count)),
                      IconButton(
                        onPressed: onClose,
                        tooltip: 'Close',
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        if (count == 0)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: Text(
                              'The text was read, but no doses like '
                              '"500 mg" were found. Try a clearer photo.',
                              style: AppTextStyles.body,
                            ),
                          ),
                        for (final (index, medicine) in state.medicines.indexed)
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: state.selected.contains(index),
                            onChanged: (_) => onToggle(index),
                            title: Text(
                              medicine.name,
                              style: AppTextStyles.itemName,
                            ),
                            subtitle: Text(
                              '${medicine.dosage} · ${medicine.frequency.label}',
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          shape: const Border(),
                          collapsedShape: const Border(),
                          title: Text(
                            'Recognised text',
                            style: AppTextStyles.caption,
                          ),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: SelectableText(
                                state.rawText,
                                style: AppTextStyles.caption,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    // With nothing found, the button just closes the sheet
                    onPressed: count == 0
                        ? onClose
                        : (selectedCount == 0 ? null : onAdd),
                    child: Text(
                      count == 0
                          ? 'Scan again'
                          : 'Add $selectedCount to my cabinet',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return Text('No medicines found', style: AppTextStyles.title);
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Found ', style: AppTextStyles.title),
        PlasterHighlight(
          text: count == 1 ? '1 medicine' : '$count medicines',
          style: AppTextStyles.title,
        ),
      ],
    );
  }
}