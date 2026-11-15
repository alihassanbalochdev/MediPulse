import 'package:medipulse_medical/features/medications/domain/dose_frequency.dart';

class DetectedMedicine {
  const DetectedMedicine({
    required this.name,
    required this.dosage,
    required this.frequency,
  });

  final String name;
  final String dosage; // like '500 mg'
  final DoseFrequency frequency;
}