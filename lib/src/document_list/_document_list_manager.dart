part of '../../flamestore.dart';

class _DocumentListManager {
  _DocumentListManager(
    this._, {
    _DocumentListFirestoreAdapter adapter,
    Map<DocumentListKey, BehaviorSubject<_DocumentListState>> map,
  })  : _db = adapter ?? _DocumentListFirestoreAdapter(_),
        _state = map ?? {};

  final Map<DocumentListKey, BehaviorSubject<_DocumentListState>> _state;
  final _DocumentListFirestoreAdapter _db;
  final _FlamestoreUtil _;

  Future<List<T>> get<T extends Document>(DocumentListKey<T> list) async {
    _createIfAbsent(list);
    final oldList = _state[list].value;
    final snapshots = await _db.get<T>(list, oldList.lastDoc);
    if (snapshots.isEmpty) {
      _updateState(list, hasMore: false);
    } else {
      final newRefs = snapshots.map((snapshot) => snapshot.reference);
      final toUpdateRefs = [...oldList.refs, ...newRefs];
      final lastDoc = snapshots[snapshots.length - 1];
      _updateState(list, lastDoc: lastDoc, refs: toUpdateRefs);
    }
    final colName = _.colNameOfList(list);
    return snapshots
        .map((snapshot) => _.docFromSnapshot(snapshot, colName))
        .cast<T>()
        .toList();
  }

  ValueStream<_DocumentListState> streamOf(DocumentListKey list) {
    _createIfAbsent(list);
    return _state[list];
  }

  Future<List<T>> refresh<T extends Document>(DocumentListKey<T> list) async {
    _createIfAbsent(list);
    _state[list].add(_DocumentListState());
    return get<T>(list);
  }

  void addRefToList(DocumentReference ref, List<DocumentListKey> lists) {
    lists.forEach((list) {
      final oldRefs = _state[list].value.refs;
      final isRefInList = oldRefs.map((e) => e.path).contains(ref.path);
      if (!isRefInList) {
        final newRefs = [ref, ...oldRefs];
        _updateState(list, refs: newRefs);
      }
    });
  }

  void deleteRefFromList(DocumentReference ref) {
    _state.keys.forEach((list) {
      final oldRefs = _state[list].value.refs;
      final newRefs = oldRefs..remove(ref);
      _updateState(list, refs: newRefs);
    });
  }

  void _createIfAbsent(DocumentListKey list) {
    if (!_state.containsKey(list)) {
      _state[list] = BehaviorSubject.seeded(_DocumentListState());
    }
  }

  void _updateState(
    DocumentListKey list, {
    List<DocumentReference> refs,
    DocumentSnapshot lastDoc,
    bool hasMore,
  }) {
    _createIfAbsent(list);
    final oldState = _state[list].value;
    final newState = _DocumentListState(
      refs: refs ?? oldState.refs,
      lastDoc: lastDoc ?? oldState.lastDoc,
      hasMore: hasMore ?? oldState.hasMore,
    );
    _state[list].add(newState);
  }
}
