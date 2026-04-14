// lib/widgets/recording_card.dart
import 'package:flutter/material.dart';
import '../screens/library_screen.dart'; // RecordingModel
import 'waveform_visualiser.dart';

/// Card for audio recordings shown in the Library grid.
/// [showWaveform] toggles the waveform bars (hidden in "courses" tab).
class RecordingCard extends StatelessWidget {
  const RecordingCard({
    required this.model,
    this.showWaveform = true,
    this.onTap,
    super.key,
  });

  final RecordingModel model;
  final bool showWaveform;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const onCard = Colors.white;
    const onCardMuted = Colors.white70;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          // User-defined color from DB; already passed inside RecordingModel
          color: model.color,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lecture tag
            Text(
              model.lecture,
              style: const TextStyle(
                color: onCardMuted, fontSize: 9,
                fontWeight: FontWeight.w600, letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            // Title
            Text(
              model.title,
              style: const TextStyle(
                color: onCard, fontSize: 15,
                fontWeight: FontWeight.w800, height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            // Course code
            Text(
              model.courseCode,
              style: const TextStyle(
                color: onCardMuted, fontSize: 9,
                fontWeight: FontWeight.w600, letterSpacing: 0.6,
              ),
            ),
            if (showWaveform) ...[
              const SizedBox(height: 10),
              const MiniWaveform(
                color: onCard,
                opacity: 0.7,
                height: 16,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.play_arrow, color: onCard, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    model.duration,
                    style: const TextStyle(color: onCard, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    model.duration,
                    style: const TextStyle(color: onCardMuted, fontSize: 11),
                  ),
                ],
              ),
            ],
            const Spacer(),
            // Date + time
            Text(
              model.date,
              style: const TextStyle(color: onCardMuted, fontSize: 9, letterSpacing: 0.4),
            ),
            Text(
              model.time,
              style: const TextStyle(color: onCardMuted, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
