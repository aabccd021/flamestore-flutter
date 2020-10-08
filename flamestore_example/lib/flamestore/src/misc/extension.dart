part of '../../flamestore.dart';

extension on Map {
  void removeNull() => removeWhere((_, value) => value == null);
  // String get prettyPrint => entries
  //     .map<String>((e) => '${e.key}: ${e.value}')
  //     .toList()
  //     .join(',\n');
}

extension on List {
  String get prettyPrint => join(',\n');
}
