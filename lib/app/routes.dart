// lib/app/routes.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Screen imports
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/verification_screen.dart';
import '../screens/home_screen.dart';
import '../screens/library_screen.dart';
import '../screens/add_notebook_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/recording_screen.dart';
import '../screens/summary_screen.dart';

// ─── Route names ─────────────────────────────────────────────────────────────
abstract class AppRoute {
  static const splash       = '/';
  static const onboarding   = '/onboarding';
  static const login        = '/login';
  static const signup       = '/signup';
  static const verification = '/verification';
  static const home         = '/home';
  static const library      = '/library';
  static const add          = '/add';
  static const profile      = '/profile';
  static const recording    = '/recording/:courseId';
  static const summary      = '/summary/:noteId';
}

// ─── Router provider ─────────────────────────────────────────────────────────

/// Stub – replace with your real authProvider.
final _authStateProvider = StateProvider<bool>((ref) => false);

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(_authStateProvider);

  return GoRouter(
    initialLocation: AppRoute.splash,
    redirect: (context, state) {
      final onAuthPage = state.matchedLocation == AppRoute.login ||
          state.matchedLocation == AppRoute.signup ||
          state.matchedLocation == AppRoute.verification ||
          state.matchedLocation == AppRoute.onboarding ||
          state.matchedLocation == AppRoute.splash;

      if (!isAuthenticated && !onAuthPage) return AppRoute.login;
      if (isAuthenticated && onAuthPage) return AppRoute.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoute.splash,
        pageBuilder: (ctx, state) => _fade(const SplashScreen(), state),
      ),
      GoRoute(
        path: AppRoute.onboarding,
        pageBuilder: (ctx, state) => _fade(const OnboardingScreen(), state),
      ),
      GoRoute(
        path: AppRoute.login,
        pageBuilder: (ctx, state) => _fade(const LoginScreen(), state),
      ),
      GoRoute(
        path: AppRoute.signup,
        pageBuilder: (ctx, state) => _fade(const SignupScreen(), state),
      ),
      GoRoute(
        path: AppRoute.verification,
        pageBuilder: (ctx, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return _fade(VerificationScreen(email: email), state);
        },
      ),
      // ── Shell route for main tab navigation ────────────────────────────
      ShellRoute(
        builder: (ctx, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoute.home,
            pageBuilder: (ctx, state) => _noTransition(const HomeScreen(), state),
          ),
          GoRoute(
            path: AppRoute.library,
            pageBuilder: (ctx, state) => _noTransition(const LibraryScreen(), state),
          ),
          GoRoute(
            path: AppRoute.add,
            pageBuilder: (ctx, state) => _noTransition(const AddNotebookScreen(), state),
          ),
          GoRoute(
            path: AppRoute.profile,
            pageBuilder: (ctx, state) => _noTransition(const ProfileScreen(), state),
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.recording,
        pageBuilder: (ctx, state) {
          final courseId = state.pathParameters['courseId'] ?? '';
          return _slide(RecordingScreen(courseId: courseId), state);
        },
      ),
      GoRoute(
        path: AppRoute.summary,
        pageBuilder: (ctx, state) {
          final noteId = state.pathParameters['noteId'] ?? '';
          return _slide(SummaryScreen(noteId: noteId), state);
        },
      ),
    ],
    errorBuilder: (ctx, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

// ─── Page transition helpers ─────────────────────────────────────────────────
CustomTransitionPage<void> _fade(Widget child, GoRouterState state) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (ctx, animation, _, c) =>
          FadeTransition(opacity: animation, child: c),
    );

CustomTransitionPage<void> _noTransition(Widget child, GoRouterState state) =>
    NoTransitionPage<void>(key: state.pageKey, child: child);

CustomTransitionPage<void> _slide(Widget child, GoRouterState state) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (ctx, animation, _, c) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1), end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: c,
      ),
    );

// ─── Main Shell (bottom navigation) ──────────────────────────────────────────
class MainShell extends ConsumerWidget {
  const MainShell({required this.child, super.key});
  final Widget child;

  static const _tabs = [
    AppRoute.home,
    AppRoute.library,
    AppRoute.add,
    AppRoute.profile,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabs.indexWhere((t) => location.startsWith(t));

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex < 0 ? 0 : currentIndex,
        onTap: (i) => context.go(_tabs[i]),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books_outlined), activeIcon: Icon(Icons.library_books), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}