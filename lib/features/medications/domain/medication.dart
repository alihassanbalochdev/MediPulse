import 'package:medipulse_medical/features/medications/domain/dose_frequency.dart';
import 'package:medipulse_medical/features/medications/domain/medication_form.dart';

class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.form,
    required this.frequency,
    this.stockRemaining,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String dosage; // like '500 mg'
  final MedicationForm form;
  final DoseFrequency frequency;
  final int? stockRemaining; // null means we don't track stock
  final bool isActive;

  bool get isLowStock => switch (stockRemaining) {
        final stock? => stock <= 5,
        null => false,
      };

  // Same name + dose means the same medicine, even if typed in a different case
  String get duplicateKey => '${name.toLowerCase()}|$dosage';

  Medication copyWith({
    String? name,
    String? dosage,
    MedicationForm? form,
    DoseFrequency? frequency,
    int? stockRemaining,
    bool? isActive,
  }) {
    return Medication(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      form: form ?? this.form,
      frequency: frequency ?? this.frequency,
      stockRemaining: stockRemaining ?? this.stockRemaining,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      form: MedicationForm.values.byName(json['form'] as String),
      frequency: DoseFrequency.values.byName(json['frequency'] as String),
      stockRemaining: (json['stockRemaining'] as num?)?.toInt(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'form': form.name,
        'frequency': frequency.name,
        'stockRemaining': stockRemaining,
        'isActive': isActive,
      };
}