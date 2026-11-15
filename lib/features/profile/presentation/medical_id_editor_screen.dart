import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/features/dashboard/domain/emergency_profile.dart';
import 'package:medipulse_medical/features/dashboard/presentation/providers/emergency_profile_provider.dart';
import 'package:medipulse_medical/features/medications/presentation/widgets/choice_chip_group.dart';

const _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', '?'];

class MedicalIdEditorScreen extends ConsumerStatefulWidget {
  const MedicalIdEditorScreen({super.key});

  @override
  ConsumerState<MedicalIdEditorScreen> createState() =>
      _MedicalIdEditorScreenState();
}

class _MedicalIdEditorScreenState extends ConsumerState<MedicalIdEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _allergies;
  late final TextEditingController _contactName;
  late final TextEditingController _contactRelation;
  late final TextEditingController _contactPhone;
  late String _bloodType;

  @override
  void initState() {
    super.initState();
    // The profile is already loaded by the time this screen opens
    final p = ref.read(emergencyProfileProvider).value ?? EmergencyProfile.empty;

    _name = TextEditingController(text: p.fullName);
    _age = TextEditingController(text: p.age > 0 ? '${p.age}' : '');
    _allergies = TextEditingController(text: p.allergies.join(', '));
    _contactName = TextEditingController(text: p.contactName);
    _contactRelation = TextEditingController(text: p.contactRelation);
    _contactPhone = TextEditingController(text: p.contactPhone);
    _bloodType = p.bloodType;
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _allergies.dispose();
    _contactName.dispose();
    _contactRelation.dispose();
    _contactPhone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = EmergencyProfile(
      fullName: _name.text.trim(),
      age: int.tryParse(_age.text.trim()) ?? 0,
      bloodType: _bloodType,
      allergies: [
        for (final item in _allergies.text.split(','))
          if (item.trim().isNotEmpty) item.trim(),
      ],
      prescriptions: const [], // filled in from the cabinet when shown
      contactName: _contactName.text.trim(),
      contactRelation: _contactRelation.text.trim(),
      contactPhone: _contactPhone.text.trim(),
    );

    await ref.read(emergencyProfileProvider.notifier).save(profile);

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medical ID', style: AppTextStyles.title)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.screen,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Shown on your emergency card, even offline. '
                'Your active medicines are added automatically.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSpacing.xl),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _age,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age (optional)'),
                validator: (v) {
                  final text = v?.trim() ?? '';
                  if (text.isEmpty) return null;
                  final n = int.tryParse(text);
                  return (n == null || n < 0 || n > 120) ? 'Enter a valid age' : null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Blood type', style: AppTextStyles.caption),
              const SizedBox(height: AppSpacing.sm),
              ChoiceChipGroup<String>(
                values: _bloodTypes,
                selected: _bloodType,
                labelOf: (t) => t == '?' ? 'Unknown' : t,
                onSelected: (t) => setState(() => _bloodType = t),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextFormField(
                controller: _allergies,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Severe allergies',
                  hintText: 'Penicillin, Peanuts',
                  helperText: 'Separate with commas',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Emergency contact', style: AppTextStyles.caption),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _contactName,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _contactRelation,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Relation',
                  hintText: 'Father',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _contactPhone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: AppSpacing.xxl),
              FilledButton(onPressed: _save, child: const Text('Save Medical ID')),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
