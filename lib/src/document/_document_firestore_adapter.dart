part of '../../flamestore.dart';

class _DocumentFirestoreAdapter {
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

  Future<void> create<T extends Document>(
    DocumentReference reference,
    T document,
  ) async {
    final data = document.toDataMap()
      ..removeWhere((key, _) => !document.firestoreCreateFields().contains(key))
      ..removeNull();
    print('CREATE $reference $data');
    return reference..set(data, SetOptions(merge: true));
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
