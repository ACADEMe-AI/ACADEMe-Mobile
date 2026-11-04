import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/screen_scale.dart';

class StudyPage extends StatelessWidget {
  const StudyPage({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

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
                padding: EdgeInsets.fromLTRB(padding - 8, 4, padding - 8, 0),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelStrong.copyWith(
                          color: context.palette.text,
                        ),
                      ),
                    ),
                    ...actions,
                  ],
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.subhead.copyWith(
                fontSize: 15,
                color: context.palette.text,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class LinkRow extends StatelessWidget {
  const LinkRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 40,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.surfaceRaised,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, size: 20, color: palette.text),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelStrong.copyWith(
                        color: palette.text,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: palette.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              trailing ??
                  Icon(Icons.chevron_right_rounded, color: palette.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
