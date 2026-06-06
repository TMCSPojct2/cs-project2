class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();
  Future<void> init() async {}
  Future<void> showPin(String pin) async {}
  Future<void> cancelPin() async {}
}
