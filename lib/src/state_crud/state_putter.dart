part of '../../flamestore.dart';

abstract class StatePutter<T extends StateData> {
  StatePutter(this.ref) : assert(T != StateData);
  final DocumentReference ref;

  Type get stateType => T;

  Map<String, dynamic> updateData();

  @override
  String toString() => '$runtimeType\n${updateData().prettyPrint}';
}
