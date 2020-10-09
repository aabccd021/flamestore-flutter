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

  void update<T extends Document>(T document) {
    final key = document?.reference?.path;
    if (key == null) {
      return;
    }
    if (!_map.containsKey(key) || _map[key] == null) {
      _mapStream.add(_map..[key] = BehaviorSubject<Document>.seeded(null));
    }
    _map[key].add(document);
  }

  void delete<T extends Document>(T document) {
    final key = document.reference.path;
    _mapStream.add(_map
      ..[key].close()
      ..remove(key));
  }
}
