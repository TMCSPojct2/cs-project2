import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Web-only import (conditional)
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';

@JS('Notification')
extension type JSNotification._(JSObject _) implements JSObject {
  external factory JSNotification(String title, JSNotificationOptions options);
  @JS('permission')
  external static String get permission;
  @JS('requestPermission')
  external static JSPromise<JSString> requestPermission();
}

@JS()
extension type JSNotificationOptions._(JSObject _) implements JSObject {
  external factory JSNotificationOptions({String body, String icon});
}

class LocalNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (kIsWeb) {
      // Request browser notification permission
      try {
        await JSNotification.requestPermission().toDart;
      } catch (_) {}
      _initialized = true;
      return;
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  static Future<void> showOtpNotification(String otp) async {
    if (!_initialized) await init();

    if (kIsWeb) {
      try {
        if (JSNotification.permission == 'granted') {
          JSNotification(
            'Verification Code – NABIH',
            JSNotificationOptions(
              body: 'Your OTP is: $otp',
              icon: '/icons/Icon-192.png',
            ),
          );
        }
      } catch (_) {}
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'otp_channel',
      'OTP Notifications',
      channelDescription: 'One-time password codes for registration',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'OTP',
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.show(
      0,
      'Verification Code – NABIH',
      'Your OTP is: $otp',
      details,
    );
  }
}
