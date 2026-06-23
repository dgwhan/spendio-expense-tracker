import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final Stream<bool> triggerStream;

  const ShakeWidget({
    super.key,
    required this.child,
    required this.triggerStream,
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  StreamSubscription<bool>? _subscription;
  bool _canShakeNow = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _canShakeNow = true;
        });
      }
    });

    _subscription = widget.triggerStream.listen((shouldShake) {
      if (_canShakeNow && shouldShake == true) {
        if (mounted) {
          _controller.forward(from: 0.0);
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        if (progress == 0.0 || progress == 1.0) return child!;

        // ROTATION SHAKE:
        final double angle =
            math.sin(progress * 3 * 2 * math.pi) * 0.06 * (1.0 - progress);

        return Transform.rotate(
          angle: angle,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
