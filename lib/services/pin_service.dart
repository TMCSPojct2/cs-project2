import 'dart:math';

class PinService {
  PinService._();
  static final PinService instance = PinService._();

  String? _pin;
  DateTime? _createdAt;
  static const _ttl = Duration(minutes: 15);

  String createPin() {
    _pin = (100000 + Random.secure().nextInt(900000)).toString();
    _createdAt = DateTime.now();
    return _pin!;
  }

  bool verifyPin(String input) {
    if (_pin == null || _createdAt == null) return false;
    if (DateTime.now().difference(_createdAt!) > _ttl) {
      _pin = null;
      return false;
    }
    final ok = input.trim() == _pin;
    if (ok) _pin = null;
    return ok;
  }

  void invalidate() {
    _pin = null;
    _createdAt = null;
  }
}
