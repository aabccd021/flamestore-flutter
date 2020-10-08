part of '../../flamestore.dart';

class _DocumentMapStream {
  _DocumentMapStream({
    BehaviorSubject<Map<String, BehaviorSubject<Document>>> dataStreamMap,
  }) : _mapStream = dataStreamMap ??
            BehaviorSubject<Map<String, BehaviorSubject<Document>>>.seeded({});

  final BehaviorSubject<Map<String, BehaviorSubject<Document>>> _mapStream;

  Map<String, BehaviorSubject<Document>> get _map => _mapStream.value;

  ValueStream<T> streamWherePath<T extends Document>(String path) {
    return _mapStream
        .switchMap((docSet) => Rx.combineLatestList(docSet.values)
            .map((docs) => docs
                .whereType<T>()
                .firstWhere((doc) => doc.reference.path == path))
            .onErrorReturn(null))
        .shareValue();
  }

  void updateState<T extends Document>(T document) {
    final key = document?.reference?.path;
    if (key == null) {
      return;
    }
    if (!_map.containsKey(key) || _map[key] == null) {
      _mapStream.add(
        _map..[key] = BehaviorSubject<Document>.seeded(null),
      );
    }
    _map[key].add(document);
  }

  void deleteState<T extends Document>(T document) {
    final key = document.reference.path;
    _mapStream.add(_map
      ..[key].close()
      ..remove(key));
  }
}
