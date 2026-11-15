import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/features/dashboard/domain/tilt_flick_detector.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Emits 1, 2, 3 ... each time the phone is tilted rapidly.
/// autoDispose: the sensor only runs while a widget is listening.
final tiltFlipProvider = StreamProvider.autoDispose<int>((ref) async* {
  final detector = TiltFlickDetector();
  var flips = 0;

  await for (final event in accelerometerEventStream(
    samplingPeriod: SensorInterval.gameInterval, // about 50 readings per second
  )) {
    if (detector.addSample(event.timestamp, event.x)) {
      yield ++flips;
    }
  }
});