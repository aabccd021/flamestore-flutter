part of '../../flamestore.dart';

abstract class StateData {
  DocumentReference get ref;
  void overwriteFromSnapshot(DocumentSnapshot snapshot);
  Future<void> close();
}
