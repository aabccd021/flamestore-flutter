part of '../../flamestore.dart';

class Count {
  Count({
    @required this.countDocRef,
    @required this.countField,
    @required this.countDocCol,
  });

  final DocumentReference countDocRef;
  final String countField;
  final String countDocCol;
}
