part of '../../flamestore.dart';

class TimestampField extends DocumentField {
  final DateTime value;
  bool isServerTimestamp;

  TimestampField(this.value, {this.isServerTimestamp});
  TimestampField.fromMap(dynamic value)
      : value = value is DateTime ? value : value?.toDate();
}
