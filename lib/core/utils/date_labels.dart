const _weekdays = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];
const _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// Like "Saturday, 14 November"
String dateLabel(DateTime date) =>
    '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]}';

String greetingFor(DateTime now) => switch (now.hour) {
      < 12 => 'Good morning,',
      < 17 => 'Good afternoon,',
      _ => 'Good evening,',
    };
