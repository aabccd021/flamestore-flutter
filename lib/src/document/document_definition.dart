part of '../../flamestore.dart';

class DocumentDefinition<T extends Document> {
  final String collectionName;
  final Map<String, dynamic> Function(Document document) defaultValueMap;
  final T Function(Map<String, dynamic> data) fromMap;
  final Map<String, dynamic> Function(Document document) toDataMap;
  final List<String> Function(Document document) firestoreCreateFields;
  final bool Function(Document document) shouldBeDeleted;
  final List<Sum> Function(Document document) sums;
  final List<Count> Function(Document document) counts;

  DocumentDefinition({
    @required this.collectionName,
    @required this.defaultValueMap,
    @required this.fromMap,
    @required this.toDataMap,
    @required this.firestoreCreateFields,
    @required this.shouldBeDeleted,
    @required this.sums,
    @required this.counts,
  });

  Type get type => T;
}
