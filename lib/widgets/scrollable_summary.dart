// lib/widgets/scrollable_summary.dart
import 'package:flutter/material.dart';

/// Renders the full summary text and extracts bullet points.
///
/// Bullet-point heuristic:
///   1. Lines starting with `-`, `•`, `*`, or a digit+`.` are treated as bullets.
///   2. Otherwise, non-empty lines are split as individual bullets.
///
/// The entire area scrolls via the parent's [SingleChildScrollView].
class ScrollableSummary extends StatelessWidget {
  const ScrollableSummary({
    required this.summaryText,
    this.bulletColor,
    super.key,
  });

  final String summaryText;
  /// Override bullet circle color; defaults to the theme's primary color.
  final Color? bulletColor;

  /// Parses [summaryText] into a list of bullet strings.
  static List<String> extractBullets(String text) {
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);
    final bullets = <String>[];
    for (final line in lines) {
      if (line.startsWith('- ') || line.startsWith('• ') || line.startsWith('* ')) {
        bullets.add(line.substring(2).trim());
      } else if (RegExp(r'^\d+\. ').hasMatch(line)) {
        bullets.add(line.replaceFirst(RegExp(r'^\d+\. '), '').trim());
      }
      // Non-bullet prose lines are skipped from bullets (shown as full text above)
    }
    return bullets;
  }

  /// Returns prose paragraphs (non-bullet lines).
  static String extractProse(String text) {
    final lines = text.split('\n').map((l) => l.trim());
    final prose = lines.where((l) =>
    l.isNotEmpty &&
        !l.startsWith('- ') && !l.startsWith('• ') && !l.startsWith('* ') &&
        !RegExp(r'^\d+\. ').hasMatch(l),
    );
    return prose.join('\n\n');
  }

  @override
  Widget build(BuildContext context) {
    final bullets = extractBullets(summaryText);
    final theme = Theme.of(context);
    final accent = bulletColor ?? const Color(0xFF2D8C4E); // green bullet circles

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bullets.isEmpty)
            Text(summaryText, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6))
          else
            ...List.generate(bullets.length, (i) => _BulletRow(
              index: i + 1,
              text: bullets[i],
              color: accent,
            )),
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.index, required this.text, required this.color});
  final int index;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.only(right: 12, top: 1),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}