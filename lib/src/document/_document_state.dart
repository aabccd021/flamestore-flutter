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
        .switchMap((docsSet) => Rx.combineLatestList(docsSet.values)
            .defaultIfEmpty([null])
            .map((docs) => docs
                .whereType<T>()
                .firstWhere((doc) => doc.reference.path == path))
            .onErrorReturn(null))
        .shareValue();
  }

  Document update(Document newDoc, {bool doUpdateAggregate = false}) {
    final key = newDoc?.reference?.path;
    if (key == null) return null;

    final isDocNew = !_map.containsKey(key);
    final oldDoc = isDocNew ? null : _map[key].value;

    // create empty entry if doc new
    if (isDocNew) {
      _map[key] = BehaviorSubject<Document>.seeded(null);
      _mapStream.add(_map);
    }

    // add doc to state
    _map[key].add(newDoc);

    // handle sum and count states
    if (doUpdateAggregate) {
      _.sumsOf(newDoc).forEach((sum) {
        final newValue = _.mapOf(newDoc)[sum.field].value?.toDouble();
        final oldValue =
            isDocNew ? 0 : _.mapOf(oldDoc)[sum.field].value?.toDouble();
        final valueDiff = newValue - oldValue;
        _sumOnUpdate(sum, valueDiff);
      });
      _.countsOf(newDoc).forEach((count) => _countOnUpdate(count, isDocNew));
    }
    return oldDoc;
  }

  void delete<T extends Document>(T document) {
    final key = document.reference.path;
    _map[key].close();
    _map.remove(key);
    _mapStream.add(_map);

    // _.sumsOf(document).forEach((sum) => _sumOnDelete(sum, document));
    _.countsOf(document).forEach((count) => _countOnDelete(count));
  }

  void _sumOnUpdate(Sum sum, double valueDiff) {
    final docKey = sum.ref?.path;
    if (docKey != null && _map.containsKey(docKey)) {
      final oldSumDoc = _map[docKey].value;
      final oldSumDocumentMap = _.mapOf(oldSumDoc);
      final oldSumField = oldSumDocumentMap[sum.fieldName] as SumField;
      final oldSumValue = oldSumField.value;
      if (oldSumValue != null) {
        final newSumValue = oldSumValue + valueDiff;
        final newSumField = SumField(newSumValue);
        final newSumMap = {...oldSumDocumentMap, sum.fieldName: newSumField};
        final newSumDoc = _.docFromMap(newSumMap, sum.ref);
        _map[docKey].add(newSumDoc);
      }
    }
  }

  void _countOnUpdate<T extends Document>(Count count, bool isDocNew) {
    final countDocKey = count.ref?.path;
    if (countDocKey != null && _map.containsKey(countDocKey) && isDocNew) {}
    final oldCountDoc = _map[countDocKey].value;
    final oldCountMap = _.mapOf(oldCountDoc);
    final oldCountField = oldCountMap[count.fieldName] as CountField;
    final oldCountVal = oldCountField.value;
    if (oldCountVal != null) {
      final newCountField = CountField(oldCountVal + 1);
      final newCountMap = {...oldCountMap, count.fieldName: newCountField};
      final newCountDoc = _.docFromMap(newCountMap, count.ref);
      _map[countDocKey].add(newCountDoc);
    }
  }

  // void _sumOnDelete(Sum sum, Document doc) {
  //   final sumDocKey = sum.sumDocRef?.path;
  //   if (sumDocKey != null && _map.containsKey(sumDocKey)) {
  //     final oldField = _.mapOf(doc)[sum.field] as IntField;
  //     final oldValue = oldField.value;
  //     final oldSumDoc = _map[sumDocKey].value;
  //     final oldSumDocMap = _.mapOf(oldSumDoc);
  //     final oldSumField = oldSumDocMap[sum.sumField] as SumField;
  //     final oldSumVal = oldSumField.value;
  //     if (oldSumVal != null) {
  //       final newSumVal = oldSumVal - oldValue;
  //       final newSumMap = {...oldSumDocMap, sum.sumField: SumField(newSumVal)};
  //       final newSumDoc = _.docFromMap(newSumMap, sum.sumDocRef);
  //       _map[sumDocKey].add(newSumDoc);
  //     }
  //   }
  // }

  void _countOnDelete(Count count) {
    final countDocKey = count.ref?.path;
    if (countDocKey != null && _map.containsKey(countDocKey)) {
      final oldCountDoc = _map[countDocKey].value;
      final oldCountDocMap = _.mapOf(oldCountDoc);
      final oldCountField = oldCountDocMap[count.fieldName] as CountField;
      final oldCountVal = oldCountField.value;
      if (oldCountVal != null) {
        final newCountField = CountField(oldCountVal - 1);
        final newCountMap = {...oldCountDocMap, count.fieldName: newCountField};
        final newCountDoc = _.docFromMap(newCountMap, count.ref);
        _map[countDocKey].add(newCountDoc);
      }
    }
  }
}
