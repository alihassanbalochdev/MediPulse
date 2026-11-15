import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/core/result/result.dart';
import 'package:medipulse_medical/features/medications/domain/medication.dart';
import 'package:medipulse_medical/features/medications/domain/medication_form.dart';
import 'package:medipulse_medical/features/medications/presentation/providers/medications_providers.dart';
import 'package:medipulse_medical/features/scanner/data/prescription_image_picker.dart';
import 'package:medipulse_medical/features/scanner/data/text_recognition_service.dart';
import 'package:medipulse_medical/features/scanner/domain/prescription_parser.dart';
import 'package:medipulse_medical/features/scanner/presentation/providers/scan_state.dart';

final textRecognitionServiceProvider = Provider<TextRecognitionService>((ref) {
  final service = TextRecognitionService();
  ref.onDispose(service.dispose);
  return service;
});

final prescriptionImagePickerProvider = Provider<PrescriptionImagePicker>(
  (ref) => PrescriptionImagePicker(),
);

final prescriptionParserProvider = Provider<PrescriptionParser>(
  (ref) => const PrescriptionParser(),
);

class ScanController extends Notifier<ScanState> {
  @override
  ScanState build() => const ScanIdle();

  Future<void> scan(PrescriptionImageSource source) async {
    state = const ScanInProgress();

    try {
      final path = await ref.read(prescriptionImagePickerProvider).pick(source);
      if (path == null) {
        state = const ScanIdle(); // the user backed out of the camera
        return;
      }

      final result =
          await ref.read(textRecognitionServiceProvider).recognize(path);

      state = switch (result) {
        Success(:final value) => _toSuccess(value),
        Failure(:final message) => ScanFailure(message),
      };
    } on Object {
      state = const ScanFailure('Could not open the camera or gallery.');
    }
  }

  ScanState _toSuccess(String rawText) {
    final medicines = ref.read(prescriptionParserProvider).parse(rawText);
    return ScanSuccess(
      rawText: rawText,
      medicines: medicines,
      selected: {for (var i = 0; i < medicines.length; i++) i}, // all ticked
    );
  }

  void toggle(int index) {
    if (state case final ScanSuccess current) {
      final next = {...current.selected};
      if (!next.remove(index)) next.add(index);

      state = ScanSuccess(
        rawText: current.rawText,
        medicines: current.medicines,
        selected: next,
      );
    }
  }

  /// Saves the ticked medicines into the cabinet.
  /// Returns how many were new (already-saved ones are skipped).
  Future<int> addSelectedToCabinet() async {
    final current = state;
    if (current is! ScanSuccess) return 0;

    final stamp = DateTime.now().microsecondsSinceEpoch;
    final medications = [
      for (final (index, detected) in current.selectedMedicines.indexed)
        Medication(
          id: '$stamp-$index',
          name: detected.name,
          dosage: detected.dosage,
          form: MedicationForm.tablet, // the scanner can't tell the form yet
          frequency: detected.frequency,
        ),
    ];

    final added =
        await ref.read(medicationsProvider.notifier).addAll(medications);
    state = const ScanIdle();
    return added;
  }

  void reset() => state = const ScanIdle();
}

final scanControllerProvider =
    NotifierProvider<ScanController, ScanState>(ScanController.new);