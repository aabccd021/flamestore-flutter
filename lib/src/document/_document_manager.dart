part of '../../flamestore.dart';

class _DocumentManager {
  _DocumentManager(
    this._, {
    _DocumentState state,
    _DocumentFirestoreAdapter adapter,
    FirebaseFirestore firestore,
    Map<Document, DocumentReference> fetchedDocPaths,
    Map<String, Document> debouncedDocs,
  })  : _firebase = adapter ?? _DocumentFirestoreAdapter(_),
        _state = state ?? _DocumentState(_),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _fetchedDocPaths = fetchedDocPaths ?? <String>{},
        _debouncedDocs = debouncedDocs ?? {};

  final _DocumentFirestoreAdapter _firebase;
  final _DocumentState _state;
  final FirebaseFirestore _firestore;
  final Set<String> _fetchedDocPaths;
  final Map<String, Document> _debouncedDocs;
  final _FlamestoreUtil _;

  ValueStream<T> streamWherePath<T extends Document>(String path) {
    return _state.streamWherePath<T>(path);
  }

  void set(Document doc, {Duration debounce}) {
    final key = doc?.reference?.path;
    final oldDoc = _state.update(doc, doUpdateAggregate: true);
    _debouncedDocs.putIfAbsent(key, () => oldDoc);
    EasyDebounce.debounce(key, debounce, () => _set(key, doc));
  }

  Future<void> _set(String key, Document doc) async {
    final oldDoc = _debouncedDocs.remove(key);
    if (oldDoc == null) return create(doc);
    if (_shouldDelete(doc)) return delete(oldDoc);
    return _update(oldDoc, doc);
  }

  bool _shouldDelete(Document doc) => _.mapOf(doc).values.any((field) =>
      ((field is IntField && field.value == field.deleteOn) ||
          (field is FloatField && field.value == field.deleteOn)));

  Future<T> create<T extends Document>(T doc) async {
    _state.update(doc);

    // handle special fields
    final colName = doc.colName;
    final ref = doc.reference ?? _firestore.collection(colName).doc();
    final newDocMap = await _handleSpecialFields(ref, doc);
    final newDoc = _.docFromMap(newDocMap, ref);
    _state.update(newDoc, doUpdateAggregate: true);

    // POST doc
    await _firebase.createDoc(ref, newDoc);
    return newDoc;
  }

  Future<void> _update(Document oldDoc, Document doc) async {
    _state.update(doc);

    // handle special fields
    final ref = doc.reference;
    final newDocMap = await _handleSpecialFields(ref, doc);
    final newDoc = _.docFromMap(newDocMap, ref);
    _state.update(newDoc);

    // PUT doc
    await _firebase.updateDoc(ref, oldDoc, newDoc);
  }

  Future<void> delete(Document oldDoc) async {
    _fetchedDocPaths.remove(oldDoc.reference.path);
    _state.delete(oldDoc);
    await _firebase.delete(oldDoc.reference);
  }

  Future<T> createIfAbsent<T extends Document>(T doc) async {
    return await get(doc, false) ?? await create(doc);
  }

  Future<T> get<T extends Document>(T keyDoc, bool fromCache) async {
    final path = keyDoc.reference.path;
    final onCacheDoc = await streamWherePath<T>(path).first;

    // return if doc exists in cache
    if (fromCache && _fetchedDocPaths.contains(path)) return onCacheDoc;

    // GET doc
    final snapshot = await _firebase.getDoc(keyDoc);
    _fetchedDocPaths.add(path);

    // return null if doc doesnt exists in database
    if (!snapshot.exists) return null;

    // update state
    final createdDoc = _.docFromSnapshot(snapshot, keyDoc.colName);
    _state.update(createdDoc);

    return createdDoc;
  }

  void addFromList(List<Document> docs) {
    docs.forEach((doc) => _state.update(doc));
  }

  Future<Map<String, DocumentField>> _handleSpecialFields(
    DocumentReference ref,
    Document doc,
  ) async {
    final oldDocMap = _.mapOf(doc);
    final newDocMap = Map<String, DocumentField>();
    for (final fieldName in oldDocMap.keys) {
      final field = oldDocMap[fieldName];
      newDocMap[fieldName] = await _handleSpecialField(ref, fieldName, field);
    }
    return newDocMap;
  }

  Future<T> _handleSpecialField<T extends DocumentField>(
    DocumentReference ref,
    String fieldName,
    T field,
  ) async {
    // default field values on create
    if (field.value == null) {
      if (field is CountField) return CountField(0) as T;
      if (field is SumField) return SumField(0) as T;
      if (field is TimestampField && field.isServerTimestamp) {
        return TimestampField(DateTime.now()) as T;
      }
      if (field is DynamicLinkField) {
        final newUrl = await _firebase.createDynamicLink(ref, field);
        return DynamicLinkField(
          newUrl,
          title: field.title,
          description: field.description,
          imageUrl: field.imageUrl,
          isSuffixShort: field.isSuffixShort,
        ) as T;
      }
    }
    // upload image if image file was provided
    if (field is ImageField && field.file != null) {
      final snapshot = await _firebase.uploadImage(ref, fieldName, field);
      final file = await field.file.readAsBytes();
      final image = await decodeImageFromList(file);
      final url = await snapshot.ref.getDownloadURL();
      return ImageField(
        url,
        file: null,
        height: image.height,
        width: image.width,
        fileSize: snapshot.storageMetadata.sizeBytes,
        userId: field.userId,
      ) as T;
    }
    return field;
  }
}
