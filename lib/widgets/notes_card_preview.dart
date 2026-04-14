// lib/widgets/notes_card_preview.dart
import 'package:flutter/material.dart';
import '../screens/library_screen.dart'; // TextNoteModel

/// Displays a text note card with a **1–3 line preview** of the note content.
/// The preview is truncated with an ellipsis so it never overflows the card.
///
/// The card background [model.color] is user-defined and retrieved from the DB.
class NotesCardPreview extends StatelessWidget {
  const NotesCardPreview({
    required this.model,
    this.onTap,
    super.key,
  });

  final TextNoteModel model;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const onCard = Colors.white;
    const onCardMuted = Colors.white70;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          // User-defined card color from the database
          color: model.color,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              model.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: onCard,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            // Course code label
            Text(
              model.courseCode,
              style: const TextStyle(
                color: onCardMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            // ── Note content preview: 1–3 lines, ellipsis on overflow ──────
            Text(
              model.preview,
              maxLines: 3,              // hard limit: max 3 lines
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: onCardMuted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}