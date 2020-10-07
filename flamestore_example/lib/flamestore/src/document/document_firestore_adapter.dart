part of '../../flamestore.dart';

class _DocumentFirestoreAdapter {
  _DocumentFirestoreAdapter({FirebaseFirestore firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> delete<T extends Document>(T document) {
    return document.reference.delete();
  }

  Future<DocumentSnapshot> get<T extends Document>(T keyDoc) async {
    Query query = _firestore.collection(keyDoc.metadata.collectionName);
    keyDoc.toMap()
      ..removeWhere((_, value) => value == null)
      ..forEach((key, value) => query = query.where(key, isEqualTo: value));
    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) {
      return null;
    }
    return snapshot.docs[0];
  }

  Future<DocumentReference> create<T extends Document>(T document) async {
    final data = {...document.toMap(), ...document.defaultMap}
      ..removeWhere((_, value) => value == null);
    final collection = _firestore.collection(document.metadata.collectionName);
    return collection.add(data);
  }

  Future<void> update<T extends Document>({
    @required DocumentReference reference,
    @required T document,
  }) async {
    final data = document.toMap()..removeWhere((_, value) => value == null);
    return reference.set(data, SetOptions(merge: true));
  }
}
