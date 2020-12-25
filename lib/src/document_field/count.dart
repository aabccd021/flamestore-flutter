part of '../../flamestore.dart';

class Count {
  Count({
    @required this.ref,
    @required this.fieldName,
    @required this.countDocCol,
  });

  final DocumentReference ref;
  final String fieldName;
  final String countDocCol;
}

class CountField extends DocumentField {
  final int value;
  CountField(this.value);
  CountField.fromMap(this.value);
}
