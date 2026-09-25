import 'package:flutter/material.dart';

import '../../../domain/models/app_language.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/keycap.dart';

class LanguageSheet extends StatefulWidget {
  const LanguageSheet({super.key, required this.current});

  final AppLanguage current;

  static Future<AppLanguage?> show(
    BuildContext context, {
    required AppLanguage current,
  }) => showModalBottomSheet<AppLanguage>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.palette.surface,
    barrierColor: AppColors.keycapEdge.withValues(alpha: .35),
    showDragHandle: true,
    builder: (_) => LanguageSheet(current: current),
  );

  @override
  State<LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<LanguageSheet> {
  late AppLanguage _picked = widget.current;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .86,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'App language',
              style: AppTextStyles.display.copyWith(
                fontSize: 24,
                color: context.palette.text,
              ),
            ),
            Text(
              'Pebby and your study cards will use this language.',
              style: AppTextStyles.label.copyWith(
                color: context.palette.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final language in AppLanguage.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _LanguageKey(
                        language: language,
                        isSelected: language == _picked,
                        onTap: () => setState(() => _picked = language),
                      ),
                    ),
                  const _ComingSoon(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: _picked == widget.current
                  ? 'OK'
                  : 'OK · Switch to ${_picked.nativeName}',
              isPrimary: true,
              onTap: () => Navigator.of(
                context,
              ).pop(_picked == widget.current ? null : _picked),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageKey extends StatelessWidget {
  const _LanguageKey({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      label: language.englishName,
      child: Keycap(
        face: isSelected ? AppColors.selected : context.palette.surface,
        depth: 3,
        height: 64,
        isLatched: isSelected,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.nativeName,
                      style: AppTextStyles.labelStrong.copyWith(
                        fontSize: 16,
                        color: context.palette.text,
                      ),
                    ),
                    Text(
                      '${language.englishName} · ${language.sample}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected
                            ? AppColors.selectedInk
                            : context.palette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: context.palette.text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLanguage.comingSoon.join(' · '),
              style: AppTextStyles.labelStrong.copyWith(
                color: context.palette.textMuted,
              ),
            ),
            Text(
              'More languages coming soon',
              style: AppTextStyles.caption.copyWith(
                color: context.palette.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
