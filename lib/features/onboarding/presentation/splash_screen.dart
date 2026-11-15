import 'package:flutter/material.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/core/widgets/pill_illustration.dart';
import 'package:medipulse_medical/features/dashboard/presentation/widgets/ecg_line_painter.dart';

/// Shown while the app reads its saved state. Matches the splash mockup:
/// scrub teal, tilted pill, "Medi" + peach "Pulse", tagline, ECG line.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // One loop = one heartbeat at a calm 60 BPM
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scrub,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PillIllustration(size: 120, angleDegrees: -32),
                const SizedBox(height: AppSpacing.md),
                Text.rich(
                  TextSpan(
                    children: const [
                      TextSpan(text: 'Medi'),
                      TextSpan(
                        text: 'Pulse',
                        style: TextStyle(color: AppColors.plaster),
                      ),
                    ],
                    style: AppTextStyles.display.copyWith(
                      fontSize: 40,
                      color: AppColors.paper,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Never miss a dose',
                  style: AppTextStyles.body.copyWith(color: AppColors.aquaBright),
                ),
              ],
            ),
          ),
          // The heartbeat line near the bottom
          Positioned(
            left: 48,
            right: 48,
            bottom: 48,
            child: RepaintBoundary(
              child: SizedBox(
                height: 34,
                child: CustomPaint(
                  painter: EcgLinePainter(
                    progress: _pulse,
                    color: AppColors.aquaBright,
                    beatsVisible: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
