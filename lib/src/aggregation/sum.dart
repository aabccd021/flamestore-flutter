part of '../../flamestore.dart';

class Sum {
  Sum({
    @required this.field,
    @required this.sumDoc,
    @required this.sumField,
    @required this.sumDocCol,
  });
  final String field;
  final DocumentReference sumDoc;
  final String sumField;
  final String sumDocCol;
}
