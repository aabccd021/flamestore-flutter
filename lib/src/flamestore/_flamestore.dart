part of '../../flamestore.dart';

class _Flamestore {
  _Flamestore({
    _DocumentListManager listManager,
    _DocumentManager documentManager,
  })  : _documentManager = documentManager ?? _DocumentManager(),
        _listManager = listManager ?? _DocumentListManager();

  final _DocumentListManager _listManager;
  final _DocumentManager _documentManager;

  Future<void> initialize(FlamestoreConfig projectConfig) async {
    _documentManager.config = projectConfig;
  }

  Future<void> getList<T extends Document, V extends DocumentListKey<T>>(
    DocumentListKey<T> list,
  ) async {
    final documents = await _listManager.get<T, V>(list);
    return _documentManager.addFromList<T>(documents);
  }

  Future<void> refreshList<T extends Document, V extends DocumentListKey<T>>(
    DocumentListKey<T> list,
  ) async {
    final documents = await _listManager.refresh<T, V>(list);
    return _documentManager.addFromList<T>(documents);
  }

  ValueStream<DocumentListState> streamOfList(DocumentListKey list) {
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
    T document, {
    List<DocumentListKey<T>> appendOnLists,
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
