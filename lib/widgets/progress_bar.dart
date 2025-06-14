
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ProgressBar extends StatelessWidget {
  final ValueListenable<int> progress;
  const ProgressBar({Key? key, required this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: progress,
      builder: (context, value, _) {
        if (value == 100) return const SizedBox.shrink();
        return LinearProgressIndicator(
          value: value / 100,
          minHeight: 3,
          backgroundColor: const Color(0xFFE0E0E0),
          color: const Color(0xFF379A43),
        );
      },
    );
  }
}