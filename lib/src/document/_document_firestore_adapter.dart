part of '../../flamestore.dart';

class _DocumentFirestoreAdapter {
  Future<T> get<T extends Document>(T document) async {
    final reference = document.reference;
    final snapshot = await reference.get();
    final data = snapshot?.data();
    print('GET DOCUMENT $reference $data');
    if (data == null) {
      return null;
    }
    return document.fromSnapshot(snapshot);
  }

  Future<void> create<T extends Document>(
    DocumentReference reference,
    T document,
  ) async {
    final data = document.toDataMap().map((key, value) => value is Map
        ? MapEntry(key, value..removeWhere((key, _) => key != 'reference'))
        : MapEntry(key, value))
      ..removeWhere((key, _) => !document.firestoreCreateFields().contains(key))
      ..removeNull();
    print('CREATE DOCUMENT $reference $data');
    return reference..set(data, SetOptions(merge: true));
  }

  Future<void> update<T extends Document>(
      DocumentReference reference, T updatedData) {
    final data = updatedData.toDataMap()..removeNull();
    print('UPDATE DOCUMENT $reference $data');
    return reference.set(data, SetOptions(merge: true));
  }

  Future<void> delete<T extends Document>(T document) {
    final reference = document.reference;
    print('DELETE DOCUMENT $reference');
    return reference.delete();
  }
}
