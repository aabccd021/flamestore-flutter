part of '../../flamestore.dart';

abstract class Document<T extends DocumentKey> extends Equatable {
  final DocumentReference reference;
  const Document(this.reference);

  @protected
  DocumentMetadata get metadata;

  @protected
  Document documentFromData(Map<String, dynamic> data);

  @protected
  Document documentFromReference(DocumentReference reference);

  @protected
  Document get defaultDocument;

  @protected
  Map<String, dynamic> get defaultMap;

  @protected
  Document mergeWith(Document document);

  @protected
  Map<String, dynamic> toMap();

  @protected
  bool get shouldBeDeleted;
}

class DocumentMetadata {
  DocumentMetadata({@required this.collectionName});
  final String collectionName;
}

class DocumentKey {}
