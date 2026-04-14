// lib/screens/auth/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/notey_logo.dart';
import '../../widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/toast_widget.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      AppToast.show(
        context,
        message: 'Please fill in all fields',
        type: ToastType.error,
      );
      return;
    }

    final auth = ref.read(authProvider);
    final success = await auth.signUp(email, password, name);

    if (!mounted) return;

    if (success) {
      AppToast.show(
        context,
        message: 'Account created! Please verify your email.',
        type: ToastType.success,
      );
      // Small delay for the user to see the success message before navigation
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        context.go('${AppRoute.verification}?email=$email');
      }
    } else {
      AppToast.show(
        context,
        message: auth.errorMessage ?? 'Signup failed. Please try again.',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider.select((p) => p.isLoading));

    return LoadingWrapper(
      isLoading: isLoading,
      message: 'Creating account...',
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
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'sign up to benefit from full features',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Full  Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 8),
                CustomTextField(controller: _nameCtrl, hintText: 'John Doe'),
                const SizedBox(height: 20),
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
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : _signUp,
                  child: const Text('SIGN UP', style: TextStyle(letterSpacing: 2)),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Have an account already ? ',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppRoute.login),
                        child: Text(
                          'sign In',
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
