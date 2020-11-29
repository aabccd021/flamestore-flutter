part of '../../flamestore.dart';

class _DocumentListManager {
  _DocumentListManager({
    _DocumentListFirestoreAdapter adapter,
    Map<DocumentListKey, BehaviorSubject<_DocumentListState>> map,
  })  : _db = adapter ?? _DocumentListFirestoreAdapter(),
        _state = map ?? {};

  final Map<DocumentListKey, BehaviorSubject<_DocumentListState>> _state;
  final _DocumentListFirestoreAdapter _db;

  Future<List<T>> get<T extends Document, V extends DocumentListKey<T>>(
    V list,
  ) async {
    _createIfAbsent(list);
    final oldList = _state[list].value;
    final snapshots = await _db.get(list, oldList.lastDocument);
    if (snapshots.isEmpty) {
      _updateState(list, hasMore: false);
    } else {
      final newReferences = snapshots.map((snapshot) => snapshot.reference);
      _updateState(
        list,
        lastDocument: snapshots[snapshots.length - 1],
        references: [...oldList.references, ...newReferences],
      );
    }
    return snapshots
        .map((snapshot) => list.document.fromSnapshot(snapshot))
        .cast<T>()
        .toList();
  }

  ValueStream<_DocumentListState> streamOf(DocumentListKey list) {
    _createIfAbsent(list);
    return _state[list];
  }

  Future<List<T>> refresh<T extends Document, V extends DocumentListKey<T>>(
    V list,
  ) async {
    _createIfAbsent(list);
    _state[list].add(_DocumentListState());
    return get(list);
  }

  void addReference(
    DocumentReference reference,
    List<DocumentListKey> lists,
  ) {
    for (final list in lists) {
      final oldReferences = _state[list].value.references;
      // avoid duplicate references in list
      if (!oldReferences.map((ref) => ref.path).contains(reference.path)) {
        _updateState(
          list,
          references: [reference, ...oldReferences],
        );
      }
    }
  }

  void deleteReference(DocumentReference reference) {
    for (final list in _state.keys) {
      final references = _state[list].value.references..remove(reference);
      _updateState(list, references: references);
    }
  }

  void _createIfAbsent(DocumentListKey list) {
    if (!_state.containsKey(list) || _state[list] == null) {
      _state[list] = BehaviorSubject.seeded(_DocumentListState());
    }
  }

  void _updateState(
    DocumentListKey list, {
    List<DocumentReference> references,
    DocumentSnapshot lastDocument,
    bool hasMore,
  }) {
    _createIfAbsent(list);
    final state = _state[list].value;
    _state[list].add(
      _DocumentListState(
        references: references ?? state.references,
        lastDocument: lastDocument ?? state.lastDocument,
        hasMore: hasMore ?? state.hasMore,
      ),
    );
  }
}
