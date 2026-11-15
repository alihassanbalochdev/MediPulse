import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';


abstract final class AppTextStyles {
  // Big next-dose time on the hero card, like "8:30"
  static final TextStyle heroTime = GoogleFonts.outfit(
    fontSize: 64,
    fontWeight: FontWeight.w500,
    height: 1.05,
    letterSpacing: -1,
  );

  // Screen titles like "Good evening"
  static final TextStyle display = GoogleFonts.outfit(
    fontSize: 30,
    fontWeight: FontWeight.w500,
    height: 1.15,
  );

  // Section titles like "Today"
  static final TextStyle title = GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  // Medicine names in lists
  static final TextStyle itemName = GoogleFonts.outfit(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  static final TextStyle body = GoogleFonts.outfit(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // Small grey text like "500 mg" or "1 of 4 done"
  static final TextStyle caption = GoogleFonts.outfit(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  static final TextStyle button = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}