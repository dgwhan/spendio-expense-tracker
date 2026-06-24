import 'package:flutter/material.dart';

class HomeSectionContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const HomeSectionContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}
