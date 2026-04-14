import 'package:flutter/material.dart';
import '../screens/home_screen.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    required this.course,
    required this.cardColor,
    required this.onTap,
    super.key,
  });

  final CourseCardModel course;
  final Color cardColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const onCardText = Colors.white;
    const onCardMuted = Colors.white70;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.lecture,
              style: const TextStyle(
                color: onCardMuted, fontSize: 10,
                fontWeight: FontWeight.w600, letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              course.title,
              style: const TextStyle(
                color: onCardText, fontSize: 16,
                fontWeight: FontWeight.w800, height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Container(height: 0.5, color: onCardMuted),
            const SizedBox(height: 8),
            Text(
              course.courseCode,
              style: const TextStyle(
                color: onCardMuted, fontSize: 10,
                fontWeight: FontWeight.w600, letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                course.preview,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: onCardMuted, fontSize: 11, height: 1.4),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.date,
                        style: const TextStyle(color: onCardMuted, fontSize: 9, letterSpacing: 0.5),
                      ),
                      Text(
                        course.time,
                        style: const TextStyle(color: onCardMuted, fontSize: 9),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}