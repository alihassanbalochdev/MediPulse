import 'package:flutter/material.dart';

abstract final class AppColors {
  // Base
  static const Color paper = Color(0xFFEDF6F2);
  static const Color scrub = Color(0xFF0E4C4F);

  // Accent
  static const Color plaster = Color(0xFFF4A582);
  static const Color plasterSoft = Color(0xFFFBD9C7);

  // Soft tints
  static const Color aqua = Color(0xFFBFE6DF);
  static const Color aquaBright = Color(0xFF8FD9CB);

  // Text and status
  static const Color muted = Color(0xFF5A7576);
  static const Color alert = Color(0xFFC8372D);
  static const Color alertSoft = Color(0xFFFF7A6B);

  // Emergency ID card
  static const Color emergency = Color(0xFFB3261E);
  static const Color emergencySoft = Color(0xFFFFD9D6); // NEW: light text on red
  static const Color emergencyTint = Color(0xFFFFE1DE); // NEW: allergy chip fill
  static const Color emergencyDeep = Color(0xFF7A130D); // NEW: allergy chip text
  static const Color emergencyInk = Color(0xFF1A1A1A); // NEW: main text on white
  static const Color emergencyMuted = Color(0xFF5B5B5B); // NEW: small grey text
}