// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/routes.dart';
import '../widgets/notey_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _barsAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _barsAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Navigate after splash
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go(AppRoute.onboarding);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3),
          AnimatedBuilder(
            animation: _barsAnim,
            builder: (_, __) => NOteyLogoAnimated(progress: _barsAnim.value),
          ),
          const SizedBox(height: 24),
          const Text(
            'NOtey',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const Spacer(flex: 3),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Color(0xFF7B3FE4),
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'loading ...',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}