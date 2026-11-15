enum DoseFrequency {
  onceDaily('Once daily', 1),
  twiceDaily('Twice daily', 2),
  threeTimesDaily('Three times daily', 3),
  fourTimesDaily('Four times daily', 4),
  asNeeded('As needed', null),
  unknown('Not found', null);

  const DoseFrequency(this.label, this.timesPerDay);

  final String label;
  final int? timesPerDay;

  static DoseFrequency fromTimesPerDay(int times) => switch (times) {
        1 => onceDaily,
        2 => twiceDaily,
        3 => threeTimesDaily,
        4 => fourTimesDaily,
        _ => unknown,
      };
}