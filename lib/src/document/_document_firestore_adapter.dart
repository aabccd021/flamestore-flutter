part of '../../flamestore.dart';

class _DocumentFirestoreAdapter {
  _DocumentFirestoreAdapter(
    this._, {
    FirebaseFirestore firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  final _FlamestoreUtil _;

  Future<DocumentSnapshot> get<T extends Document>(T document) async {
    final snapshot = await document.reference.get();
    final data = snapshot?.data();
    print('GET DOCUMENT ${document.reference} ${data}');
    if (data == null) {
      return null;
    }
    return snapshot;
  }

  Future<void> create<T extends Document>(
    DocumentReference reference,
    T document,
  ) async {
    final data = _.dataMapFrom(document).map((key, value) => value is Map
        ? MapEntry(key, value..removeWhere((key, _) => key != 'reference'))
        : MapEntry(key, value))
      ..removeWhere(
          (key, __) => !_.firestoreCreateFields(document).contains(key))
      ..removeNull();
    print('CREATE DOCUMENT $reference $data');
    return reference..set(data, SetOptions(merge: true));
  }

  Future<void> update<T extends Document>(
    DocumentReference reference,
    T updatedData,
  ) {
    final data = _.dataMapFrom(updatedData)..removeNull();
    print('UPDATE DOCUMENT $reference $data');
    return reference.set(data, SetOptions(merge: true));
  }

  Future<void> delete<T extends Document>(T document) {
    print('DELETE DOCUMENT ${document.reference}');
    return document.reference.delete();
  }

  Future<String> createDynamicLink(
    String collectionName,
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
      link: Uri.parse('https://$domain/$collectionName/$id'),
      androidParameters: AndroidParameters(
        packageName: project.androidPackageName,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: field.title,
        description: field.description,
        imageUrl: field.imageUrl == null ? null : Uri.parse(field.imageUrl),
      ),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: '$collectionName',
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
