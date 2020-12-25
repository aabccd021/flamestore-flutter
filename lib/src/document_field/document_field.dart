part of '../../flamestore.dart';

abstract class DocumentField {
  dynamic get value;

  dynamic get firestoreValue => value;

  @override
  bool operator ==(other) =>
      other is DocumentField && other.firestoreValue == firestoreValue;
}
