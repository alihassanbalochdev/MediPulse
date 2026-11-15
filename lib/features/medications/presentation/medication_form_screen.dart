import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/features/medications/domain/dose_frequency.dart';
import 'package:medipulse_medical/features/medications/domain/medication.dart';
import 'package:medipulse_medical/features/medications/domain/medication_form.dart';
import 'package:medipulse_medical/features/medications/presentation/providers/medications_providers.dart';
import 'package:medipulse_medical/features/medications/presentation/widgets/choice_chip_group.dart';

/// Add a medicine (medication == null) or edit an existing one.
class MedicationFormScreen extends ConsumerStatefulWidget {
  const MedicationFormScreen({super.key, this.medication});

  final Medication? medication;

  @override
  ConsumerState<MedicationFormScreen> createState() =>
      _MedicationFormScreenState();
}

class _MedicationFormScreenState extends ConsumerState<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _dosage;
  late final TextEditingController _stock;
  late MedicationForm _form;
  late DoseFrequency _frequency;
  late bool _isFinished;

  bool get _isEditing => widget.medication != null;

  @override
  void initState() {
    super.initState();
    final m = widget.medication;
    _name = TextEditingController(text: m?.name ?? '');
    _dosage = TextEditingController(text: m?.dosage ?? '');
    _stock = TextEditingController(text: m?.stockRemaining?.toString() ?? '');
    _form = m?.form ?? MedicationForm.tablet;
    _frequency = m?.frequency ?? DoseFrequency.onceDaily;
    _isFinished = !(m?.isActive ?? true);
  }

  @override
  void dispose() {
    _name.dispose();
    _dosage.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final medication = Medication(
      // keep the old id when editing, make a new one when adding
      id: widget.medication?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      dosage: _dosage.text.trim(),
      form: _form,
      frequency: _frequency,
      stockRemaining: int.tryParse(_stock.text.trim()), // empty -> null
      isActive: !_isFinished,
    );

    final saved =
        await ref.read(medicationsProvider.notifier).save(medication);

    if (!mounted) return; // the screen may have closed while we waited
    if (saved) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This medicine and dose is already in your cabinet.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit medicine' : 'Add medicine',
          style: AppTextStyles.title,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.screen,
            children: [
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Medicine name',
                  hintText: 'Panadol',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _dosage,
                decoration: const InputDecoration(
                  labelText: 'Dose',
                  hintText: '500 mg',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a dose' : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Type', style: AppTextStyles.caption),
              const SizedBox(height: AppSpacing.sm),
              ChoiceChipGroup<MedicationForm>(
                values: MedicationForm.values,
                selected: _form,
                labelOf: (f) => f.label,
                onSelected: (f) => setState(() => _form = f),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('How often', style: AppTextStyles.caption),
              const SizedBox(height: AppSpacing.sm),
              ChoiceChipGroup<DoseFrequency>(
                values: [
                  for (final f in DoseFrequency.values)
                    if (f != DoseFrequency.unknown) f,
                ],
                selected: _frequency,
                labelOf: (f) => f.label,
                onSelected: (f) => setState(() => _frequency = f),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextFormField(
                controller: _stock,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Pills left (optional)',
                  hintText: '30',
                ),
                validator: (v) {
                  final text = v?.trim() ?? '';
                  if (text.isEmpty) return null; // optional
                  final n = int.tryParse(text);
                  return (n == null || n < 0) ? 'Enter a whole number' : null;
                },
              ),
              if (_isEditing) ...[
                const SizedBox(height: AppSpacing.lg),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Course finished', style: AppTextStyles.body),
                  value: _isFinished,
                  onChanged: (v) => setState(() => _isFinished = v),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              FilledButton(
                onPressed: _save,
                child: Text(_isEditing ? 'Save changes' : 'Add to cabinet'),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}