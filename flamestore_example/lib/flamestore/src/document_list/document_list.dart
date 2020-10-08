part of '../../flamestore.dart';

abstract class DocumentList<T extends Document> extends Equatable {
  Query query(CollectionReference collection);
  T get document;
  int get limit => 5;
}
