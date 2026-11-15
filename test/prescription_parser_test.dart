import 'package:flutter_test/flutter_test.dart';
import 'package:medipulse_medical/features/medications/domain/dose_frequency.dart';
import 'package:medipulse_medical/features/scanner/domain/prescription_parser.dart';

void main() {
  const parser = PrescriptionParser();

  test('reads name, dose and frequency from a typical line', () {
    final result = parser.parse('1. Tab. METFORMIN 500mg BD x 30 days');

    expect(result, hasLength(1));
    expect(result.first.name, 'Metformin');
    expect(result.first.dosage, '500 mg');
    expect(result.first.frequency, DoseFrequency.twiceDaily);
  });

  test('reads the 1-0-1 style as twice a day', () {
    final result = parser.parse('Cap Amoxicillin 250 mg 1-0-1');

    expect(result.first.name, 'Amoxicillin');
    expect(result.first.frequency, DoseFrequency.twiceDaily);
  });

  test('keeps IU uppercase and reads once daily', () {
    final result = parser.parse('Syp Vitamin D 1000 IU once daily');

    expect(result.first.name, 'Vitamin D');
    expect(result.first.dosage, '1000 IU');
    expect(result.first.frequency, DoseFrequency.onceDaily);
  });

  test('ignores header lines with no dose', () {
    expect(parser.parse('Patient: Ali Hassan\nAge 24 years'), isEmpty);
  });
}