part of '../../flamestore.dart';

class DocumentDefinition<T extends Document> {
  final T Function(Map<String, dynamic> data) mapToDoc;
  final List<String> creatableFields;
  final List<String> updatableFields;

  final Map<String, DocumentField> Function(T document) docToMap;
  Map<String, DocumentField> _docToMap(Document document) {
    return docToMap(document as T);
  }

  // List<Sum> Function(T document) sums;
  // List<Sum> _sums(Document document) {
  //   return sums != null ? sums(document as T) : [];
  // }

  // List<Count> Function(T document) counts;
  // List<Count> _counts(Document document) {
  //   return counts != null ? counts(document as T) : [];
  // }

  DocumentDefinition({
    @required this.mapToDoc,
    @required this.docToMap,
    @required this.creatableFields,
    @required this.updatableFields,
    // this.sums,
    // this.counts,
  });
}
