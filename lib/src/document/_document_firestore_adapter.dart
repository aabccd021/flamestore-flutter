part of '../../flamestore.dart';

class _DocumentFirestoreAdapter {
  _DocumentFirestoreAdapter(
    this._, {
    FirebaseFirestore firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  final _FlamestoreUtil _;

  Future<DocumentSnapshot> get<T extends Document>(T doc) async {
    final snapshot = await doc.reference.get();
    final data = snapshot?.data();
    print('GET DOCUMENT ${doc.reference} ${data}');
    if (data == null) {
      return null;
    }
    return snapshot;
  }

  Future<void> create<T extends Document>(DocumentReference ref, T doc) async {
    final data = _.dataMapOf(doc).map((key, value) => value is Map
        ? MapEntry(key, value..removeWhere((key, _) => key != 'reference'))
        : MapEntry(key, value))
      ..removeWhere((key, __) => !_.creatableFields(doc).contains(key))
      ..removeNull();
    print('CREATE DOCUMENT $ref $data');
    return ref..set(data, SetOptions(merge: true));
  }

  Future<void> update<T extends Document>(
    DocumentReference ref,
    T updatedData,
  ) {
    final data = _.dataMapOf(updatedData)..removeNull();
    print('UPDATE DOCUMENT $ref $data');
    return ref.set(data, SetOptions(merge: true));
  }

  Future<void> delete<T extends Document>(T doc) {
    print('DELETE DOCUMENT ${doc.reference}');
    return doc.reference.delete();
  }

  Future<String> createDynamicLink(
    String colName,
    String id,
    DynamicLinkField field,
  ) async {
    assert(_ != null && _.flamestoreConfig != null);
    final projectId = _firestore.app.options.projectId;
    final project = _.flamestoreConfig.projects[projectId];
    final domain = project.domain ?? '${projectId}.web.app';
    final dynamicLinkDomain = project.dynamicLinkDomain ?? '${domain}/links';
    final isSuffixShort = field.isSuffixShort ?? false;
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://$dynamicLinkDomain',
      link: Uri.parse('https://$domain/$colName/$id'),
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
}
