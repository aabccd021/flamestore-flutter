part of '../../flamestore.dart';

class _StateListManager {
  _StateListManager(
    this.modelManager, {
    _StateListService listService,
    Map<StateList, BehaviorSubject<_StateListData>> stateListDataStreamMap,
  })  : _listService = listService ?? _StateListService(modelManager),
        _map = stateListDataStreamMap ?? {};

  final Map<StateList, BehaviorSubject<_StateListData>> _map;
  final _StateListService _listService;
  final _StateModelManager modelManager;

  Future<List<DocumentSnapshot>> listFetch(StateList stateList) async {
    _createEmptyListIfNotExists(stateList);
    final oldStateList = _map[stateList].value;
    if (!oldStateList.hasMore) {
      return [];
    }
    final snapshots =
        await _listService.fetchList(stateList, oldStateList.lastDocument);
    if (snapshots.isEmpty) {
      _updateStateList(stateList, hasMore: false);
    } else {
      final newRefs = snapshots.map((s) => s.reference);
      _updateStateList(stateList,
          lastDocument: snapshots[snapshots.length - 1],
          refs: [...oldStateList.refs, ...newRefs]);
    }
    return snapshots;
  }

  void addRefToLists(DocumentReference ref, List<StateList> stateLists) {
    for (final stateList in stateLists) {
      final oldRefs = _map[stateList].value.refs;
      final updatedRefs = [ref, ...oldRefs];
      _updateStateList(stateList, refs: updatedRefs);
    }
  }

  ValueStream<List<DocumentReference>> listStream(
    StateList stateList,
  ) {
    _createEmptyListIfNotExists(stateList);
    return _map[stateList]
        .map((event) => event.refs)
        .defaultIfEmpty([]).shareValue();
  }

  Future<void> listRefresh(StateList stateList) async {
    clearList(stateList);
    await listFetch(stateList);
  }

  void deleteRefFromAllLists(DocumentReference ref) {
    for (final stateList in _map.keys) {
      final newRefs = _map[stateList].value.refs..remove(ref);
      _updateStateList(stateList, refs: newRefs);
    }
  }

  void clearList(StateList stateList) {
    _createEmptyListIfNotExists(stateList);
    _map[stateList].add(_StateListData());
  }

  void _createEmptyListIfNotExists(StateList stateList) {
    if (!_map.containsKey(stateList) || _map[stateList] == null) {
      _map[stateList] =
          BehaviorSubject<_StateListData>.seeded(_StateListData());
    }
  }

  void _updateStateList(
    StateList stateList, {
    List<DocumentReference> refs,
    DocumentSnapshot lastDocument,
    bool hasMore,
  }) {
    _createEmptyListIfNotExists(stateList);
    final oldStateList = _map[stateList].value;
    final newState = _StateListData(
      refs: refs ?? oldStateList.refs,
      lastDocument: lastDocument ?? oldStateList.lastDocument,
      hasMore: hasMore ?? oldStateList.hasMore,
    );
    Logger(printer: PrettyPrinter(methodCount: 1)).v('$stateList\n\n$newState');
    _map[stateList].add(newState);
  }
}
