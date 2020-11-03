part of '../../flamestore.dart';

class _Flamestore {
  _Flamestore({
    _DocumentListManager listManager,
    _DocumentManager documentManager,
  })  : _documentManager = documentManager ?? _DocumentManager(),
        _listManager = listManager ?? _DocumentListManager();

  final _DocumentListManager _listManager;
  final _DocumentManager _documentManager;

  Future<void> getList<T extends Document, V extends DocumentList<T>>(
    DocumentList<T> list,
  ) async {
    final documents = await _listManager.get<T, V>(list);
    return _documentManager.addFromList<T>(documents);
  }

  Future<void> refreshList<T extends Document, V extends DocumentList<T>>(
    DocumentList<T> list,
  ) async {
    final documents = await _listManager.refresh<T, V>(list);
    return _documentManager.addFromList<T>(documents);
  }

  ValueStream<DocumentListState<T>>
      streamOfList<T extends Document, V extends DocumentList<T>>(
    DocumentList list,
  ) {
    return _listManager
        .streamOf(list)
        .map((state) => _internalStateToExternalState<T>(state))
        .shareValue();
  }

  DocumentListState<T> _internalStateToExternalState<T extends Document>(
    _DocumentListState state,
  ) {
    final stream = state.references
        .map((reference) => docStreamWherePath<T>(reference.path));
    return DocumentListState(
      state.hasMore,
      Rx.combineLatestList(stream).shareValue(),
    );
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
    T document, {
    List<DocumentList<T>> appendOnLists,
  }) async {
    final newDocument = await _documentManager.create(document);
    if (appendOnLists != null) {
      _listManager.addReference(newDocument.reference, appendOnLists);
    }
    return newDocument;
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
