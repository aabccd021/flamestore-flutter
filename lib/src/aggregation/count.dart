part of '../../flamestore.dart';

class Count {
  Count({
    @required this.countDoc,
    @required this.countField,
    @required this.countDocCol,
  });

  final DocumentReference countDoc;
  final String countField;
  final String countDocCol;
}
