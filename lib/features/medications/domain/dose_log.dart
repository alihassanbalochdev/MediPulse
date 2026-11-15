enum DoseLogStatus { taken, skipped }

/// One id for one scheduled dose: which medicine, at which moment.
String doseKey(String medicationId, DateTime scheduledAt) =>
    '$medicationId|${scheduledAt.millisecondsSinceEpoch}';

class DoseLog {
  const DoseLog({
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.scheduledAt,
    required this.status,
    required this.loggedAt,
  });

  final String medicationId;
  // Name and dose are copied here so history still reads correctly
  // after a medicine is edited or deleted.
  final String medicationName;
  final String dosage;
  final DateTime scheduledAt;
  final DoseLogStatus status;
  final DateTime loggedAt;

  String get key => doseKey(medicationId, scheduledAt);

  factory DoseLog.fromJson(Map<String, dynamic> json) {
    return DoseLog(
      medicationId: json['medicationId'] as String,
      medicationName: json['medicationName'] as String,
      dosage: json['dosage'] as String,
      scheduledAt:
          DateTime.fromMillisecondsSinceEpoch(json['scheduledAt'] as int),
      status: DoseLogStatus.values.byName(json['status'] as String),
      loggedAt: DateTime.fromMillisecondsSinceEpoch(json['loggedAt'] as int),
    );
  }

  Map<String, dynamic> toJson() => {
        'medicationId': medicationId,
        'medicationName': medicationName,
        'dosage': dosage,
        'scheduledAt': scheduledAt.millisecondsSinceEpoch,
        'status': status.name,
        'loggedAt': loggedAt.millisecondsSinceEpoch,
      };
}
