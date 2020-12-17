part of '../../flamestore.dart';

class _DocumentManager {
  _DocumentManager(
    this._, {
    _DocumentState state,
    _DocumentFirestoreAdapter adapter,
    FirebaseFirestore firestore,
    Map<Document, DocumentReference> fetched,
  })  : _adapter = adapter ?? _DocumentFirestoreAdapter(_),
        _state = state ?? _DocumentState(_),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _fetchedDocPaths = fetched ?? <String>{};

  final _DocumentFirestoreAdapter _adapter;
  final _DocumentState _state;
  final FirebaseFirestore _firestore;
  final Set<String> _fetchedDocPaths;
  final _FlamestoreUtil _;

  ValueStream<T> streamWherePath<T extends Document>(String path) {
    return _state.streamWherePath<T>(path);
  }

  void set<T extends Document>(T doc, {Duration debounce}) async {
    _state.update<T>(doc, doUpdateAggregate: true);
    final reference = doc.reference;
    EasyDebounce.debounce(
      reference.path,
      debounce,
      () async {
        final oldDoc = await get(doc, true);
        if (oldDoc == null) {
          return create(doc);
        }
        if (_.shouldDelete(doc)) {
          return delete(oldDoc);
        }
        return _update(oldDoc, doc);
      },
    );
  }

  Future<T> create<T extends Document>(T doc) async {
    final colName = doc.colName;
    final ref = doc.reference ?? _firestore.collection(colName).doc();
    Map<String, dynamic> newDocMap = Map<String, dynamic>();
    final docMap = {
      ..._.mapOf(doc),
      ..._.defaultValueMapOf(doc),
    };
    for (final fieldName in docMap.keys) {
      final field = docMap[fieldName];
      if (field is DynamicLinkField) {
        newDocMap[fieldName] = await _adapter.createDynamicLink(
          colName,
          ref.id,
          field,
        );
      } else {
        newDocMap[fieldName] = field;
      }
    }
    final newDoc = _.docOfMap(newDocMap, colName);
    if (newDoc.reference != null) {
      _state.update<T>(newDoc);
    }
    await _adapter.create(ref, newDoc);
    newDoc..reference = ref;
    _state.update<T>(newDoc);
    return newDoc;
  }

  Future<T> _update<T extends Document>(T oldDoc, T newDoc) async {
    final mergedDoc = _.mergeDocs(oldDoc, newDoc);
    _state.update<T>(mergedDoc);
    await _adapter.update(oldDoc.reference, newDoc);
    return mergedDoc;
  }

  Future<void> delete<T extends Document>(T oldDoc) async {
    await _state.delete(oldDoc);
    await _adapter.delete(oldDoc);
  }

  Future<T> createIfAbsent<T extends Document>(T doc) async {
    return await get(doc, false) ?? await create(doc);
  }

  Future<T> get<T extends Document>(T keyDoc, bool fromCache) async {
    final path = keyDoc.reference.path;
    final onMemoryDoc = await streamWherePath<T>(
      path,
    ).first;
    if (fromCache && _fetchedDocPaths.contains(path)) {
      return onMemoryDoc;
    }
    final snapshot = await _adapter.get(keyDoc);
    _fetchedDocPaths.add(path);
    if (snapshot == null) {
      return null;
    }
    final createdDoc = _.docFromSnapshot(snapshot, keyDoc.colName);
    final T updatedDoc =
        onMemoryDoc != null ? _.mergeDocs(onMemoryDoc, createdDoc) : createdDoc;
    await _state.update<T>(updatedDoc);
    return updatedDoc;
  }

  Future<void> addFromList<T extends Document>(List<T> docs) async {
    for (final doc in docs) {
      await _state.update<T>(doc);
    }
  }
}
