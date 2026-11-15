enum MedicationForm {
  tablet('Tablet'),
  capsule('Capsule'),
  syrup('Syrup'),
  injection('Injection');

  const MedicationForm(this.label);

  final String label;
}