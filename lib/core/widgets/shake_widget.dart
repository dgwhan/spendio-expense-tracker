import 'dart:async';
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
        final double offset = 12.0 *
            (1.0 - progress) *
            (progress * 4.0 * 3.14159).floor().clamp(-1, 1) *
            ((progress * 4.0 * 3.14159) * 5).floor().sineValue();

        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

extension on int {
  double sineValue() => this % 2 == 0 ? 1.0 : -1.0;
}
