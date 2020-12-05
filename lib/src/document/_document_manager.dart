part of '../../flamestore.dart';

class _DocumentManager {
  _DocumentManager({
    _DocumentsState state,
    _DocumentFirestoreAdapter adapter,
    FirebaseFirestore firestore,
    Map<Document, DocumentReference> fetched,
  })  : _db = adapter ?? _DocumentFirestoreAdapter(),
        _state = state ?? _DocumentsState(),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _fetchedDocumentPaths = fetched ?? <String>{};

  final _DocumentFirestoreAdapter _db;
  final _DocumentsState _state;
  final FirebaseFirestore _firestore;
  final Set<String> _fetchedDocumentPaths;
  FlamestoreConfig config;

  ValueStream<T> streamWherePath<T extends Document>(String path) {
    return _state.streamWherePath<T>(path);
  }

  void set<T extends Document>(T document, {Duration debounce}) async {
    _state.update<T>(document, updateAggregate: true);
    EasyDebounce.debounce(
      document.reference.path,
      debounce,
      () async {
        final oldDocument = await get(document, true);
        if (oldDocument == null) {
          return create(document);
        }
        if (document.shouldBeDeleted) {
          return delete(oldDocument);
        }
        return _update(oldDocument, document);
      },
    );
  }

  Future<T> create<T extends Document>(T document) async {
    final collectionName = document.collectionName;
    final reference =
        document.reference ?? _firestore.collection(collectionName).doc();
    Map<String, dynamic> newDocumentMap = Map<String, dynamic>();
    final documentMap = {
      ...document.toMap(),
      ...document.defaultValueMap,
    };
    for (final key in documentMap.keys) {
      final field = documentMap[key];
      if (field is DynamicLinkField) {
        newDocumentMap[key] = await _createDynamicLink(
          collectionName,
          reference.id,
          field,
        );
      } else {
        newDocumentMap[key] = field;
      }
    }
    final newDocument = document.fromMap(newDocumentMap);
    if (newDocument.reference != null) {
      _state.update<T>(newDocument);
    }
    await _db.create(reference, newDocument);
    newDocument.reference = reference;
    _state.update<T>(newDocument);
    return newDocument;
  }

  Future<T> _update<T extends Document>(T oldDocument, T newDocument) async {
    final mergedDocument = oldDocument.mergeDataWith(newDocument);
    _state.update<T>(mergedDocument);
    await _db.update(oldDocument.reference, newDocument);
    return mergedDocument;
  }

  Future<void> delete<T extends Document>(T oldDocument) async {
    await _state.delete(oldDocument);
    await _db.delete(oldDocument);
  }

  Future<T> createIfAbsent<T extends Document>(T document) async {
    return await get(document, false) ?? await create(document);
  }

  Future<T> get<T extends Document>(T keyDocument, bool fromCache) async {
    final path = keyDocument.reference.path;
    final onMemoryDocument = await streamWherePath<T>(path).first;
    if (fromCache && _fetchedDocumentPaths.contains(path)) {
      return onMemoryDocument;
    }
    final createdDocument = await _db.get(keyDocument);
    _fetchedDocumentPaths.add(path);
    if (createdDocument == null) {
      return null;
    }
    final T updatedDocument = onMemoryDocument != null
        ? onMemoryDocument.mergeDataWith(createdDocument)
        : createdDocument;
    await _state.update<T>(updatedDocument);
    return updatedDocument;
  }

  Future<void> addFromList<T extends Document>(List<T> documents) async {
    for (final document in documents) {
      await _state.update<T>(document);
    }
  }

  Future<String> _createDynamicLink(
    String collectionName,
    String id,
    DynamicLinkField field,
  ) async {
    assert(config != null && config.projects != null);
    final projectId = _firestore.app.options.projectId;
    final project = config.projects[projectId];
    final domain = project.domain ?? '${projectId}.web.app';
    final dynamicLinkDomain = project.dynamicLinkDomain ?? '${domain}/links';
    final isSuffixShort = field.isSuffixShort ?? false;
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://$dynamicLinkDomain',
      link: Uri.parse('https://$domain/$collectionName/$id'),
      androidParameters: AndroidParameters(
        packageName: project.androidPackageName,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: field.title,
        description: field.description,
        imageUrl: field.imageUrl == null ? null : Uri.parse(field.imageUrl),
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: isSuffixShort
            ? ShortDynamicLinkPathLength.short
            : ShortDynamicLinkPathLength.unguessable,
      ),
    );
    final ShortDynamicLink dynamicUrl = await parameters.buildShortLink();
    return dynamicUrl.shortUrl.toString();
  }
}
