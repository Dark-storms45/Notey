// lib/widgets/notey_logo.dart
import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Static NOtey wordmark with audio-bar icon (used in login / signup).
class NOteyLogoStatic extends StatelessWidget {
  const NOteyLogoStatic({this.dark = false, super.key});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AudioBars(color: NOteyColors.primary, barCount: 5, animated: false),
        const SizedBox(width: 8),
        Text(
          'NOtey',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: dark ? Colors.white : Colors.black,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Animated version used on the splash screen.
class NOteyLogoAnimated extends StatelessWidget {
  const NOteyLogoAnimated({required this.progress, super.key});
  /// Value from 0.0 to 1.0 driving the bar heights.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return _AudioBars(color: NOteyColors.primary, barCount: 5, animated: true, progress: progress);
  }
}

class _AudioBars extends StatelessWidget {
  const _AudioBars({
    required this.color,
    required this.barCount,
    required this.animated,
    this.progress = 0.5,
  });

  final Color color;
  final int barCount;
  final bool animated;
  final double progress;

  // Pre-set bar height multipliers to mimic the audio-waveform icon
  static const _multipliers = [0.5, 0.85, 1.0, 0.7, 0.55];

  @override
  Widget build(BuildContext context) {
    const baseHeight = 32.0;
    const width = 5.0;
    const gap = 3.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(barCount, (i) {
        final mult = _multipliers[i % _multipliers.length];
        final h = animated
            ? baseHeight * (mult * 0.6 + progress * mult * 0.4)
            : baseHeight * mult;
        return Container(
          width: width,
          height: h,
          margin: EdgeInsets.only(right: i < barCount - 1 ? gap : 0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}