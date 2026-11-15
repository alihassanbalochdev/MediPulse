import 'dart:math' as math;

import 'package:flutter/material.dart';

class FlipCard3D extends StatefulWidget {
  const FlipCard3D({
    super.key,
    required this.showBack,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 650),
  });

  final bool showBack;
  final Widget front;
  final Widget back;
  final Duration duration;

  @override
  State<FlipCard3D> createState() => _FlipCard3DState();
}

class _FlipCard3DState extends State<FlipCard3D>
    with SingleTickerProviderStateMixin {
  // 0 = front fully visible, 1 = back fully visible
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.showBack ? 1 : 0,
  );

  @override
  void didUpdateWidget(FlipCard3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showBack != widget.showBack) {
      // forward/reverse continue from the current value, so a mid-flip
      // change of mind turns around smoothly instead of jumping
      widget.showBack ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final eased = Curves.easeInOutCubic.transform(_controller.value);
        final angle = eased * math.pi; // 0 to 180 degrees
        final isBackVisible = angle > math.pi / 2; // past the edge-on moment

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012) // perspective
            ..rotateY(angle),
          child: SizedBox.expand(
            child: isBackVisible
                // Past 90 degrees the whole card is mirrored. Rotating the
                // back face another 180 degrees cancels that, so text reads
                // correctly.
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: widget.back,
                  )
                : widget.front,
          ),
        );
      },
    );
  }
}