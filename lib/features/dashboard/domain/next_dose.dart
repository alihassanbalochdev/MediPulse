// A Dart 3 record type: a small data bundle with named fields, no class needed
typedef NextDose = ({String name, String dosage, DateTime time});

extension DateTimeClock on DateTime {
  // Returns a record: ('8:30', 'PM')
  ({String time, String period}) get clock12 {
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final minuteText = minute.toString().padLeft(2, '0');
    return (time: '$hour12:$minuteText', period: hour < 12 ? 'AM' : 'PM');
  }
}

String countdownLabel(Duration remaining) {
  final minutes = remaining.inMinutes;
  return switch (minutes) {
    <= 0 => 'Due now',
    < 60 => '$minutes min to go',
    _ => '${minutes ~/ 60}h ${minutes % 60}m to go',
  };
}