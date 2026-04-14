import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../providers/recorder_provider.dart';
import '../../providers/recording_processing_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/recording_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/toast_widget.dart';
import '../../widgets/waveform_visualiser.dart';

class RecordingScreen extends ConsumerStatefulWidget {
  const RecordingScreen({required this.courseId, super.key});
  final String courseId;

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  final GlobalKey<LiveWaveformState> _waveKey = GlobalKey<LiveWaveformState>();
  StreamSubscription? _amplitudeSubscription;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Start recording automatically when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recorderProvider.notifier).start();
      _subscribeToAmplitude();
    });
  }

  void _subscribeToAmplitude() {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = ref.read(recorderProvider.notifier).amplitudeStream.listen((amp) {
      // Normalise amplitude from -160dB-0dB to 0.0-1.0 range
      // This is a simple linear mapping for visualisation
      final normalised = (amp.current + 160) / 160;
      _waveKey.currentState?.addSample(normalised);
    });
  }

  void _togglePause() {
    final recorder = ref.read(recorderProvider.notifier);
    if (recorder.status == RecorderStatus.paused) {
      recorder.resume();
      _pulseController.repeat(reverse: true);
    } else {
      recorder.pause();
      _pulseController.stop();
    }
  }

  Future<void> _stop() async {
    _pulseController.stop();
    _amplitudeSubscription?.cancel();
    final path = await ref.read(recorderProvider.notifier).stop();
    
    if (path == null) {
      AppToast.show(context, message: 'Recording failed. No file saved.', type: ToastType.error);
      return;
    }

    final courseIdInt = int.tryParse(widget.courseId) ?? 0;
    
    // Start AI Processing
    await ref.read(recordingProcessingProvider.notifier).processRecording(
      path, 
      'Lecture Recording', 
      courseIdInt
    );

    if (!mounted) return;

    final processingState = ref.read(recordingProcessingProvider);
    if (processingState.status == ProcessingStatus.completed) {
      AppToast.show(context, message: 'Notes generated successfully!', type: ToastType.success);
      
      // Fetch the latest recording to get its ID for the summary route
      final recordings = await ref.read(recordingsProvider.notifier).getRecordingsForCourse(courseIdInt);
      if (recordings.isNotEmpty && mounted) {
        final latestNote = recordings.first;
        context.go('/summary/${latestNote.id}');
      } else if (mounted) {
        context.go('/library');
      }
    } else if (processingState.status == ProcessingStatus.error) {
      AppToast.show(context, message: processingState.error ?? 'Processing failed', type: ToastType.error);
    }
  }

  void _delete() {
    _amplitudeSubscription?.cancel();
    ref.read(recorderProvider.notifier).stop();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _amplitudeSubscription?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final h = duration.inHours.toString().padLeft(2, '0');
    final m = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final recorderState = ref.watch(recorderProvider);
    final processingState = ref.watch(recordingProcessingProvider);
    final courseIdInt = int.tryParse(widget.courseId);
    
    // Fetch course name from provider
    final course = ref.watch(courseProvider).courses
        .where((c) => c.id == courseIdInt).firstOrNull;
    final courseName = course?.name.toUpperCase() ?? 'RECORDING...';
    
    final isPaused = recorderState.status == RecorderStatus.paused;
    final isProcessing = processingState.status != ProcessingStatus.idle && 
                         processingState.status != ProcessingStatus.completed &&
                         processingState.status != ProcessingStatus.error;

    return LoadingWrapper(
      isLoading: isProcessing,
      message: processingState.message ?? 'Processing audio...',
      variant: LoadingVariant.audioBars,
      child: Scaffold(
        appBar: AppBar(
          leading: const ThemeToggleButton(),
          title: Text(courseName, style: const TextStyle(letterSpacing: 0.5)),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Recording badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFD43B2B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isPaused ? 'paused...' : 'recording...',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            const SizedBox(height: 32),
            // Timer
            Text(
              _formatDuration(recorderState.duration),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: 2),
            ),
            const SizedBox(height: 32),
            
            // Live Waveform Visualiser
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LiveWaveform(
                key: _waveKey,
                color: const Color(0xFF1C4DBF),
                isPaused: isPaused,
                height: 100,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Animated mic button
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) {
                final scale = isPaused ? 1.0 : _pulseAnim.value;
                return Transform.scale(
                  scale: scale,
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow rings
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1C4DBF).withValues(alpha: 0.15),
                          ),
                        ),
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1C4DBF).withValues(alpha: 0.25),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1C4DBF).withValues(alpha: 0.4),
                          ),
                        ),
                        // Core button
                        Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1C4DBF),
                          ),
                          child: const Icon(Icons.mic, color: Colors.white, size: 32),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ControlButton(
                  icon: isPaused ? Icons.play_arrow : Icons.pause,
                  color: const Color(0xFFD43B2B),
                  onTap: _togglePause,
                ),
                const SizedBox(width: 20),
                _ControlButton(
                  icon: Icons.stop,
                  color: const Color(0xFFD43B2B),
                  onTap: _stop,
                ),
                const SizedBox(width: 20),
                _ControlButton(
                  icon: Icons.delete_outline,
                  color: Colors.grey.shade300,
                  onTap: _delete,
                  dark: false,
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.dark = true,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: dark ? color.withValues(alpha: 0.12) : color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: dark ? color : Colors.black54, size: 26),
      ),
    );
  }
}