part of '../../flamestore.dart';

class _DocumentListFirestoreAdapter {
  _DocumentListFirestoreAdapter(
    this._, {
    FirebaseFirestore firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final _FlamestoreUtil _;
  Future<List<DocumentSnapshot>> get<T extends Document>(
    DocumentListKey<T> list,
    DocumentSnapshot lastDocument,
  ) async {
    final colName = _.colNameOf(T);
    final col = _firestore.collection(colName);
    Query query = list.query(col).limit(list.limit);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    final snapshot = await query.get();
    return snapshot.docs;
  }
}
