import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/course.dart';
import '../repositories/course_repository.dart';
import '../core/services/isar_service.dart';

final courseProvider = ChangeNotifierProvider<CourseProvider>((ref) {
  return CourseProvider();
});

class CourseProvider extends ChangeNotifier {
  final CourseRepository _repository = CourseRepository(IsarService());
  List<Course> _courses = [];
  bool _isLoading = false;

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;

  CourseProvider() {
    _init();
  }

  void _init() {
    _repository.watchCourses().listen((courses) {
      _courses = courses;
      notifyListeners();
    });
  }

  Future<bool> addCourse(String name, {String? instructor, String? color}) async {
    _setLoading(true);
    try {
      final course = Course()
        ..name = name
        ..instructor = instructor
        ..color = color
        ..createdAt = DateTime.now();

      await _repository.saveCourse(course);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  Future<void> deleteCourse(Id id) async {
    _setLoading(true);
    await _repository.deleteCourse(id);
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}