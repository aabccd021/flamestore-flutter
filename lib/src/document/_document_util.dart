part of '../../flamestore.dart';

class _FlamestoreUtil {
  _FlamestoreUtil(
    this.flamestoreConfig, {
    Map<DocumentListKey, String> docTypeToColName,
  }) : _docTypeToColName = docTypeToColName ?? {};

  final FlamestoreConfig flamestoreConfig;
  final Map<DocumentListKey, String> _docTypeToColName;
  Map<String, DocumentDefinition> get defOf =>
      flamestoreConfig.documentDefinitions;

  String colNameOfList<T extends Document>(DocumentListKey<T> list) {
    if (T != Document) {
      _docTypeToColName[list] = colNameOf(T);
    }
    return _docTypeToColName[list];
  }

  String colNameOf(Type type) {
    return flamestoreConfig.collectionClassMap[type];
  }

  Document docFromSnapshot(DocumentSnapshot snapshot, String type) {
    final def = defOf[type];
    final map = {...snapshot.data(), 'reference': snapshot.reference};
    final doc = def.mapToDoc(map);
    return doc;
  }

  Map<String, DocumentField> mapOf(Document document) {
    final def = defOf[document.colName];
    return def._docToMap(document);
  }

  Document docFromMap(Map<String, DocumentField> map, DocumentReference ref) {
    final colName = colNameOfRef(ref);
    final def = defOf[colName];
    final valueMap =
        map.map((fieldName, field) => MapEntry(fieldName, field.value));
    final newMap = {...valueMap, 'reference': ref};
    return def.mapToDoc(newMap);
  }

  List<String> creatableFields(Document document) {
    final def = defOf[document.colName];
    return def.creatableFields;
  }

  List<String> updatableFields(Document document) {
    final def = defOf[document.colName];
    return def.updatableFields;
  }

  List<Sum> sumsOf(Document document) {
    return flamestoreConfig.sums[document.colName](document);
  }

  List<Count> countsOf(Document document) {
    return flamestoreConfig.counts[document.colName](document);
  }

  String colNameOfRef(DocumentReference ref) {
    return ref.path.split("/")[0];
  }
}
