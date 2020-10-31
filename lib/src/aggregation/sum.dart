part of '../../flamestore.dart';

class Sum {
  Sum({
    @required this.field,
    @required this.sumDocument,
    @required this.sumField,
  });

  final String field;
  final DocumentReference sumDocument;
  final String sumField;
}
