import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../me/widgets/account_screen.dart';
import '../../me/widgets/appearance_screen.dart';
import '../../me/widgets/appearance_switch_screen.dart';
import '../../me/widgets/class_board_screen.dart';
import '../../me/widgets/delete_account_screen.dart';
import '../../me/widgets/language_sheet.dart';
import '../../me/widgets/language_switch_screen.dart';
import '../../me/widgets/notifications_screen.dart';
import 'app_shell.dart';

mixin MeNavigation on State<AppShell> {
  void showMessage(String message);

  Future<T?> pushMe<T>(Widget page) =>
      Navigator.of(context).push<T>(MaterialPageRoute<T>(builder: (_) => page));

  Future<void> openClassAndBoard() async {
    final message = await pushMe<String>(
      ClassBoardScreen(viewModel: widget.me),
    );
    if (message != null) showMessage(message);
  }

  Future<void> openLanguage() async {
    final picked = await LanguageSheet.show(
      context,
      current: widget.me.language,
    );
    if (picked == null || !mounted) return;
    final switched = await pushMe<bool>(
      LanguageSwitchScreen(viewModel: widget.me, language: picked),
    );
    if (!mounted) return;
    showMessage(
      switched == true
          ? '${picked.greeting} Pebby will now answer in ${picked.nativeName}.'
          : 'Couldn’t switch the language. Try again.',
    );
  }

  void openAppearance() => pushMe<void>(
    AppearanceScreen(
      viewModel: widget.me,
      onPick: (isDark) => pushMe<void>(
        AppearanceSwitchScreen(viewModel: widget.me, isDark: isDark),
      ),
    ),
  );

  Future<void> openNotifications() async {
    await pushMe<void>(NotificationsScreen(viewModel: widget.me));
    widget.onRemindersWanted?.call();
  }

  void openAccount() => pushMe<void>(
    AccountScreen(
      viewModel: widget.me,
      onDeleteAccount: () => pushMe<void>(
        DeleteAccountScreen(
          viewModel: widget.me,
          onDeleted: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      ),
    ),
  );

  Future<void> confirmLogOut() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: context.palette.surface,
      showDragHandle: true,
      builder: (context) => const _LogOutSheet(),
    );
    if (confirmed == true) await widget.me.logOut.execute();
  }
}

class _LogOutSheet extends StatelessWidget {
  const _LogOutSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Log out?',
              style: AppTextStyles.display.copyWith(
                fontSize: 24,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your progress is saved to your account. Log in again any time.',
              style: AppTextStyles.label.copyWith(
                color: context.palette.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Stay',
              onTap: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Log out',
              isPrimary: true,
              onTap: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
  }
}
