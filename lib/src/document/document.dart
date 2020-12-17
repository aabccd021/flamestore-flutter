part of '../../flamestore.dart';

abstract class Document {
  Document({FirebaseFirestore firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  DocumentReference _reference;
  String _id = '';

  String get colName;

  set reference(DocumentReference reference) => _reference = reference;

  @protected
  List<String> get keys;

  DocumentReference get reference {
    if (keys.isNotEmpty) {
      return _firestore.collection(colName).doc(keys.join('_'));
    }
    if (_id.isNotEmpty) {
      return _firestore.collection(colName).doc(_id);
    }
    return _reference;
  }
}
