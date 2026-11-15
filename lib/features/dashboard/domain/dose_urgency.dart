import 'package:flutter/material.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';

enum DoseUrgency { calm, soon, urgent }

// Decides the urgency from the time left
DoseUrgency urgencyFor(Duration remaining) => switch (remaining.inMinutes) {
      <= 15 => DoseUrgency.urgent,
      <= 60 => DoseUrgency.soon,
      _ => DoseUrgency.calm,
    };

// What the ECG line looks like in each state
typedef UrgencyLook = ({Color color, int bpm, double beatsVisible});

extension DoseUrgencyLook on DoseUrgency {
  UrgencyLook get look => switch (this) {
        DoseUrgency.calm => (
            color: AppColors.aquaBright,
            bpm: 60,
            beatsVisible: 2.0,
          ),
        DoseUrgency.soon => (
            color: AppColors.plaster,
            bpm: 80,
            beatsVisible: 3.0,
          ),
        DoseUrgency.urgent => (
            color: AppColors.alertSoft,
            bpm: 120,
            beatsVisible: 4.0,
          ),
      };
}