import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import '../core/services/audio_recording_service.dart';

enum RecorderStatus { idle, recording, paused }

final recorderProvider = ChangeNotifierProvider<RecorderProvider>((ref) {
  return RecorderProvider();
});

class RecorderProvider extends ChangeNotifier {
  final AudioRecordingService _service = AudioRecordingService();
  
  RecorderStatus _status = RecorderStatus.idle;
  Duration _duration = Duration.zero;
  Timer? _timer;
  
  RecorderStatus get status => _status;
  Duration get duration => _duration;
  bool get isRecording => _status == RecorderStatus.recording;

  Stream<Amplitude> get amplitudeStream => _service.getAmplitude();

  Future<void> start() async {
    try {
      await _service.startRecording();
      _status = RecorderStatus.recording;
      _startTimer();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> stop() async {
    final path = await _service.stopRecording();
    _status = RecorderStatus.idle;
    _stopTimer();
    _duration = Duration.zero;
    notifyListeners();
    return path;
  }

  void pause() {
    _service.pauseRecording();
    _status = RecorderStatus.paused;
    _timer?.cancel();
    notifyListeners();
  }

  void resume() {
    _service.resumeRecording();
    _status = RecorderStatus.recording;
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _duration += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _service.dispose();
    _stopTimer();
    super.dispose();
  }
}