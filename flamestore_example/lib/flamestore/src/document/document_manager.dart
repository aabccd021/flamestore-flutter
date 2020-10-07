part of '../../flamestore.dart';

class _DocumentManager {
  _DocumentManager({
    _DocumentMapStream map,
    _DocumentFirestoreAdapter adapter,
    Map<Document, DocumentReference> fetcherKeyDocs,
  })  : _adapter = adapter ?? _DocumentFirestoreAdapter(),
        _map = map ?? _DocumentMapStream(),
        _fetchedDocKeys = fetcherKeyDocs ?? <Document>{};

  final _DocumentFirestoreAdapter _adapter;
  final _DocumentMapStream _map;
  final Set<Document> _fetchedDocKeys;

  ValueStream<T> streamWhere<T extends Document>(T key) =>
      _map.streamOf<T>(key);

  ValueStream<T> streamWhereRef<T extends Document>(DocumentReference ref) =>
      _map.streamOfRef<T>(ref);

  Future<T> set<T extends Document>(T doc, {T key}) async {
    if (key == null) {
      return _create(doc);
    }
    final oldDoc = await get(key: key, fromCache: false);
    if (oldDoc == null) {
      return _create(doc.mergeWith(key));
    }
    if (doc.shouldBeDeleted) {
      await _delete(oldDoc);
      return null;
    }
    return _update(oldDoc, doc);
  }

  Future<T> _create<T extends Document>(T doc) async {
    final newDoc = doc.mergeWith(doc.defaultDocument);
    final reference = await _adapter.create(newDoc);
    await _map.updateDocumentState(reference: reference, document: newDoc);
    return newDoc;
  }

  Future<T> _update<T extends Document>(T oldDoc, T updateData) async {
    await _adapter.update(reference: oldDoc.reference, document: updateData);
    final newDoc = oldDoc.mergeWith(updateData);
    await _map.updateDocumentState(
      reference: newDoc.reference,
      document: newDoc,
    );
    return newDoc;
  }

  Future<void> _delete<T extends Document>(T oldDoc) async {
    await _adapter.delete(oldDoc);
    await _map.delete(oldDoc);
  }

  Future<T> get<T extends Document>({
    @required T key,
    @required bool fromCache,
  }) async {
    final doc = streamWhere(key).value;
    if (fromCache && _fetchedDocKeys.contains(key)) {
      return doc;
    }
    final snapshot = await _adapter.get(key);
    _fetchedDocKeys.add(key);
    // Return null if document absent in firestore
    if (snapshot == null) {
      return null;
    }
    final newDoc = key
        .documentFromData(snapshot.data())
        .mergeWith(key.documentFromReference(snapshot.reference));
    // Add new document if absent in memory
    if (doc == null) {
      await _map.updateDocumentState(
        reference: newDoc.reference,
        document: newDoc,
      );
      return newDoc;
    }
    // Update document if exists in memory
    final updatedDoc = doc.mergeWith(newDoc);
    await _map.updateDocumentState(
      reference: updatedDoc.reference,
      document: updatedDoc,
    );
    return updatedDoc;
  }

  Future<void> addFromList<T extends Document>(List<T> docs) async {
    for (final doc in docs) {
      await _map.updateDocumentState(reference: doc.reference, document: doc);
    }
  }
}
