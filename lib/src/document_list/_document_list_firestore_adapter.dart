part of '../../flamestore.dart';

class _DocumentListFirestoreAdapter {
  _DocumentListFirestoreAdapter({
    FirebaseFirestore firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  Future<List<DocumentSnapshot>> get(
    DocumentList list,
    DocumentSnapshot lastDocument,
  ) async {
    final collectionName = list.document.metadata.collectionName;
    final collection = _firestore.collection(collectionName);
    Query query = list.query(collection).limit(list.limit);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    final snapshot = await query.get();
    return snapshot.docs;
  }
}
