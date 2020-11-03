part of '../../flamestore.dart';

class _DocumentManager {
  _DocumentManager({
    _DocumentsState state,
    _DocumentFirestoreAdapter adapter,
    Map<Document, DocumentReference> fetched,
  })  : _db = adapter ?? _DocumentFirestoreAdapter(),
        _state = state ?? _DocumentsState(),
        _fetchedDocumentPaths = fetched ?? <String>{};

  final _DocumentFirestoreAdapter _db;
  final _DocumentsState _state;
  final Set<String> _fetchedDocumentPaths;

  ValueStream<T> streamWherePath<T extends Document>(String path) {
    return _state.streamWherePath<T>(path);
  }

  void set<T extends Document>(T document, {Duration debounce}) async {
    _state.update<T>(document);
    EasyDebounce.debounce(
      document.reference.path,
      debounce,
      () async {
        final oldDocument = await get(document, true);
        if (oldDocument == null) {
          return create(document);
        }
        if (document.shouldBeDeleted) {
          return delete(oldDocument);
        }
        return _update(oldDocument, document);
      },
    );
  }

  Future<T> create<T extends Document>(T document) async {
    final newDocument = document.withDefaultValue();
    if (newDocument.reference != null) {
      _state.update<T>(newDocument);
    }
    final reference = await _db.create(newDocument);
    newDocument.reference = reference;
    _state.update<T>(newDocument);
    return newDocument;
  }

  Future<T> _update<T extends Document>(T oldDocument, T newDocument) async {
    final mergedDocument = oldDocument.mergeDataWith(newDocument);
    _state.update<T>(mergedDocument);
    await _db.update(oldDocument.reference, newDocument);
    return mergedDocument;
  }

  Future<void> delete<T extends Document>(T oldDocument) async {
    await _state.delete(oldDocument);
    await _db.delete(oldDocument);
  }

  Future<T> createIfAbsent<T extends Document>(T document) async {
    return await get(document, false) ?? await create(document);
  }

  Future<T> get<T extends Document>(T keyDocument, bool fromCache) async {
    final path = keyDocument.reference.path;
    final onMemoryDocument = await streamWherePath<T>(path).first;
    if (fromCache && _fetchedDocumentPaths.contains(path)) {
      return onMemoryDocument;
    }
    final createdDocument = await _db.get(keyDocument);
    _fetchedDocumentPaths.add(path);
    if (createdDocument == null) {
      return null;
    }
    final T updatedDocument = onMemoryDocument != null
        ? onMemoryDocument.mergeDataWith(createdDocument)
        : createdDocument;
    await _state.update<T>(updatedDocument);
    return updatedDocument;
  }

  Future<void> addFromList<T extends Document>(List<T> documents) async {
    for (final document in documents) {
      await _state.update<T>(document);
    }
  }
}
