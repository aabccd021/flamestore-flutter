part of '../../flamestore.dart';

class DocumentListState<T extends Document> {
  DocumentListState(this.hasMore, this.documents);
  final bool hasMore;
  final ValueStream<List<T>> documents;
}
