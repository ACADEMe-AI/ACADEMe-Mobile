import '../../../utils/dates.dart';
import 'app_l10n.dart';

String relativeDayLabel(AppLocalizations l10n, DateTime day, {DateTime? now}) {
  final days = dateOnly(day).difference(dateOnly(now ?? DateTime.now())).inDays;
  return switch (days) {
    0 => l10n.studyToday,
    1 => l10n.folderDueTomorrow,
    -1 => l10n.folderDueYesterday,
    < 0 => l10n.folderDueDaysAgo(-days),
    _ => l10n.folderDueInDays(days),
  };
}

String relativeDayLine(AppLocalizations l10n, DateTime day, {DateTime? now}) =>
    '${shortDay(day)} · ${relativeDayLabel(l10n, day, now: now)}';
