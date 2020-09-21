part of '../../flamestore.dart';

class _StateDataMapStream {
  _StateDataMapStream(
    this.modelManager, {
    BehaviorSubject<Map<String, BehaviorSubject<StateData>>> dataStreamMap,
  }) : _dataStreamMapStream = dataStreamMap ??
            BehaviorSubject<Map<String, BehaviorSubject<StateData>>>.seeded({});

  final BehaviorSubject<Map<String, BehaviorSubject<StateData>>>
      _dataStreamMapStream;
  final _StateModelManager modelManager;

  Map<String, BehaviorSubject<StateData>> get _dataStreamMap =>
      _dataStreamMapStream.value;

  ValueStream<T> streamOf<T extends StateData>(StateFetcher<T> fetcher) {
    if (fetcher.stateType == T.runtimeType) {
      throw InvalidStateType(fetcher, T);
    }
    if (T == StateData) {
      throw const EmptyStateType('streamOf');
    }
    return _dataStreamMapStream
        .switchMap<T>((dataStreamMap) => Rx.combineLatestList<StateData>(
                dataStreamMap.values)
            .map<T>((stateDatas) =>
                stateDatas.whereType<T>().firstWhere(fetcher.condition))
            .onErrorReturnWith((error) => _onStreamNotFound(error, fetcher)))
        .shareValue();
  }

  Future<T> valueOf<T extends StateData>(StateFetcher<T> fetcher) =>
      streamOf<T>(fetcher).first;

  Future<void> nullifyState(DocumentReference ref) async {
    await _dataStreamMap[ref.id].value?.close();
    _dataStreamMap[ref.id].add(null);
  }

  Future<void> updateStateFromSnapshot({
    @required DocumentReference ref,
    @required Type stateDataType,
    @required DocumentSnapshot snapshot,
  }) async {
    if (!_dataStreamMap.containsKey(ref.id) || _dataStreamMap[ref.id] == null) {
      _dataStreamMapStream.add(
          _dataStreamMap..[ref.id] = BehaviorSubject<StateData>.seeded(null));
    }
    if (_dataStreamMap[ref.id].value == null) {
      final newState = modelManager.stateFromSnapshot(stateDataType, snapshot);
      _dataStreamMap[ref.id].add(newState);
      Logger(printer: PrettyPrinter(methodCount: 1)).v(newState);
    } else {
      final newState = _dataStreamMap[ref.id].value
        ..overwriteFromSnapshot(snapshot);
      Logger(printer: PrettyPrinter(methodCount: 1)).v(newState);
    }
  }

  T _onStreamNotFound<T extends StateData>(
      dynamic error, StateFetcher<T> fetcher) {
    if (error is StateError && error.message == 'No element') {
      Logger(printer: PrettyPrinter(methodCount: 1))
          .v('$T not found\n\n$fetcher');
      return null;
    }
    Logger(printer: PrettyPrinter(methodCount: 1))
        .w('error when finding $T\n\n$fetcher');
    throw error;
  }
}

class InvalidStateType implements Exception {
  const InvalidStateType(this.stateFetcher, this.type);
  final StateFetcher stateFetcher;
  final Type type;

  @override
  String toString() =>
      'Invalid State:\n' 'fetcher: $stateFetcher\n' 'type: $type\n';
}
