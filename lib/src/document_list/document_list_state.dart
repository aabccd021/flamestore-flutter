part of '../../flamestore.dart';

class DocumentListState {
  DocumentListState(this.hasMore, this.docs);
  final bool hasMore;
  final List<DocumentReference> docs;
}
