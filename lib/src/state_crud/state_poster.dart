part of '../../flamestore.dart';

abstract class StatePoster<T extends StateData> {
  StatePoster() : assert(T != StateData);
  Map<String, dynamic> toFirestore();
  List<StateList> get updatedStateLists;
  Type get stateType => T;
  @override
  String toString() => '$runtimeType'
      '\n\n\nmap:\n${toFirestore().prettyPrint}'
      '\n\n\nstateLists:\n${updatedStateLists.prettyPrint}';
}

abstract class UniqueStatePoster<T extends StateData> extends StatePoster<T> {
  UniqueStatePoster() : assert(T != StateData);
  StateFetcher<T> get stateFetcher;
}
