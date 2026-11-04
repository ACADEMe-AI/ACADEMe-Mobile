import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/screen_scale.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.title,
    required this.children,
    this.bottom,
  });

  final String title;
  final List<Widget> children;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    return AnnotatedRegion(
      value: context.palette.systemBars,
      child: Scaffold(
        backgroundColor: context.palette.surface,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(padding - 8, 4, padding, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      tooltip: 'Back',
                      icon: const Icon(Icons.chevron_left_rounded, size: 28),
                      color: context.palette.text,
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.display.copyWith(
                          fontSize: 24,
                          color: context.palette.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(padding, 0, padding, 24),
                  children: children,
                ),
              ),
              if (bottom case final button?)
                Padding(
                  padding: EdgeInsets.fromLTRB(padding, 8, padding, 16),
                  child: button,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
