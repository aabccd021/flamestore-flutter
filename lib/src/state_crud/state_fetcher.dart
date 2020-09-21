part of '../../flamestore.dart';

abstract class StateFetcher<T extends StateData> extends Equatable {
  StateFetcher() : assert(T != StateData);
  Type get stateType => T;
  Future<QuerySnapshot> get(CollectionReference collection);
  bool condition(T state);
}

class RefFetcher<T extends StateData> extends StateFetcher<T> {
  RefFetcher(this.ref) : assert(T != StateData);
  final DocumentReference ref;

  @override
  bool condition(T state) => state.ref.id == ref.id;

  @override
  Future<QuerySnapshot> get(CollectionReference collection) =>
      throw UnimplementedError();

  @override
  List<Object> get props => [ref];

  @override
  String toString() => 'RefFetcher' '\n$T' '\n${ref.id}';
}
