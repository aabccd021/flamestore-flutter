part of '../../flamestore.dart';

class _StateListService {
  _StateListService(this.modelManager);
  final _StateModelManager modelManager;

  Future<List<DocumentSnapshot>> fetchList(
    StateList stateList,
    DocumentSnapshot lastDocument,
  ) async {
    Logger(printer: PrettyPrinter(methodCount: 1)).d(stateList);
    final limit = stateList.limit;
    final collectionName = modelManager.collectionNameOf(stateList.stateType);
    final collection = FirebaseFirestore.instance.collection(collectionName);
    var query = stateList.query(collection);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    query = query.limit(limit);
    final querySnapshot = await query.get();
    return querySnapshot.docs;
  }
}

class InvalidCollectionReference implements Exception {
  const InvalidCollectionReference(this.stateList);
  final StateList stateList;

  @override
  String toString() =>
      'Invalid Collection Reference on StateList : ${stateList.runtimeType}';
}
