// lib/screens/recording/course_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/theme_toggle_button.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/toast_widget.dart';

class CoursePickerScreen extends ConsumerStatefulWidget {
  const CoursePickerScreen({super.key});

  @override
  ConsumerState<CoursePickerScreen> createState() => _CoursePickerScreenState();
}

class _CoursePickerScreenState extends ConsumerState<CoursePickerScreen> {
  final _searchCtrl = TextEditingController();
  Course? _selected;
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Filtering ─────────────────────────────────────────────────────────────
  List<Course> _filter(List<Course> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((c) =>
      c.name.toLowerCase().contains(q) ||
      (c.instructor?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  // Simplified recent logic: top 2 based on createdAt for now
  List<Course> _recent(List<Course> all) {
    final sorted = [...all]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(2).toList();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  void _startRecording() {
    if (_selected == null) {
      AppToast.show(context, message: 'Please select a course first', type: ToastType.warning);
      return;
    }
    context.push('/recording/${_selected!.id}');
  }

  void _goCreateCourse() {
    context.go(AppRoute.add);
  }

  @override
  Widget build(BuildContext context) {
    final courseState = ref.watch(courseProvider);
    final allCourses = courseState.courses;
    final isLoading = courseState.isLoading;

    final filtered = _filter(allCourses);
    final recent = _query.isEmpty ? _recent(allCourses) : <Course>[];
    final recentIds = recent.map((c) => c.id).toSet();
    final rest = filtered.where((c) => !recentIds.contains(c.id)).toList();

    return LoadingWrapper(
      isLoading: isLoading,
      message: 'Loading courses...',
      child: Scaffold(
        appBar: AppBar(
          leading: const ThemeToggleButton(),
          title: const Text('Choose a course'),
          actions: [
            TextButton(
              onPressed: _goCreateCourse,
              child: const Text(
                '+ new',
                style: TextStyle(
                  color: NOteyColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // ── Search bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: _SearchBar(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),

            // ── Selected course badge ────────────────────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: _selected != null
                  ? _SelectedBadge(course: _selected!)
                  : const SizedBox.shrink(),
            ),

            // ── Course list ──────────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty && !isLoading
                  ? const _EmptyState()
                  : ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  if (recent.isNotEmpty) ...[
                    const _SectionHeader(label: 'Recent'),
                    ...recent.map(
                          (c) => _CourseRow(
                        course: c,
                        isSelected: _selected?.id == c.id,
                        onTap: () => setState(() =>
                        _selected = _selected?.id == c.id ? null : c),
                      ),
                    ),
                  ],

                  if (rest.isNotEmpty) ...[
                    _SectionHeader(
                      label: _query.isEmpty ? 'All courses' : 'Results',
                    ),
                    ...rest.map(
                          (c) => _CourseRow(
                        course: c,
                        isSelected: _selected?.id == c.id,
                        onTap: () => setState(() =>
                        _selected = _selected?.id == c.id ? null : c),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Bottom CTA ───────────────────────────────────────────────────
            _BottomCta(
              selected: _selected,
              onStart: _startRecording,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SearchBar
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged, super.key});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search,
            size: 18,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search courses…',
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  const _CourseRow({
    required this.course,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final Course course;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color courseColor = NOteyColors.cardPurple;
    if (course.color != null) {
      try {
        courseColor = Color(int.parse(course.color!, radix: 16));
      } catch (_) {}
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            color: isSelected
                ? courseColor.withValues(alpha: isDark ? 0.18 : 0.07)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                _ColorSphere(color: courseColor, isSelected: isSelected),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      if (course.instructor != null)
                        Text(
                          course.instructor!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: NOteyColors.primary, size: 20),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 64),
          child: Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
        ),
      ],
    );
  }
}

class _ColorSphere extends StatelessWidget {
  const _ColorSphere({required this.color, required this.isSelected});
  final Color color;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: isSelected
            ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))]
            : null,
      ),
    );
  }
}

class _SelectedBadge extends StatelessWidget {
  const _SelectedBadge({required this.course});
  final Course course;

  @override
  Widget build(BuildContext context) {
    Color courseColor = NOteyColors.cardPurple;
    if (course.color != null) {
      try {
        courseColor = Color(int.parse(course.color!, radix: 16));
      } catch (_) {}
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: courseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: courseColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: courseColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Selected: ${course.name}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: courseColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  const _BottomCta({required this.selected, required this.onStart});
  final Course? selected;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: ElevatedButton(
        onPressed: selected == null ? null : onStart,
        style: ElevatedButton.styleFrom(
          backgroundColor: NOteyColors.primary,
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: const Text('START RECORDING'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text('No courses found', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}
