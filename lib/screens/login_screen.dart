// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/notey_logo.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/social_auth_button.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/toast_widget.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      AppToast.show(
        context, 
        message: 'Please fill in all fields', 
        type: ToastType.error
      );
      return;
    }

    final auth = ref.read(authProvider);
    final success = await auth.signIn(email, password);

    if (!mounted) return;

    if (success) {
      AppToast.show(
        context, 
        message: 'Login successful! Welcome back.',
        type: ToastType.success
      );
      // Small delay for the user to see the success message
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) context.go(AppRoute.home);
    } else {
      AppToast.show(
        context, 
        message: auth.errorMessage ?? 'Login failed. Please check your credentials.', 
        type: ToastType.error
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch loading state to show overlay
    final isLoading = ref.watch(authProvider.select((p) => p.isLoading));

    return LoadingWrapper(
      isLoading: isLoading,
      message: 'Logging in...',
      variant: LoadingVariant.ring,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Center(child: NOteyLogoStatic()),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Login to access your account',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _emailCtrl,
                  hintText: 'example@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _passCtrl,
                  hintText: '••••••••••••',
                  obscureText: _obscure,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'forgot password ?',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  child: const Text('LOGIN', style: TextStyle(letterSpacing: 2)),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or login with',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SocialAuthButton(
                        label: 'Google',
                        onPressed: () {},
                        icon: Icons.g_mobiledata,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SocialAuthButton(
                        label: 'Apple',
                        onPressed: () {},
                        icon: Icons.apple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account ? ",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppRoute.signup),
                        child: Text(
                          'sign up',
                          style: TextStyle(
                            color: NOteyColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}