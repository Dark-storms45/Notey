
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/recording_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).currentUser;
    final recordings = ref.watch(recordingsProvider).recordings;
    final courses = ref.watch(courseProvider).courses;

    final name = user?.userMetadata?['full_name'] ?? 'User';
    final initials = name.split(' ').map((e) => e[0]).take(2).join().toUpperCase();

    // Calculate dynamic stats
    final recordingCount = recordings.length;
    final courseCount = courses.length;
    
    // Calculate total hours (approximate from duration in seconds)
    final totalSeconds = recordings.fold(0, (sum, rec) => sum + (rec.duration ?? 0));
    final totalHours = (totalSeconds / 3600).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        leading: const ThemeToggleButton(),
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Avatar + name
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Stats
            Row(
              children: [
                _StatCard(value: recordingCount.toString(), label: 'Recording'),
                const SizedBox(width: 12),
                _StatCard(value: totalHours, label: 'Total Hours'),
                const SizedBox(width: 12),
                _StatCard(value: courseCount.toString(), label: 'Course'),
              ],
            ),
            const SizedBox(height: 24),
            // Recording settings
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey.shade900 
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recording',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Divider(),
                  const Text('Audio Quality', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      _SettingChip(label: 'Standard', selected: true),
                      SizedBox(width: 10),
                      _SettingChip(label: 'High', selected: false),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Text('Export Format', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      _SettingChip(label: 'Docx', selected: true),
                      SizedBox(width: 10),
                      _SettingChip(label: 'PDF', selected: false),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Log out
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 0.5,
                ),
              ),
              child: GestureDetector(
                onTap: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go(AppRoute.login);
                  }
                },
                child: Row(
                  children: const [
                    Icon(Icons.logout, size: 22),
                    SizedBox(width: 12),
                    Text('Log out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey.shade900 
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _SettingChip extends StatelessWidget {
  const _SettingChip({required this.label, required this.selected});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF1C4DBF) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}