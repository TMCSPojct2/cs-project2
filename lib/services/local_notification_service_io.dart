import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    // Request Android 13+ permission
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _ready = true;
  }

  Future<void> showPin(String pin) async {
    try { await init(); } catch (_) {}
    const androidDetails = AndroidNotificationDetails(
      'nabih_otp',
      'Verification',
      channelDescription: 'NABIH account verification codes',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'nabih_otp',
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(
      1,
      'NABIH – رمز التحقق',
      'رمزك: $pin  •  Your code: $pin',
      details,
    );
  }

  Future<void> cancelPin() async {
    await _plugin.cancel(1);
  }
}
