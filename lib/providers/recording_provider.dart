import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/recordings.dart';
import '../repositories/recording_repository.dart';
import '../core/services/isar_service.dart';

final recordingsProvider = ChangeNotifierProvider<RecordingProvider>((ref) {
  return RecordingProvider();
});

class RecordingProvider extends ChangeNotifier {
  final RecordingRepository _repository = RecordingRepository(IsarService());
  List<Recording> _recordings = [];
  bool _isLoading = false;

  List<Recording> get recordings => _recordings;
  bool get isLoading => _isLoading;

  RecordingProvider() {
    _init();
  }

  void _init() {
    _repository.watchRecordings().listen((recordings) {
      _recordings = recordings;
      notifyListeners();
    });
  }

  Future<void> saveRecording(Recording recording) async {
    _setLoading(true);
    await _repository.saveRecording(recording);
    _setLoading(false);
  }

  Future<void> deleteRecording(Id id) async {
    _setLoading(true);
    await _repository.deleteRecording(id);
    _setLoading(false);
  }

  Future<List<Recording>> getRecordingsForCourse(int courseId) async {
    return await _repository.getRecordingsForCourse(courseId);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}