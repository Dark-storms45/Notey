// lib/screens/library/library_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/recording_card.dart';
import '../../widgets/notes_card_preview.dart';
import '../../providers/recording_provider.dart';
import '../../providers/course_provider.dart';

// ── Filter tabs ───────────────────────────────────────────────────────────────
enum _LibraryFilter { all, courses, recent, starred }

// ── UI Models ─────────────────────────────────────────────────────────────────
class RecordingModel {
  const RecordingModel({
    required this.id,
    required this.lecture,
    required this.title,
    required this.courseCode,
    required this.duration,
    required this.date,
    required this.time,
    required this.color,
  });
  final String id, lecture, title, courseCode, duration, date, time;
  final Color color;
}

class TextNoteModel {
  const TextNoteModel({
    required this.id, required this.title,
    required this.courseCode, required this.preview, required this.color,
  });
  final String id, title, courseCode, preview;
  final Color color;
}

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  _LibraryFilter _filter = _LibraryFilter.all;

  @override
  Widget build(BuildContext context) {
    final recordings = ref.watch(recordingsProvider).recordings;
    final courses = ref.watch(courseProvider).courses;

    // Helper to get course color
    Color getCourseColor(int? courseId) {
      final course = courses.where((c) => c.id == courseId).firstOrNull;
      if (course?.color != null) {
        try {
          return Color(int.parse(course!.color!, radix: 16));
        } catch (_) {}
      }
      return NOteyColors.cardPurple;
    }

    // Helper to get course name
    String getCourseName(int? courseId) {
      final course = courses.where((c) => c.id == courseId).firstOrNull;
      return course?.name ?? 'Unknown Course';
    }

    // Map all recordings to RecordingModel
    final allRecordingModels = recordings.map((rec) => RecordingModel(
      id: rec.id.toString(),
      lecture: 'LECTURE ${rec.id}',
      title: rec.title,
      courseCode: getCourseName(rec.courseId),
      duration: _formatDuration(rec.duration ?? 0),
      date: DateFormat('MMMM dd yyyy').format(rec.recordedAt).toUpperCase(),
      time: DateFormat('HH:mm').format(rec.recordedAt),
      color: getCourseColor(rec.courseId),
    )).toList();

    // Map recordings with summaries to TextNoteModel
    final textNoteModels = recordings
        .where((rec) => rec.summary != null && rec.summary!.isNotEmpty)
        .map((rec) => TextNoteModel(
      id: rec.id.toString(),
      title: rec.title,
      courseCode: getCourseName(rec.courseId),
      preview: rec.summary!,
      color: getCourseColor(rec.courseId),
    )).toList();

    // Recent recordings (e.g., last 5)
    final recentRecordingModels = allRecordingModels.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        leading: const ThemeToggleButton(),
        title: const Text('My Notes'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _FilterChips(
            selected: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildContent(allRecordingModels, textNoteModels, recentRecordingModels)),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildContent(
      List<RecordingModel> all,
      List<TextNoteModel> texts,
      List<RecordingModel> recent,
      ) {
    switch (_filter) {
      case _LibraryFilter.all:
        return _AllTab(recordings: all, textNotes: texts);
      case _LibraryFilter.courses:
        // In a real app, this might show Course groupings. 
        // For now, reuse the recordings list as in the stub.
        return _CoursesTab(recordings: all);
      case _LibraryFilter.recent:
        return _RecentTab(recordings: recent);
      case _LibraryFilter.starred:
        return const _EmptyState(label: 'No starred course yet');
    }
  }
}

// ── Filter chips ──────────────────────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onChanged});
  final _LibraryFilter selected;
  final ValueChanged<_LibraryFilter> onChanged;

  static const _labels = {
    _LibraryFilter.all: 'All',
    _LibraryFilter.courses: 'courses',
    _LibraryFilter.recent: 'recent',
    _LibraryFilter.starred: 'starred',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: _LibraryFilter.values.map((f) {
          final isSelected = f == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? NOteyColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Text(
                  _labels[f]!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── All tab ───────────────────────────────────────────────────────────────────
class _AllTab extends StatelessWidget {
  const _AllTab({required this.recordings, required this.textNotes});
  final List<RecordingModel> recordings;
  final List<TextNoteModel> textNotes;

  @override
  Widget build(BuildContext context) {
    if (recordings.isEmpty && textNotes.isEmpty) {
      return const _EmptyState(label: 'Your library is empty');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recordings.isNotEmpty) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.82,
              ),
              itemCount: recordings.length,
              itemBuilder: (_, i) => RecordingCard(model: recordings[i]),
            ),
            const SizedBox(height: 20),
          ],
          if (textNotes.isNotEmpty) ...[
            Text(
              'TEXT NOTES',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                letterSpacing: 1.2,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.9,
              ),
              itemCount: textNotes.length,
              itemBuilder: (_, i) => NotesCardPreview(model: textNotes[i]),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Courses tab ───────────────────────────────────────────────────────────────
class _CoursesTab extends StatelessWidget {
  const _CoursesTab({required this.recordings});
  final List<RecordingModel> recordings;

  @override
  Widget build(BuildContext context) {
    if (recordings.isEmpty) return const _EmptyState(label: 'No courses found');

    final latest = recordings.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.9,
            ),
            itemCount: recordings.length,
            itemBuilder: (_, i) => RecordingCard(model: recordings[i], showWaveform: false),
          ),
          const SizedBox(height: 20),
          // Latest recording banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('LATEST RECORDING', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
                      const SizedBox(height: 6),
                      Text(latest.title.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Text(latest.duration, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        const Text('TODAY', style: TextStyle(fontWeight: FontWeight.w500)),
                      ]),
                    ],
                  ),
                ),
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: NOteyColors.primary.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow, color: NOteyColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recent tab ────────────────────────────────────────────────────────────────
class _RecentTab extends StatelessWidget {
  const _RecentTab({required this.recordings});
  final List<RecordingModel> recordings;

  @override
  Widget build(BuildContext context) {
    if (recordings.isEmpty) return const _EmptyState(label: 'No recent recordings');

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.82,
      ),
      itemCount: recordings.length,
      itemBuilder: (_, i) => RecordingCard(model: recordings[i]),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
      ),
    );
  }
}