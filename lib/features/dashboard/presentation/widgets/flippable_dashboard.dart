import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medipulse_medical/core/widgets/flip_card_3d.dart';
import 'package:medipulse_medical/features/dashboard/presentation/providers/emergency_profile_provider.dart';
import 'package:medipulse_medical/features/dashboard/presentation/providers/tilt_flip_provider.dart';

class FlippableDashboard extends ConsumerStatefulWidget {
  const FlippableDashboard({
    super.key,
    required this.frontBuilder,
    required this.back,
  });

  /// Gets a `flip` callback so the front can offer a button fallback.
  final Widget Function(BuildContext context, VoidCallback flip) frontBuilder;
  final Widget back;

  @override
  ConsumerState<FlippableDashboard> createState() =>
      _FlippableDashboardState();
}

class _FlippableDashboardState extends ConsumerState<FlippableDashboard> {
  bool _showBack = false;

  void _flip() => setState(() => _showBack = !_showBack);

  @override
  Widget build(BuildContext context) {
    // NEW: warm up the emergency data now, so the back face is instant.
    // An empty listener keeps it loaded without rebuilding this widget.
    ref.listen<AsyncValue<Object?>>(emergencyProfileProvider, (previous, next) {});

    // Flip every time the tilt provider emits a new event.
    // Listening here also keeps the sensor stream alive while mounted.
    ref.listen<AsyncValue<int>>(tiltFlipProvider, (previous, next) {
      if (next case AsyncData()) _flip();
    });

    return FlipCard3D(
      showBack: _showBack,
      front: widget.frontBuilder(context, _flip),
      back: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _flip, // tap the emergency card to flip back
        child: widget.back,
      ),
    );
  }
}