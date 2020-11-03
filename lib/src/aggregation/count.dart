part of '../../flamestore.dart';

class Count {
  Count({
    @required this.countDocument,
    @required this.countField,
  });

  final DocumentReference countDocument;
  final String countField;
}
