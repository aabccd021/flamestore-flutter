part of '../../flamestore.dart';

abstract class Document {
  Document({FirebaseFirestore firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  DocumentReference _reference;

  @protected
  DocumentMetadata get metadata;

  @protected
  Document createDocumentFromData(Map<String, dynamic> data);

  @protected
  Document withDefaultValue();

  @protected
  Map<String, dynamic> get defaultMap;

  @protected
  Document mergeWith(Document document);

  @protected
  Map<String, dynamic> toMap();

  @protected
  bool get shouldBeDeleted;

  @protected
  List<String> get keys;

  DocumentReference get reference => keys.isEmpty
      ? _reference
      : _firestore.collection(metadata.collectionName).doc(keys.join('_'));

  @protected
  set reference(DocumentReference reference) => _reference = reference;
}

class DocumentMetadata {
  DocumentMetadata({@required this.collectionName});
  final String collectionName;
}
