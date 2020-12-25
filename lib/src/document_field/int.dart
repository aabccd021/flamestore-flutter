part of '../../flamestore.dart';

class IntField extends DocumentField {
  final int value;
  final int deleteOn;

  IntField(
    this.value, {
    this.deleteOn,
  });
}
