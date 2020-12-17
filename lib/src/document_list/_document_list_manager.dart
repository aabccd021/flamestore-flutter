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
    final colName = _.colNameOf(T);
    _createIfAbsent(list);
    final oldList = _state[list].value;
    final snapshots = await _db.get<T>(list, oldList.lastDoc);
    if (snapshots.isEmpty) {
      _updateState(list, hasMore: false);
    } else {
      final newReferences = snapshots.map((snapshot) => snapshot.reference);
      _updateState(
        list,
        lastDoc: snapshots[snapshots.length - 1],
        refs: [...oldList.references, ...newReferences],
      );
    }
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
    return get(list);
  }

  void addReference(DocumentReference ref, List<DocumentListKey> lists) {
    for (final list in lists) {
      final oldRefs = _state[list].value.references;
      // avoid duplicate references in list
      if (!oldRefs.map((e) => e.path).contains(ref.path)) {
        final prependedRefs = [ref, ...oldRefs];
        _updateState(list, refs: prependedRefs);
      }
    }
  }

  void deleteReference(DocumentReference reference) {
    for (final list in _state.keys) {
      final references = _state[list].value.references..remove(reference);
      _updateState(list, refs: references);
    }
  }

  void _createIfAbsent(DocumentListKey list) {
    if (!_state.containsKey(list) || _state[list] == null) {
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
    final state = _state[list].value;
    _state[list].add(
      _DocumentListState(
        refs: refs ?? state.references,
        lastDoc: lastDoc ?? state.lastDoc,
        hasMore: hasMore ?? state.hasMore,
      ),
    );
  }
}
