import 'package:flutter/material.dart';

import '../../../domain/models/reminder.dart';
import '../../../domain/models/study_preferences.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../view_models/me_view_model.dart';
import 'daily_goal_sheet.dart';
import 'reminder_time_sheet.dart';
import 'settings_list.dart';
import 'settings_page.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.viewModel});

  final MeViewModel viewModel;

  static const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final p = viewModel.preferences;
        void update(StudyPreferences next) => viewModel.updatePreferences(next);
        final hour = p.reminderHour;
        final hour12 = hour % 12 == 0 ? 12 : hour % 12;
        final minute = p.reminderMinute.toString().padLeft(2, '0');
        final period = hour < 12 ? l10n.reminderAm : l10n.reminderPm;
        final reminderLabel = '$hour12:$minute $period';
        return SettingsPage(
          title: l10n.notifRemindersAndGoalTitle,
          children: [
            if (viewModel.notificationAccess != NotificationAccess.unknown)
              _AccessGroup(
                access: viewModel.notificationAccess,
                onTurnOn: viewModel.turnOnNotifications,
              ),
            SettingsGroup(
              title: l10n.notifStudyReminder,
              children: [
                SettingsSwitchRow(
                  label: l10n.notifRemindMeToStudy,
                  value: p.remindsToStudy,
                  onChanged: (on) => update(p.copyWith(remindsToStudy: on)),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: p.remindsToStudy
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        SettingsGroup(
                          title: l10n.notifTime,
                          children: [
                            SettingsRow(
                              label: l10n.notifRemindMeAt,
                              value: reminderLabel,
                              onTap: () async {
                                final picked = await ReminderTimeSheet.show(
                                  context,
                                  hour: p.reminderHour,
                                  minute: p.reminderMinute,
                                );
                                if (picked case (final hour, final minute)) {
                                  update(
                                    viewModel.preferences.copyWith(
                                      reminderHour: hour,
                                      reminderMinute: minute,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (var day = 1; day <= 7; day++) ...[
                              if (day > 1) const SizedBox(width: 4),
                              Expanded(
                                child: _DayKey(
                                  letter: _dayLetters[day - 1],
                                  isOn: p.reminderDays.contains(day),
                                  onTap: () => update(
                                    p.copyWith(
                                      reminderDays: p.reminderDays.contains(day)
                                          ? ({...p.reminderDays}..remove(day))
                                          : {...p.reminderDays, day},
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    )
                  : const SizedBox(width: double.infinity),
            ),
            SettingsGroup(
              title: l10n.notifAlsoTellMe,
              children: [
                SettingsSwitchRow(
                  label: l10n.notifStreakAboutToEnd,
                  value: p.savesStreak,
                  onChanged: (on) => update(p.copyWith(savesStreak: on)),
                ),
                SettingsSwitchRow(
                  label: l10n.notifEveningBeforeTest,
                  value: p.warnsBeforeTests,
                  onChanged: (on) => update(p.copyWith(warnsBeforeTests: on)),
                ),
                SettingsSwitchRow(
                  label: l10n.notifWhenLevelUp,
                  value: p.celebratesLevelUps,
                  onChanged: (on) => update(p.copyWith(celebratesLevelUps: on)),
                ),
              ],
            ),
            SettingsGroup(
              title: l10n.dailyGoalTitle,
              children: [
                SettingsRow(
                  label: l10n.dailyGoalStudyEachDay,
                  value: l10n.dailyGoalMinutesLabel(p.dailyGoalMinutes),
                  onTap: () async {
                    final picked = await DailyGoalSheet.show(
                      context,
                      minutes: p.dailyGoalMinutes,
                    );
                    if (picked != null) {
                      update(
                        viewModel.preferences.copyWith(
                          dailyGoalMinutes: picked,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _AccessGroup extends StatelessWidget {
  const _AccessGroup({required this.access, required this.onTurnOn});

  final NotificationAccess access;
  final VoidCallback onTurnOn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAllowed = access == NotificationAccess.allowed;
    return SettingsGroup(
      title: l10n.notifNotifications,
      children: [
        SettingsRow(
          label: l10n.notifNotifications,
          value: isAllowed ? l10n.notifAllowed : l10n.notifNotAllowed,
        ),
        if (!isAllowed)
          SettingsRow(
            label: access == NotificationAccess.askable
                ? l10n.notifTurnOn
                : l10n.notifTurnOnInSettings,
            onTap: onTurnOn,
          ),
      ],
    );
  }
}

class _DayKey extends StatelessWidget {
  const _DayKey({
    required this.letter,
    required this.isOn,
    required this.onTap,
  });

  final String letter;
  final bool isOn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isOn,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isOn ? AppColors.primary : context.palette.surfaceRaised,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            letter,
            style: AppTextStyles.labelStrong.copyWith(
              color: isOn ? AppColors.onPrimary : context.palette.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
