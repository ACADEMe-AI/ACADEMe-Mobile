import 'package:flutter/foundation.dart';

import '../../../data/repositories/reminder_repository.dart';

class NotificationPrimerViewModel extends ChangeNotifier {
  NotificationPrimerViewModel({required ReminderRepository reminders})
    : _reminders = reminders {
    _reminders.addListener(notifyListeners);
  }

  final ReminderRepository _reminders;

  bool get wantsPrimer => _reminders.wantsPrimer;

  Future<void> answer({required bool allow}) =>
      _reminders.answerPrimer(allow: allow);

  Future<void> resumed() => _reminders.checkAccess();

  @override
  void dispose() {
    _reminders.removeListener(notifyListeners);
    super.dispose();
  }
}
