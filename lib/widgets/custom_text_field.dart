// lib/widgets/custom_text_field.dart
import 'package:flutter/material.dart';

/// Reusable text field matching the NOtey design system.
/// Applies the theme's [InputDecorationTheme] automatically.
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.controller,
    this.hintText = '',
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
      ),
    );
  }
}