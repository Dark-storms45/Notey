// lib/screens/auth/verification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/toast_widget.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({required this.email, super.key});
  final String email;

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  // Supabase OTPs are typically 6 digits
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    // Auto-verify if last digit is entered
    if (index == 5 && value.isNotEmpty) {
      _verify();
    }
  }

  Future<void> _verify() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      AppToast.show(context, message: 'Please enter the full 6-digit code', type: ToastType.error);
      return;
    }

    final auth = ref.read(authProvider.notifier);
    final success = await auth.verifyEmail(widget.email, otp);

    if (!mounted) return;

    if (success) {
      AppToast.show(context, message: 'Email verified successfully!', type: ToastType.success);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) context.go(AppRoute.home);
    } else {
      AppToast.show(context, message: ref.read(authProvider).errorMessage ?? 'Verification failed', type: ToastType.error);
    }
  }

  Future<void> _resend() async {
    final auth = ref.read(authProvider.notifier);
    final success = await auth.resendVerificationEmail(widget.email);

    if (!mounted) return;

    if (success) {
      AppToast.show(context, message: 'Verification code resent!', type: ToastType.success);
    } else {
      AppToast.show(context, message: ref.read(authProvider).errorMessage ?? 'Failed to resend code', type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider.select((p) => p.isLoading));

    return LoadingWrapper(
      isLoading: isLoading,
      message: 'Verifying code...',
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left, size: 28),
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verification',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.mail_outline_rounded, size: 48, color: NOteyColors.primary),
                ),
                const SizedBox(height: 32),
                Text(
                  'Enter the verification code we sent to\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 40),
                // OTP boxes
                FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) => _OtpBox(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      onChanged: (v) => _onDigitEntered(i, v),
                    )),
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: isLoading ? null : _verify,
                  child: const Text('VERIFY', style: TextStyle(letterSpacing: 2)),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code ? ",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: isLoading ? null : _resend,
                      child: Text(
                        'Resend',
                        style: TextStyle(
                          color: NOteyColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          filled: false,
        ),
        onChanged: onChanged,
      ),
    );
  }
}