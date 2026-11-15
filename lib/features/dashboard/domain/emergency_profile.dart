class EmergencyProfile {
  const EmergencyProfile({
    required this.fullName,
    required this.age,
    required this.bloodType,
    required this.allergies,
    required this.prescriptions,
    required this.contactName,
    required this.contactRelation,
    required this.contactPhone,
  });

  final String fullName;
  final int age;
  final String bloodType; // like 'O+', or '?' when unknown
  final List<String> allergies;
  final List<String> prescriptions;
  final String contactName;
  final String contactRelation;
  final String contactPhone;

  // 'O+' becomes 'O positive' so a paramedic can read it at a glance
  String get bloodTypeSpoken => bloodType
      .replaceFirst('+', ' positive')
      .replaceFirst('-', ' negative');

  EmergencyProfile copyWith({
    String? fullName,
    int? age,
    String? bloodType,
    List<String>? allergies,
    List<String>? prescriptions,
    String? contactName,
    String? contactRelation,
    String? contactPhone,
  }) {
    return EmergencyProfile(
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      prescriptions: prescriptions ?? this.prescriptions,
      contactName: contactName ?? this.contactName,
      contactRelation: contactRelation ?? this.contactRelation,
      contactPhone: contactPhone ?? this.contactPhone,
    );
  }

  factory EmergencyProfile.fromJson(Map<String, dynamic> json) {
    return EmergencyProfile(
      fullName: json['fullName'] as String,
      age: (json['age'] as num).toInt(),
      bloodType: json['bloodType'] as String,
      allergies: List<String>.from(json['allergies'] as List),
      prescriptions: List<String>.from(json['prescriptions'] as List),
      contactName: json['contactName'] as String,
      contactRelation: json['contactRelation'] as String,
      contactPhone: json['contactPhone'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'age': age,
        'bloodType': bloodType,
        'allergies': allergies,
        'prescriptions': prescriptions,
        'contactName': contactName,
        'contactRelation': contactRelation,
        'contactPhone': contactPhone,
      };

  /// A new person starts here. Never invent medical data for them.
  static const empty = EmergencyProfile(
    fullName: '',
    age: 0,
    bloodType: '?',
    allergies: [],
    prescriptions: [],
    contactName: '',
    contactRelation: '',
    contactPhone: '',
  );

  // Placeholder data for previews and tests only.
  static const demo = EmergencyProfile(
    fullName: 'Ali Hassan',
    age: 24,
    bloodType: 'O+',
    allergies: ['Penicillin', 'Peanuts', 'Latex'],
    prescriptions: [
      'Metformin 500 mg, twice daily',
      'Lisinopril 10 mg, once daily',
    ],
    contactName: 'Hassan Baloch',
    contactRelation: 'Father',
    contactPhone: '+92 300 0000000',
  );
}
