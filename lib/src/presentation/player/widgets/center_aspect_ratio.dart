import 'package:flutter/material.dart';

class CenterAspectRatio extends StatelessWidget {
  const CenterAspectRatio({
    required this.child,
    required this.aspectRatio,
    super.key,
  });
  final Widget child;
  final double aspectRatio;
  @override
  Widget build(BuildContext context) {
    return Center(child: AspectRatio(aspectRatio: aspectRatio, child: child));
  }
}
