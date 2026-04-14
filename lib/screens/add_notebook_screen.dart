// lib/screens/add/add_notebook_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../providers/course_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/toast_widget.dart';

class AddNotebookScreen extends ConsumerStatefulWidget {
  const AddNotebookScreen({super.key});

  @override
  ConsumerState<AddNotebookScreen> createState() => _AddNotebookScreenState();
}

class _AddNotebookScreenState extends ConsumerState<AddNotebookScreen> {
  final _nameCtrl = TextEditingController();
  final _instructorCtrl = TextEditingController();
  final _semesterCtrl = TextEditingController();

  static const _colorChoices = [
    Color(0xFFE53935), // red
    Color(0xFF43A047), // green
    Color(0xFF5E35B1), // purple
    Color(0xFFAB47BC), // violet
    Color(0xFFE91E63), // pink
  ];

  Color _selectedColor = _colorChoices.first;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _instructorCtrl.dispose();
    _semesterCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      AppToast.show(context, message: 'Please enter a course name', type: ToastType.error);
      return;
    }

    final success = await ref.read(courseProvider.notifier).addCourse(
      name,
      instructor: _instructorCtrl.text.trim(),
      color: _selectedColor.value.toRadixString(16),
    );

    if (!mounted) return;

    if (success) {
      AppToast.show(context, message: 'Notebook created successfully!', type: ToastType.success);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) context.pop();
    } else {
      AppToast.show(context, message: 'Failed to create notebook', type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(courseProvider.select((p) => p.isLoading));

    return LoadingWrapper(
      isLoading: isLoading,
      message: 'Creating notebook...',
      child: Scaffold(
        appBar: AppBar(
          leading: const ThemeToggleButton(),
          title: const Text('Add New NoteBook'),
          titleSpacing: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _label('Course Name'),
              const SizedBox(height: 8),
              CustomTextField(controller: _nameCtrl, hintText: 'e.g. Mobile Development'),
              const SizedBox(height: 20),
              _label('Instructor'),
              const SizedBox(height: 8),
              CustomTextField(controller: _instructorCtrl, hintText: 'e.g. Dr. Smith'),
              const SizedBox(height: 20),
              _label('Semester / Year'),
              const SizedBox(height: 8),
              CustomTextField(controller: _semesterCtrl, hintText: 'e.g. Fall 2024'),
              const SizedBox(height: 24),
              _label('Color'),
              const SizedBox(height: 12),
              Row(
                children: _colorChoices.map((c) {
                  final selected = c == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: Colors.black54, width: 3)
                            : null,
                      ),
                      child: selected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: isLoading ? null : _create,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C4DBF),
                ),
                child: const Text('CREATE NEW BOOK', style: TextStyle(letterSpacing: 0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
  );
}