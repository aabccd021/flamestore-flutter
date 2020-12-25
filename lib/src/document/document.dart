part of '../../flamestore.dart';

abstract class Document {
  Document(this._ref, {FirebaseFirestore firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  final DocumentReference _ref;

  @protected
  String get colName;

  @protected
  List<String> get keys => [];

  DocumentReference get reference => keys.isNotEmpty
      ? _firestore.collection(colName).doc(keys.join('_'))
      : _ref;
}
