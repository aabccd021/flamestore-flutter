part of '../../flamestore.dart';

class Flamestore {
  Flamestore._privateConstructor();
  static final Flamestore _instance = Flamestore._privateConstructor();
  static Flamestore get instance => _instance;

  _Flamestore _flamestore;

  Future<void> initialize(FlamestoreConfig projectConfig) async {
    return _flamestore = _Flamestore(_FlamestoreUtil(projectConfig));
  }

  Future<void> getList<T extends Document>(DocumentListKey<T> list) {
    return _flamestore.getList<T>(list);
  }

  ValueStream<DocumentListState> _streamOfList<T extends Document>(
    DocumentListKey<T> list,
  ) {
    return _flamestore.streamOfList(list);
  }

  Future<void> refreshList(DocumentListKey list) {
    return _flamestore.refreshList(list);
  }

  void setDoc<T extends Document>(T doc, {Duration debounce = Duration.zero}) {
    return _flamestore.setDoc(doc, debounce: debounce);
  }

  Future<T> getDoc<T extends Document>(T doc, {bool fromCache = true}) {
    return _flamestore.getDoc(doc, fromCache: fromCache);
  }

  Future<T> createDoc<T extends Document>(
    T doc, {
    List<DocumentListKey<T>> appendOnLists,
  }) {
    return _flamestore.createDoc(doc, appendOnLists: appendOnLists);
  }

  Future<T> createDocIfAbsent<T extends Document>(T doc) {
    return _flamestore.createDocIfAbsent(doc);
  }

  Future<void> deleteDocument<T extends Document>(T doc) {
    return _flamestore.deleteDoc(doc);
  }

  ValueStream<T> _docStreamWherePath<T extends Document>(String path) {
    return _flamestore.docStreamWherePath<T>(path);
  }
}
