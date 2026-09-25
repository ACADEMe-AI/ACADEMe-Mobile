import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/app_back_button.dart';
import '../../core/ui/brand_mark.dart';
import '../../core/ui/screen_scale.dart';
import '../../core/ui/split_headline.dart';
import '../../core/ui/stagger.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({
    super.key,
    required this.pebby,
    required this.lead,
    required this.accent,
    required this.subtitle,
    required this.children,
  });

  final Widget pebby;
  final String lead;
  final String accent;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scale = ScreenScale.of(context);
    final palette = context.palette;

    return AnnotatedRegion(
      value: palette.systemBars,
      child: Scaffold(
        backgroundColor: palette.surface,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    scale.pagePadding,
                    8,
                    scale.pagePadding,
                    16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const AppBackButton(),
                          const Spacer(),
                          BrandMark(size: scale.markSize * .8, atEnd: true),
                        ],
                      ),
                      Center(
                        child: SizedBox.square(
                          dimension: (scale.headlineSize * 3).clamp(
                            132.0,
                            196.0,
                          ),
                          child: pebby,
                        ),
                      ),
                      Stagger(
                        gap: 0,
                        delay: const Duration(milliseconds: 120),
                        step: const Duration(milliseconds: 60),
                        children: [
                          const SizedBox(height: 24),
                          SplitHeadline(
                            lead: lead,
                            accent: accent,
                            size: scale.headlineSize * .82,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: scale.bodySize,
                              height: 1.45,
                              color: palette.textMuted,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ...children,
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
