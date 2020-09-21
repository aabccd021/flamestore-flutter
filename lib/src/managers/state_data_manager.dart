part of '../../flamestore.dart';

class _StateDataManager {
  _StateDataManager(
    this.modelManager, {
    _StateDataMapStream map,
    _StateDataService stateDataService,
    Map<StateFetcher, DocumentReference> fetchedFetchers,
  })  : _stateDataService = stateDataService ?? _StateDataService(modelManager),
        _map = map ?? _StateDataMapStream(modelManager),
        _fetchedFetchers = fetchedFetchers ?? <StateFetcher>{};

  final _StateDataService _stateDataService;
  final _StateDataMapStream _map;
  final Set<StateFetcher> _fetchedFetchers;
  final _StateModelManager modelManager;

  ValueStream<T> streamOf<T extends StateData>(StateFetcher<T> fetcher) =>
      _map.streamOf<T>(fetcher);

  Future<T> valueOf<T extends StateData>(StateFetcher<T> fetcher) =>
      _map.valueOf<T>(fetcher);

  Future<DocumentReference> post(StatePoster statePoster) async {
    final keyFetcherType = modelManager.keyFetcherTypeOf(statePoster.stateType);
    if (keyFetcherType != null) {
      if (statePoster is UniqueStatePoster) {
        final stateFetcher = statePoster.stateFetcher;
        if (stateFetcher.runtimeType != keyFetcherType) {}
        final fetchResult = await _stateDataService.fetch(stateFetcher);
        if (fetchResult != null) {
          throw DataAlreadyExistsInDb(statePoster);
        }
      } else {
        throw RequireUniqueStatePoster(statePoster);
      }
    }
    final ref = await _stateDataService.post(statePoster);
    final snapshot =
        await _stateDataService.fetchRef(ref, statePoster.stateType);
    await _map.updateStateFromSnapshot(
        ref: ref, stateDataType: statePoster.stateType, snapshot: snapshot);
    return ref;
  }

  Future<void> postIfNotExistsInDbThenFetch(
    UniqueStatePoster poster,
  ) async {
    final snapshot = await _unsafeFetchAndUpdateState(poster.stateFetcher);
    if (snapshot == null) {
      await post(poster);
    }
  }

  Future<void> fetch<T extends StateData>(
    StateFetcher<T> stateFetcher, {
    bool overwrite = false,
  }) async {
    final state = await valueOf<T>(stateFetcher);
    if (overwrite ||
        (state == null && !_fetchedFetchers.contains(stateFetcher))) {
      await _unsafeFetchAndUpdateState(stateFetcher);
      _fetchedFetchers.add(stateFetcher);
    }
  }

  Future<void> addFromList(
    StateList stateList,
    List<DocumentSnapshot> snapshots,
  ) async {
    for (final snapshot in snapshots) {
      await _map.updateStateFromSnapshot(
          ref: snapshot.reference,
          stateDataType: stateList.stateType,
          snapshot: snapshot);
    }
  }

  Future<void> put(StatePutter putter) async {
    final ref = putter.ref;
    await _stateDataService.put(ref, putter);
    final snapshot = await _stateDataService.fetchRef(ref, putter.stateType);
    await _map.updateStateFromSnapshot(
        ref: ref, stateDataType: putter.stateType, snapshot: snapshot);
  }

  Future<void> delete(DocumentReference ref) async {
    await _stateDataService.deleteRef(ref);
    await _map.nullifyState(ref);
  }

  Future<DocumentSnapshot> _unsafeFetchAndUpdateState(
    StateFetcher fetcher,
  ) async {
    final snapshot = await _stateDataService.fetch(fetcher);
    if (snapshot == null) {
      return null;
    }
    await _map.updateStateFromSnapshot(
        ref: snapshot.reference,
        stateDataType: fetcher.stateType,
        snapshot: snapshot);
    return snapshot;
  }
}

class DataAlreadyExistsInDb implements Exception {
  const DataAlreadyExistsInDb(this.statePoster);
  final StatePoster statePoster;

  @override
  String toString() =>
      'Data already exists in firestore: ${statePoster.runtimeType}';
}

class RequireUniqueStatePoster implements Exception {
  const RequireUniqueStatePoster(this.statePoster);
  final StatePoster statePoster;

  @override
  String toString() => 'StateData ${statePoster.stateType} '
      'needs to be posted using UniqueStatePoster instead of StatePoster';
}
