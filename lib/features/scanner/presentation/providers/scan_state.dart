import 'package:medipulse_medical/features/scanner/domain/detected_medicine.dart';

sealed class ScanState {
  const ScanState();
}

final class ScanIdle extends ScanState {
  const ScanIdle();
}

final class ScanInProgress extends ScanState {
  const ScanInProgress();
}

final class ScanSuccess extends ScanState {
  const ScanSuccess({
    required this.rawText,
    required this.medicines,
    required this.selected,
  });

  final String rawText; // kept so we can show it and tune the parser
  final List<DetectedMedicine> medicines;
  final Set<int> selected; // indexes the user has ticked

  List<DetectedMedicine> get selectedMedicines => [
        for (var i = 0; i < medicines.length; i++)
          if (selected.contains(i)) medicines[i],
      ];
}

final class ScanFailure extends ScanState {
  const ScanFailure(this.message);

  final String message;
}