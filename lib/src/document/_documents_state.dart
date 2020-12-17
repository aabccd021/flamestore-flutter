part of '../../flamestore.dart';

class _DocumentState {
  _DocumentState(
    this._, {
    BehaviorSubject<Map<String, BehaviorSubject<Document>>> stream,
  }) : _mapStream = stream ??
            BehaviorSubject<Map<String, BehaviorSubject<Document>>>.seeded(
                {'': BehaviorSubject.seeded(null)});

  final _FlamestoreUtil _;
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
      _.sums(newDocument).forEach((sum) {
        final oldValue = isDocNew ? 0 : _.dataMapFrom(oldDocument)[sum.field];
        final valueDiff = _.dataMapFrom(newDocument)[sum.field] - oldValue;
        _sumOnUpdate(sum, valueDiff);
      });
      _.counts(newDocument).forEach((count) {
        _countOnUpdate(count, isDocNew);
      });
    }
  }

  void delete<T extends Document>(T document) {
    final key = document.reference.path;
    final deletedMap = _map
      ..[key].close()
      ..remove(key);
    _mapStream.add(deletedMap);

    //sum
    _.sums(document).forEach((sum) => _sumOnDelete(sum, document));

    ///count
    _.counts(document).forEach((count) => _countOnDelete(count));
  }

  void _sumOnUpdate(Sum sum, dynamic valueDiff) {
    final sumDocumentKey = sum.sumDoc?.path;
    if (sumDocumentKey != null && _map.containsKey(sumDocumentKey)) {
      final oldSumDoc = _map[sumDocumentKey].value;
      final oldSumDocumentMap = _.dataMapFrom(oldSumDoc);
      final oldSumValue = oldSumDocumentMap[sum.sumField];
      if (oldSumValue != null) {
        final newSumValue = oldSumValue + valueDiff;
        final newSumMap = {...oldSumDocumentMap, sum.sumField: newSumValue};
        final newSumDocument = _.docOfMap(newSumMap, sum.sumDocCol);
        newSumDocument..reference = oldSumDoc.reference;
        _map[sumDocumentKey].add(newSumDocument);
      }
    }
  }

  void _countOnUpdate<T extends Document>(Count count, bool isDocNew) {
    final countDocKey = count.countDoc?.path;
    if (countDocKey != null && _map.containsKey(countDocKey) && isDocNew) {}
    final oldCountDoc = _map[countDocKey].value;
    final oldCountDocMap = _.dataMapFrom(oldCountDoc);
    final oldCountVal = oldCountDocMap[count.countField];
    if (oldCountVal != null) {
      final newCountVal = oldCountVal + 1;
      final newCountMap = {...oldCountDocMap, count.countField: newCountVal};
      final newCountDoc = _.docOfMap(newCountMap, count.countDocCol);
      newCountDoc..reference = oldCountDoc.reference;
      _map[countDocKey].add(newCountDoc);
    }
  }

  void _sumOnDelete(Sum sum, Document doc) {
    final sumDocKey = sum.sumDoc?.path;
    if (sumDocKey != null && _map.containsKey(sumDocKey)) {
      final oldValue = _.dataMapFrom(doc)[sum.field];
      final oldSumDoc = _map[sumDocKey].value;
      final oldSumDocMap = _.dataMapFrom(oldSumDoc);
      final oldSumVal = oldSumDocMap[sum.sumField];
      if (oldSumVal != null) {
        final newSumVal = oldSumVal - oldValue;
        final newSumMap = {...oldSumDocMap, sum.sumField: newSumVal};
        final newSumDoc = _.docOfMap(newSumMap, sum.sumDocCol);
        newSumDoc..reference = oldSumDoc.reference;
        _map[sumDocKey].add(newSumDoc);
      }
    }
  }

  void _countOnDelete(Count count) {
    final countDocKey = count.countDoc?.path;
    if (countDocKey != null && _map.containsKey(countDocKey)) {
      final oldCountDoc = _map[countDocKey].value;
      final oldCountDocMap = _.dataMapFrom(oldCountDoc);
      final oldCountVal = oldCountDocMap[count.countField];
      if (oldCountVal != null) {
        final newCountValue = oldCountVal - 1;
        final newCountMap = {
          ...oldCountDocMap,
          count.countField: newCountValue
        };
        final newCountDoc = _.docOfMap(newCountMap, count.countDocCol);
        newCountDoc..reference = oldCountDoc.reference;
        _map[countDocKey].add(newCountDoc);
      }
    }
  }
}
