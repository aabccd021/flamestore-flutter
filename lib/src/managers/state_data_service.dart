part of '../../flamestore.dart';

class _StateDataService {
  _StateDataService(this.modelManager, {FirebaseFirestore fireStoreInstance})
      : _fireStoreInstance = fireStoreInstance ?? FirebaseFirestore.instance;

  final FirebaseFirestore _fireStoreInstance;
  final _StateModelManager modelManager;

  Future<void> deleteRef(DocumentReference ref) {
    Logger(printer: PrettyPrinter(methodCount: 1)).d(ref.id);
    return ref.delete();
  }

  Future<DocumentSnapshot> fetch(
    StateFetcher stateFetcher,
  ) async {
    Logger(printer: PrettyPrinter(methodCount: 1)).d(stateFetcher);
    if (stateFetcher is RefFetcher) {
      return stateFetcher.ref.get();
    }
    final stateType = stateFetcher.stateType;
    final collectionName = modelManager.collectionNameOf(stateType);
    final collection = _fireStoreInstance.collection(collectionName);
    final querySnapshot = await stateFetcher.get(collection);
    if (querySnapshot.docs.isEmpty) {
      return null;
    }
    return querySnapshot.docs[0];
  }

  Future<DocumentSnapshot> fetchRef(
    DocumentReference ref,
    Type stateType,
  ) {
    Logger(printer: PrettyPrinter(methodCount: 1))
        .i('$stateType\nref: ${ref.id}');
    return ref.get();
  }

  Future<DocumentReference> post(StatePoster statePoster) async {
    final stateType = statePoster.stateType;
    final data = statePoster.toFirestore();
    final attributes = modelManager.attributesOf(stateType);
    for (final key in data.keys) {
      if (!attributes.contains(key)) {
        throw InvalidFirestoreKey(key);
      }
    }
    final collectionName = modelManager.collectionNameOf(stateType);
    final collection = _fireStoreInstance.collection(collectionName);
    Logger(printer: PrettyPrinter(methodCount: 1)).d(statePoster);
    return collection.add(data);
  }

  Future<void> put(DocumentReference ref, StatePutter putter) async {
    Logger(printer: PrettyPrinter(methodCount: 1)).i('ref: ${ref.id}\n$putter');
    final attributes = modelManager.attributesOf(putter.stateType);
    final data = putter.updateData();
    for (final key in data.keys) {
      if (!attributes.contains(key)) {
        throw InvalidFirestoreKey(key);
      }
    }
    return ref.set(data, SetOptions(merge: true));
  }
}

class InvalidFirestoreKey implements Exception {
  InvalidFirestoreKey(this.invalidKey);
  final String invalidKey;
}
