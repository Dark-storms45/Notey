// lib/widgets/app_bar_with_title.dart
import 'package:flutter/material.dart';
import 'theme_toggle_button.dart';

/// Standard NOtey AppBar with ThemeToggleButton as leading,
/// optional search and action icons.
class AppBarWithTitle extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWithTitle({
    required this.title,
    this.showSearch = false,
    this.extraActions = const [],
    super.key,
  });

  final String title;
  final bool showSearch;
  final List<Widget> extraActions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: const ThemeToggleButton(),
      title: Text(title),
      actions: [
        if (showSearch)
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ...extraActions,
      ],
    );
  }
}