part of '../../flamestore.dart';

abstract class Document {
  Document({FirebaseFirestore firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  DocumentReference _reference;

  @protected
  String get collectionName;

  @protected
  Map<String, dynamic> get defaultValueMap;

  @protected
  Document fromMap(Map<String, dynamic> data);

  @protected
  Map<String, dynamic> toDataMap();

  @protected
  List<String> firestoreCreateFields();

  @protected
  bool get shouldBeDeleted;

  @protected
  List<String> get keys;

  @protected
  set reference(DocumentReference reference) => _reference ??= reference;

  DocumentReference get reference => keys.isEmpty
      ? _reference
      : _firestore.collection(collectionName).doc(keys.join('_'));

  Map<String, dynamic> toMap() => {...toDataMap(), 'reference': reference};

  bool dataEquals(Document other) {
    return mapEquals(toDataMap(), other.toDataMap());
  }

  @mustCallSuper
  @protected
  Document mergeDataWith(Document other) =>
      fromMap({...toMap(), ...other.toMap()});

  @mustCallSuper
  @protected
  Document fromSnapshot(DocumentSnapshot snapshot) {
    return fromMap(snapshot.data())..reference = snapshot.reference;
  }

  @mustCallSuper
  @protected
  Document withDefaultValue() {
    return fromMap({...toMap(), ...defaultValueMap});
  }
}
