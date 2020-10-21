part of '../../flamestore.dart';

abstract class Document {
  // TODO: store all data as map
  // TODO: cast parent abstract to child class
  Document({FirebaseFirestore firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  DocumentReference _reference;

  @protected
  String get collectionName;

  @mustCallSuper
  @protected
  Document fromSnapshot(DocumentSnapshot snapshot) {
    return fromMap(snapshot.data())..reference = snapshot.reference;
  }

  @protected
  Document withDefaultValue();

  @protected
  Document fromMap(Map<String, dynamic> data);

  @protected
  Map<String, dynamic> toDataMap();

  @protected
  bool get shouldBeDeleted;

  @protected
  List<String> get keys;

  @protected
  set reference(DocumentReference reference) => _reference ??= reference;

  DocumentReference get reference => keys.isEmpty
      ? _reference
      : _firestore.collection(collectionName).doc(keys.join('_'));

  @mustCallSuper
  @protected
  Document mergeWith(Document other) => fromMap({...toMap(), ...other.toMap()});

  Map<String, dynamic> toMap() => {...toDataMap(), 'reference': reference};
}
