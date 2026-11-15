import 'package:image_picker/image_picker.dart';

enum PrescriptionImageSource { camera, gallery }

class PrescriptionImagePicker {
  PrescriptionImagePicker([ImagePicker? picker])
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Returns the image path, or null if the user cancelled.
  Future<String?> pick(PrescriptionImageSource source) async {
    final file = await _picker.pickImage(
      source: switch (source) {
        PrescriptionImageSource.camera => ImageSource.camera,
        PrescriptionImageSource.gallery => ImageSource.gallery,
      },
    );
    return file?.path;
  }
}