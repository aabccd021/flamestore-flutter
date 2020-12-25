part of '../../flamestore.dart';

class FloatField extends DocumentField {
  final double value;
  double deleteOn;

  FloatField(this.value, {this.deleteOn});
  FloatField.fromMap(dynamic value) : value = value?.toDouble();
}
