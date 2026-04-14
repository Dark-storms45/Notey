// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../app/theme.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/course_card.dart';
import '../providers/recording_provider.dart';
import '../providers/course_provider.dart';

class CourseCardModel {
  const CourseCardModel({
    required this.id,
    required this.lecture,
    required this.title,
    required this.courseCode,
    required this.preview,
    required this.date,
    required this.time,
  });
  final String id;
  final String lecture;
  final String title;
  final String courseCode;
  final String preview;
  final String date;
  final String time;
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordings = ref.watch(recordingsProvider).recordings;
    final allCourses = ref.watch(courseProvider).courses;

    // Map Isar Recording models to CourseCardModel for UI display
    final courseCardModels = recordings.map((rec) {
      // Find the course name for this recording
      final course = allCourses.where((c) => c.id == rec.courseId).firstOrNull;
      
      return CourseCardModel(
        id: rec.id.toString(),
        lecture: 'LECTURE ${rec.id}',
        title: rec.title,
        courseCode: course?.name ?? 'UNKNOWN COURSE',
        preview: rec.summary ?? rec.transcript ?? 'No summary available yet...',
        date: DateFormat('MMMM dd yyyy').format(rec.recordedAt).toUpperCase(),
        time: DateFormat('HH:mm').format(rec.recordedAt),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: const ThemeToggleButton(),
        title: const Text('Home'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.upload_outlined, color: NOteyColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: courseCardModels.isEmpty
          ? const Center(child: Text('No recordings yet. Start your first one!'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
                itemCount: courseCardModels.length,
                itemBuilder: (_, i) {
                  final model = courseCardModels[i];
                  
                  // Find the course to get its saved color
                  final course = allCourses.where((c) => c.id.toString() == model.id).firstOrNull;
                  Color cardColor = NOteyColors.cardPurple;
                  if (course?.color != null) {
                    try {
                      cardColor = Color(int.parse(course!.color!, radix: 16));
                    } catch (_) {}
                  }

                  return CourseCard(
                    course: model,
                    cardColor: cardColor,
                    onTap: () => context.go('/summary/${model.id}'),
                  );
                },
              ),
            ),
    );
  }
}