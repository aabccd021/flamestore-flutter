part of '../../flamestore.dart';

class _StateModelManager {
  Map<Type, StateModel> _stateUtilMap;

  StateData stateFromSnapshot(Type v, DocumentSnapshot snapshot) =>
      _stateUtilMap[v].snapshotBuilder(snapshot);

  String collectionNameOf(Type v) => _stateUtilMap[v].collectionName;

  List<String> attributesOf(Type v) => _stateUtilMap[v].attributes;

  Type keyFetcherTypeOf(Type v) => _stateUtilMap[v]?.keyFetcherType;

  void setupModels(Map<Type, StateModel> modelMap) => _stateUtilMap = modelMap;
}

class StateModel<T extends StateData> {
  const StateModel(
    this.snapshotBuilder,
    this.collectionName,
    this.attributes, {
    this.keyFetcherType,
  });
  final T Function(DocumentSnapshot) snapshotBuilder;
  final String collectionName;
  final List<String> attributes;
  final Type keyFetcherType;
}
