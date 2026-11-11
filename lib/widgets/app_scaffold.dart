import 'package:flutter/material.dart';

import 'app_background.dart';
import 'theme_toggle_button.dart';

/// Structure commune des écrans : fond, en-tête compact (retour, titre, thème).
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.title,
    this.leading,
    this.showBack = true,
  });

  final Widget child;
  final String? title;
  final Widget? leading;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Row(children: [
                if (showBack && Navigator.of(context).canPop()) ...[
                  GlassIconButton(
                    tooltip: 'Retour',
                    onTap: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  ),
                  const SizedBox(width: 12),
                ],
                if (leading != null) ...[leading!, const SizedBox(width: 10)],
                Expanded(
                  child: Text(
                    title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const ThemeToggleButton(),
              ]),
            ),
            Expanded(child: child),
          ]),
        ),
      ),
    );
  }
}
