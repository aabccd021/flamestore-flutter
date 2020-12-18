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
    assert(type != null);
    final def = defOf[type];
    final doc = def.mapToDoc(snapshot.data());
    doc.reference = snapshot.reference;
    return doc;
  }

  T mergeDocs<T extends Document>(T thisDoc, T otherDoc) {
    final def = defOf[thisDoc.colName];
    final util = def;
    final doc = util.mapToDoc({
      ...mapOf(thisDoc),
      ...mapOf(otherDoc),
    });
    doc.reference = otherDoc.reference ?? thisDoc.reference;
    return doc;
  }

  Map<String, dynamic> mapOf(Document document) {
    return {
      ...dataMapOf(document),
      'reference': document.reference,
    };
  }

  Map<String, dynamic> dataMapOf(Document document) {
    final def = defOf[document.colName];
    return def.docToMap(document);
  }

  bool shouldDelete(Document document) {
    final def = defOf[document.colName];
    return def.docShouldBeDeleted(document);
  }

  Map<String, dynamic> defaultValueMapOf(Document document) {
    final def = defOf[document.colName];
    return def.defaultValueMap(document);
  }

  Document docOfMap(Map<String, dynamic> map, String type) {
    assert(type != null);
    final def = defOf[type];
    return def.mapToDoc(map);
  }

  List<String> creatableFields(Document document) {
    final def = defOf[document.colName];
    return def.creatableFields();
  }

  List<Sum> sumsOf(Document document) {
    final def = defOf[document.colName];
    return def.sums(document);
  }

  List<Count> countsOf(Document document) {
    final def = defOf[document.colName];
    return def.counts(document);
  }
}
