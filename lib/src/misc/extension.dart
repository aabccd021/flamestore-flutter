part of '../../flamestore.dart';

extension on Map {
  void removeNull() {
    entries.forEach((entry) {
      final value = entry.value;
      if (value is Map) {
        value..removeNull();
        this[entry.key] = value.isEmpty ? null : value;
      }
    });
    removeWhere((_, value) => value == null);
  }
}
