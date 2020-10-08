part of '../../flamestore.dart';

class Flamestore {
  Flamestore._privateConstructor();
  static final Flamestore _instance = Flamestore._privateConstructor();
  static Flamestore get instance => _instance;

  final _Flamestore _flamestore = _Flamestore();

  Future<void> getList<T extends Document, V extends DocumentList<T>>(
    DocumentList<T> list,
  ) {
    return _flamestore.getList<T, V>(list);
  }

  ValueStream<DocumentListState<T>>
      _streamOfList<T extends Document, V extends DocumentList<T>>(
    V list,
  ) {
    return _flamestore.streamOfList(list);
  }

  Future<void> refreshList(DocumentList list) {
    return _flamestore.refreshList(list);
  }

  Future<T> setDoc<T extends Document>(
    T document, {
    List<DocumentList<T>> appendOnLists,
  }) async {
    return _flamestore.setDoc(document, appendOnLists: appendOnLists);
  }

  Future<T> getDoc<T extends Document>(T document, {bool fromCache = true}) {
    return _flamestore.getDoc(document, fromCache: fromCache);
  }

  ValueStream<T> _docStreamWherePath<T extends Document>(String path) {
    return _flamestore.docStreamWherePath<T>(path);
  }
}
