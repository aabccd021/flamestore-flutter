part of '../../flamestore.dart';

class _FlamestoreUtil {
  _FlamestoreUtil(this.flamestoreConfig);
  final FlamestoreConfig flamestoreConfig;
  Map<String, DocumentDefinition> get defOf =>
      flamestoreConfig.documentDefinitions;

  String colNameOf(Type type) {
    return flamestoreConfig.collectionClassMap[type];
  }

  Document docFromSnapshot(DocumentSnapshot snapshot, String type) {
    final def = defOf[type];
    final doc = def.fromMap(snapshot.data());
    doc.reference = snapshot.reference;
    return doc;
  }

  T mergeDocs<T extends Document>(T thisDoc, T otherDoc) {
    final def = defOf[thisDoc.colName];
    final util = def;
    final doc = util.fromMap({
      ...mapFrom(thisDoc),
      ...mapFrom(otherDoc),
    });
    doc.reference = otherDoc.reference ?? thisDoc.reference;
    return doc;
  }

  Map<String, dynamic> mapFrom(Document document) {
    return {
      ...dataMapFrom(document),
      'reference': document.reference,
    };
  }

  Map<String, dynamic> dataMapFrom(Document document) {
    final def = defOf[document.colName];
    return def.toDataMap(document);
  }

  bool docShouldBeDeleted(Document document) {
    final def = defOf[document.colName];
    return def.shouldBeDeleted(document);
  }

  Map<String, dynamic> defaultValueMapOf(Document document) {
    final def = defOf[document.colName];
    return def.defaultValueMap(document);
  }

  Document docOfMap(Map<String, dynamic> map, String type) {
    final def = defOf[type];
    return def.fromMap(map);
  }

  List<String> firestoreCreateFields(Document document) {
    final def = defOf[document.colName];
    return def.firestoreCreateFields(document);
  }

  List<Sum> sums(Document document) {
    final def = defOf[document.colName];
    return def.sums(document);
  }

  List<Count> counts(Document document) {
    final def = defOf[document.colName];
    return def.counts(document);
  }
}
