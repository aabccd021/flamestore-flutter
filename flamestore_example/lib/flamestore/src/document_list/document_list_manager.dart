part of '../../flamestore.dart';

class _DocumentListManager {
  _DocumentListManager({
    _DocumentListFirestoreAdapter adapter,
    Map<DocumentList, BehaviorSubject<_DocumentListInternalState>> map,
  })  : _adapter = adapter ?? _DocumentListFirestoreAdapter(),
        _map = map ?? {};

  final Map<DocumentList, BehaviorSubject<_DocumentListInternalState>> _map;
  final _DocumentListFirestoreAdapter _adapter;

  Future<List<T>> get<T extends Document, V extends DocumentList<T>>(
    V docList,
  ) async {
    _createListIfAbsent(docList);
    final oldDocList = _map[docList].value;
    final snapshots =
        await _adapter.get(list: docList, lastDoc: oldDocList.lastDoc);
    if (snapshots.isEmpty) {
      _updateDocumentList(docList, hasMore: false);
    } else {
      final newRefs = snapshots.map((snapshot) => snapshot.reference);
      _updateDocumentList(
        docList,
        lastDoc: snapshots[snapshots.length - 1],
        refs: [...oldDocList.refs, ...newRefs],
      );
    }
    return snapshots
        .map((snapshot) =>
            (docList.document.createDocumentFromData(snapshot.data()))
              ..reference = snapshot.reference)
        .cast<T>()
        .toList();
  }

  void addRefToLists(DocumentReference ref, List<DocumentList> docLists) {
    for (final docList in docLists) {
      final oldRefs = _map[docList].value.refs;
      _updateDocumentList(
        docList,
        refs: [ref, ...oldRefs],
      );
    }
  }

  ValueStream<_DocumentListInternalState> streamOf(DocumentList docList) {
    _createListIfAbsent(docList);
    return _map[docList];
  }

  Future<void> refresh(DocumentList docList) async {
    clear(docList);
    await get(docList);
  }

  void clear(DocumentList docList) {
    _createListIfAbsent(docList);
    final emptyDocList = _DocumentListInternalState();
    _map[docList].add(emptyDocList);
  }

  void deleteRefFromAllLists(DocumentReference ref) {
    for (final docList in _map.keys) {
      final newRefs = _map[docList].value.refs..remove(ref);
      _updateDocumentList(docList, refs: newRefs);
    }
  }

  void _createListIfAbsent(DocumentList docList) {
    if (!_map.containsKey(docList) || _map[docList] == null) {
      final emptyDocList = _DocumentListInternalState();
      _map[docList] =
          BehaviorSubject<_DocumentListInternalState>.seeded(emptyDocList);
    }
  }

  void _updateDocumentList(
    DocumentList list, {
    List<DocumentReference> refs,
    DocumentSnapshot lastDoc,
    bool hasMore,
  }) {
    _createListIfAbsent(list);
    final oldDocList = _map[list].value;
    _map[list].add(
      _DocumentListInternalState(
        refs: refs ?? oldDocList.refs,
        lastDoc: lastDoc ?? oldDocList.lastDoc,
        hasMore: hasMore ?? oldDocList.hasMore,
      ),
    );
  }
}
