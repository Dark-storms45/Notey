// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    this.subtitle = '',
    required this.isFirst,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isFirst;
}

const _pages = [
  _OnboardingPage(
    icon: Icons.mic,
    title: 'Your lectures,Recorded,\nTranscribed and summerized',
    isFirst: true,
  ),
  _OnboardingPage(
    icon: Icons.mic_none_outlined,
    title: 'Crystal clear Recording',
    subtitle: 'Advanced noise isolation ensures\nevery word is captured perfectly',
    isFirst: false,
  ),
  _OnboardingPage(
    icon: Icons.auto_awesome,
    title: 'Smart Summaries',
    subtitle: '',
    isFirst: false,
  ),
  _OnboardingPage(
    icon: Icons.menu_book_rounded,
    title: 'Course NoteBooks',
    subtitle: '',
    isFirst: false,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _current = 0;

  void _next() {
    if (_current < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoute.login);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // skip
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 20),
                child: GestureDetector(
                  onTap: () => context.go(AppRoute.login),
                  child: Text(
                    'skip',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            // pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _current = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _PageContent(page: _pages[i]),
              ),
            ),
            // dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _current;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 28 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: active ? NOteyColors.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            // NEXT button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: NOteyColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'NEXT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.chevron_right, size: 22),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});
  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (page.isFirst)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: NOteyColors.primary,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(page.icon, size: 56, color: Colors.white),
            )
          else
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(page.icon, size: 64, color: NOteyColors.primary),
            ),
          const SizedBox(height: 40),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: page.isFirst ? 15 : 22,
              fontWeight: page.isFirst ? FontWeight.w400 : FontWeight.w800,
              color: Colors.black,
              height: 1.4,
            ),
          ),
          if (page.subtitle.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              page.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}