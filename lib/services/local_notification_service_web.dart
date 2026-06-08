// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  Future<void> init() async {
    await html.Notification.requestPermission();
  }

  Future<bool> showPin(String pin) async {
    final perm = await html.Notification.requestPermission();
    if (perm == 'granted') {
      html.Notification(
        'NABIH – رمز التحقق',
        body: 'رمزك: $pin  •  Your code: $pin',
      );
      return true;
    }
    return false;
  }

  Future<void> cancelPin() async {}
}
