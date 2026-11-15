import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/features/scanner/data/prescription_image_picker.dart';
import 'package:medipulse_medical/features/scanner/presentation/providers/scan_state.dart';
import 'package:medipulse_medical/features/scanner/presentation/providers/scanner_providers.dart';
import 'package:medipulse_medical/features/scanner/presentation/widgets/scan_capture_controls.dart';
import 'package:medipulse_medical/features/scanner/presentation/widgets/scan_frame.dart';
import 'package:medipulse_medical/features/scanner/presentation/widgets/scan_results_sheet.dart';

class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scanControllerProvider);
    final controller = ref.read(scanControllerProvider.notifier);
    final isBusy = state is ScanInProgress;

    return Scaffold(
      backgroundColor: AppColors.scrub,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xl),
                _StatusLine(state: state),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ScanFrame(isScanning: isBusy),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ScanCaptureControls(
                  enabled: !isBusy,
                  onCamera: () => controller.scan(PrescriptionImageSource.camera),
                  onGallery: () =>
                      controller.scan(PrescriptionImageSource.gallery),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) => SlideTransition(
                position: animation.drive(
                  Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              ),
              child: switch (state) {
                final ScanSuccess success => ScanResultsSheet(
                    key: const ValueKey('results'),
                    state: success,
                    onToggle: controller.toggle,
                    onClose: controller.reset,
                    onAdd: () => _onAdd(context, controller),
                  ),
                _ => const SizedBox.shrink(key: ValueKey('none')),
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onAdd(BuildContext context, ScanController controller) async {
    // Grab these before the await, so we never use a stale BuildContext
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final added = await controller.addSelectedToCabinet();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          added == 0
              ? 'Those medicines are already in your cabinet.'
              : '$added medicine(s) added to your cabinet.',
        ),
      ),
    );
    navigator.maybePop(); // back to the cabinet, if we came from there
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.state});

  final ScanState state;

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (state) {
      ScanIdle() || ScanSuccess() => (
          'Take a photo of a prescription or medicine box',
          AppColors.aquaBright,
        ),
      ScanInProgress() => ('Reading prescription…', AppColors.plaster),
      ScanFailure(:final message) => (message, AppColors.alertSoft),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.body.copyWith(color: color),
      ),
    );
  }
}