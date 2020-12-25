part of '../../flamestore.dart';

class Sum {
  Sum({
    @required this.field,
    @required this.ref,
    @required this.fieldName,
  });
  final String field;
  final DocumentReference ref;
  final String fieldName;
}

class SumField extends DocumentField {
  SumField(this.value);
  SumField.fromMap(dynamic value) : value = value?.toDouble();
  final double value;
}
