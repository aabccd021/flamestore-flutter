part of '../../flamestore.dart';

class _DocumentFirestoreAdapter {
  _DocumentFirestoreAdapter({FirebaseFirestore firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> delete<T extends Document>(T document) {
    return document.reference.delete();
  }

  Future<T> get<T extends Document>(T keyDocument) async {
    final reference = keyDocument.reference;
    final snapshot = await reference?.get();
    final data = snapshot?.data();
    print('GET $reference $data');
    if (data == null) {
      return null;
    }
    return keyDocument.createDocumentFromData(data);
  }

  Future<DocumentReference> create<T extends Document>(T document) async {
    final reference = document.reference;
    final data = {...document.toMap(), ...document.defaultMap}..removeNull();
    print('CREATE $reference $data');
    if (reference != null) {
      return reference..set(data, SetOptions(merge: true));
    }
    final collectionName = document.metadata.collectionName;
    return _firestore.collection(collectionName).add(data);
  }

  Future<void> update<T extends Document>(T oldDocument, T updatedData) {
    final reference = oldDocument.reference;
    final data = updatedData.toMap()..removeNull();
    print('UPDATE $reference $data');
    return reference.set(data, SetOptions(merge: true));
  }
}
