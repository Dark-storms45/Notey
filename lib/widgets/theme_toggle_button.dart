import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

/// Replaces the hamburger / side-nav icon throughout the app.
/// Reads `themeModeProvider` and toggles between light ↔ dark.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final isDark = mode == ThemeMode.dark;

    return IconButton(
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) =>
            RotationTransition(turns: anim, child: FadeTransition(opacity: anim, child: child)),
        child: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          key: ValueKey(isDark),
          size: 22,
        ),
      ),
      onPressed: () {
        ref.read(themeModeProvider.notifier).state =
        isDark ? ThemeMode.light : ThemeMode.dark;
      },
    );
  }
}