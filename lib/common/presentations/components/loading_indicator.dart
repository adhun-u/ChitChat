import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final Color color;
  final double? strokeWidth;
  const LoadingIndicator({super.key, required this.color, this.strokeWidth});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(strokeWidth: strokeWidth, color: color);
  }
}
