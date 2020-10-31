part of '../../flamestore.dart';

class _DocumentsState {
  _DocumentsState({
    BehaviorSubject<Map<String, BehaviorSubject<Document>>> stream,
  }) : _mapStream = stream ??
            BehaviorSubject<Map<String, BehaviorSubject<Document>>>.seeded({});

  final BehaviorSubject<Map<String, BehaviorSubject<Document>>> _mapStream;
  Map<String, BehaviorSubject<Document>> get _map => _mapStream.value;

  ValueStream<T> streamWherePath<T extends Document>(String path) {
    return _mapStream
        .switchMap((documentsSet) => Rx.combineLatestList(documentsSet.values)
            .map((documents) => documents
                .whereType<T>()
                .firstWhere((document) => document.reference.path == path))
            .onErrorReturn(null))
        .shareValue();
  }

  void update<T extends Document>(T newDocument) {
    final key = newDocument?.reference?.path;
    if (key == null) {
      return;
    }
    final isDocNew = !_map.containsKey(key) || _map[key] == null;
    if (isDocNew) {
      _mapStream.add(_map..[key] = BehaviorSubject<Document>.seeded(null));
    }

    ///sum
    newDocument.sum.forEach((sumElement) {
      final sumDocumentKey = sumElement.sumDocument?.path;
      if (sumDocumentKey != null && _map.containsKey(sumDocumentKey)) {
        final oldDocument = _map[key].value;
        final oldValue =
            isDocNew ? 0 : oldDocument.toDataMap()[sumElement.field];
        final valueDiff = newDocument.toDataMap()[sumElement.field] - oldValue;
        final oldSumDocument = _map[sumDocumentKey].value;
        final oldSumDocumentMap = oldSumDocument.toDataMap();
        final newSumValue = oldSumDocumentMap[sumElement.sumField] + valueDiff;
        final newSumDocument = oldSumDocument.fromMap({
          ...oldSumDocumentMap,
          sumElement.sumField: newSumValue,
        });
        newSumDocument.reference = oldSumDocument.reference;
        _map[sumDocumentKey].add(newSumDocument);
      }
    });

    ///
    _map[key].add(newDocument);
  }

  void delete<T extends Document>(T document) {
    final key = document.reference.path;
    _mapStream.add(_map
      ..[key].close()
      ..remove(key));
  }
}
