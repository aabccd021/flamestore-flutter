part of '../../flamestore.dart';

class _DocumentsState {
  _DocumentsState({
    BehaviorSubject<Map<String, BehaviorSubject<Document>>> stream,
  }) : _mapStream = stream ??
            BehaviorSubject<Map<String, BehaviorSubject<Document>>>.seeded(
                {'': BehaviorSubject.seeded(null)});

  final BehaviorSubject<Map<String, BehaviorSubject<Document>>> _mapStream;
  Map<String, BehaviorSubject<Document>> get _map => _mapStream.value;

  ValueStream<T> streamWherePath<T extends Document>(String path) {
    return _mapStream
        .switchMap((documentsSet) => Rx.combineLatestList(documentsSet.values)
            .defaultIfEmpty([null])
            .map((documents) => documents
                .whereType<T>()
                .firstWhere((document) => document.reference.path == path))
            .onErrorReturn(null))
        .shareValue();
  }

  void update<T extends Document>(
    T newDocument, {
    bool updateAggregate = false,
  }) {
    final key = newDocument?.reference?.path;
    if (key == null) {
      return;
    }
    final isDocNew = !_map.containsKey(key) || _map[key] == null;
    if (isDocNew) {
      _mapStream.add(_map..[key] = BehaviorSubject<Document>.seeded(null));
    }

    final oldDocument = _map[key].value;

    ///
    _map[key].add(newDocument);

    if (updateAggregate) {
      ///sum
      newDocument.sums.forEach((sum) {
        final sumDocumentKey = sum.sumDocument?.path;
        if (sumDocumentKey != null && _map.containsKey(sumDocumentKey)) {
          final oldValue = isDocNew ? 0 : oldDocument.toDataMap()[sum.field];
          final valueDiff = newDocument.toDataMap()[sum.field] - oldValue;
          final oldSumDocument = _map[sumDocumentKey].value;
          final oldSumDocumentMap = oldSumDocument.toDataMap();
          final oldSumValue = oldSumDocumentMap[sum.sumField];
          if (oldSumValue != null) {
            final newSumValue = oldSumValue + valueDiff;
            final newSumDocument = oldSumDocument.fromMap({
              ...oldSumDocumentMap,
              sum.sumField: newSumValue,
            });
            newSumDocument.reference = oldSumDocument.reference;
            _map[sumDocumentKey].add(newSumDocument);
          }
        }
      });

      ///count
      newDocument.counts.forEach((count) {
        final countDocumentKey = count.countDocument?.path;
        if (countDocumentKey != null &&
            _map.containsKey(countDocumentKey) &&
            isDocNew) {
          final oldCountDocument = _map[countDocumentKey].value;
          final oldCountDocumentMap = oldCountDocument.toDataMap();
          final oldCountValue = oldCountDocumentMap[count.countField];
          if (oldCountValue != null) {
            final newCountValue = oldCountValue + 1;
            final newCountDocument = oldCountDocument.fromMap({
              ...oldCountDocumentMap,
              count.countField: newCountValue,
            });
            newCountDocument.reference = oldCountDocument.reference;
            _map[countDocumentKey].add(newCountDocument);
          }
        }
      });
    }
  }

  void delete<T extends Document>(T document) {
    final key = document.reference.path;
    _mapStream.add(
      _map
        ..[key].close()
        ..remove(key),
    );

    //sum
    document.sums.forEach((sum) {
      final sumDocumentKey = sum.sumDocument?.path;
      if (sumDocumentKey != null && _map.containsKey(sumDocumentKey)) {
        final oldValue = document.toDataMap()[sum.field];
        final oldSumDocument = _map[sumDocumentKey].value;
        final oldSumDocumentMap = oldSumDocument.toDataMap();
        final oldSumValue = oldSumDocumentMap[sum.sumField];
        if (oldSumValue != null) {
          final newSumValue = oldSumValue - oldValue;
          final newSumDocument = oldSumDocument.fromMap({
            ...oldSumDocumentMap,
            sum.sumField: newSumValue,
          });
          newSumDocument.reference = oldSumDocument.reference;
          _map[sumDocumentKey].add(newSumDocument);
        }
      }
    });

    ///count
    document.counts.forEach((count) {
      final countDocumentKey = count.countDocument?.path;
      if (countDocumentKey != null && _map.containsKey(countDocumentKey)) {
        final oldCountDocument = _map[countDocumentKey].value;
        final oldCountDocumentMap = oldCountDocument.toDataMap();
        final oldCountValue = oldCountDocumentMap[count.countField];
        if (oldCountValue != null) {
          final newCountValue = oldCountValue - 1;
          final newCountDocument = oldCountDocument.fromMap({
            ...oldCountDocumentMap,
            count.countField: newCountValue,
          });
          newCountDocument.reference = oldCountDocument.reference;
          _map[countDocumentKey].add(newCountDocument);
        }
      }
    });
  }
}
