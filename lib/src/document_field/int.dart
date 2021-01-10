part of '../../flamestore.dart';

class IntField extends DocumentField {
  final int value;
  int deleteOn;

  IntField(
    this.value, {
    this.deleteOn,
  });

  IntField.fromMap(dynamic value): value = value;
}
