import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../domain/models/app_language.dart';
import '../../../core/themes/app_theme.dart';
import 'setup_step_frame.dart';

class LanguageStep extends StatefulWidget {
  const LanguageStep({
    super.key,
    required this.initial,
    required this.isSaving,
    required this.onSubmit,
  });

  final AppLanguage? initial;
  final bool isSaving;
  final ValueChanged<AppLanguage> onSubmit;

  @override
  State<LanguageStep> createState() => _LanguageStepState();
}

class _LanguageStepState extends State<LanguageStep> {
  late int _index = (widget.initial ?? AppLanguage.english).index;
  late final _pages = PageController(
    viewportFraction: .56,
    initialPage: _index,
  );

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    HapticFeedback.selectionClick();
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final language = AppLanguage.values[_index];
    return SetupStepFrame(
      title: 'Which language do you learn in?',
      buttonLabel: 'Choose ${language.nativeName}',
      isSaving: widget.isSaving,
      onSubmit: () => widget.onSubmit(language),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 228,
            child: PageView.builder(
              controller: _pages,
              itemCount: AppLanguage.values.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) => _LanguageCard(
                language: AppLanguage.values[index],
                tint: context.palette.tints[index % 5],
                pages: _pages,
                index: index,
                onTap: () => _pages.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Dots(count: AppLanguage.values.length, active: _index),
          const SizedBox(height: 12),
          Text(
            'You can change it any time in Settings.',
            style: AppTextStyles.caption.copyWith(
              color: context.palette.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.language,
    required this.tint,
    required this.pages,
    required this.index,
    required this.onTap,
  });

  final AppLanguage language;
  final Color tint;
  final PageController pages;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pages,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: context.palette.edge,
              width: AppKeycap.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: context.palette.edge,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  language.greeting,
                  style: AppTextStyles.display.copyWith(
                    fontSize: 32,
                    color: context.palette.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  language.nativeName,
                  style: AppTextStyles.display.copyWith(
                    fontSize: 20,
                    color: context.palette.text,
                  ),
                ),
                Text(
                  language.englishName,
                  style: AppTextStyles.caption.copyWith(
                    color: context.palette.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      builder: (context, child) {
        final page = pages.hasClients && pages.position.haveDimensions
            ? pages.page ?? index.toDouble()
            : pages.initialPage.toDouble();
        final distance = (page - index).abs().clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Transform.scale(scale: 1 - distance * .16, child: child),
        );
      },
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == active ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == active ? AppColors.primary : context.palette.border,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
      ],
    );
  }
}
