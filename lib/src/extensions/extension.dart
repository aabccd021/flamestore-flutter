part of '../../flamestore.dart';

String getString(dynamic value) =>
    value is DocumentReference ? value?.id : '$value';

extension on Map {
  String get prettyPrint => entries
      .map<String>((e) => '${e.key}: ${getString(e.value)}')
      .toList()
      .join(',\n');
}

extension on List {
  String get prettyPrint => map<String>(getString).toList().join(',\n');
}
