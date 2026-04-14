
import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─── Shared constants ─────────────────────────────────────────────────────────
const _kBarGap    = 2.0;
const _kBarRadius = 2.0;
const _kMinHeight = 4.0;

// ─────────────────────────────────────────────────────────────────────────────
// 1.  PLAYBACK WAVEFORM
//     Renders a static waveform from pre-computed amplitude data.
//     Bars to the left of [progress] are colored with [activeColor];
//     bars to the right use [inactiveColor].
// ─────────────────────────────────────────────────────────────────────────────

/// Playback waveform — pass a list of normalised amplitudes (0.0 – 1.0)
/// and a [progress] value (0.0 – 1.0) to colour played/unplayed bars.
///
/// ```dart
/// WaveformPlayback(
///   amplitudes: myNote.waveformData,   // List<double> from DB
///   progress: playerPosition / totalDuration,
///   activeColor: Color(0xFFE040C8),
/// )
/// ```
class WaveformPlayback extends StatelessWidget {
  const WaveformPlayback({
    required this.amplitudes,
    required this.progress,
    this.activeColor  = const Color(0xFFE040C8),
    this.inactiveColor,
    this.height = 52,
    super.key,
  });

  final List<double> amplitudes;

  final double progress;
  final Color activeColor;
  /// Defaults to [activeColor] at 20% opacity
  final Color? inactiveColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final inactive = inactiveColor ??
        Theme.of(context).colorScheme.outline.withOpacity(0.35);
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _PlaybackPainter(
          amplitudes: amplitudes,
          progress: progress.clamp(0.0, 1.0),
          activeColor: activeColor,
          inactiveColor: inactive,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _PlaybackPainter extends CustomPainter {
  _PlaybackPainter({
    required this.amplitudes,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  final List<double> amplitudes;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;
    final n = amplitudes.length;
    final barW = ((size.width - _kBarGap * (n - 1)) / n).clamp(1.0, double.infinity);
    final activePaint  = Paint()..color = activeColor;
    final inactivePaint = Paint()..color = inactiveColor;

    for (int i = 0; i < n; i++) {
      final x = i * (barW + _kBarGap);
      final barH = math.max(_kMinHeight, amplitudes[i].clamp(0.0, 1.0) * (size.height - 8));
      final y = (size.height - barH) / 2;
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barW, barH),
        const Radius.circular(_kBarRadius),
      );
      canvas.drawRRect(rr, i / n < progress ? activePaint : inactivePaint);
    }
  }

  @override
  bool shouldRepaint(_PlaybackPainter old) =>
      old.progress != progress || old.amplitudes != amplitudes;
}

// ─────────────────────────────────────────────────────────────────────────────
// 2.  LIVE RECORDING WAVEFORM
//     Streams animated bars that grow in real-time as the mic captures audio.
//     Feed it amplitude samples via [addSample()] or use the built-in
//     simulation mode for UI development.
// ─────────────────────────────────────────────────────────────────────────────

/// Live recording waveform — animates a scrolling bar graph.
///
/// **Production use**: call [addSample(amplitude)] on every audio callback.
/// **Dev/preview use**: set [simulate] = true to auto-generate fake audio data.
///
/// ```dart
/// final waveKey = GlobalKey<LiveWaveformState>();
///
/// LiveWaveform(
///   key: waveKey,
///   color: Color(0xFFE040C8),
///   barCount: 80,
///   height: 72,
/// )
///
/// // From your audio recorder callback:
/// waveKey.currentState?.addSample(normalizedAmplitude);
/// ```
class LiveWaveform extends StatefulWidget {
  const LiveWaveform({
    this.color = const Color(0xFFE040C8),
    this.barCount = 80,
    this.height = 72,
    this.simulate = false,
    this.isPaused = false,
    super.key,
  });

  final Color color;
  final int barCount;
  final double height;
  /// Set true during development to see simulated audio bars.
  final bool simulate;
  final bool isPaused;

  @override
  State<LiveWaveform> createState() => LiveWaveformState();
}

class LiveWaveformState extends State<LiveWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _ticker;
  final List<double> _bars = [];
  final _rng = math.Random();
  double _simT = 0;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_onTick);

    if (widget.simulate) _ticker.repeat();
  }

  void _onTick() {
    if (widget.isPaused) return;
    if (widget.simulate) {
      _simT += 0.05;
      // Simulate a mix of speech-like amplitude
      final v = (0.3 +
          (math.sin(_simT * 2.3) * 0.25).abs() +
          (math.sin(_simT * 7.1) * 0.15).abs() +
          _rng.nextDouble() * 0.1)
          .clamp(0.1, 1.0);
      _pushBar(v);
    }
  }

  /// Call this with a normalised amplitude (0.0 – 1.0) from your audio plugin.
  void addSample(double amplitude) {
    if (!widget.simulate) _pushBar(amplitude.clamp(0.0, 1.0));
  }

  void _pushBar(double v) {
    if (!mounted) return;
    setState(() {
      _bars.add(v);
      if (_bars.length > widget.barCount) _bars.removeAt(0);
    });
  }

  @override
  void didUpdateWidget(LiveWaveform old) {
    super.didUpdateWidget(old);
    if (widget.simulate && !old.simulate) _ticker.repeat();
    if (!widget.simulate && old.simulate) _ticker.stop();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: CustomPaint(
        painter: _LivePainter(
          bars: List.unmodifiable(_bars),
          color: widget.color,
          isPaused: widget.isPaused,
          barCount: widget.barCount,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _LivePainter extends CustomPainter {
  _LivePainter({
    required this.bars,
    required this.color,
    required this.isPaused,
    required this.barCount,
  });

  final List<double> bars;
  final Color color;
  final bool isPaused;
  final int barCount;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;
    final n = bars.length;
    final barW = ((size.width - _kBarGap * (barCount - 1)) / barCount)
        .clamp(1.0, double.infinity);

    // Left-offset so new bars appear on the right
    final startX = (barCount - n) * (barW + _kBarGap);

    for (int i = 0; i < n; i++) {
      final x = startX + i * (barW + _kBarGap);
      final barH = math.max(_kMinHeight, bars[i] * (size.height - 8));
      final y = (size.height - barH) / 2;

      // Fade older bars
      final alpha = isPaused ? 0.3 : (0.35 + (i / n) * 0.65);
      final paint = Paint()..color = color.withOpacity(alpha);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barW, barH),
          const Radius.circular(_kBarRadius),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_LivePainter old) =>
      old.bars != bars || old.isPaused != isPaused;
}

// ─────────────────────────────────────────────────────────────────────────────
// 3.  MINI STATIC WAVEFORM  (for cards)
//     Lightweight, no animation – just a row of pre-set bars.
// ─────────────────────────────────────────────────────────────────────────────

/// Lightweight static waveform for use inside recording cards.
/// No state, no animation — purely decorative.
class MiniWaveform extends StatelessWidget {
  const MiniWaveform({
    this.color = Colors.white,
    this.opacity = 0.7,
    this.height = 18,
    super.key,
  });

  final Color color;
  final double opacity;
  final double height;

  static const _kHeights = [0.35, 0.55, 0.8, 0.45, 0.9, 0.65, 0.4, 0.75, 0.5, 0.9, 0.4, 0.65, 0.5];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _kHeights.map((v) {
          return Container(
            width: 3,
            height: math.max(_kMinHeight, v * height),
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: color.withOpacity(opacity),
              borderRadius: BorderRadius.circular(_kBarRadius),
            ),
          );
        }).toList(),
      ),
    );
  }
}