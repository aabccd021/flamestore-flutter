part of '../../flamestore.dart';

class Flamestore {
  Flamestore._privateConstructor();
  static final Flamestore _instance = Flamestore._privateConstructor();
  static Flamestore get instance => _instance;

  final _Flamestore _flamestore = _Flamestore();

  Future<void> getList<T extends Document, V extends DocumentListKey<T>>(
    DocumentListKey<T> list,
  ) {
    return _flamestore.getList<T, V>(list);
  }

  ValueStream<DocumentListState> _streamOfList(DocumentListKey list) {
    return _flamestore.streamOfList(list);
  }

  Future<void> refreshList(DocumentListKey list) {
    return _flamestore.refreshList(list);
  }

  void setDocument<T extends Document>(
    T document, {
    Duration debounce = Duration.zero,
  }) {
    return _flamestore.setDocument(
      document,
      debounce: debounce,
    );
  }

  Future<T> getDocument<T extends Document>(
    T document, {
    bool fromCache = true,
  }) {
    return _flamestore.getDocument(document, fromCache: fromCache);
  }

  Future<T> createDocument<T extends Document>(
    T document, {
    List<DocumentListKey<T>> appendOnLists,
  }) {
    return _flamestore.createDocument(document, appendOnLists: appendOnLists);
  }

  Future<T> createDocumentIfAbsent<T extends Document>(T document) {
    return _flamestore.createDocumentIfAbsent(document);
  }

  Future<void> deleteDocument<T extends Document>(T document) {
    return _flamestore.deleteDocument(document);
  }

  ValueStream<T> _docStreamWherePath<T extends Document>(String path) {
    return _flamestore.docStreamWherePath<T>(path);
  }
}
