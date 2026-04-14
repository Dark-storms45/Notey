// lib/widgets/social_auth_button.dart
import 'package:flutter/material.dart';

/// Outlined button for social auth providers (Google, Apple).
class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    required this.label,
    required this.onPressed,
    required this.icon,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(
          color: isDark ? Colors.white24 : Colors.grey.shade300,
          width: 1,
        ),
        backgroundColor: isDark ? Colors.white10 : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }
}