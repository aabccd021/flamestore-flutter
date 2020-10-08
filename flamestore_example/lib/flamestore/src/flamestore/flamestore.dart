part of '../../flamestore.dart';

class Flamestore {
  Flamestore._privateConstructor();
  static final Flamestore _instance = Flamestore._privateConstructor();
  static Flamestore get instance => _instance;

  final _Flamestore _flamestore = _Flamestore();

  Future<void> getList<T extends Document, V extends DocumentList<T>>(
    DocumentList<T> documentList,
  ) {
    return _flamestore.getList<T, V>(documentList);
  }

  ValueStream<DocumentListState<T>>
      _streamOfList<T extends Document, V extends DocumentList<T>>(
    V documentList,
  ) {
    return _flamestore.streamOfList(documentList);
  }

  Future<void> refreshList(DocumentList documentList) {
    return _flamestore.refreshList(documentList);
  }

  Future<T> setDoc<T extends Document>(
    T document, {
    List<DocumentList<T>> appendOnLists,
  }) async {
    return _flamestore.setDoc(document, appendOnLists: appendOnLists);
  }

  Future<T> getDoc<T extends Document>(T key, {bool fromCache = true}) {
    return _flamestore.getDoc(key, fromCache: fromCache);
  }

  ValueStream<T> _docStreamWherePath<T extends Document>(String path) {
    return _flamestore.docStreamWherePath<T>(path);
  }
}

class _Flamestore {
  _Flamestore({
    _DocumentListManager listManager,
    _DocumentManager documentManager,
  })  : _docManager = documentManager ?? _DocumentManager(),
        _listManager = listManager ?? _DocumentListManager();

  final _DocumentListManager _listManager;
  final _DocumentManager _docManager;

  Future<void> getList<T extends Document, V extends DocumentList<T>>(
      DocumentList<T> documentList) async {
    final docs = await _listManager.get<T, V>(documentList);
    return _docManager.addFromList<T>(docs);
  }

  ValueStream<DocumentListState<T>>
      streamOfList<T extends Document, V extends DocumentList<T>>(
    DocumentList documentList,
  ) {
    return _listManager
        .streamOf(documentList)
        .map((state) => _internalStateToExternalState<T>(state))
        .shareValue();
  }

  DocumentListState<T> _internalStateToExternalState<T extends Document>(
    _DocumentListInternalState internalState,
  ) {
    final refsStream =
        internalState.refs.map((ref) => docStreamWherePath<T>(ref.path));
    return DocumentListState(
      internalState.hasMore,
      Rx.combineLatestList(refsStream).shareValue(),
    );
  }

  Future<void> refreshList(DocumentList documentList) {
    return _listManager.refresh(documentList);
  }

  Future<T> setDoc<T extends Document>(
    T document, {
    List<DocumentList<T>> appendOnLists,
  }) async {
    final doc = await _docManager.set(document);
    if (appendOnLists != null) {
      _listManager.addRefToLists(doc.reference, appendOnLists);
    }
    return doc;
  }

  Future<T> getDoc<T extends Document>(T key, {bool fromCache = true}) {
    return _docManager.get(key, fromCache);
  }

  ValueStream<T> docStreamWherePath<T extends Document>(String path) {
    return _docManager.streamWherePath<T>(path);
  }
}
