class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();
  Future<void> init() async {}
  Future<bool> showPin(String pin) async => false;
  Future<void> cancelPin() async {}
}
