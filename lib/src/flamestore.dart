part of '../flamestore.dart';

class Flamestore {
  Flamestore._privateConstructor();
  static final Flamestore _instance = Flamestore._privateConstructor();
  static Flamestore get instance => _instance;

  final _Flamestore _flamestore = _Flamestore(_StateModelManager());

  void setupModels(Map<Type, StateModel> newModels) =>
      _flamestore.setupModels(newModels);

  Future<void> delete(DocumentReference key) => _flamestore.delete(key);

  Future<void> fetch<T extends StateData>(
    StateFetcher stateFetcher, {
    bool overwrite = false,
  }) {
    assert(T != StateData);
    return _flamestore.fetch<T>(stateFetcher, overwrite: overwrite);
  }

  Future<DocumentReference> post(StatePoster postState) =>
      _flamestore.post(postState);

  Future<void> postIfNotExistsInDbThenFetch(UniqueStatePoster postState) =>
      _flamestore.postIfNotExistsInDbThenFetch(postState);

  Future<void> put(StatePutter putState) => _flamestore.put(putState);

  ValueStream<T> streamOf<T extends StateData>(StateFetcher<T> fetcher) {
    assert(T != StateData);
    return _flamestore.streamOf<T>(fetcher);
  }

  Future<T> valueOf<T extends StateData>(StateFetcher<T> fetcher) {
    assert(T != StateData);
    return _flamestore.valueOf<T>(fetcher);
  }

  void clearList(StateList stateList) => _flamestore.clearList(stateList);

  Future<void> listFetch(StateList stateList) =>
      _flamestore.listFetch(stateList);

  Future<void> listRefresh(StateList stateList) =>
      _flamestore.listRefresh(stateList);

  ValueStream<List<DocumentReference>> listStream(StateList stateList) =>
      _flamestore.listStreamOf(stateList);
}

class _Flamestore {
  _Flamestore(
    this._modelManager, {
    _StateListManager listManager,
    _StateDataManager dataManager,
  })  : _listManager = listManager ?? _StateListManager(_modelManager),
        _dataManager = dataManager ?? _StateDataManager(_modelManager);

  final _StateListManager _listManager;
  final _StateDataManager _dataManager;
  final _StateModelManager _modelManager;

  void setupModels(Map<Type, StateModel> newModels) =>
      _modelManager.setupModels(newModels);

  Future<void> delete(DocumentReference stateKey) async {
    await _dataManager.delete(stateKey);
    _listManager.deleteRefFromAllLists(stateKey);
  }

  Future<void> fetch<T extends StateData>(
    StateFetcher stateFetcher, {
    bool overwrite = false,
  }) {
    if (T == StateData) {
      throw const EmptyStateType('fetch');
    }
    return _dataManager.fetch<T>(stateFetcher, overwrite: overwrite);
  }

  Future<DocumentReference> post(StatePoster poster) async {
    final ref = await _dataManager.post(poster);
    _listManager.addRefToLists(ref, poster.updatedStateLists);
    return ref;
  }

  Future<void> postIfNotExistsInDbThenFetch(UniqueStatePoster poster) =>
      _dataManager.postIfNotExistsInDbThenFetch(poster);

  Future<void> put(StatePutter putter) => _dataManager.put(putter);

  ValueStream<T> streamOf<T extends StateData>(StateFetcher<T> fetcher) {
    if (T == StateData) {
      throw const EmptyStateType('streamOf');
    }
    return _dataManager.streamOf<T>(fetcher);
  }

  Future<T> valueOf<T extends StateData>(StateFetcher<T> fetcher) {
    if (T == StateData) {
      throw const EmptyStateType('valueOf');
    }
    return _dataManager.valueOf<T>(fetcher);
  }

  void clearList(StateList stateList) => _listManager.clearList(stateList);

  Future<void> listFetch(StateList stateList) async {
    final snapshots = await _listManager.listFetch(stateList);
    await _dataManager.addFromList(stateList, snapshots);
  }

  Future<void> listRefresh(StateList stateList) =>
      _listManager.listRefresh(stateList);

  ValueStream<List<DocumentReference>> listStreamOf(StateList stateList) =>
      _listManager.listStream(stateList);
}

class EmptyStateType implements Exception {
  const EmptyStateType(this.functionName);
  final String functionName;

  @override
  String toString() => 'Please provide Type in $functionName<Type>()';
}
