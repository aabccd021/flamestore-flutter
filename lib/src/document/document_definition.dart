part of '../../flamestore.dart';

class DocumentDefinition<T extends Document> {
  final String collectionName;
  final Map<String, dynamic> Function(Document document) defaultValueMap;
  final T Function(Map<String, dynamic> data) mapToDoc;
  final Map<String, dynamic> Function(Document document) docToMap;
  final List<String> Function(Document document) creatableFields;
  final bool Function(Document document) docShouldBeDeleted;
  final List<Sum> Function(Document document) sums;
  final List<Count> Function(Document document) counts;

  DocumentDefinition({
    @required this.collectionName,
    @required this.defaultValueMap,
    @required this.mapToDoc,
    @required this.docToMap,
    @required this.creatableFields,
    @required this.docShouldBeDeleted,
    @required this.sums,
    @required this.counts,
  });

  Type get type => T;
}
