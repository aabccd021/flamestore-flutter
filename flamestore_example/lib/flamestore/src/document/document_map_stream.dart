part of '../../flamestore.dart';

class _DocumentMapStream {
  _DocumentMapStream({
    BehaviorSubject<Map<String, BehaviorSubject<Document>>> dataStreamMap,
  }) : _docStreamMapStream = dataStreamMap ??
            BehaviorSubject<Map<String, BehaviorSubject<Document>>>.seeded({});

  final BehaviorSubject<Map<String, BehaviorSubject<Document>>>
      _docStreamMapStream;

  Map<String, BehaviorSubject<Document>> get _dataStreamMap =>
      _docStreamMapStream.value;

  ValueStream<T> streamOf<T extends Document>(T key) {
    return _docStreamMapStream
        .switchMap<T>((docStreamMap) =>
            Rx.combineLatestList<Document>(docStreamMap.values)
                .map<T>((docs) => docs
                    .whereType<T>()
                    .firstWhere((doc) => _filterDocByKey(doc, key)))
                .onErrorReturnWith((error) => _onStreamNotFound(error, "$key")))
        .shareValue();
  }

  ValueStream<T> streamOfRef<T extends Document>(DocumentReference reference) {
    return _docStreamMapStream
        .switchMap<T>((docStreamMap) =>
            Rx.combineLatestList<Document>(docStreamMap.values)
                .map<T>((docs) => docs
                    .whereType<T>()
                    .firstWhere((doc) => doc.reference == reference))
                .onErrorReturnWith((error) =>
                    _onStreamNotFound<T>(error, "path:${reference.path}")))
        .shareValue();
  }

  bool _filterDocByKey<T extends Document>(T doc, T key) {
    final filter = key.toMap()..removeWhere((_, value) => value == null);
    return filter.entries
        .reduce((value, element) => MapEntry(
            'result', value.value && element.value == doc.toMap()[element.key]))
        .value;
  }

  Future<void> delete<T extends Document>(T document) async {
    _dataStreamMap[document.reference.path].add(null);
  }

  Future<void> updateDocumentState<T extends Document>({
    @required DocumentReference reference,
    @required T document,
  }) async {
    if (!_dataStreamMap.containsKey(reference.path) ||
        _dataStreamMap[reference.path] == null) {
      _docStreamMapStream.add(
        _dataStreamMap..[reference.path] = BehaviorSubject<Document>.seeded(null),
      );
    }
    _dataStreamMap[reference.path].add(document);
  }

  T _onStreamNotFound<T extends Document>(dynamic error, String filter) {
    if (error is StateError && error.message == 'No element') {
      print('$T not found\n$filter');
      return null;
    }
    print('error when finding $T\n$filter');
    throw error;
  }
}
