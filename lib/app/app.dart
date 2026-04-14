// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'routes.dart';

// Assumed existing provider from providers/theme_provider.dart
// import '../providers/theme_provider.dart';

/// Temporary stub – replace with your real provider import.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class NOteyApp extends ConsumerWidget {
  const NOteyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'NOtey',
      debugShowCheckedModeBanner: false,
      theme: NOteyTheme.lightTheme,
      darkTheme: NOteyTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}