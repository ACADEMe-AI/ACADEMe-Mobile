import 'package:academe/data/services/notification_service.dart';
import 'package:academe/domain/models/reminder.dart';

class FakeNotificationService implements NotificationService {
  FakeNotificationService({
    this.isGranted = false,
    this.hasPrompt = true,
    this.grantsOnRequest = true,
  });

  bool isGranted;
  bool hasPrompt;
  bool grantsOnRequest;
  var permissionRequests = 0;
  var settingsOpened = 0;
  List<Reminder> scheduled = const [];

  @override
  Future<bool> isAllowed() async => isGranted;

  @override
  Future<bool> canRequest() async => hasPrompt;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    if (hasPrompt && grantsOnRequest) isGranted = true;
    return isGranted;
  }

  @override
  Future<void> openSettings() async => settingsOpened++;

  @override
  Future<void> replaceAll(List<Reminder> reminders) async =>
      scheduled = reminders;
}
