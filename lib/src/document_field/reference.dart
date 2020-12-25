part of '../../flamestore.dart';

class ReferenceField extends DocumentField {
  ReferenceField(
    this.reference, {
    this.fields,
  });

  ReferenceField.fromMap(Map<String, dynamic> data)
      : reference = data['reference'],
        fields = data..removeWhere((key, _) => key == 'reference');

  final DocumentReference reference;
  final Map<String, dynamic> fields;

  @override
  Map<String, dynamic> get value => {...(fields ?? {}), 'reference': reference};

  Map<String, dynamic> get firestoreValue => {'reference': reference};

  @override
  bool operator ==(other) =>
      other is ReferenceField && other.reference.path == reference.path;
}
