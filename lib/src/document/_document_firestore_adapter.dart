part of '../../flamestore.dart';

class _DocumentFirestoreAdapter {
  _DocumentFirestoreAdapter(
    this._, {
    FirebaseFirestore firestore,
    FirebaseStorage storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final _FlamestoreUtil _;

  Future<DocumentSnapshot> getDoc<T extends Document>(T doc) async {
    final snapshot = await doc.reference.get();
    print('GET DOCUMENT ${doc.reference} ${snapshot?.data()}');
    return snapshot;
  }

  Future<void> createDoc(DocumentReference ref, Document doc) async {
    final creatableFieldNames = _.creatableFields(doc);
    final data = _.mapOf(doc).map(
        (key, field) => MapEntry(key, field.firestoreValue))
      ..removeWhere((fieldName, __) => !creatableFieldNames.contains(fieldName))
      ..removeNull();
    print('CREATE DOCUMENT $ref $data');
    await ref.set(data, SetOptions(merge: true));
  }

  Future<void> updateDoc(
    DocumentReference ref,
    Document oldDoc,
    Document newDoc,
  ) async {
    final updatableFields = _.updatableFields(newDoc);
    final oldDocMap = _.mapOf(oldDoc);
    final updateMap = _.mapOf(newDoc)
      ..removeWhere((fieldName, __) => !updatableFields.contains(fieldName))
      ..removeWhere((fieldName, field) => oldDocMap[fieldName] == field);
    final firestoreMap = updateMap
        .map((key, field) => MapEntry(key, field.firestoreValue))
          ..removeNull();
    print('UPDATE DOCUMENT $ref $firestoreMap');
    await ref.set(firestoreMap, SetOptions(merge: true));
  }

  Future<void> delete(DocumentReference ref) async {
    print('DELETE DOCUMENT ${ref}');
    await ref.delete();
  }

  Future<String> createDynamicLink(
    DocumentReference ref,
    DynamicLinkField field,
  ) async {
    final colName = _.colNameOfRef(ref);
    final docId = ref.id;
    final projectId = _firestore.app.options.projectId;
    final project = _.flamestoreConfig.projects[projectId];
    final domain = project.domain ?? '${projectId}.web.app';
    final dynamicLinkDomain = project.dynamicLinkDomain ?? '${domain}/links';
    final isSuffixShort = field.isSuffixShort ?? false;
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://$dynamicLinkDomain',
      link: Uri.parse('https://$domain/$colName/$docId'),
      androidParameters: AndroidParameters(
        packageName: project.androidPackageName,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: field.title,
        description: field.description,
        imageUrl: field.imageUrl == null ? null : Uri.parse(field.imageUrl),
      ),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: '$colName',
        medium: 'dynamic-link',
        source: 'flamestore-dynamic-link',
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength:
            isSuffixShort ? ShortDynamicLinkPathLength.short : null,
      ),
    );
    final ShortDynamicLink dynamicUrl = await parameters.buildShortLink();
    final shortUrl = dynamicUrl.shortUrl.toString();
    print('CREATED DYNAMIC LINK $shortUrl');
    return shortUrl;
  }

  Future<StorageTaskSnapshot> uploadImage(
    DocumentReference ref,
    String fieldName,
    ImageField field,
  ) async {
    final docId = ref.id;
    final colName = _.colNameOfRef(ref);
    final fileName = '${field.userId}\_$docId.png';
    final filePath = '$colName/$fieldName/raw/$fileName';
    final snapshot =
        await _storage.ref().child(filePath).putFile(field.file).onComplete;
    print('UPLOADED IMAGE $filePath');
    return snapshot;
  }
}
