part of '../../flamestore.dart';

abstract class Document {
  Document({FirebaseFirestore firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  DocumentReference _reference;

  @protected
  DocumentMetadata get metadata;

  @protected
  Document _fromSnapshot(DocumentSnapshot snapshot) {
    return fromMap(snapshot.data())..reference = snapshot.reference;
  }

  @protected
  Document withDefaultValue();

  @protected
  Map<String, dynamic> get defaultMap;

  @protected
  Document fromMap(Map<String, dynamic> data);

  Map<String, dynamic> toMap() => {...toDataMap(), 'reference': reference};

  @protected
  Map<String, dynamic> toDataMap();

  @protected
  bool get shouldBeDeleted;

  @protected
  List<String> get keys;

  @protected
  set reference(DocumentReference reference) => _reference ??= reference;

  DocumentReference get reference => keys.isEmpty
      ? _reference
      : _firestore.collection(metadata.collectionName).doc(keys.join('_'));
}

class DocumentMetadata {
  DocumentMetadata({@required this.collectionName});
  final String collectionName;
}
