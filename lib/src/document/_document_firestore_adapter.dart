part of '../../flamestore.dart';

class _DocumentFirestoreAdapter {
  _DocumentFirestoreAdapter({FirebaseFirestore firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<T> get<T extends Document>(T document) async {
    final reference = document.reference;
    final snapshot = await reference.get();
    final data = snapshot?.data();
    print('GET $reference $data');
    if (data == null) {
      return null;
    }
    return document.fromSnapshot(snapshot);
  }

  Future<DocumentReference> create<T extends Document>(T document) async {
    final reference = document.reference;
    final data = {...document.toDataMap(), ...document.defaultFirestoreMap}
      ..removeNull();
    print('CREATE $reference $data');
    if (reference != null) {
      return reference..set(data, SetOptions(merge: true));
    }
    return _firestore.collection(document.collectionName).add(data);
  }

  Future<void> update<T extends Document>(
      DocumentReference reference, T updatedData) {
    final data = updatedData.toDataMap()..removeNull();
    print('UPDATE $reference $data');
    return reference.set(data, SetOptions(merge: true));
  }

  Future<void> delete<T extends Document>(T document) {
    final reference = document.reference;
    print('UPDATE $reference');
    return reference.delete();
  }
}
