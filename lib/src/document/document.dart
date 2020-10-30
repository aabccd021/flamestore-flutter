part of '../../flamestore.dart';

abstract class Document {
  Document({FirebaseFirestore firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  DocumentReference _reference;
  String _id = '';

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
  set reference(DocumentReference reference) => _reference = reference;

  set id(String id) => _id = id;

  DocumentReference get reference {
    if (keys.isNotEmpty) {
      return _firestore.collection(collectionName).doc(keys.join('_'));
    }
    if (_id.isNotEmpty) {
      return _firestore.collection(collectionName).doc(_id);
    }
    return _reference;
  }

  Map<String, dynamic> toMap() => {...toDataMap(), 'reference': reference};

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
