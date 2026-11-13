import 'package:flutter/material.dart';

import '../../../routing/routes.dart';
import '../../../utils/dates.dart';
import '../../../utils/result.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/pebby.dart';
import '../../core/ui/top_notice.dart';
import '../../me/widgets/account_screen.dart';
import '../../me/widgets/appearance_screen.dart';
import '../../me/widgets/appearance_switch_screen.dart';
import '../../me/widgets/class_board_screen.dart';
import '../../me/widgets/delete_account_screen.dart';
import '../../me/widgets/language_sheet.dart';
import '../../me/widgets/language_switch_screen.dart';
import '../../me/widgets/notifications_screen.dart';
import '../../progress/view_models/progress_view_model.dart';
import '../../progress/widgets/progress_screen.dart';
import 'app_shell.dart';

mixin MeNavigation on State<AppShell> {
  void showMessage(
    String message, {
    TopNoticeKind kind = TopNoticeKind.success,
    double? pose,
  });

  void onLeft() {
    if (widget.me.deleteAccount.result case Ok(:final value)) {
      showMessage(
        context.l10n.deleteScheduledSnack(longDate(value.toLocal())),
        pose: PebbyPose.noticeGoodbye,
      );
      widget.onLoggedOut?.call();
    } else if (widget.me.logOut.isCompleted) {
      widget.onLoggedOut?.call();
    }
  }

  Future<T?> pushMe<T>(Widget page) =>
      Navigator.of(context).push<T>(MaterialPageRoute<T>(builder: (_) => page));

  Future<void> openClassAndBoard() async {
    final message = await pushMe<String>(
      ClassBoardScreen(viewModel: widget.me),
    );
    if (message != null) {
      showMessage(message, pose: PebbyPose.noticeSaved);
    }
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
    if (switched == true) {
      showMessage(
        context.l10n.meLanguageSwitched(picked.greeting, picked.nativeName),
        pose: PebbyPose.noticeLanguageDone,
      );
    } else {
      showMessage(
        context.l10n.meLanguageSwitchFailed,
        kind: TopNoticeKind.error,
        pose: PebbyPose.noticeError,
      );
    }
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

  void openProgress() {
    final pro = widget.pro;
    if (pro == null) return;
    final progress = ProgressViewModel(
      progress: widget.progressRepository,
      billing: widget.billingRepository,
    );
    pushMe<void>(
      ProgressScreen(
        me: widget.me,
        progress: progress,
        onGoPro: () async {
          await Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamed<bool>(Routes.paywall);
          if (!mounted) return;
          await pro.load.execute();
          await progress.ensureLoaded(force: true);
        },
      ),
    ).whenComplete(progress.dispose);
  }

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
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.meLogOutTitle,
              style: AppTextStyles.display.copyWith(
                fontSize: 24,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.meLogOutBody,
              style: AppTextStyles.label.copyWith(
                color: context.palette.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: l10n.meLogOutStay,
              onTap: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: l10n.meLogOut,
              isPrimary: true,
              onTap: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
  }
}
