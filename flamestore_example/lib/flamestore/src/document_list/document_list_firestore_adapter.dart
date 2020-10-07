part of '../../flamestore.dart';

class _DocumentListFirestoreAdapter {
  _DocumentListFirestoreAdapter({
    FirebaseFirestore firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  Future<List<DocumentSnapshot>> get({
    @required DocumentList list,
    @required DocumentSnapshot lastDoc,
  }) async {
    final collection =
        _firestore.collection(list.document.metadata.collectionName);
    Query query = list.query(collection).limit(list.limit);
    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }
    final querySnapshot = await query.get();
    return querySnapshot.docs;
  }
}
