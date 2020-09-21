part of '../../flamestore.dart';

abstract class StateList<T extends StateData> extends Equatable {
  StateList() : assert(T != StateData);
  Query query(CollectionReference collection);
  Type get stateType => T;
  int get limit => 5;

  @override
  String toString() => '$runtimeType\n'
      'limit: $limit';
}
