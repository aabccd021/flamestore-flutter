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
    DocumentSnapshot lastDoc,
  ) async {
    final colName = _.colNameOfList(list);
    final collection = _firestore.collection(colName);
    final baseQuery = list.query(collection).limit(list.limit);
    final paginatedQuery =
        lastDoc != null ? baseQuery.startAfterDocument(lastDoc) : baseQuery;
    final snapshot = await paginatedQuery.get();
    return snapshot.docs;
  }
}
