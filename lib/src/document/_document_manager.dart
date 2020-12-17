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
        _fetchedDocumentPaths = fetched ?? <String>{};

  final _DocumentFirestoreAdapter _adapter;
  final _DocumentState _state;
  final FirebaseFirestore _firestore;
  final Set<String> _fetchedDocumentPaths;
  final _FlamestoreUtil _;

  ValueStream<T> streamWherePath<T extends Document>(String path) {
    return _state.streamWherePath<T>(
      path,
    );
  }

  void set<T extends Document>(T document, {Duration debounce}) async {
    _state.update<T>(document, updateAggregate: true);
    final reference = document.reference;
    EasyDebounce.debounce(
      reference.path,
      debounce,
      () async {
        final oldDocument = await get(document, true);
        if (oldDocument == null) {
          return create(document);
        }
        if (_.docShouldBeDeleted(document)) {
          return delete(oldDocument);
        }
        return _update(oldDocument, document);
      },
    );
  }

  Future<T> create<T extends Document>(T doc) async {
    final colName = doc.colName;
    final ref = doc.reference ?? _firestore.collection(colName).doc();
    Map<String, dynamic> newDocMap = Map<String, dynamic>();
    final docMap = {
      ..._.mapFrom(doc),
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
    final onMemoryDocument = await streamWherePath<T>(
      path,
    ).first;
    if (fromCache && _fetchedDocumentPaths.contains(path)) {
      return onMemoryDocument;
    }
    final snapshot = await _adapter.get(keyDoc);
    _fetchedDocumentPaths.add(path);
    if (snapshot == null) {
      return null;
    }
    final createdDocument = _.docFromSnapshot(snapshot, keyDoc.colName);
    final T updatedDocument = onMemoryDocument != null
        ? _.mergeDocs(onMemoryDocument, createdDocument)
        : createdDocument;
    await _state.update<T>(updatedDocument);
    return updatedDocument;
  }

  Future<void> addFromList<T extends Document>(List<T> documents) async {
    for (final document in documents) {
      await _state.update<T>(document);
    }
  }
}
