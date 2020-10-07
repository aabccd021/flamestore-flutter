part of '../../flamestore.dart';

class Flamestore {
  // Singleton
  Flamestore._privateConstructor();
  static final Flamestore _instance = Flamestore._privateConstructor();
  static Flamestore get instance => _instance;

  final _Flamestore _flamestore = _Flamestore();

  Future<void> getList<T extends Document, V extends DocumentList<T>>(
    DocumentList<T> documentList,
  ) {
    return _flamestore.getList<T, V>(documentList);
  }

  ValueStream<DocumentListState<T>> _streamOfList<T extends Document>(
    DocumentList documentList,
  ) {
    return _flamestore.streamOfList<T>(documentList);
  }

  Future<void> refreshList(DocumentList documentList) {
    return _flamestore.refreshList(documentList);
  }

  Future<T> setDoc<T extends Document>(
    T value, {
    T key,
    List<DocumentList<T>> appendOnLists,
  }) async {
    return _flamestore.setDoc(value, key: key, appendOnLists: appendOnLists);
  }

  Future<T> getDoc<T extends Document>(T key, {bool fromCache = true}) {
    return _flamestore.getDoc(key, fromCache: fromCache);
  }

  ValueStream<T> _docStreamWhere<T extends Document>(T key) {
    return _flamestore.docStreamWhere<T>(key);
  }

  ValueStream<T> _docStreamWhereRef<T extends Document>(
    DocumentReference reference,
  ) {
    return _flamestore.docStreamWhereRef<T>(reference);
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

  ValueStream<DocumentListState<T>> streamOfList<T extends Document>(
    DocumentList documentList,
  ) {
    return _listManager
        .streamOf(documentList)
        .map(
          (state) => DocumentListState(
            state.hasMore,
            Rx.combineLatestList(
                    state.refs.map((ref) => docStreamWhereRef<T>(ref)))
                .shareValue(),
          ),
        )
        .shareValue();
  }

  Future<void> refreshList(DocumentList documentList) {
    return _listManager.refresh(documentList);
  }

  Future<T> setDoc<T extends Document>(
    T value, {
    T key,
    List<DocumentList<T>> appendOnLists,
  }) async {
    final doc = await _docManager.set(value, key: key);
    if (appendOnLists != null) {
      _listManager.addRefToLists(doc.reference, appendOnLists);
    }
    return doc;
  }

  Future<T> getDoc<T extends Document>(T key, {bool fromCache = true}) {
    return _docManager.get(key: key, fromCache: fromCache);
  }

  ValueStream<T> docStreamWhere<T extends Document>(T key) {
    return _docManager.streamWhere<T>(key);
  }

  ValueStream<T> docStreamWhereRef<T extends Document>(
    DocumentReference reference,
  ) {
    return _docManager.streamWhereRef<T>(reference);
  }
}
