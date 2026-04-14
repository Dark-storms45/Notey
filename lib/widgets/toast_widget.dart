
import 'package:flutter/material.dart';
import 'dart:async';


enum ToastType { success, error, warning, info, recording, custom }


class _ToastStyle {
  const _ToastStyle({
    required this.background,
    required this.border,
    required this.iconColor,
    required this.icon,
  });
  final Color background;
  final Color border;
  final Color iconColor;
  final IconData icon;
}

final _kStyles = {
  ToastType.success: const _ToastStyle(
    background: Color(0xFFEAF3DE),
    border:     Color(0xFF3B6D11),
    iconColor:  Color(0xFF27500A),
    icon: Icons.check_circle_outline_rounded,
  ),
  ToastType.error: const _ToastStyle(
    background: Color(0xFFFCEBEB),
    border:     Color(0xFFA32D2D),
    iconColor:  Color(0xFF791F1F),
    icon: Icons.cancel_outlined,
  ),
  ToastType.warning: const _ToastStyle(
    background: Color(0xFFFAEEDA),
    border:     Color(0xFF854F0B),
    iconColor:  Color(0xFF633806),
    icon: Icons.warning_amber_rounded,
  ),
  ToastType.info: const _ToastStyle(
    background: Color(0xFFE6F1FB),
    border:     Color(0xFF185FA5),
    iconColor:  Color(0xFF0C447C),
    icon: Icons.info_outline_rounded,
  ),
  ToastType.recording: const _ToastStyle(
    background: Color(0xFFFBEAF0),
    border:     Color(0xFF993556),
    iconColor:  Color(0xFF72243E),
    icon: Icons.mic_none_rounded,
  ),
  ToastType.custom: _ToastStyle(
    // custom uses the `color` param; these are fallbacks
    background: const Color(0x1FE040C8),
    border:     const Color(0xFFE040C8),
    iconColor:  const Color(0xFF993556),
    icon: Icons.auto_awesome_rounded,
  ),
};

// ─── Toast widget ─────────────────────────────────────────────────────────────

/// A flexible toast notification ("roast") widget.
///
/// Usage:
/// ```dart
/// // Show via overlay helper:
/// AppToast.show(
///   context,
///   type: ToastType.success,
///   message: 'Recording saved successfully.',
/// );
///
/// // Or with a custom colour:
/// AppToast.show(
///   context,
///   type: ToastType.custom,
///   color: Color(0xFFE040C8),
///   title: 'Card updated',
///   message: 'Your card colour was saved.',
/// );
/// ```
class AppToastWidget extends StatefulWidget {
  const AppToastWidget({
    required this.message,
    required this.type,
    this.title,
    /// Effective only when [type] == [ToastType.custom].
    this.color,
    this.duration = const Duration(seconds: 4),
    this.onDismiss,
    super.key,
  });

  final String message;
  final ToastType type;
  final String? title;
  final Color? color;
  final Duration duration;
  final VoidCallback? onDismiss;

  @override
  State<AppToastWidget> createState() => _AppToastWidgetState();
}

class _AppToastWidgetState extends State<AppToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();

    _timer = Timer(widget.duration, _dismiss);
  }

  void _dismiss() {
    _ctrl.reverse().then((_) => widget.onDismiss?.call());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  _ToastStyle get _style {
    if (widget.type == ToastType.custom && widget.color != null) {
      final c = widget.color!;
      return _ToastStyle(
        background: c.withOpacity(0.12),
        border:     c,
        iconColor:  c,
        icon: Icons.auto_awesome_rounded,
      );
    }
    return _kStyles[widget.type] ?? _kStyles[ToastType.info]!;
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    return FadeTransition(
      opacity: _anim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(_anim),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: style.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: style.border.withOpacity(0.25), width: 0.8),
          ),
          child: Row(
            children: [
              // Icon circle
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: style.border.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(style.icon, color: style.iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.title != null)
                      Text(
                        widget.title!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: style.iconColor,
                        ),
                      ),
                    Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: style.iconColor.withOpacity(0.85),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Dismiss
              GestureDetector(
                onTap: _dismiss,
                child: Icon(Icons.close, size: 16, color: style.iconColor.withOpacity(0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Overlay helper ───────────────────────────────────────────────────────────

/// Static helper to show a toast from anywhere.
///
/// ```dart
/// AppToast.show(context, type: ToastType.success, message: 'Done!');
/// AppToast.show(context, type: ToastType.custom, color: Color(0xFFE040C8), message: 'Card updated');
/// ```
class AppToast {
  AppToast._();

  static void show(
      BuildContext context, {
        required ToastType type,
        required String message,
        String? title,
        Color? color,
        Duration duration = const Duration(seconds: 4),
        /// Position from bottom of screen
        double bottomOffset = 100,
      }) {
    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: 16,
        right: 16,
        bottom: bottomOffset,
        child: Material(
          color: Colors.transparent,
          child: AppToastWidget(
            type: type,
            message: message,
            title: title,
            color: color,
            duration: duration,
            onDismiss: () => entry?.remove(),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(entry);
  }
}