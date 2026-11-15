import 'package:flutter_test/flutter_test.dart';
import 'package:medipulse_medical/core/utils/date_labels.dart';

void main() {
  test('dateLabel writes weekday, day and month', () {
    // 14 November 2026 is a Saturday
    expect(dateLabel(DateTime(2026, 11, 14)), 'Saturday, 14 November');
  });

  test('greetingFor follows the hour of the day', () {
    expect(greetingFor(DateTime(2026, 11, 14, 8)), 'Good morning,');
    expect(greetingFor(DateTime(2026, 11, 14, 14)), 'Good afternoon,');
    expect(greetingFor(DateTime(2026, 11, 14, 20)), 'Good evening,');
  });
}
