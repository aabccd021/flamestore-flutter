part of '../../flamestore.dart';

extension on Map {
  void removeNull() => removeWhere((_, value) => value == null);
}
