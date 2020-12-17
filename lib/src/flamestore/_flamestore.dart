part of '../../flamestore.dart';

class _Flamestore {
  _Flamestore(
    _FlamestoreUtil _, {
    _DocumentListManager listManager,
    _DocumentManager documentManager,
  })  : _listManager = listManager ?? _DocumentListManager(_),
        _docManager = documentManager ?? _DocumentManager(_);

  final _DocumentListManager _listManager;
  final _DocumentManager _docManager;

  Future<void> getList<T extends Document>(DocumentListKey<T> list) async {
    final docs = await _listManager.get(list);
    return _docManager.addFromList<T>(docs);
  }

  Future<void> refreshList<T extends Document>(DocumentListKey<T> list) async {
    final docs = await _listManager.refresh<T>(list);
    return _docManager.addFromList<T>(docs);
  }

  ValueStream<DocumentListState> streamOfList<T extends Document>(
    DocumentListKey<T> list,
  ) {
    return _listManager
        .streamOf(list)
        .map((state) => DocumentListState(state.hasMore, state.refs))
        .shareValue();
  }

  void setDoc<T extends Document>(T doc, {Duration debounce = Duration.zero}) {
    _docManager.set(doc, debounce: debounce);
  }

  Future<T> getDoc<T extends Document>(T doc, {bool fromCache = true}) {
    return _docManager.get(doc, fromCache);
  }

  Future<T> createDoc<T extends Document>(
    T doc, {
    List<DocumentListKey<T>> appendOnLists,
  }) async {
    final newDoc = await _docManager.create(doc);
    if (appendOnLists != null) {
      final newDocRef = newDoc.reference;
      _listManager.addReference(newDocRef, appendOnLists);
    }
    return newDoc;
  }

  Future<T> createDocIfAbsent<T extends Document>(T doc) {
    return _docManager.createIfAbsent(doc);
  }

  Future<void> deleteDoc<T extends Document>(T doc) {
    _listManager.deleteReference(doc.reference);
    return _docManager.delete(doc);
  }

  ValueStream<T> docStreamWherePath<T extends Document>(String path) {
    return _docManager.streamWherePath<T>(path);
  }
}
