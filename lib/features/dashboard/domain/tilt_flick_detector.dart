import 'dart:collection';
import 'dart:math' as math;

class TiltFlickDetector {
  TiltFlickDetector({
    this.swingThreshold = 7.0,
    this.window = const Duration(milliseconds: 350),
    this.cooldown = const Duration(milliseconds: 1200),
  });

  final double swingThreshold; // m/s^2 the x-axis must swing by
  final Duration window; // how fast the swing must happen
  final Duration cooldown; // ignore new flicks right after one

  // Dart 3 record as a tiny sample type: no class needed
  final Queue<({DateTime time, double x})> _samples = Queue();
  DateTime? _lastFlick;

  /// Feed one sensor reading. Returns true when a rapid tilt is detected.
  bool addSample(DateTime time, double x) {
    _samples.addLast((time: time, x: x));

    // Drop samples older than the window. The newest sample has age 0,
    // so the queue can never become empty here.
    while (time.difference(_samples.first.time) > window) {
      _samples.removeFirst();
    }

    final lastFlick = _lastFlick;
    if (lastFlick != null && time.difference(lastFlick) < cooldown) {
      return false;
    }

    final xs = _samples.map((s) => s.x);
    final swing = xs.reduce(math.max) - xs.reduce(math.min);
    if (swing < swingThreshold) return false;

    _lastFlick = time;
    _samples.clear();
    return true;
  }
}