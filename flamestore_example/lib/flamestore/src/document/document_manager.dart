part of '../../flamestore.dart';

class _DocumentManager {
  _DocumentManager({
    _DocumentMapStream map,
    _DocumentFirestoreAdapter adapter,
    Map<Document, DocumentReference> fetcherKeyDocs,
  })  : _adapter = adapter ?? _DocumentFirestoreAdapter(),
        _map = map ?? _DocumentMapStream(),
        _fetchedDocKeys = fetcherKeyDocs ?? <String>{};

  final _DocumentFirestoreAdapter _adapter;
  final _DocumentMapStream _map;
  final Set<String> _fetchedDocKeys;

  ValueStream<T> streamWherePath<T extends Document>(String path) {
    return _map.streamWherePath<T>(path);
  }

  Future<T> set<T extends Document>(T doc) async {
    if (doc.reference == null) {
      return _create(doc);
    }
    final oldDoc = await get(doc, true);
    if (oldDoc == null) {
      return _create(doc);
    }
    if (doc.shouldBeDeleted) {
      await _delete(oldDoc);
      return null;
    }
    return _update(oldDoc, doc);
  }

  Future<T> _create<T extends Document>(T doc) async {
    final newDoc = doc.withDefaultValue();
    _map.updateState<T>(newDoc);
    final reference = await _adapter.create(newDoc);
    newDoc.reference = reference;
    _map.updateState<T>(newDoc);
    return newDoc;
  }

  Future<T> _update<T extends Document>(T oldDocument, T newDocument) async {
    final mergedDocument = oldDocument.mergeWith(newDocument);
    _map.updateState<T>(mergedDocument);
    await _adapter.update(oldDocument, newDocument);
    return mergedDocument;
  }

  Future<void> _delete<T extends Document>(T oldDoc) async {
    await _map.deleteState(oldDoc);
    await _adapter.delete(oldDoc);
  }

  Future<T> get<T extends Document>(T keyDocument, bool fromCache) async {
    final path = keyDocument.reference.path;
    final onMemoryDocument = await streamWherePath<T>(path).first;
    if (fromCache && _fetchedDocKeys.contains(path)) {
      return onMemoryDocument;
    }
    final createdDocument = await _adapter.get(keyDocument);
    _fetchedDocKeys.add(path);
    if (createdDocument == null) {
      return null;
    }
    final updatedDocument = onMemoryDocument != null
        ? onMemoryDocument.mergeWith(createdDocument)
        : createdDocument;
    await _map.updateState<T>(updatedDocument);
    return updatedDocument;
  }

  Future<void> addFromList<T extends Document>(List<T> docs) async {
    for (final doc in docs) {
      await _map.updateState<T>(doc);
    }
  }
}
