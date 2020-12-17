part of '../../flamestore.dart';

class _Flamestore {
  _Flamestore(
    _FlamestoreUtil _, {
    _DocumentListManager listManager,
    _DocumentManager documentManager,
  })  : _listManager = listManager ?? _DocumentListManager(_),
        _documentManager = documentManager ?? _DocumentManager(_);

  final _DocumentListManager _listManager;
  final _DocumentManager _documentManager;

  Future<void> getList<T extends Document>(DocumentListKey<T> list) async {
    final documents = await _listManager.get<T>(
      list,
    );
    return _documentManager.addFromList<T>(documents);
  }

  Future<void> refreshList<T extends Document>(DocumentListKey<T> list) async {
    final documents = await _listManager.refresh<T>(list);
    return _documentManager.addFromList<T>(documents);
  }

  ValueStream<DocumentListState> streamOfList<T extends Document>(
    DocumentListKey<T> list,
  ) {
    return _listManager
        .streamOf(list)
        .map((state) => DocumentListState(state.hasMore, state.references))
        .shareValue();
  }

  void setDocument<T extends Document>(
    T document, {
    Duration debounce = Duration.zero,
  }) {
    _documentManager.set(document, debounce: debounce);
  }

  Future<T> getDocument<T extends Document>(
    T document, {
    bool fromCache = true,
  }) {
    return _documentManager.get(document, fromCache);
  }

  Future<T> createDocument<T extends Document>(
    T doc, {
    List<DocumentListKey<T>> appendOnLists,
  }) async {
    final newDoc = await _documentManager.create(doc);
    if (appendOnLists != null) {
      final newDocRef = newDoc.reference;
      _listManager.addReference(newDocRef, appendOnLists);
    }
    return newDoc;
  }

  Future<T> createDocumentIfAbsent<T extends Document>(T document) {
    return _documentManager.createIfAbsent(document);
  }

  Future<void> deleteDocument<T extends Document>(T document) {
    _listManager.deleteReference(document.reference);
    return _documentManager.delete(document);
  }

  ValueStream<T> docStreamWherePath<T extends Document>(String path) {
    return _documentManager.streamWherePath<T>(path);
  }
}
