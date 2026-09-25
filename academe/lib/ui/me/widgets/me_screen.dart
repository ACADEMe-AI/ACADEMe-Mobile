import 'package:flutter/material.dart';

import '../../../domain/models/level.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/keycap.dart';
import '../../core/ui/screen_scale.dart';
import '../view_models/me_view_model.dart';
import 'settings_list.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({
    super.key,
    required this.viewModel,
    required this.onClassAndBoard,
    required this.onLanguage,
    required this.onAppearance,
    required this.onNotifications,
    required this.onAccount,
    required this.onHelp,
    required this.onPrivacy,
    required this.onLogOut,
    this.pro,
  });

  final MeViewModel viewModel;
  final VoidCallback onClassAndBoard;
  final VoidCallback onLanguage;
  final VoidCallback onAppearance;
  final VoidCallback onNotifications;
  final VoidCallback onAccount;
  final VoidCallback onHelp;
  final VoidCallback onPrivacy;
  final VoidCallback onLogOut;
  final Widget? pro;

  static const version = 'ACADEMe 2.0.0';

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => ListView(
        padding: EdgeInsets.fromLTRB(
          padding,
          8,
          padding,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          _ProfileCard(viewModel: viewModel),
          const SizedBox(height: 12),
          _Stats(xp: viewModel.profile.xp, level: viewModel.level),
          if (pro case final card?) ...[const SizedBox(height: 16), card],
          SettingsGroup(
            title: 'Learning',
            children: [
              SettingsRow(
                label: 'Class and board',
                value: viewModel.syllabusLabel,
                onTap: onClassAndBoard,
              ),
              SettingsRow(
                label: 'App language',
                value: viewModel.language.nativeName,
                onTap: onLanguage,
              ),
              SettingsRow(
                label: 'Appearance',
                value: viewModel.appearanceLabel,
                onTap: onAppearance,
              ),
            ],
          ),
          SettingsGroup(
            title: 'Notifications',
            children: [
              SettingsRow(
                label: 'Reminders and daily goal',
                value: viewModel.notificationsLabel,
                onTap: onNotifications,
              ),
            ],
          ),
          SettingsGroup(
            title: 'Account',
            children: [
              SettingsRow(label: 'Account', onTap: onAccount),
              SettingsRow(label: 'Help and feedback', onTap: onHelp),
              SettingsRow(label: 'Privacy and terms', onTap: onPrivacy),
            ],
          ),
          const SizedBox(height: 24),
          Keycap(
            face: context.palette.tintRose,
            depth: AppKeycap.buttonDepth,
            height: 56,
            isEnabled: !viewModel.logOut.isRunning,
            onTap: onLogOut,
            child: Center(
              child: Text(
                viewModel.logOut.isRunning ? 'Logging out…' : 'Log out',
                style: AppTextStyles.button.copyWith(
                  color: context.palette.errorInk,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            version,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: context.palette.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.viewModel});

  final MeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final account = viewModel.account;
    final name = '${account?.firstName ?? ''} ${account?.lastName ?? ''}'
        .trim();
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.palette.tintLavender,
            borderRadius: BorderRadius.circular(AppRadius.lg + 4),
            border: Border.all(
              color: context.palette.edge,
              width: AppKeycap.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: context.palette.edge,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SizedBox.square(
            dimension: 64,
            child: Center(
              child: Text(
                initial,
                style: AppTextStyles.display.copyWith(
                  fontSize: 30,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? 'Student' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.display.copyWith(
                  fontSize: 24,
                  color: context.palette.text,
                ),
              ),
              if (account?.email case final email?)
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: context.palette.textMuted,
                  ),
                ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  _Chip(viewModel.syllabusLabel),
                  _Chip(viewModel.language.nativeName),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: context.palette.text,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.xp, required this.level});

  final int xp;
  final Level level;

  static const streak = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Stat(
            leading: Icon(
              Icons.local_fire_department_rounded,
              size: 22,
              color: streak > 0 ? AppColors.streak : context.palette.border,
            ),
            value: '$streak',
            label: 'day streak',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Stat(
            value: 'Lv ${level.number}',
            label: '${level.toNext(xp)} XP to Lv ${level.number + 1}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Stat(
            leading: const Icon(
              Icons.bolt_rounded,
              size: 22,
              color: AppColors.selected,
            ),
            value: '$xp',
            label: 'XP',
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.leading});

  final String value;
  final String label;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ?leading,
                Text(
                  value,
                  style: AppTextStyles.display.copyWith(
                    fontSize: 22,
                    color: context.palette.text,
                  ),
                ),
              ],
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: AppTextStyles.caption.copyWith(
                color: context.palette.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
