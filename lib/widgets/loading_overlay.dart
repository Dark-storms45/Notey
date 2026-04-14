// lib/widgets/loading_overlay.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LoadingVariant — choose which animation to show
// ─────────────────────────────────────────────────────────────────────────────
enum LoadingVariant {
  /// Spinning arc ring — general purpose loading
  ring,

  /// Five bouncing audio bars — use during transcription / AI processing
  audioBars,

  /// Three bouncing dots — use during quick saves / uploads
  dots,
}

// ─────────────────────────────────────────────────────────────────────────────
// AppLoadingOverlay
//
// Usage — wrap any widget tree:
//
//   Stack(children: [
//     YourScreen(),
//     if (_isLoading)
//       AppLoadingOverlay(
//         variant: LoadingVariant.audioBars,
//         message: 'Transcribing audio…',
//         subtitle: 'This may take a moment',
//       ),
//   ])
//
// Or via the helper method (inserts over any route):
//
//   final hide = AppLoadingOverlay.show(context,
//     variant: LoadingVariant.ring,
//     message: 'Loading…',
//   );
//   await someAsyncWork();
//   hide();
// ─────────────────────────────────────────────────────────────────────────────
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    this.variant = LoadingVariant.ring,
    this.message,
    this.subtitle,
    /// Opacity of the scrim behind the card. 0.55 feels natural on dark,
    /// 0.45 on light. The widget auto-selects based on brightness.
    this.scrimOpacity,
    /// Override the brand colour (defaults to NOtey magenta-pink).
    this.color = const Color(0xFFE040C8),
    super.key,
  });

  final LoadingVariant variant;
  final String? message;
  final String? subtitle;
  final double? scrimOpacity;
  final Color color;

  // ── Overlay helper ─────────────────────────────────────────────────────────
  /// Shows the overlay above the current route. Returns a VoidCallback that
  /// removes it. Always call the returned function when loading is done.
  ///
  /// ```dart
  /// final hide = AppLoadingOverlay.show(context,
  ///   variant: LoadingVariant.audioBars,
  ///   message: 'Transcribing audio…',
  /// );
  /// await someWork();
  /// hide();
  /// ```
  static VoidCallback show(
      BuildContext context, {
        LoadingVariant variant = LoadingVariant.ring,
        String? message,
        String? subtitle,
        Color color = const Color(0xFFE040C8),
      }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => AppLoadingOverlay(
        variant: variant,
        message: message,
        subtitle: subtitle,
        color: color,
      ),
    );
    overlay.insert(entry);
    return entry.remove;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final opacity = scrimOpacity ?? (isDark ? 0.55 : 0.45);
    final scrim = isDark
        ? Colors.black.withOpacity(opacity)
        : Colors.white.withOpacity(opacity);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // ── Translucent scrim (blocks interaction) ───────────────────────
          ModalBarrier(
            color: scrim,
            dismissible: false,
          ),
          // ── Centred loader card ───────────────────────────────────────────
          Center(
            child: _LoaderCard(
              variant: variant,
              message: message,
              subtitle: subtitle,
              color: color,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LoaderCard — the white/dark pill that floats above the scrim
// ─────────────────────────────────────────────────────────────────────────────
class _LoaderCard extends StatelessWidget {
  const _LoaderCard({
    required this.variant,
    required this.color,
    required this.isDark,
    this.message,
    this.subtitle,
  });

  final LoadingVariant variant;
  final Color color;
  final bool isDark;
  final String? message;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final msgColor = isDark ? const Color(0xFFE0E0E0) : const Color(0xFF222222);
    final subColor = isDark ? const Color(0xFF888888) : const Color(0xFF999999);

    Widget indicator;
    switch (variant) {
      case LoadingVariant.ring:
        indicator = _RingIndicator(color: color, size: 52);
      case LoadingVariant.audioBars:
        indicator = _AudioBarsIndicator(color: color, height: 44);
      case LoadingVariant.dots:
        indicator = _DotsIndicator(color: color);
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 130, maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        // Very subtle border — visible on both light and dark
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.07)
              : Colors.black.withOpacity(0.06),
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          if (message != null) ...[
            const SizedBox(height: 14),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: msgColor,
                height: 1.4,
              ),
            ),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: subColor, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Variant 1 — Ring spinner
// ─────────────────────────────────────────────────────────────────────────────
class _RingIndicator extends StatefulWidget {
  const _RingIndicator({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  State<_RingIndicator> createState() => _RingIndicatorState();
}

class _RingIndicatorState extends State<_RingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _RingPainter(
            progress: _ctrl.value,
            color: widget.color,
            trackColor: widget.color.withOpacity(0.14),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width - 6) / 2;

    // Track
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..color = trackColor
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Spinning arc — sweeps from a start angle that rotates each frame
    const sweepAngle = math.pi * 1.2; // ~216° arc
    final startAngle = progress * math.pi * 2 - math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Variant 2 — Audio bars (5 bars, staggered bounce)
// ─────────────────────────────────────────────────────────────────────────────
class _AudioBarsIndicator extends StatefulWidget {
  const _AudioBarsIndicator({required this.color, required this.height});
  final Color color;
  final double height;

  @override
  State<_AudioBarsIndicator> createState() => _AudioBarsIndicatorState();
}

class _AudioBarsIndicatorState extends State<_AudioBarsIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Each bar has a different phase offset and peak fraction
  static const _bars = [
    (phase: 0.0,  peak: 0.65),
    (phase: 0.12, peak: 0.85),
    (phase: 0.24, peak: 1.0),
    (phase: 0.36, peak: 0.75),
    (phase: 0.48, peak: 0.55),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _bars.asMap().entries.map((e) {
              final b = e.value;
              // Shift the animation phase per bar so they don't all move together
              final t = (_ctrl.value + b.phase) % 1.0;
              final sinVal = math.sin(t * math.pi);          // 0 → 1 → 0
              const minH = 5.0;
              final barH = minH + (sinVal * b.peak) * (widget.height - minH);

              return Container(
                width: 5,
                height: barH,
                margin: EdgeInsets.only(left: e.key > 0 ? 4 : 0),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Variant 3 — Bouncing dots (3 dots, staggered)
// ─────────────────────────────────────────────────────────────────────────────
class _DotsIndicator extends StatefulWidget {
  const _DotsIndicator({required this.color});
  final Color color;

  @override
  State<_DotsIndicator> createState() => _DotsIndicatorState();
}

class _DotsIndicatorState extends State<_DotsIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _phases = [0.0, 0.15, 0.30];
  static const _dotSize = 10.0;
  static const _bounceH = 8.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _dotSize + _bounceH,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _phases.asMap().entries.map((e) {
              final t = (_ctrl.value + e.value) % 1.0;
              final bounce = math.sin(t * math.pi) * _bounceH;
              return Transform.translate(
                offset: Offset(0, -bounce),
                child: Container(
                  width: _dotSize,
                  height: _dotSize,
                  margin: EdgeInsets.only(left: e.key > 0 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Convenience wrapper — wraps a widget and conditionally shows the overlay
//
// Usage:
//   LoadingWrapper(
//     isLoading: _isLoading,
//     variant: LoadingVariant.audioBars,
//     message: 'Transcribing audio…',
//     child: YourScreen(),
//   )
// ─────────────────────────────────────────────────────────────────────────────
class LoadingWrapper extends StatelessWidget {
  const LoadingWrapper({
    required this.isLoading,
    required this.child,
    this.variant = LoadingVariant.ring,
    this.message,
    this.subtitle,
    this.color = const Color(0xFFE040C8),
    super.key,
  });

  final bool isLoading;
  final Widget child;
  final LoadingVariant variant;
  final String? message;
  final String? subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          AppLoadingOverlay(
            variant: variant,
            message: message,
            subtitle: subtitle,
            color: color,
          ),
      ],
    );
  }
}