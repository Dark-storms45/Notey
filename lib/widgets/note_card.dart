import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'waveform_visualiser.dart';

/// Note card used on Home and Library screens
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.lectureNumber,
    required this.title,
    required this.courseCode,
    required this.date,
    required this.time,
    required this.color,
    this.excerpt,
    this.showAudioWave = false,
    this.audioDuration,
    this.onTap,
  });

  final int lectureNumber;
  final String title;
  final String courseCode;
  final String date;
  final String time;
  final Color color;
  final String? excerpt;
  final bool showAudioWave;
  final String? audioDuration;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lecture badge
            Text(
              'LECTURE $lectureNumber',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            // Title
            Text(
              title,
              style: GoogleFonts.syne(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Course code divider
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white30),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                courseCode.toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Audio wave or excerpt
            if (showAudioWave) ...[
              _AudioWaveRow(duration: audioDuration ?? '0:00'),
            ] else if (excerpt != null) ...[
              Text(
                excerpt!,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: Colors.white70,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Spacer(),
            // Footer: date + time + mic icon
            Row(
              children: [
                Text(
                  date,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: Colors.white60,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioWaveRow extends StatelessWidget {
  const _AudioWaveRow({required this.duration});
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Using the central MiniWaveform component from waveform_visualiser.dart
        const MiniWaveform(
          color: Colors.white,
          opacity: 0.7,
          height: 20,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.play_arrow, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Text(
              duration,
              style: GoogleFonts.dmSans(fontSize: 10, color: Colors.white70),
            ),
            const Spacer(),
            Text(
              duration,
              style: GoogleFonts.dmSans(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }
}
