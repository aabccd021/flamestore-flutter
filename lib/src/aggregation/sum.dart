part of '../../flamestore.dart';

class Sum {
  Sum({
    @required this.field,
    @required this.sumDocRef,
    @required this.sumField,
    @required this.sumDocCol,
  });
  final String field;
  final DocumentReference sumDocRef;
  final String sumField;
  final String sumDocCol;
}
