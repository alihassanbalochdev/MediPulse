import 'package:medipulse_medical/features/medications/domain/dose_frequency.dart';
import 'package:medipulse_medical/features/scanner/domain/detected_medicine.dart';

class PrescriptionParser {
  const PrescriptionParser();

  // Matches 500 mg, 10mg, 2.5 mg, 5 ml, 1000 IU, 0.5 %
  // (?![a-z]) stops "5 gm" or "2 gel" from matching a unit by accident
  static final _dosage = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*(mg|mcg|µg|g|ml|iu|%)(?![a-z])',
    caseSensitive: false,
  );

  // Strips "1." numbering and form words like Tab., Cap, Syp, Inj from the start
  static final _leadingNoise = RegExp(
    r'^\s*(?:\d+\s*[.)]\s*)?(?:(?:rx|tab|tabs|tablet|tablets|cap|caps|capsule|capsules|syp|syrup|inj|injection|susp|drops|cream)\b\.?\s*)*',
    caseSensitive: false,
  );

  // Morning-noon-night style, like 1-0-1. Not part of a longer number (dates).
  static final _dashPattern = RegExp(r'(?<!\d)(\d)\s*-\s*(\d)\s*-\s*(\d)(?!\d)');

  // Checked in order, so "twice daily" wins over plain "daily"
  static final List<(DoseFrequency, RegExp)> _frequencyRules = [
    (
      DoseFrequency.fourTimesDaily,
      RegExp(r'\b(qid|qds|four times|4 times|4x)\b'),
    ),
    (
      DoseFrequency.threeTimesDaily,
      RegExp(r'\b(tds|tid|three times|thrice|3 times|3x)\b'),
    ),
    (
      DoseFrequency.twiceDaily,
      RegExp(r'\b(bd|bid|twice|two times|2 times|2x)\b'),
    ),
    (
      DoseFrequency.asNeeded,
      RegExp(r'\b(sos|prn|as needed|when needed)\b'),
    ),
    (
      DoseFrequency.onceDaily,
      RegExp(r'\b(od|qd|once|daily|1 time|1x)\b'),
    ),
  ];

  List<DetectedMedicine> parse(String rawText) {
    final medicines = <DetectedMedicine>[];
    final seen = <String>{};

    for (final line in rawText.split('\n')) {
      final dosageMatch = _dosage.firstMatch(line);
      if (dosageMatch == null) continue; // no dose means not a medicine line

      final name = _cleanName(line.substring(0, dosageMatch.start));
      if (name == null) continue;

      final dosage = '${dosageMatch.group(1)} ${_unit(dosageMatch.group(2)!)}';

      // Skip the same medicine read twice (OCR sometimes repeats lines)
      if (!seen.add('${name.toLowerCase()}|$dosage')) continue;

      medicines.add(
        DetectedMedicine(
          name: name,
          dosage: dosage,
          frequency: _frequencyOf(line.substring(dosageMatch.end)),
        ),
      );
    }
    return medicines;
  }

  String _unit(String raw) => switch (raw.toLowerCase()) {
        'iu' => 'IU',
        final other => other,
      };

  String? _cleanName(String beforeDosage) {
    var name = beforeDosage.replaceFirst(_leadingNoise, '');
    name = name.replaceAll(RegExp(r'[^A-Za-z0-9\s\-/+]'), ' ');
    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();

    // A real drug name has letters. This drops "5 days" style leftovers.
    final letters = RegExp(r'[A-Za-z]').allMatches(name).length;
    if (letters < 3) return null;

    return name
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  DoseFrequency _frequencyOf(String textAfterDosage) {
    final text = textAfterDosage.toLowerCase();

    if (_dashPattern.firstMatch(text) case final match?) {
      var total = 0;
      for (var group = 1; group <= 3; group++) {
        total += int.parse(match.group(group)!);
      }
      return DoseFrequency.fromTimesPerDay(total);
    }

    for (final (frequency, rule) in _frequencyRules) {
      if (rule.hasMatch(text)) return frequency;
    }
    return DoseFrequency.unknown;
  }
}