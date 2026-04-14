// lib/screens/summary/summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/scrollable_summary.dart';
import '../../providers/recording_provider.dart';
import '../../providers/course_provider.dart';
import '../../widgets/waveform_visualiser.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/toast_widget.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({required this.noteId, super.key});
  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingId = int.tryParse(noteId);
    final recordingState = ref.watch(recordingsProvider);
    final courses = ref.watch(courseProvider).courses;

    final recording = recordingState.recordings.where((r) => r.id == recordingId).firstOrNull;
    
    if (recording == null) {
      return const Scaffold(
        body: Center(child: Text('Note not found')),
      );
    }

    final course = courses.where((c) => c.id == recording.courseId).firstOrNull;
    final courseName = course?.name ?? 'Unknown Course';
    final summaryText = recording.summary ?? 'No summary available for this recording.';
    
    final formattedDate = DateFormat('MMMM dd').format(recording.recordedAt);
    final duration = _formatDuration(recording.duration ?? 0);

    return LoadingWrapper(
      isLoading: recordingState.isLoading,
      message: 'Updating note...',
      child: Scaffold(
        appBar: AppBar(
          leading: const ThemeToggleButton(),
          title: Text(courseName.toUpperCase(), style: const TextStyle(letterSpacing: 0.5)),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, ref, recording.id),
            ),
          ],
        ),
        body: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Summary header card (dark)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.auto_awesome, color: NOteyColors.primary, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'summary',
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '${recording.title} _\n$courseName',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8, runSpacing: 8,
                            children: [
                              _MetaChip(label: 'Lecture ${recording.id}'),
                              _MetaChip(label: formattedDate),
                              _MetaChip(label: duration),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Scrollable bullet-point summary
                    ScrollableSummary(summaryText: summaryText),
                  ],
                ),
              ),
            ),
            // Bottom controls (waveform + actions)
            _BottomBar(),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to permanently delete this note?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(recordingsProvider.notifier).deleteRecording(id);
      if (context.mounted) {
        AppToast.show(context, message: 'Note deleted', type: ToastType.success);
        Navigator.of(context).pop();
      }
    }
  }

  String _formatDuration(int seconds) {
    final d = Duration(seconds: seconds);
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '${h}h ${m}min';
    return '${m}min';
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }
}

class _BottomBar extends StatefulWidget {
  @override
  State<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outline, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Waveform visualization (static bars for now)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                child: MiniWaveform(
                  color: Colors.black87,
                  height: 28,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() => _playing = !_playing),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _playing ? Icons.pause : Icons.play_arrow,
                    color: const Color(0xFFE53935),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionButton(
                icon: Icons.download_outlined,
                color: const Color(0xFFE88A1A),
                onTap: () {
                  AppToast.show(context, message: 'Exporting note...', type: ToastType.info);
                },
              ),
              const SizedBox(width: 16),
              _ActionButton(
                icon: Icons.bookmark,
                color: const Color(0xFFE53935),
                onTap: () {
                  AppToast.show(context, message: 'Note bookmarked', type: ToastType.success);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}