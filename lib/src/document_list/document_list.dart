part of '../../flamestore.dart';

abstract class DocumentListKey<T extends Document> extends Equatable {
  Query query(CollectionReference collection);
  int get limit => 5;
}
