import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:medipulse_medical/core/result/result.dart';

class TextRecognitionService {
  // Latin script covers English drug names. The model ships inside the app,
  // so it works offline from the very first launch.
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  Future<Result<String>> recognize(String imagePath) async {
    try {
      final input = InputImage.fromFilePath(imagePath);
      final result = await _recognizer.processImage(input);
      final text = result.text.trim();

      if (text.isEmpty) {
        return const Failure<String>(
          'No text found. Try a clearer photo in good light.',
        );
      }
      return Success<String>(text);
    } on Object catch (error) {
      return Failure<String>('Could not read the image.', cause: error);
    }
  }

  Future<void> dispose() => _recognizer.close();
}